module GSReg

using DataFrames
using Base.Threads

export gsreg

INTERCEPT_DEFAULT = true
OUTSAMPLE_DEFAULT = -1
SAMESAMPLE_DEFAULT = false
THREADS_DEFAULT = nthreads()
CRITERIA_DEFAULT = nothing
CRITERIA_DEFAULT_OUTSAMPLE = [ "rmseout" ]
CRITERIA_DEFAULT_INSAMPLE = [ "r2adj" ]
CSV_DEFAULT = "gsreg.csv"

AVAILABLE_CRITERIA = Dict(
    "r2adj" => Dict(
        "sample" => "in",
        "index" => "max"
    ),
    "bic" => Dict(
        "sample" => "in",
        "index" => "min"
    ),
    "aic" => Dict(
        "sample" => "in",
        "index" => "min"
    ),
    "aicc" => Dict(
        "sample" => "in",
        "index" => "min"
    ),
    "cp" => Dict(
        "sample" => "in",
        "index" => "min"
    ),
    "rmsein" => Dict(
        "sample" => "in",
        "index" => "min"
    ), 
    "rmseout" => Dict(
        "sample" => "out",
        "index" => "min"
    )
)

include("strings.jl")
include("types.jl")
include("other/utils.jl")
include("interface.jl")
include("criteria.jl")
include("core.jl")

end # module GSReg
    
