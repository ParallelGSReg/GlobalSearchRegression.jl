module GSReg

using DataFrames, Missings
using Base.Threads
using CSV
using Compat, Compat.LinearAlgebra

export gsreg

const INTERCEPT_DEFAULT = true
const INSAMPLE_MIN_SIZE = 20
const OUTSAMPLE_DEFAULT = 0
const SAMESAMPLE_DEFAULT = false
const TTEST_DEFAULT = false
const METHOD_DEFAULT = "fast"
const THREADS_DEFAULT = nthreads()
const CRITERIA_DEFAULT = nothing
const CRITERIA_DEFAULT_OUTSAMPLE = [ :rmseout ]
const CRITERIA_DEFAULT_INSAMPLE = [ ]
const CSV_DEFAULT = "gsreg.csv"

AVAILABLE_METHODS = ["precise","fast"]

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
        "verbose_show" => false,
        "index" => 1
    ),
    :bic => Dict(
        "verbose_title" => "BIC",
        "verbose_show" => true,
        "index" => -1
    ),
    :aic => Dict(
        "verbose_title" => "AIC",
        "verbose_show" => true,
        "index" => -1
    ),
    :aicc => Dict(
        "verbose_title" => "AIC Corrected",
        "verbose_show" => true,
        "index" => -1
    ),
    :cp => Dict(
        "verbose_title" => "Mallows's Cp",
        "verbose_show" => true,
        "index" => -1
    ),
    :rmse => Dict(
        "verbose_title" => "RMSE",
        "verbose_show" => true,
        "index" => -1
    ),
    :rmseout => Dict(
        "verbose_title" => "RMSE OUT",
        "verbose_show" => true,
        "index" => -1
    ),
    :sse => Dict(
        "verbose_title" => "SSE",
        "verbose_show" => true,
        "index" => -1
    )
)


include("strings.jl")
include("other/utils.jl")
include("interface.jl")
include("core.jl")

end # module GSReg
