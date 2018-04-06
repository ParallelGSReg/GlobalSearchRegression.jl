module GSReg

using DataFrames

export gsreg

NOCONSTANT_DEFAULT = false

include("other/utils.jl")
include("types.jl")
include("interface.jl")
include("criteria.jl")
include("core.jl")

end # module GSReg
