const ALLSUBSETREGRESSION_EXTRAKEY = :allsubsetregression
const FIXEDVARIABLES_DEFAULT = nothing
const INSAMPLE_MIN = 20
const OUTSAMPLE_DEFAULT = 20
const CRITERIA_DEFAULT = []
const MODELAVG_DEFAULT = false
const TTEST_DEFAULT = false
const RESIDUALTEST_DEFAULT = false
const ORDERRESULTS_DEFAULT = false

const INDEX = :index
const EQUATION_GENERAL_INFORMATION = [:nobs, :ncoef, :sse, :r2, :F, :rmse]
const RESIDUAL_TESTS_TIME = [:jbtest, :wtest, :bgtest]
const RESIDUAL_TESTS_CROSS = [:jbtest, :wtest]
const ORDER = :order
const WEIGHT = :weight

const AVAILABLE_CRITERIA = Dict(
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
