# 此文件为翻译器核心

mutable struct System <: AbstractComponent
    name::String
    comps::Dict
    nodes::Vector
end

function System(input::Dict)
    time = string(now())[1:end-4]
    time = replace(time, ":" => "_")
    time = replace(time, "-" => "_")
    name = get(input, "Name", "System" * time)
    comps = get(input, "ComponentList", nothing)
    isnothing(comps) || isempty(comps) && error("\033[1;31m错误\033[0m:一个系统至少有一个组件!请检查!")
    nodes = get(input, "ConnectionList", nothing)
    isnothing(nodes) && @warn "\033[1;33m警告\033[0m:您的系统没有任何连接!"
    return System(
        name,
        comps,
        nodes
    )
end

function compile_data(data::Component{true})
    back = Dict()
    # 写入常量(@parameters)
    args = ""# 组件函数默认参数
    define = ""# 组件内部定义参数
    sys = ""# 定义系统的参数
    for p in sort!(collect(keys(data.paras)), by=x -> x[2])
        k = p[1]
        sys *= "$k;"
        v = get(data.paras, p, nothing)
        if v.number isa Number && v.number > 1
            if v.value isa Number
                args *= "$k = $(v.value)*ones($(v.number)),"
                define *= "@parameters $k[1:$(v.number)]=$k\n"
                continue
            end
            define *= "@parameters $k[1:$(v.number)]=$(v.value)\n"
        elseif v.number isa Number && v.number == 1
            if v.value isa Number
                args *= "$k = $(v.value),"
                define *= "@parameters $k=$k\n"
                continue
            end
            define *= "@parameters $k=$(v.value)\n"
        elseif v.number isa Symbol
            if v.value isa Number
                n = get(data.sparas, v.number, nothing).value
                args *= "$k = $(v.value)*ones($n),"
                define *= "@parameters $k[1:$(v.number)]=$k\n"
                continue
            end
            define *= "@parameters $k[1:$(v.number)]=$(v.value)\n"
        end
    end
    push!(back, :parameters => ProcessedData(args, define, sys))
    # 写入变量(@variables)
    define = ""# 定义变量
    sys = ""# 定义系统变量
    for (k, v) in data.vars
        if v.number > 1
            define *= "@variables $k(t)[1:$(v.number)]=$(v.value) $(parse_metadata(v))\n"
        else
            define *= "@variables $k(t)=$(v.value) $(parse_metadata(v))\n"
        end
        define *= "$k = setmetadata($k, Ai4EnergyMetaData, \"$v\")\n"
        sys *= "$k;"
    end
    push!(back, :variables => ProcessedData("", define, sys))
    # 写入结构参数(@structural_parameters)
    args = ""# 组件函数默认参数
    for (k, v) in data.sparas
        args *= "$k = $(v.value),"
    end
    push!(back, :structural_parameters => ProcessedData(args, "", ""))
    # 写入常数
    define = ""
    for (k, v) in data.consts
        define *= "$k = $(v.value);"
    end
    push!(back, :constants => ProcessedData("", define, ""))
    return back
end

function compiler(comp::Component{false}, create=true)
    medias = parse_media(comp.medias, comp.type)
    !isnothing(medias) && generate_material(medias)
    son_comps_types = Set(map(x -> x["Type"], collect(values(comp.comps))))
    io = open("./$(comp.type).jl", "w")
    for comp in son_comps_types
        if haskey(custom_models[], comp)
            d_comp = custom_models[][comp]
            scp = Component(d_comp)
            code = compiler(scp, false)
        else
            lib, name = split(comp, "_", limit=2)
            model = get_model(name, lib)
            code = model["PrecompiledModel"]
        end
        eval(code)
    end
    data = compile_data(comp)
    write(io, "function $(comp.type)(;name, $(data[:parameters].args) $(data[:structural_parameters].args))\n")
    ports = ""
    for (k, v) in comp.ports
        ports *= "$k;"
        v.number = Meta.parse(v.number)
        if v.number isa Number && v.number > 1
            write(io, "@named $k[1:$(v.number)] = $(v.type)()\n")
        elseif v.number isa Number && v.number == 1
            write(io, "@named $k = $(v.type)()\n")
        elseif v.number isa Symbol
            write(io, "@named $k[1:$(v.number)] = $(v.type)()\n")
        end
    end
    sons = ""
    for (ck, cv) in comp.comps
        sons *= "$ck;"
        init = init_data(get(comp.init_data, ck, nothing))
        if cv.number isa Number && cv.number > 1
            write(io, "@named $k[1:$(cv.number)] = $ck($init)\n")
        elseif cv.number isa Number && cv.number == 1
            write(io, "@named $k = $ck($init)\n")
        elseif cv.number isa Symbol
            write(io, "@named $k[1:$(cv.number)] = $ck($init)\n")
        end
    end
    write(io, "$(data[:constants].define)\n$(data[:parameters].define)\n$(data[:variables].define)")
    write(io, "eqs = Equation[\n$(comp.conn)]\n")
    write(io, comp.eqs)
    write(io, "return compose(ODESystem(eqs, t, [$(data[:variables].sys)], [$(data[:parameters].sys)]; name=name), [$ports; $sons])\n")
    write(io, "\nend")
    close(io)
    if create
        include("./$(comp.type).jl")
        comp.mtkm = eval(comp.type)
    else
        open("./$(comp.type).jl", "r") do io
            return read(io, String)
        end
    end
    nothing
end

function compile_custom_port(ports::Vector)
    io = IOBuffer()
    for port in ports
        write(io, "@connector $(port["Type"]) begin\n")
        vars = parse_vars(port["Variables"])
        for (pk, pv) in vars
            write(io, "$pk(t)=$(pv.value), $(parse_metadata(pv))\n")
            write(
                io,
                """begin
                	$pk = setmetadata($pk, Ai4EnergyMetaData, \"$pv\")
                end\n
                """
            )
        end
        write(io, "end\n")
        seekstart(io)
        code = read(io, String)
        push!(custom_port_types[], Symbol(port["Type"]) => code)
        truncate(io, 0)
        seekstart(io)
    end
end

function compile_port(ports::Dict, io::IO)
    for (_, v) in ports
        write(io, v)
    end
    nothing
end

function compiler(comp::Component{true}, create=true)
    io = open("./$(comp.type).jl", "w")
    data = compile_data(comp)
    medias = parse_media(comp.medias, string(comp.type))
    !isnothing(medias) && generate_material(medias)
    write(io, "function $(comp.type)(;name, $(data[:parameters].args) $(data[:structural_parameters].args))\n")
    ports = ""
    for (k, v) in comp.ports
        ports *= "$k;"
        n = Meta.parse(v.number)
        if n isa Number && n > 1
            write(io, "@named $k[1:$(v.number)] = $(v.type)()\n")
        elseif n isa Number && n == 1
            write(io, "@named $k = $(v.type)()\n")
        elseif n isa Symbol
            write(io, "@named $k[1:$(v.number)] = $(v.type)()\n")
        end
    end
    write(io, "$(data[:constants].define)\n$(data[:parameters].define)\n$(data[:variables].define)\n")
    write(io, "eqs = Equation[]\n")
    write(io, comp.eqs)
    write(io, "return compose(ODESystem(eqs, t, [$(data[:variables].sys)], [$(data[:parameters].sys)]; name=name), [$ports])\n")
    write(io, "end")
    close(io)
    if create
        include("./$(comp.type).jl")
        comp.mtkm = eval(comp.type)
    else
        open("./$(comp.type).jl", "r") do io
            return read(io, String)
        end
    end
    nothing
end

function init_data(input::Dict)
    args = ""
    if isempty(input)
        return ""
    end
    for (k, v) in input
        if k == "Null"
            continue
        end
        args *= "$k=$v,"
    end
    println(args)
    return args
end

function compiler(sys::Vector)
    comps = [Component(t) for t in sys]
    @async for c in comps
        put!(components, c)
    end
    @sync for _ = 1:workers[]
        errormonitor(@async begin
            while isready(components)
                comp_task = take!(components)
                compiler(comp_task)
                push!(ready_components[], comp_task.type => comp_task)
            end
        end)
    end
end

# 初始化系统
function init(parameters)
    paras = ""
    for (para, value) in parameters
        if typeof(value) <: Dict
            cf = changeunit(value["Unit"])
            paras = paras * "$para = $(value["Value"]*cf)"
        else
            paras = paras * "$para = $value"
        end
    end
    return paras
end

# 获取初始条件
function init_conditions(ic::Dict)
    initconditions = ""
    if isempty(ic)
        @warn "未设置初值条件,可能导致无法运行或结果出错!"
    else
        for (var, value) in ic
            initconditions *= "system.$var => $value,"
        end
    end
    return "[$initconditions]"
end

# 生成MTK系统代码
function compiler(sys::System)
    io = open("./$(sys.name).jl", "w")
    write(io, "function $(sys.name)(;name)\n")
    sub_system = ""
    for (k, v) in sys.comps
        sub_system *= k * ";"
        if haskey(ready_components[], v["Type"] isa String ? Symbol(v["Type"]) : v["Type"])
            write(io, "@named $k = ready_components[][:$(v["Type"])]($(init_data(v["Data"])))\n")
        else
            lib, name = split(v["Type"], "_", limit=2)
            model = get_model(string(name), string(lib))
            eval(model["PrecompiledModel"])
            write(io, "@named $k = $(v["Type"])($(init_data(v["Init"])))\n")
        end
    end
    write(io, "eqs = Equation[$(connect_nodes(sys.nodes))]\n")
    write(io, "return compose(ODESystem(eqs, t, [], []; name=name), [$sub_system])\nend\n\n")
    write(io, "@named sys = $(sys.name)()\nglobal system = sys\n")
    close(io)
end

"""
设置返回值字典.
"""
function generate_back(sim_args::Dict)
    initial_conditions = get(sim_args, "InitialConditions", nothing)
    settings = get(sim_args, "Settings", nothing)
    name = "Simulation$(now()).jl"
    open(name, "w") do io
        init = ""
        if isnothing(initial_conditions)
            init = "ModelingToolkit.missing_variable_defaults(current_system[])"
        else
            u0 = map(x -> ("current_system[].$(x.first)=>$(x.second)"), collect(initial_conditions))
            init = "[$(join(u0, ","))]"
        end
        tspan = ""
        if isnothing(settings["TimeSpan"])
            tspan = "(0.0, 1.0)"
        else
            tspan = "$(settings["TimeSpan"][1]):$(settings["TimeSpan"][2])"
        end
        write(io, "prob = ODESystem(current_system[], $init, $tspan)\n")
        solver = get(settings, "Solver", "Tsit5")
        write(io, "sol = solve(prob, $solver())")
        back_info = get(settings, "BackInfo", nothing)
        # 初始化返回字典
        write(io, "back_results = Dict()\n")
        # 写入返回信息
        write(io, "backs = $back_info\n")
        # 向返回字典中加入返回值
        expr = quote
            for back in backs
                eval(Meta.parse("get!(back_results, \"$back\", sol[current_system[].$back])"))
            end
            push!(back_results, "t" => sol.t)
        end
        write(io, "$expr")
        write(io, "\n")
        # 返回字典
        write(io, "back_results")
    end
    return name
end

# 删除项目文件
function delete_projact(name::String)
    files = readdir(name, join=true)
    for file in files
        rm(file)
    end
    rm(name)
    @info "旧的$(name)已被删除!"
    nothing
end

function simulation(name::String)
    try
        result = include("./$name")
        #delete_projact(name)
        println(result)
        return result
    catch e
        println(e)
        return e
    end
end

function simulation(args::Dict)
    name = generate_back(args)
    res = simulation(name)
    if res isa Dict
        return res
    else
        return Dict("Error" => "$res")
    end
end

# 分析函数
function analysis_system(input::Dict)
    global custom_data_types[] = input["DataTypes"]
    compile_custom_port(input["ConnectionTypes"])
    open("./PortType.jl", "w") do io
        compile_port(port_types[], io)
        compile_port(custom_port_types[], io)
    end
    include("./PortType.jl")
    global custom_models[] = input["ModelList"]
    compiler(input["ModelList"])
    simulation_system = System(input["System"])
    compiler(simulation_system)
    @info "代码文件生成成功!开始进行系统分析..."
    system = include("./$(simulation_system.name).jl")
    vars = map(states(system)) do x
        str = "$x"
        return replace(str[1:end-3], "₊" => ".")
    end
    global current_system[] = ModelingToolkit.structural_simplify(system)
    results = map(states(current_system[])) do x
        str = "$x"
        return replace(str[1:end-3], "₊" => ".")
    end
    back = Dict("States" => results, "Variables" => vars)
    return back
end

nothing