# 函数模块,包括一些基础的函数以及自定义函数的处理

@variables t

Diff = Differential(t)

# 构建Julia函数
function generate_functions(head, body)
    if body.head == :tuple
        return Expr(:function, head, Expr(:block, body.args...))
    elseif body.head == :call
        return :($head = $body)
    else
        throw("函数体错误!请检查!")
    end
end

# 生成Julia函数,并登记为MTK函数
macro functions(head, body)
    quote
        generate_functions(head, body)
        @register_symbolic $head
    end
end