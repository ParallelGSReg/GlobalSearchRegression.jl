module GSReg

using DataFrames

export
    GSRegSingleResult,
    gsreg

include("core.jl")
include("interface.jl")

end
