# 此文件为翻译器核心

struct System <: AbstractComponent
    name::String
    libs::Vector
    comps::Dict
    nodes::Dict
    initial_conditions::Dict
    settings::Dict
end

function System(input::Dict)
    name = get(input, "Name", "System")
    libs = get(input, "Packages", nothing)
    isnothing(libs) || isempty(libs) && @warn "\033[1;33m警告\033[0m:您未使用任何标准库!"
    comps = get(input, "ComponentList", nothing)
    isnothing(comps) || isempty(comps) && error("\033[1;31m错误\033[0m:一个系统至少有一个组件!请检查!")
    nodes = get(input, "Nodes", nothing)
    isnothing(nodes) && @warn "\033[1;33m警告\033[0m:您的系统没有任何连接!"
    init = get(input, "InitialConditions", nothing)
    # TODO
    settings = get(input, "Settings", Dict())
    # TODO
    return System(
        name,
        [String[]; libs],
        comps,
        nodes,
        init,
        settings
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
        define *= "$k = setmetadata($k, Ai4EnergyMetaData, $v)"
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
    son_comps_types = Set(map(x -> x["Type"], collect(values(comp.comps))))
    son_comps = Dict()
    io = open("./$(comp.type).jl", "w")
    for comp in son_comps_types
        d_comp = get_data(comp, :Components)
        scp = Component(d_comp)
        code = compiler(scp, false)
        write(io, code)
        push!(son_comps, scp.type => scp)
    end
    data = compile_data(comp)
    write(io, "function $(comp.type)(;name, $(data[:parameters].args) $(data[:structural_parameters].args))\n")
    ports = ""
    for (k, v) in comp.ports
        ports *= "$k;"
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
            write(io, "@named $k[1:$(cv.number)] = son_comps[$ck].mtkm($init)\n")
        elseif cv.number isa Number && cv.number == 1
            write(io, "@named $k = son_comps[$ck].mtkm($init)\n")
        elseif cv.number isa Symbol
            write(io, "@named $k[1:$(cv.number)] = son_comps[$ck].mtkm($init)\n")
        end
    end
    write(io, "$(data[:constants].define)\n$(data[:parameters].define)\n$(data[:variables].define)")
    write(io, "eqs = Equation[\n$(comp.conn)]\n")
    write(io, comp.eqs)
    write(io, "compose(ODESystem(eqs, t, [$(data[:variables].sys)], [$(data[:parameters].sys)]; name=name), [$ports; $sons])")
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

function compile_port(ports::Dict)
    io = open("./PortType.jl", "w")
    for (k, v) in ports
        write(io, "@connector $k begin\n")
        for (pk, pv) in v.vars
            write(io, "$pk(t)=$(pv.value), $(parse_metadata(pv))\n")
            write(
                io,
                """begin
                	$pk = setmetadata($pk, Ai4EnergyMetaData, $pv)
                end\n
                """
            )
        end
        write(io, "end\n")
    end
    close(io)
    nothing
end

function compiler(comp::Component{true}, create=true)
    io = open("./$(comp.type).jl", "w")
    data = compile_data(comp)
    medias = parse_media.(comp.media)
    !isnothing(medias) && generate_material.(medias)
    write(io, "function $(comp.type)(;name, $(data[:parameters].args) $(data[:structural_parameters].args))\n")
    ports = ""
    for (k, v) in comp.ports
        ports *= "$k;"
        if v.number isa Number && v.number > 1
            write(io, "@named $k[1:$(v.number)] = $(v.type)()\n")
        elseif v.number isa Number && v.number == 1
            write(io, "@named $k = $(v.type)()\n")
        elseif v.number isa Symbol
            write(io, "@named $k[1:$(v.number)] = $(v.type)()\n")
        end
    end
    write(io, "$(data[:constants].define)\n$(data[:parameters].define)\n$(data[:variables].define)")
    write(io, "eqs = Equation[]\n")
    write(io, comp.eqs)
    write(io, "compose(ODESystem(eqs, t, [$(data[:variables].sys)], [$(data[:parameters].sys)]; name=name), [$ports])")
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
    for (k, v) in input
        args *= "$k=$(v["Value"]),"
    end
    println(args)
    return args
end

function compiler(sys::System)
    types = collect(Set(map(x -> Symbol(x["Type"]), collect(values(sys.comps)))))
    comps = [Component(get_data(t, :Components)) for t in types]
    compile_port(port_types[])
    include("./PortType.jl")
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
    io = open("./$(sys.name).jl", "w")
    write(io, "function $(sys.name)(;name)\n")
    ports = ""
    for (k, v) in sys.comps
        println(v["Init"])
        ports *= k * ";"
        write(io, "@named $k = ready_components[][:$(v["Type"])]($(init_data(v["Init"])))\n")
    end
    write(io, "eqs = Equation[$(parse_conn(sys.nodes))]\n")
    write(io, "compose(ODESystem(eqs, t, [], []; name=name), [$ports])\nend\n\n")
    write(io, "@mtkbuild sys = $(sys.name)()\nglobal system = sys\n")
    close(io)
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
function generateMTKSystem(io, sys; name="System")
    write(io, "@mtkmodel $name begin\n")
    # 初始化组件
    write(io, "@components begin\n")
    for (k, v) in sys["ComponentList"]
        paras = haskey(v, "Parameters") ? init(v["Parameters"]) : ""
        write(io, "$k = $(v["Type"])($(paras))\n")
    end
    write(io, "end\n")
    # 连接节点
    haskey(sys, "ConnectNodeList") ? begin
        write(io, "@equations begin\n")
        for (_, nodes) in sys["ConnectNodeList"]
            write(io, "$(connect_nodes(nodes))")
        end
        write(io, "end\n")
    end : (@warn "警告!系统没有节点列表,这可能导致出错,请注意!")
    write(io, "end\n\n")
    write(io, "@named system = $name()\nglobal system = system\n")
    write(io, "simulation_error_flag = 7\n")
    nothing
end

"""
设置返回值字典.
"""
function generate_back(io, back_info)
    # 初始化返回字典
    write(io, "back_results = Dict()\n")
    # 写入返回信息
    write(io, "back_info = $back_info\n")
    # 向返回字典中加入返回值
    expr = quote
        for back in back_info
            eval(Meta.parse("get!(back_results, \"$back\", sol[system.$back])"))
        end
        push!(back_results, "t" => sol.t)
    end
    write(io, "$expr")
    write(io, "\n")
    # 返回字典
    write(io, "back_results")
    nothing
end

# 生成MTK设置条件
function generate_settings(io, settings)
    # 设置初始条件
    write(io, "initialconditions = $(init_conditions(settings["InitialConditions"]))\n")
    write(io, "simulation_error_flag = 8\n")
    # 仿真参数设置
    # 设置时间域
    !haskey(settings, "TimeSpan") && error("仿真不能不设置时间域,请检查!")
    ts = settings["TimeSpan"]
    write(io, "prob = ODEProblem(system, initialconditions, ($(ts[1]), $(ts[2])))\n")
    write(io, "simulation_error_flag = 9\n")
    # 求解问题
    write(io, "global sol = solve(prob)\n")
    write(io, "simulation_error_flag = 10\n")
    # 设置返回值
    generate_back(io, settings["BackValues"])
    nothing
end

# 生成仿真文件
function generate_simulation_file(IO; project_name="Project1")
    sys = JSON3.read(IO, Dict)
    # 系统信息
    # 创建仿真文件,并生成数据流
    # 创建工程路径并切换工作路径
    mkdir(project_name)
    cd(project_name)
    io = open("MainSystem.jl", "w")# 此文件名为专用名称,写死
    try
        # 写入全局错误旗帜
        write(io, "global simulation_error_flag = 1\n")
        # 建立组件的MTK模型
        !haskey(sys, "Packages") && (@warn "警告!未使用任何依赖包!")
        !haskey(sys, "ComponentList") && error("系统不能没有组件列表(ComponentList),请检查!")
        write(io, "include(\"projact_ports.jl\")\n")
        model_file = generate_component(sys["ComponentList"], sys["Packages"])

        for model in model_file
            write(io, "include(\"$model\")\n")
        end
        # 换行
        write(io, "\n")
        # 建立MTK系统
        haskey(sys, "Name") ? generateMTKSystem(io, sys; name=sys["Name"]) : generateMTKSystem(io, sys)
        # 关闭文件
        close(io)
        cd("..")
        nothing
    finally
        close(io)
    end
end

"""
在环境中运行任务并返回解.
"""
function run_task(task_name::String)
    !isdir(task_name) && error("$(task_name)文件丢失!请重试!")
    return include(".\\$task_name\\MainSystem.jl")
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

# 分析函数
function analysis_system(url::String; name="Project1")
    isdir(name) && delete_projact(name)
    open("$url", "r") do IO
        generate_simulation_file(IO, project_name=name)
    end
    @info "代码文件生成成功!开始进行系统分析..."
    run_task(name)
    vars = map(states(system)) do x
        str = "$x"
        return replace(str[1:end-3], "₊" => ".")
    end
    global system = ModelingToolkit.structural_simplify(system)
    results = map(states(system)) do x
        str = "$x"
        return replace(str[1:end-3], "₊" => ".")
    end
    back = Dict("States" => results, "Variables" => vars)
    return JSON3.write(back)
end

function simulation(settings::String, name="Project1")
    println(settings)
    try
        open("./$name/simulation.jl", "w") do io
            generate_settings(io, JSON3.read(settings, Dict))
        end
        result = include("./$name/simulation.jl")
        #delete_projact(name)
        println(result)
        return JSON3.write(result)
    catch e
        println(e)
    end
end

function simulation(input::Dict)
    global simulation_system = System(input)
    global load_path[:Port] = simulation_system.libs
    global load_path[:Components] = simulation_system.libs
    compiler(simulation_system)
    include("./$(simulation_system.name).jl")
    initial_conditions = take!(init)
    if isempty(initial_conditions)
        prob = ODEProblem(sys, ModelingToolkit.missing_variable_defaults(sys), (0.0, 20.0))
    else
        u0 = map(x -> (eval(Meta.parse("sys.$(x.first)=>$(x.second)"))), collect(initial_conditions))
        prob = ODEProblem(sys, u0, (0.0, 20.0))
    end
    global sol = solve(prob)
    nothing
end

nothing