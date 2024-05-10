# 此文件处理方程
function parse_eqs(::Nothing)
    error("\033[1;31m错误\033[0m:组件必须含有方程!请检查!")
end

function parse_eqs(input::Vector)
    eqs = ""
    head = r"^\s*(?:for|if) .+"
    stop = r"^\s*end\s*"
    stack = []
    for line in input
        line[1] = '#' && continue
        if occursin(head, line)
            push!(stack, 1)
            block *= line * "\n"
        elseif occursin(stop, line)
            pop!(stack)
            block *= line * "\n"
        elseif isempty(stack)
            if block != ""
                eqs *= "@equations $(block)\n"
                block = ""
            else
                eqs *= "@equations $(line)\n"
            end
        else
            block *= line * "\n"
        end
    end
    return eqs
end

# 将符号替换成数字(循环展开)
function change_symbol(expr::Expr, bsymbol::Symbol, symbol::Number)
    for e in eachindex(expr.args)
        if expr.args[e] == bsymbol
            expr.args[e] = symbol
        elseif typeof(expr.args[e]) == Expr
            change_symbol(expr.args[e], bsymbol, symbol)
        end
    end
    nothing
end

# 处理符号和数字
parse_eqs(expr::Union{Symbol,Number}) = expr

#处理表达式
function parse_eqs(expr::Expr)
    if expr.head == :(=)
        return :(push!(eqs, $(expr.args[1]) ~ $(parse_eqs(expr.args[2]))))
    elseif expr.head == :block
        for e in expr.args
            e isa LineNumberNode && continue
            return :($(parse_eqs(e)))
        end
    elseif expr.head == :if
        length(expr.args) == 2 && return Expr(:if, expr.args[1], parse_eqs(expr.args[2]))
        if expr.args[3] == :elseif
            return Expr(:if, expr.args[1], parse_eqs(expr.args[2]))
        else
            return Expr(:if, expr.args[1], parse_eqs(expr.args[2]), parse_eqs(expr.args[3]))
        end
    elseif expr.head == :elseif
        length(expr.args) == 2 && return Expr(:elseif, expr.args[1], parse_eqs(expr.args[2]))
        if expr.args[3] == :elseif
            return Expr(:elseif, expr.args[1], parse_eqs(expr.args[2]))
        else
            return Expr(:elseif, expr.args[1], parse_eqs(expr.args[2]), parse_eqs(expr.args[3]))
        end
    elseif expr.head == :call
        return expr
    elseif expr.head == :ref
        return expr
    elseif expr.head == :for
        return Expr(:for, expr.args[1], parse_eqs(expr.args[2].args[2]))
    elseif expr.head == :tuple
        return Expr(:tuple, parse_eqs.(expr.args)...)
    elseif expr.head == :.
        return expr
    elseif expr.head == :generator
        return Expr(:for, expr.args[2], parse_eqs(expr.args[1]))
    else
        error("错误!表达式中出现了不应当有的部分!请检查!")
    end
end

# 处理方程的宏
macro equations(eq)
    esc(parse_eqs(eq))
end


# 生成方程
function generate_eqs(eqs_dict::Vector)
    isempty(eqs_dict) && error("错误!组件不能没有方程!请检查!")
    eqs = ""
    for eq in eqs_dict
        # 去除注释
        eq[1] == '#' && continue
        eqs *= "@equations $(eq)\n"
    end
    return eqs
end

# 生成连接方程(逻辑有所改动,现在一个节点就是两个端口)
function connect_nodes(nodes::Vector)
    expr1 = Meta.parse(nodes[1])
    expr2 = Meta.parse(nodes[2])
    if expr1.head == :ref
        expr1 = "$(expr1.args[1])_$(expr1.args[2])"
    end
    if expr2.head == :ref
        expr2 = "$(expr2.args[1])_$(expr2.args[2])"
    end
    return "connect($expr1, $expr2)\n"
end