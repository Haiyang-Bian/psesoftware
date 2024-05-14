# 将json模型转化为MTK代码
abstract type AbstractComponent end
# 端口结构体
struct Port
    type::String
    number::Union{Int64,String}
    metadata::Any
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
        code = get_data(port, :Port)
        push!(port_types[], Symbol(port) => code)
    end
    return ports
end
