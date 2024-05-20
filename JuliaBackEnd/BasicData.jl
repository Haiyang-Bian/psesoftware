# 对基础数据的处理

abstract type AbstractData end
# 自定义元数据键
abstract type Ai4EnergyMetaData end

# 参数结构体
mutable struct Data <: AbstractData
    type::Symbol
    value::Union{Number,Expr,Symbol}
    bound::Tuple
    number::Union{Int64,Symbol}
    incremental::Bool
    incremental_bounds::Tuple
    unit::Any
    k::Number
    connect_type::Symbol
    metadata::Any
end

function Data(data::Dict)
    value = get(data, "Value", 0)

end

function Data()
    return Data(
        :NoUnits,
        0.0,
        (-Inf, Inf),
        1,
        false,
        (),
        NoUnits,
        1,
        :Equal,
        nothing
    )
end

# 处理后的数据结构体(用于生成组件函数)
struct ProcessedData
    args::String
    define::String
    sys::String
end

# 转译变量
function parse_vars(::Nothing)
    @warn "\033[1;33m警告\033[0m:组件没有变量!"
    return Dict()
end

function parse_vars(input::Dict)
    vars = Dict()
    for (k, v) in input
        data = Data()
        type = get_data(Symbol(get(v, "Type", nothing)), :DataType)
        data.type = Symbol(type["Name"])
        value = get(v, "Value", nothing)
        isnothing(value) && (value = type["DefaultValue"])
        data.value = Meta.parse(value)
        bounds = get(v, "Bounds", nothing)
        isnothing(bounds) && (bounds = type["Bounds"])
        data.bound = bounds
        is_incremental = get(v, "Incremental", false)
        data.incremental = is_incremental
        is_incremental && (
            data.incremental = true;
            data.incremental_bounds = type["IncrementalBounds"]
        )
        unit = get(v, "Unit", nothing)
        if isnothing(unit)
            data.unit = uparse(type["DefaultUnit"])
        else
            data.unit = uparse(unit)
            data.k = (uparse("1.0" * unit) |> uparse(type["DefaultUnit"])).val
        end
        data.connect_type = Symbol(get(v, "ConnectType", :Equal))
        push!(vars, Symbol(k) => data)
    end
    return vars
end

# 获取表达式中的符号
function get_expr_symbols(x::Expr; back=Set([]))
    for s in x.args[2:end]
        s isa Number && continue
        s isa Symbol && push!(back, s)
        s isa Expr && get_expr_symbols(s; back=back)
    end
    return back
end

# 对表达式进行排序
function range_expr(input::Dict)
    range_set = Dict()
    s = 1
    while !isempty(input)
        expr = pop!(input)
        if expr.second.value isa Number
            push!(range_set, (expr.first, s) => expr.second)
        elseif expr.second.value isa Symbol
            expr.second.value in map((x) -> x[1], keys(range_set)) && (
                push!(range_set, (expr.first, s) => expr.second)
            )
        else
            issubset(get_expr_symbols(expr.second.value), map((x) -> x[1], collect(keys(range_set)))) && (
                push!(range_set, (expr.first, s) => expr.second)
            )
        end
        s += 1
    end
    return range_set
end

# 处理参数
function parse_paras(::Nothing)
    @warn "\033[1;33m警告\033[0m:组件没有参数!"
    return Dict()
end

Meta.parse(x::Number) = x

function parse_paras(input::Dict)
    paras = Dict()
    for (k, v) in input
        data = Data()
        type = get_data(Symbol(get(v, "Type", nothing)), :DataType)
        data.type = Symbol(type["Name"])
        value = get(v, "Value", nothing)
        if isnothing(value)
            error("\033[1;31m错误\033[0m:参数必须赋值!请检查!")
        else
            data.value = Meta.parse(value)
        end
        unit = get(v, "Unit", nothing)
        if isnothing(unit)
            data.unit = uparse(type["DefaultUnit"])
        else
            data.unit = uparse(unit)
            data.k = (uparse("1.0" * unit) |> uparse(type["DefaultUnit"])).val
        end
        push!(paras, Symbol(k) => data)
    end
    return range_expr(paras)
end

# 转译结构参数
parse_sparas(::Nothing) = Dict()

function parse_sparas(input::Dict)
    sparas = Dict()
    for (k, v) in input
        data = Data()
        data.type = Symbol(type["Name"])
        value = get(v, "Value", nothing)
        if isnothing(value)
            @warn "\033[1;33m警告\033[0m:已声明结构参数但未赋值!将带入零!"
            data.value = 0.0
        else
            data.value = value
        end
        push!(sparas, Symbol(k) => data)
    end
    return sparas
end

# 转译常数
parse_const(::Nothing) = Dict()

function parse_const(input::Vector)
    cons = Dict()
    for v in input
        data = Data()
        type = get_data(Symbol(v), :Constans)
        data.type = Symbol(type["Name"])
        data.value = Meta.parse(type["DefaultValue"])
        data.unit = uparse(type["DefaultUnit"])
        push!(cons, Symbol(v) => data)
    end
    return cons
end

# 生成MateData
function parse_metadata(data::Data)
    metadata_string = "bounds="
    if data.incremental
        metadata_string *= "$(data.incremental_bounds),"
    else
        metadata_string *= "$(data.bound),"
    end
    data.connect_type != :Equal && (metadata_string *= "connect=$(data.connect_type)")
    return "[$(metadata_string)]"
end

# 去单位
# 物理量去单位
function remove_unit(default::String, unit::String)
    u = eval(Meta.parse("u\"$default\"(1.0u\"$unit\")"))
    return u.val
end

# 物理常数去单位
function remove_unit(unit::String)
    u = eval(Meta.parse("upreferred(u\"$unit\")(1.0u\"$unit\")"))
    return u.val
end

# 设置物理量
# 无修改设置
function set_data(data::String)
    base_type = get_datatype(data)
    get!(base_type, "Value", base_type["DefaultValue"])
    return base_type
end

# 有修改设置
function set_data(data::Dict)
    real_data = set_data(data["Type"])
    if haskey(data, "Unit")
        get!(real_data, "Unit", data["Unit"])
        conversion_factor = remove_unit(real_data["DefaultUnit"], real_data["Unit"])
        real_data["Value"] = real_data["Value"] * conversion_factor
        get!(real_data, "ConversionFactor", conversion_factor)
    end
    haskey(data, "Bounds") && (real_data["Bounds"] = data["Bounds"])
    haskey(data, "Input") && get!(real_data, "Input", data["Input"])
    haskey(data, "Output") && get!(real_data, "Output", data["Output"])
    haskey(data, "ConnectType") && get!(real_data, "ConnectType", data["ConnectType"])
    return real_data
end

# 交换变量位置
function swap(v::Vector, i::Int64, j::Int64)
    max(i, j) > length(v) && error("数组访问越界!")
    s = v[i]
    v[i] = v[j]
    v[j] = s
    nothing
end

# 判断符号是否在表达式中
function symbol_isin(s::Symbol, expr::Union{Expr,Symbol,Number})
    expr isa Union{Symbol,Number} && (return s == expr)
    for e in expr.args
        symbol_isin(s, e) && (return true)
    end
    return false
end

# 参数定义表达式排序
function range_exprs(v::Vector)
    n = length(v)
    n < 2 && return nothing
    for i = n:-1:2
        for j = i-1:-1:1
            v[j].value isa Number && continue
            expr = Meta.parse(v[j].value)
            symbol_isin(v[i].name, expr) && swap(v, i, j)
        end
    end
    nothing
end

# 对参数数组的预处理
function parameter_preprocess(v::Vector)
    isempty(v) && return "", "", ""
    ps = ""
    ps_str = ""
    ps_args = ""
    for p in v
        ps *= "$(p.name);"
        if p.array == 1
            ps_str *= "@parameters $(p.name)"
        else
            ps_str *= "@parameters $(p.name)[1:$(p.array)]"
        end
        if p.value isa Number
            ps_str *= "=$(p.name) $(p.metadata)\n"
            ps_args *= "$(p.name) = $(p.value),"
        else
            ps_str *= "=$(p.value) $(p.metadata)\n"
        end
        ps_str *= "$(p.name) = setmetadata($(p.name), Ai4EnergyMetaData, $(p.data))\n"
    end
    return ps, ps_str, ps_args
end

# 对变量的预处理
function variables_preprocess(v::Vector)
    isempty(v) && return "", "", ""
    vars = ""
    vars_str = ""
    for p in v
        vars *= "$(p.name);"
        if p.array == 1
            vars_str *= "@variables $(p.name)(t) = $(p.value) $(p.metadata)\n"
        else
            vars_str *= "@variables $(p.name)(t)[1:$(p.array)] = $(p.value) $(p.metadata)\n"
        end
        vars_str *= "$(p.name) = setmetadata($(p.name), Ai4EnergyMetaData, $(p.data))\n"
    end
    return vars, vars_str
end

# 对常数的预处理
function constants_preprocess(v::Vector)
    isempty(v) && return "", ""
    cons = ""
    cons_str = ""
    for p in v
        cons *= "$(p.name);"
        cons_str *= "@parameters $(p.name) = $(p.value)\n"
        cons_str *= "$(p.name) = setmetadata($(p.name), Ai4EnergyMetaData, $(p.data))\n"
    end
    return cons, cons_str
end