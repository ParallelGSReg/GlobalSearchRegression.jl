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

# NOTE:
# (adanmauri) Replaced below
"""
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
)"""

# NOTE:
# (adanmari) This name would be changed
AVAILABLE_VARIABLES = [ :b, :bstd, :t_test ]
AVAILABLE_CRITERIA = Dict(
    :r2adj => Dict(
    ),
    :bic => Dict(
    ),
    :aic => Dict(
    ),
    :aicc => Dict(
    ),
    :cp => Dict(
    ),
    :rmse => Dict(
    ),
    :sse => Dict(
    )
)


include("strings.jl")
include("other/utils.jl")
include("interface.jl")
include("core.jl")

end # module GSReg
