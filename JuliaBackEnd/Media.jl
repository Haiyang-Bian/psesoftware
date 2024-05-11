# 处理物质信息

# 物质信息结构体(参数类型,true为纯净物,false为混合物)
mutable struct Media{T}
    name::String# 物质名称
    type::String
    mixlist::Any# 物质列表
end

const global inlist = Dict(
    "Tempurature" => "T",
    "Pressure" => "P",
    "MassDensity" => "D",
    "MolarDensity" => "DMOLAR",
    "MolarSpecificEnthalpy" => "HMOLAR",
    "MassSpecificEnthalpy" => "H",
    "MolarVaporQuality" => "Q",
    "MolarSpecificEntropy" => "SMOLAR",
    "MassSpecificEntropy" => "S",
    "MolarSpecificInternalEnergy" => "UMOLAR",
    "MassSpecificInternalEnergy" => "U"
)

const global outlist = Dict(
    "D_mass" => "D",
    "D_molar" => "DMOLAR",
    "H_molar" => "HMOLAR",
    "H_mass" => "H",
    "MolarVaporQuality" => "Q",
    "S_molar" => "SMOLAR",
    "S_mass" => "S",
    "U_molar" => "UMOLAR",
    "U_mass" => "U",
    "SpeedOfSound" => "A",
    "ThermalConductivity" => "L",
    "IdealGasCp_mass" => "CP0MASS",
    "IdealGasCp_molar" => "CP0MOLAR",
    "Cv_mass" => "CVMASS",
    "Cv_molar" => "CVMOLAR",
    "Cp_mass" => "CPMASS",
    "Cp_molar" => "CPMOLAR",
    "Gas_constant" => "GAS_CONSTANT",
    "G_molar" => "GMOLAR",
    "G_mass" => "GMASS",
    "IsentropicExpansionCoefficient" => "ISENTROPIC_EXPANSION_COEFFICIENT",
    "IsobaricExpansionCoefficient" => "ISOBARIC_EXPANSION_COEFFICIENT",
    "IsothermalCompressibility" => "ISOTHERMAL_COMPRESSIBILITY",
    "SurfaceTension" => "SURFACE_TENSION",
    "MolarMass" => "MOLAR_MASS",
    "Viscosity" => "V",
    "Z" => "Z"
)

const global const_props = Dict(
    "T_triple" => "TTRIPLE",
    "T_critical" => "TCRIT",
    "P_triple" => "PTRIPLE",
    "P_critical" => "PCRIT",
    "D_mass_critical" => "RHOCRIT",
    "D_molar_critical" => "RHOMOLAR_CRITICAL",
)

# 生成纯物质
function generate_material(m::Media{true})
    @info "正在生成 $(m.name) 物质"
    open("$(m.name).jl", "w") do io
        write(io, "module $(m.name)\n")
        write(io, "using ModelingToolkit, CoolProp\n")
        write(io, "import Main.Ai4EnergyMetaData, Main.Media\n")
        write(
            io,
            """PropsSI(
                out::AbstractString,
                name1::AbstractString,
                value1::Real,
                name2::AbstractString,
                value2::Real,
                fluid::AbstractString
            ) = CoolProp.PropsSI(out, name1, value1, name2, value2, fluid)\n
            """
        )
        write(io, "@register_symbolic PropsSI(out::AbstractString, name1::AbstractString, value1::Real, name2::AbstractString, value2::Real, fluid::AbstractString)\n")
        write(io, "media = $m\n")
        write(io, "inlist = $inlist\n")
        write(io, "outlist = $outlist\n")
        write(io, "const_props = $const_props\n")
        write(io, "const global Tmin = CoolProp.PropsSI(\"T_min\", media.mixlist)\n")
        write(io, "const global Tmax = CoolProp.PropsSI(\"T_max\", media.mixlist)\n")
        write(io, "const global Pmin = CoolProp.PropsSI(\"P_min\", media.mixlist)\n")
        write(io, "const global Pmax = CoolProp.PropsSI(\"P_max\", media.mixlist)\n")
        write(
            io,
            """
         function get_suitable_val(x::Real, type::String)
         	if type == "Tempurature"
         		if x < Tmin
         			return Tmin + 0.1
         		elseif x > Tmax
         			return Tmax - 0.1
         		else
         			return x
         		end
         	elseif type == "Pressure"
         		if x < Pmin
         			return Pmin + 0.1
         		elseif x > Pmax
         			return Pmax - 0.1
         		else
         			return x
         		end
         	elseif type == "MassDensity"
         		Dmin = CoolProp.PropsSI("D", "T", Tmin, "P", Pmin, media.mixlist)
         		Dmax = CoolProp.PropsSI("D", "T", Tmax, "P", Pmax, media.mixlist)
         		if x < Dmin
         			return Dmin + 0.1
         		elseif x > Dmax
         			return Dmax - 0.1
         		else
         			return x
         		end
         	elseif type == "MolarDensity"
         		Dmin = CoolProp.PropsSI("DMOLAR", "T", Tmin, "P", Pmin, media.mixlist)
         		Dmax = CoolProp.PropsSI("DMOLAR", "T", Tmax, "P", Pmax, media.mixlist)
         		if x < Dmin
         			return Dmin + 0.1
         		elseif x > Dmax
         			return Dmax - 0.1
         		else
         			return x
         		end
         	elseif type == "MolarSpecificEnthalpy"
         		Hmin = CoolProp.PropsSI("HMOLAR", "T", Tmin, "P", Pmin, media.mixlist)
         		Hmax = CoolProp.PropsSI("HMOLAR", "T", Tmax, "P", Pmax, media.mixlist)
         		if x < Hmin
         			return Hmin + 0.1
         		elseif x > Hmax
         			return Hmax - 0.1
         		else
         			return x
         		end
         	elseif type == "MassSpecificEnthalpy"
         		Hmin = CoolProp.PropsSI("H", "T", Tmin, "P", Pmin, media.mixlist)
         		Hmax = CoolProp.PropsSI("H", "T", Tmax, "P", Pmax, media.mixlist)
         		if x < Hmin
         			return Hmin + 0.1
         		elseif x > Hmax
         			return Hmax - 0.1
         		else
         			return x
         		end
           			elseif type == "MolarVaporQuality"
         			if x < 0
         				return 0
         			elseif x > 1
         				return 1
         			else
         				return x
         			end
     elseif type == "MolarSpecificEntropy"
         			Smin = CoolProp.PropsSI("SMOLAR", "T", Tmin, "P", Pmin, media.mixlist)
         			Smax = CoolProp.PropsSI("SMOLAR", "T", Tmax, "P", Pmax, media.mixlist)
         			if x < Smin
         				return Smin + 0.1
     	elseif x > Smax
         				return Smax - 0.1
         			else
         				return x
         			end
         		elseif type == "MassSpecificEntropy"
         			Smin = CoolProp.PropsSI("S", "T", Tmin, "P", Pmin, media.mixlist)
         			Smax = CoolProp.PropsSI("S", "T", Tmax, "P", Pmax, media.mixlist)
   		if x < Smin
         				return Smin + 0.1
         			elseif x > Smax
         				return Smax - 0.1
         			else
         				return x
         			end
    elseif type == "MolarSpecificInternalEnergy"
    	Umin = CoolProp.PropsSI("UMOLAR", "T", Tmin, "P", Pmin, media.mixlist)
    	Umax = CoolProp.PropsSI("UMOLAR", "T", Tmax, "P", Pmax, media.mixlist)
    	if x < Umin
    		return Umin + 0.1
    	elseif x > Umax
    		return Umax- 0.1
    		else
    			return x
    		end
    elseif type == "MassSpecificInternalEnergy"
    	Umin = CoolProp.PropsSI("U", "T", Tmin, "P", Pmin, media.mixlist)
    	Umax = CoolProp.PropsSI("U", "T", Tmax, "P", Pmax, media.mixlist)
    	if x < Umin
    		return Umin + 0.1
    	elseif x >Umax
    		return Umax - 0.1
    	else
    		return x
    	end
                end
   end
            """
        )
        write(io, "@register_symbolic get_suitable_val(x::Real, type::String)\n")
        write(
            io,
            """for (prop, label) in const_props
                @eval begin
                    \$(Symbol(prop)) = CoolProp.PropsSI(\$label, \$(media.mixlist))
                end
            end\n""" *
            """for (func, value) in outlist
                @eval begin
                    function \$(Symbol(func))(x1::Num, x2::Num)
                        x1_m = getmetadata(x1, Ai4EnergyMetaData)
                        x2_m = getmetadata(x2, Ai4EnergyMetaData)
                        return PropsSI(
           	\$value, 
           	inlist[x1_m["Type"]], 
           	get_suitable_val(x1, x1_m["Type"]), 
           	inlist[x2_m["Type"]], 
           	get_suitable_val(x2, x2_m["Type"]), 
           	\$(media.mixlist)
           )
                    end
                end
            end
            """
        )
        write(io, "end\n")
    end
    include("$(m.name).jl")
    #rm("$(m.name).jl")
end

parse_media(::Nothing) = Dict()

function parse_media(m::Dict)
    isempty(m) && return nothing
    if m["List"] isa String
        return Media{true}(
            m["Name"],
            m["Type"],
            m["List"]
        )
    else
        return Media{false}(
            m["Name"],
            m["Type"],
            m["List"]
        )
    end
end

# 将混合物展开
function collect_mix_media(media_list::Set)
    mix_list = Set([])
    for media in media_list
        if media["Type"] == "Mixture"
            union!(mix_list, [get_media(_media) for (_media, _) in media["List"]])
        end
    end
    return mix_list
end

# 创建物质
# 创建混合物组分
function create_mix_component(io, mix::Dict)
    isnothing(mix) && return nothing
    write(io, "@mtkmodel _$(mix["Name"])\n")
    write(io, "@parameters begin\n id=$(mix["Number"])end\n")
    write(io, "@variables begin\nx(t)=0.0\nend\n")
    write(io, "end\n")
    nothing
end

# 混合物
function create_mixture(io, media::Dict)
    write(io, "@mtkmodel $(media["Name"]) begin\n")
    write(io, "@components begin\n")
    # 设置约束方程
    eq = ""
    for (k, v) in media_type.mixlist
        # 赋予默认值,以物质类型的完全小写作为该系统的名字
        write(io, "$(lowercase(k)) = _$k(x=$v)\n")
        eq = eq * "$(lowercase(k)).x+"
    end
    write(io, "end\n")
    write(io, "@equations begin\n$(eq[1:end-1])~1\nend\n")
    write(io, "end\n")
    nothing
end

# 遍历整个物质表,创建纯物质的同时,收集混合物中的组成物质
function create_media(io, media::Dict)
    if media["Type"] == "Mixture"
        # 创建混合物质
        create_mixture(io, media)
    else
        # 创建纯物质
        write(io, "@mtkmodel $(media["Name"]) begin\n")
        write(io, "@parameters begin\nid=$(media["Number"])\nend\n")
        if haskey(media, "Variables")
            vars = ""
            # 设置约束方程
            eq = ""
            for (k, v) in media["Variables"]
                eq = eq * "$(lowercase(k)).x+"
                data = setdata(v["Type"])
                # 处理数组
                vars = vars * (
                    haskey(v, "Number") ?
                    "$k(t)[1:$(v["Number"])] = $(data["Value"]), " * parse_metadata(data) * "\n" :
                    "$k(t) = $(data["Value"]), " * parse_metadata(data) * "\n"
                )
            end
            write(io, "@variables begin\n$vars\nend\n")
            write(io, "@equations begin\n$(eq[1:end-1])~1\nend\n")
        end
        write(io, "end\n")
    end
    nothing
end

nothing