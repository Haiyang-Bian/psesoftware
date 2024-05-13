# RestFulApi

const CORS_HEADERS = [
    "Access-Control-Allow-Origin" => "*",
    "Access-Control-Allow-Methods" => "GET, POST, OPTIONS, PUT, DELETE, PATCH",
    "Access-Control-Allow-Headers" => "*",
    "Access-Control-Allow-Credentials" => "true"
]

# 物理量相关接口

@get "/physicalDatas" function (req::HTTP.Request)
    paras = queryparams(req)
    if isempty(paras)
        return get_datatype()
    else
        return get_datatype(paras["name"])
    end
end

@patch "/physicalDatas" function (req::HTTP.Request)
    paras = queryparams(req)
    if set_datatype(paras["name"], paras["key"], paras["value"])
        return "success"
    else
        return "fail"
    end
end

@post "/physicalDatas" function (req::HTTP.Request)
    data = json(req, Dict)
    create_datatype(data)
end

@delete "/physicalDatas" function (req::HTTP.Request)
    paras = queryparams(req)
    result = execute(connection,
        """DELETE FROM "PhysicalData"."PhysicalData" WHERE "Name" = '$(paras["name"])';"""
    )
    if LibPQ.error_message(result) == ""
        @info "已删除$(paras["name"])物理量"
    else
        @warn "删除失败!"
    end
end

# 连接类型相关接口

@get "/portTypes" function (req::HTTP.Request)
    paras = queryparams(req)
    if isempty(paras)
        return port_types[]
    else
        return port_types[paras["name"]]
    end
end

@post "/portTypes" function (req::HTTP.Request)
    data = json(req, Dict)
    port_types[] = data
end

@delete "/portTypes" function (req::HTTP.Request)
    paras = queryparams(req)
    delete!(port_types, paras["name"])
end

@patch "/portTypes" function (req::HTTP.Request)
    data = json(req, Dict)
    port_types[data["name"]] = data
end

# 模型相关接口

@get "/models" function (req::HTTP.Request)
    paras = queryparams(req)
    get_model(paras["type"], paras["libName"])
end

@put "/models" function (req::HTTP.Request)
    paras = queryparams(req)
    model = json(req, Dict)
    comp = Component(model)
    code = compiler(comp, false)
    set_model(paras["type"], paras["libName"], model, code)
end

@post "/models" function (req::HTTP.Request)
    paras = queryparams(req)
    model = json(req, Dict)
    comp = Component(model)
    code = compiler(comp, false)
    create_model(paras["type"], paras["libName"], model, code)
end

@delete "/models" function (req::HTTP.Request)
    paras = queryparams(req)
    result = execute(connection,
        """DELETE FROM "$(paras["libName"])"."ModelList" WHERE "Type" = '$(paras["type"])';"""
    )
    if LibPQ.error_message(result) == ""
        @info "已删除$paras[type]模型"
    else
        @warn "删除失败!"
    end
end

# 计算相关接口

@get "/calculate" function (req::HTTP.Request)
    paras = queryparams(req)
    sys = json(req, Dict)
    @eval begin
        $(paras["problem"])(sys)
    end
    # TODO:再说吧
end

function CorsHandler(handle)
    return function (req::HTTP.Request)
        if HTTP.method(req) == "OPTIONS"
            return HTTP.Response(200, CORS_HEADERS)
        else
            r = handle(req)
            append!(r.headers, CORS_HEADERS)
            return r
        end
    end
end