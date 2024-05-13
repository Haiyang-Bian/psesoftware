# 此文件包含各种数据库查询函数
# 数据库连接(测试)
global connection = nothing

# 建立数据库连接(测试)
function set_connection(sever::String, port::Int64)
    # 计算核心默认使用超级账户
    global connection = LibPQ.Connection("host=$sever port=$port user=postgres dbname=Ai4EnergyOfficialStandardLibrary password=1234567890")
    if isopen(connection)
        @info "已连接到http://$sever:$port"
    else
        @warn "连接失败!"
    end
    nothing
end

function switch(data_base::String)
    close(connection)
    global connection = LibPQ.Connection("host=$sever port=$port user=postgres dbname=$data_base password=1234567890")
    if isopen(connection)
        @info "已切换到$data_base"
    else
        @warn "切换失败!"
    end
    nothing
end

set_connection("localhost", 8888)

# 查找基本物理量类型
function get_datatype(name::String)
    result = execute(connection, """SELECT * FROM "PhysicalData"."PhysicalData" WHERE "Name" = '$name';""")
    if isempty(result)
        return Dict()
    else
        row = first(result)
        return Dict(
            "Name" => row[1],
            "DefaultUnit" => row[2],
            "DefaultValue" => row[3],
            "Bounds" => (row[4], row[5]),
            "Description" => row[6]
        )
    end
end

function get_datatype()
    result = execute(connection, """SELECT * FROM "PhysicalData"."PhysicalData";""")
    if isempty(result)
        return Dict()
    else
        datas = Dict[]
        rows = LibPQ.Columns(result)
        for i in eachindex(rows[1])
            data = Dict(
                "Name" => rows[1][i],
                "Unit" => rows[2][i],
                "DefaultValue" => rows[3][i],
                "Min" => rows[4][i],
                "Max" => rows[5][i],
                "Description" => rows[6][i]
            )
            push!(datas, data)
        end
        return Dict("Types" => datas)
    end
end

function set_datatype(name::String, key::String, value::String)
    result = execute(connection,
        """UPDATE "PhysicalData"."PhysicalData" 
        SET "$key" = '$value'
        WHERE "Name" = '$name';
    """)
    if LibPQ.error_message(result) == ""
        return true
    else
        return false
    end
end

function create_datatype(data::Dict)
    result = execute(connection,
        """INSERT INTO "PhysicalData"."PhysicalData" ("Name", "DefaultUnit", "DefaultValue", "Bounds", "Description") 
        VALUES ('$(data["Name"])', '$(data["DefaultUnit"])', '$(data["DefaultValue"])', '$(data["Bounds"])', '$(data["Description"])');
        """
    )
    if LibPQ.error_message(result) == ""
        return true
    else
        return false
    end
end

# 查取常数
function get_const(name::String)
end

# 查找物质类型
function get_media(name::String)
end

# 查找组件与接口
function get_model(name::String, lib_name::String)
    result = execute(connection, """SELECT ("ModelData", "JuliaCode") FROM "$lib_name"."ModelList" WHERE "Type" = '$name';""")
    if !isempty(result)
        result = first(result)
        model = JSON3.read(String(base64decode(result[1])), Dict)
        precompiled_model = String(base64decode(result[2]))
        return Dict("Model" => model, "PrecompiledModel" => precompiled_model)
    end
    return Dict()
end

function set_model(type::String, lib_name::String, model::Dict, code::String)
    result = execute(connection,
        """UPDATE "$lib_name"."ModelList" SET 
        "ModelData" = '$(base64encode(JSON3.write(model)))', 
        "JuliaCode" = '$(base64encode(code))'
        WHERE "Type" = '$type';
        """
    )
    if LibPQ.error_message(result) == ""
        @info "已更新$type模型"
    else
        @warn "更新失败!"
    end
end

function create_model(type::String, lib_name::String, model::Dict, code::String)
    result = execute(connection,
        """INSERT INTO "$lib_name"."ModelList" ("Type", "ModelData", "JuliaCode") VALUES (
        '$type', '$(base64encode(JSON3.write(model)))', '$(base64encode(code))'
        );"""
    )
    if LibPQ.error_message(result) == ""
        @info "已创建$type模型"
    else
        @warn "创建失败!"
    end
end

nothing