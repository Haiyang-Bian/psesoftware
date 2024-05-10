# 将json模型转化为MTK代码
abstract type AbstractComponent end
# 端口结构体
struct Port
    type::String
    number::Union{Int64,String}
    metadata::Any
end

struct PortType
    vars::Dict
end
# 组件从属信息结构体
struct ModelLib
    type::String
    lib::String
end

# 组件结构体
Base.@kwdef mutable struct Component{T} <: AbstractComponent
    type::Symbol
    ports::Dict
    medias::Dict
    vars::Dict
    paras::Dict
    sparas::Dict
    consts::Dict
    eqs::String
    comps::Dict = Dict()
    init_data::Dict = Dict()
    conn::String = ""
    metadata::Any = nothing
    mtkm::Function = () -> ()
end

(comp::Component)(args...; kws...) = comp.mtkm(args...; kws...)

function Base.Symbol(::Nothing)
    error("\033[1;31m错误\033[0m:类型缺失!请检查!")
end

function Component(input::Dict)
    type = Symbol(get(input, "Type", nothing))
    ports = parse_ports(get(input, "Ports", nothing))
    medias = get(input, "Medias", nothing)
    vars = parse_vars(get(input, "Variables", nothing))
    paras = parse_paras(get(input, "Parameters", nothing))
    sparas = parse_sparas(get(input, "StructrualParameters", nothing))
    consts = parse_const(get(input, "Constants", nothing))
    eqs = parse_eqs(get(input, "Equations", nothing))
    if get(input, "isBase", true)
        return Component{true}(;
            type=type,
            ports=ports,
            medias=medias,
            vars=vars,
            paras=paras,
            sparas=sparas,
            consts=consts,
            eqs=eqs
        )
    else
        comps = map(Component, get(input, "Components", nothing))
        conn = parse_conn(get(input, "Nodes", nothing))
        init = get(input, "Init", Dict())
        push!(eqs, conn)
        return Component{false}(;
            type=type,
            ports=ports,
            medias=medias,
            vars=vars,
            paras=paras,
            sparas=sparas,
            consts=consts,
            eqs=eqs,
            comps=comps,
            init_data=init,
            conn=conn
        )
    end
end

function parse_ports(::Nothing)
    error("\033[1;31m错误\033[0m:组件不能没有端口!请检查!")
end

function parse_ports(input::Dict)
    ports = Dict()
    types = Set([])
    for (k, v) in input
        push!(types, Symbol(v["Type"]))
        push!(ports, Symbol(k) => Port(
            v["Type"],
            get(v, "Number", 1),
            nothing
        ))
    end
    for port in types
        type = get_data(port, :Port)
        push!(port_types[], Symbol(port) => PortType(
            parse_vars(type["Variables"])
        ))
    end
    return ports
end

# 收集单个组件的接口类型
function collect_ports(model_ports::Dict)
    isempty(model_ports) && error("开放组件不能没有端口!请检查!")
    port_list = Set([])
    for (_, port) in model_ports
        # 收集所有接口类型
        if port["Type"] == "Fluid"
            push!(port_list, port)
        else
            push!(port_list, port["Type"])
        end
    end
    return port_list
end

# 收集单个组件的模型信息
# TODO:关于如何确定模型来源,这个问题再考虑...
function collect_models(type::String, source::String)
    model = get_model(type, source)
    !haskey(model, "Ports") && error("开放组件不能没有端口字段(Ports),请检查书写格式!")
    return model, collect_ports(model["Ports"])
end

# 以组件和包的关联结构体收集模型
collect_models(m::ModelLib) = collect_models(m.type, m.lib)

# 接口
function parse_port(io, port::Port)
    port_model = get_model(port.con.type, port.con.lib)
    write(io, "@connector $(port.info) begin\n")
    port_vars = create_data(Connector(port_model))
    write(io, "$port_vars end\n")
    nothing
end

# 一般组件
function parse_component(model::Dict)
    io = open("$(model["Type"]).jl", "w")
    vars, pars, structural_paras, cons = create_data(Model(model))
    cs, cs_str = constants_preprocess(cons)
    ps, ps_str, ps_args = parameter_preprocess(pars)
    vs, vs_str = variables_preprocess(vars)
    write(io, "function $(model["Type"])(;name,$(ps_args) $structural_paras)\n")
    # 加入接口
    port_ns = ""
    for (port_name, port_type) in model["Ports"]
        port_ns *= port_name * ";"
        port_number = ""
        if port_type["Number"] > 1
            port_number = "[1:$(port_type["Number"])]"
        end
        write(io, "@named $(port_name)$port_number = $(port_type["Type"])()\n")
    end
    cs != "" && write(io, cs_str, "\n")
    ps != "" && write(io, ps_str, "\n")
    write(io, vs_str, "\n")
    write(io, "eqs = Equation[]\n")
    write(io, generate_eqs(model["Equations"]))
    write(io, "return compose(ODESystem(eqs,t,[$vs],[$ps $cs], name = name),[$port_ns])\n")
    write(io, "end\n")
    close(io)
    return "$(model["Type"]).jl"
end

# 关联组件类型与从属库的函数
function combine_information(type_list::Set, lib_list::Dict)
    back_list = ModelLib[]
    while !isempty(type_list)
        flag = true
        type = pop!(type_list)
        for (k, v) in lib_list
            type in v && begin
                push!(back_list, ModelLib(type, k))
                flag = false
                break
            end
        end
        flag && error("错误!没有在已加载的包中找到类型为$(type)的组件!请检查!")
    end
    return back_list
end

# 派发一下
function combine_information_port(type_list::Set, lib_list::Union{String,Vector})
    back_list = Port[]
    for type in type_list
        type = pop!(type_list)
        flag = true
        for lib in lib_list
            port = get_model(type, lib)
            if !isnothing(port)
                flag = false
                push!(back_list, Port(port["Type"], port["Number"], nothing))
                break
            end
        end
        flag && error("错误!没有在已加载的包中找到类型为$(type)的组件!请检查!")
    end
    return back_list
end

# 生成组件代码
function generate_component(sys_model_list::Dict, pakages::Union{String,Vector})
    # 收集所需要的所有组件类型
    type_list = Set([comp["Type"] for (_, comp) in sys_model_list])
    isempty(type_list) && error("系统不能没有组件!请检查!")
    # 建立组件模型
    # 收集所有的物质类型
    model_list = []
    port_list = Set([])
    for type in type_list
        for lib in pakages
            model = get_model(type, lib)
            if !isnothing(model)
                push!(model_list, model)
                union!(port_list, collect_ports(model["Ports"]))
            end
        end
    end
    # 创建接口
    port_list = combine_information_port(port_list, pakages)
    io = open("projact_ports.jl", "w")
    parse_port.(io, port_list)
    close(io)
    # 创建组件
    return parse_component.(model_list)
end