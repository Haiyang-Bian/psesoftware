#module Parser

# 翻译器主模块
@info "开始加载模块"

using LibPQ, JSON3, Oxygen, HTTP, Base64
using ModelingToolkit, DifferentialEquations, Unitful, CoolProp

global components = Channel(20)
const global ready_components = Ref{Dict}(Dict())
const global port_types = Ref(Dict())
const global work_path = pwd()
const global lib_load = Ref([])
global workers = Ref(8)
global simulation_system = nothing

include("DataExchanger.jl")
include("BasicData.jl")
include("Media.jl")
include("Functions.jl")
include("Equations.jl")
include("Component.jl")
include("Parser.jl")
include("RestApi.jl")

@info "翻译器加载完成!"

serve(middleware=[CorsHandler], async=true)
#end