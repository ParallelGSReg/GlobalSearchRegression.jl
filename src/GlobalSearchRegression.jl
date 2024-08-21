module GlobalSearchRegression
	using DataFrames, Distributions, Distributed, Printf, SharedArrays, LinearAlgebra, DelimitedFiles
	const INTERCEPT_DEFAULT = true
	const INSAMPLE_MIN_SIZE = 20
	const OUTSAMPLE_DEFAULT = 0
	const TTEST_DEFAULT = false
	const METHOD_DEFAULT = "qr_32"
	const CRITERIA_DEFAULT = [:aic]
	const CRITERIA_DEFAULT_OUTSAMPLE = [:rmseout]
	const CRITERIA_DEFAULT_INSAMPLE = [:aic]
	const RESULTSCSV_DEFAULT = nothing
	const ORDER_RESULTS_DEFAULT = false
	const MODEL_AVG_DEFAULT = false
	const RESIDUAL_TEST_DEFAULT = nothing
	const TIME_DEFAULT = nothing
	const SUMMARY_DEFAULT = nothing
	const ON_MESSAGE_DEFAULT = message -> ()
	const PARALLEL_DEFAULT = nothing
	const ESTIMATOR_DEFAULT = "ols"
	const PANEL_ID_DEFAULT = nothing
	const PANEL_TESTS_DEFAULT = nothing
	const FIXED_VARIABLES_DEFAULT = nothing
	const AVAILABLE_ESTIMATORS = ["ols", "ols_fe"]
	const AVAILABLE_METHODS = ["svd_64", "svd_32", "svd_16", "qr_64", "qr_32", "qr_16", "cho_64", "cho_32", "cho_16"]
	const AVAILABLE_VARIABLES = [:b, :bstd, :t_test]
	const INDEX = :index
	const EQUATION_GENERAL_INFORMATION = [:nobs, :ncoef, :sse, :r2, :F, :rmse]
	const RESIDUAL_TESTS_TIME = [:normtest, :hettest, :corrtest]
	const RESIDUAL_TESTS_CROSS = [:normtest, :hettest]
	const ORDER = :order
	const WEIGHT = :weight
	const AVAILABLE_VCE = ["robust", "cluster"]
	const VCE_DEFAULT = nothing

	AVAILABLE_CRITERIA = Dict(
		:r2adj => Dict(
			"verbose_title" => "Adjusted R²",
			"verbose_show" => true,
			"index" => 1,
		),
		:bic => Dict(
			"verbose_title" => "BIC",
			"verbose_show" => true,
			"index" => -1,
		),
		:aic => Dict(
			"verbose_title" => "AIC",
			"verbose_show" => true,
			"index" => -1,
		),
		:aicc => Dict(
			"verbose_title" => "AIC Corrected",
			"verbose_show" => true,
			"index" => -1,
		),
		:cp => Dict(
			"verbose_title" => "Mallows's Cp",
			"verbose_show" => true,
			"index" => -1,
		),
		:rmse => Dict(
			"verbose_title" => "RMSE",
			"verbose_show" => true,
			"index" => -1,
		),
		:rmseout => Dict(
			"verbose_title" => "RMSE OUT",
			"verbose_show" => true,
			"index" => -1,
		),
		:sse => Dict(
			"verbose_title" => "SSE",
			"verbose_show" => true,
			"index" => -1,
		),
	)
	include("gsreg_result.jl")
	include("strings.jl")
	include("utils.jl")
	include("interface.jl")
	include("core.jl")
	export gsreg, export_csv, to_string
end
