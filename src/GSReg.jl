__precompile__()
module GSReg

using DataFrames, Compat, Compat.LinearAlgebra, Distributions

const INTERCEPT_DEFAULT = true
const INSAMPLE_MIN_SIZE = 20

const OUTSAMPLE_DEFAULT = 0
const SAMESAMPLE_DEFAULT = false
const TTEST_DEFAULT = false
const METHOD_DEFAULT = "fast"
const CRITERIA_DEFAULT = []
const CRITERIA_DEFAULT_OUTSAMPLE = [:rmseout]
const CRITERIA_DEFAULT_INSAMPLE = [ ]
const CSV_DEFAULT = "gsreg.csv"
const ORDER_RESULTS_DEFAULT = false
const VECTOR_OPERATION_DEFAULT = false
const MODEL_AVG_DEFAULT = false
const RESIDUAL_TEST_DEFAULT = nothing
const KEEP_WHITE_NOISE_DEFAULT = false
const TIME_DEFAULT = nothing
const SUMMARY_DEFAULT = nothing

const AVAILABLE_METHODS = ["precise", "fast"]
const AVAILABLE_VARIABLES = [:b, :bstd, :t_test]

const INDEX = :index
const EQUATION_GENERAL_INFORMATION = [:nobs, :ncoef, :sse, :r2, :F, :rmse]
const RESIDUAL_TESTS_TIME = [:jbtest, :wtest, :bgtest]
const RESIDUAL_TESTS_CROSS = [:jbtest, :wtest]
const ORDER = :order
const WEIGHT = :weight

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
include("utils.jl")
include("interface.jl")
include("gsreg_result.jl")
include("core.jl")

export gsreg

end # module GSReg
