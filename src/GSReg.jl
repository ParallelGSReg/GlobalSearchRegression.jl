module GSReg

using DataFrames
using Base.Threads

export gsreg

INTERCEPT_DEFAULT = true
OUTSAMPLE_DEFAULT = -1
SAMESAMPLE_DEFAULT = false
THREADS_DEFAULT = nthreads()
CRITERIA_DEFAULT = nothing
CRITERIA_DEFAULT_OUTSAMPLE = [ :rmseout ]
CRITERIA_DEFAULT_INSAMPLE = [ :r2adj ]
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
        "verbose_title" => "Adjusted R²",
        "verbose_show" => false
    ),
    :bic => Dict(
        "verbose_title" => "BIC",
        "verbose_show" => true
    ),
    :aic => Dict(
        "verbose_title" => "AIC",
        "verbose_show" => true
    ),
    :aicc => Dict(
        "verbose_title" => "AIC Corrected",
        "verbose_show" => true
    ),
    :cp => Dict(
        "verbose_title" => "Mallows's Cp",
        "verbose_show" => true
    ),
    :rmse => Dict(
        "verbose_title" => "RMSE",
        "verbose_show" => true
    ),
    :sse => Dict(
        "verbose_title" => "SSE",
        "verbose_show" => true
    )
)


include("strings.jl")
include("other/utils.jl")
include("interface.jl")
include("core.jl")

end # module GSReg
