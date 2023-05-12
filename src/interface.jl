function gsreg(
	equation::String;
	data::Union{DataFrames.DataFrame, Array, Tuple, Nothing} = nothing,
	datanames::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
	intercept::Union{Nothing, Bool} = INTERCEPT_DEFAULT,
	outsample::Union{Nothing, Int64} = OUTSAMPLE_DEFAULT,
	criteria = CRITERIA_DEFAULT,
	ttest::Union{Nothing, Bool} = TTEST_DEFAULT,
	method::Union{Nothing, String} = METHOD_DEFAULT,
	vectoroperation::Union{Nothing, Bool} = VECTOR_OPERATION_DEFAULT,
	modelavg::Union{Nothing, Bool} = MODEL_AVG_DEFAULT,
	residualtest = RESIDUAL_TEST_DEFAULT,
	time::Union{Nothing, Symbol, String} = TIME_DEFAULT,
	summary = SUMMARY_DEFAULT,
	csv = CSV_DEFAULT,
	resultscsv = CSV_DEFAULT,
	orderresults::Union{Nothing, Bool} = ORDER_RESULTS_DEFAULT,
	onmessage = ON_MESSAGE_DEFAULT,
	parallel = PARALLEL_DEFAULT,
)
	return gsreg(
		equation,
		data,
		datanames = datanames,
		intercept = intercept,
		outsample = outsample,
		criteria = criteria,
		ttest = ttest,
		method = method,
		vectoroperation = vectoroperation,
		modelavg = modelavg,
		residualtest = residualtest,
		time = time,
		summary = summary,
		resultscsv = resultscsv,
		csv = csv,
		orderresults = orderresults,
		onmessage = onmessage,
		parallel = parallel,
	)
end

function gsreg(
	equation::String,
	data::Union{DataFrames.DataFrame, Array, Tuple};
	datanames::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
	intercept::Union{Nothing, Bool} = INTERCEPT_DEFAULT,
	outsample::Union{Nothing, Int64} = OUTSAMPLE_DEFAULT,
	criteria = CRITERIA_DEFAULT,
	ttest::Union{Nothing, Bool} = TTEST_DEFAULT,
	method::Union{Nothing, String} = METHOD_DEFAULT,
	vectoroperation::Union{Nothing, Bool} = VECTOR_OPERATION_DEFAULT,
	modelavg::Union{Nothing, Bool} = MODEL_AVG_DEFAULT,
	residualtest = RESIDUAL_TEST_DEFAULT,
	time::Union{Nothing, Symbol, String} = TIME_DEFAULT,
	summary = SUMMARY_DEFAULT,
	csv = CSV_DEFAULT,
	resultscsv = CSV_DEFAULT,
	orderresults::Union{Nothing, Bool} = ORDER_RESULTS_DEFAULT,
	onmessage = ON_MESSAGE_DEFAULT,
	parallel = PARALLEL_DEFAULT,
)
	equation = equation_str_to_strarr(equation)
	return gsreg(
		equation,
		data,
		datanames = datanames,
		intercept = intercept,
		outsample = outsample,
		criteria = criteria,
		ttest = ttest,
		method = method,
		vectoroperation = vectoroperation,
		modelavg = modelavg,
		residualtest = residualtest,
		time = time,
		summary = summary,
		resultscsv = resultscsv,
		csv = csv,
		orderresults = orderresults,
		onmessage = onmessage,
		parallel = parallel,
	)
end

function gsreg(
	equation::Vector{String},
	data::Union{DataFrames.DataFrame, Array, Tuple};
	datanames::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
	intercept::Union{Nothing, Bool} = INTERCEPT_DEFAULT,
	outsample::Union{Nothing, Int64} = OUTSAMPLE_DEFAULT,
	criteria = CRITERIA_DEFAULT,
	ttest::Union{Nothing, Bool} = TTEST_DEFAULT,
	method::Union{Nothing, String} = METHOD_DEFAULT,
	vectoroperation::Union{Nothing, Bool} = VECTOR_OPERATION_DEFAULT,
	modelavg::Union{Nothing, Bool} = MODEL_AVG_DEFAULT,
	residualtest = RESIDUAL_TEST_DEFAULT,
	time::Union{Nothing, Symbol, String} = TIME_DEFAULT,
	summary = SUMMARY_DEFAULT,
	csv = CSV_DEFAULT,
	resultscsv = CSV_DEFAULT,
	orderresults::Union{Nothing, Bool} = ORDER_RESULTS_DEFAULT,
	onmessage = ON_MESSAGE_DEFAULT,
	parallel = PARALLEL_DEFAULT,
)
	datanames = get_datanames(data, datanames)
	equation = equation_strarr_to_symarr(equation, datanames)
	if isempty(equation)
		error(VARIABLES_NOT_OR_VALID_OR_NOT_DEFINED)
	end
	return gsreg(
		equation,
		data,
		datanames = datanames,
		intercept = intercept,
		outsample = outsample,
		criteria = criteria,
		ttest = ttest,
		method = method,
		vectoroperation = vectoroperation,
		modelavg = modelavg,
		residualtest = residualtest,
		time = time,
		summary = summary,
		resultscsv = resultscsv,
		csv = csv,
		orderresults = orderresults,
		onmessage = onmessage,
        parallel = parallel,
	)
end

function gsreg(
	equation::Vector{Symbol},
	data::Union{DataFrames.DataFrame, Array, Tuple};
	datanames::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
	intercept::Union{Nothing, Bool} = INTERCEPT_DEFAULT,
	outsample::Union{Nothing, Int64} = OUTSAMPLE_DEFAULT,
	criteria = CRITERIA_DEFAULT,
	ttest::Union{Nothing, Bool} = TTEST_DEFAULT,
	method::Union{Nothing, String} = METHOD_DEFAULT,
	vectoroperation::Union{Nothing, Bool} = VECTOR_OPERATION_DEFAULT,
	modelavg::Union{Nothing, Bool} = MODEL_AVG_DEFAULT,
	residualtest = RESIDUAL_TEST_DEFAULT,
	time::Union{Nothing, Symbol, String} = TIME_DEFAULT,
	summary = SUMMARY_DEFAULT,
	csv = CSV_DEFAULT,
	resultscsv = CSV_DEFAULT,
	orderresults::Union{Nothing, Bool} = ORDER_RESULTS_DEFAULT,
	onmessage = ON_MESSAGE_DEFAULT,
	parallel = PARALLEL_DEFAULT,
)
	datanames = datanames_strarr_to_symarr!(datanames)
	depvar = equation[1]
	expvars = equation[2:end]
	data = convert_if_is_tuple_to_array(data)
	if time !== nothing
		time = Symbol(time)
        if time ∉ datanames
            error(TIME_VARIABLE_INEXISTENT)
        end
		data = sort_data_by_time(data, time, datanames)
	end
	data = filter_data_valid_columns(data, depvar, expvars, datanames)
	data = filter_rows_with_empty_values(data)
	data = convert_if_is_dataframe_to_array(data)
	return gsreg(
		equation,
		data,
		datanames;
		intercept = intercept,
		outsample = outsample,
		criteria = criteria,
		ttest = ttest,
		method = method,
		vectoroperation = vectoroperation,
		modelavg = modelavg,
		residualtest = residualtest,
		time = time,
		summary = summary,
		csv = csv,
		resultscsv = resultscsv,
		orderresults = orderresults,
		onmessage = onmessage,
		parallel = parallel,
	)
end

function gsreg(
	equation::Vector{Symbol},
	data::Matrix,
	datanames::Vector{Symbol};
	intercept::Union{Nothing, Bool} = INTERCEPT_DEFAULT,
	outsample::Union{Nothing, Int64} = OUTSAMPLE_DEFAULT,
	criteria = CRITERIA_DEFAULT,
	ttest::Union{Nothing, Bool} = TTEST_DEFAULT,
	method::Union{Nothing, String} = METHOD_DEFAULT,
	vectoroperation::Union{Nothing, Bool} = VECTOR_OPERATION_DEFAULT,
	modelavg::Union{Nothing, Bool} = MODEL_AVG_DEFAULT,
	residualtest = RESIDUAL_TEST_DEFAULT,
	time::Union{Nothing, Symbol} = TIME_DEFAULT,
	summary = SUMMARY_DEFAULT,
	csv = CSV_DEFAULT,
	resultscsv = CSV_DEFAULT,
	orderresults::Union{Nothing, Bool} = ORDER_RESULTS_DEFAULT,
	onmessage = ON_MESSAGE_DEFAULT,
	parallel = PARALLEL_DEFAULT,
)
	if method == PRECISE
		datatype = Float64
	elseif method == STANDARD
		datatype = Float32
	elseif method == FAST
		datatype = Float16
	else
		error(METHOD_INVALID)
	end

	if !isa(data, Array{datatype})
		data = convert(Array{datatype}, data)
	end

	if outsample != OUTSAMPLE_DEFAULT
		if outsample < 0
			error(OUTSAMPLE_LOWER_VALUE)
		elseif size(data, 1) - outsample < INSAMPLE_MIN_SIZE + size(data, 2) - 1
			error(OUTSAMPLE_HIGHER_VALUE)
		end
	end

	if outsample == false && :rmseout in criteria
		error(OUTSAMPLE_MISMATCH)
	end

	if criteria == CRITERIA_DEFAULT
		if outsample != OUTSAMPLE_DEFAULT
			criteria = CRITERIA_DEFAULT_OUTSAMPLE
		else
			criteria = CRITERIA_DEFAULT_INSAMPLE
		end
	end

	if time !== nothing && time ∉ datanames
		error(TIME_VARIABLE_INEXISTENT)
	end

	if resultscsv != csv
		if resultscsv != CSV_DEFAULT && csv != CSV_DEFAULT
			error(CSV_DUPLICATED_PARAMETERS)
		elseif csv != CSV_DEFAULT
			resultscsv = csv
		end
	end

	# TODO: Is this been used?
	if parallel !== nothing
		if parallel > nworkers()
			error("Number of parallel workers can not exceed available cores. Use addprocs()")
		end

		if parallel < 1
			error("Number of workers can not be less than 1")
		end
	end

	if size(data, 1) < size(equation[2:end], 1) + 1
		error(NO_ENOUGH_OBSERVATIONS)
	end

	if !in_vector(equation, datanames)
		error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
	end

	depvar = equation[1]
	expvars = equation[2:end]
	expvars_data = data[1:end, 2:end]
	corrmatrix = cor(expvars_data)
	s = size(corrmatrix, 1)
	corrminusiden = corrmatrix - Matrix{Float64}(I, s, s)
	maxcorr = maximum(corrminusiden)
	if maxcorr > 0.999
		error(NON_LINEARLY_INDEPENDENT_EXPVARS)
	end

	result = gsreg(
		depvar,
		expvars,
		data,
		datanames = datanames,
		intercept = intercept,
		outsample = outsample,
		criteria = criteria,
		ttest = ttest,
		method = method,
		vectoroperation = vectoroperation,
		modelavg = modelavg,
		residualtest = residualtest,
		time = time,
		summary = summary,
		datatype = datatype,
		orderresults = orderresults,
		onmessage = onmessage,
		parallel = parallel,
	)
	if resultscsv !== nothing
		export_csv(resultscsv, result)
	end
	return result
end
