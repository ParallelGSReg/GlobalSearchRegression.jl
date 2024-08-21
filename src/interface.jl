function gsreg(
    equation::Union{String, Vector{String}, Vector{Symbol}}, 
	data::Union{DataFrames.DataFrame, Array, Tuple, Matrix, Array{Union{Float64,Missing}}, Array{Union{Float32,Missing}}, Array{Union{Float16,Missing}}, Nothing};
    datanames::Union{Nothing, Vector{String}, Vector{Symbol}} = nothing,
    intercept::Union{Nothing, Bool} = INTERCEPT_DEFAULT,
    outsample::Union{Nothing, Int} = OUTSAMPLE_DEFAULT,
    criteria::Union{Nothing, Symbol, Vector{Symbol}} = CRITERIA_DEFAULT,
    ttest::Union{Nothing, Bool} = TTEST_DEFAULT,
    method::Union{Nothing, String} = METHOD_DEFAULT,
    estimator::Union{Nothing, String} = ESTIMATOR_DEFAULT,
    modelavg::Union{Nothing, Bool} = MODEL_AVG_DEFAULT,
    residualtests::Union{Nothing, Bool} = RESIDUAL_TEST_DEFAULT,
    time::Union{Nothing, Symbol, String} = TIME_DEFAULT,
    panel_id::Union{Nothing, Symbol, String} = PANEL_ID_DEFAULT,
    summary::Union{Nothing, String} = SUMMARY_DEFAULT,
    resultscsv::Union{Nothing, String} = RESULTSCSV_DEFAULT,
    orderresults::Union{Nothing, Bool} = ORDER_RESULTS_DEFAULT,
    onmessage::Union{Nothing, Function} = ON_MESSAGE_DEFAULT,
    parallel::Union{Nothing, Int} = PARALLEL_DEFAULT,
    paneltests::Union{Nothing, Bool} = PANEL_TESTS_DEFAULT,
    fixedvars::Union{Nothing, Symbol, Vector{Symbol}} = FIXED_VARIABLES_DEFAULT,
    vce::Union{Nothing, String} = VCE_DEFAULT,
)
    if isa(equation, String)
        equation = equation_str_to_strarr(equation)
    end
    if isa(equation, Vector{String})
        datanames = get_datanames(data, datanames)
        equation = equation_strarr_to_symarr(equation, datanames)
        if isempty(equation)
            error(VARIABLES_NOT_VALID_OR_NOT_DEFINED)
        end
    end
    depvar = equation[1]
    expvars = equation[2:end]
	if isa(data, Tuple)
		data, datanames = data
		datanames = datanames_strarr_to_symarr!(datanames)
	end
    datanames = datanames_strarr_to_symarr!(datanames)
    if fixedvars !== nothing
        if isa(fixedvars, Symbol)
            fixedvars = [fixedvars]
        end
    end
    validate_parameters(estimator, equation, panel_id, data, datanames, time, criteria, outsample, parallel, paneltests, expvars, fixedvars, vce)
    data, datadiff, panel_id_column, panel_id_columndiff, id_count, SSB, in_sample_mask, in_sample_maskdiff, unique_ids, unique_times, time_column, fixedvars_colnum = preprocess_data(data, depvar, expvars, datanames, time, panel_id, paneltests, outsample, residualtests, fixedvars)
    finalize_data(data, equation, datanames, expvars)
    criteria = select_criteria(criteria, outsample)
    datatype = select_datatype(method)
    if !isa(data, Array{datatype})
        data = convert(Array{datatype}, data)
        if residualtests !== nothing && residualtests && panel_id !== nothing && !isa(datadiff, Array{datatype})
            datadiff = convert(Array{datatype}, datadiff)
        end
    end
    bestmodelindex =  0
    result = gsreg(
        depvar,
        expvars,
        data;
        intercept=intercept,
        outsample=outsample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        estimator=estimator,
        modelavg=modelavg,
        residualtests=residualtests,
        time=time,
        panel_id=panel_id,
		summary=summary,
        datanames=datanames,
        datatype=datatype,
        orderresults=orderresults,
        onmessage=onmessage,
        parallel=parallel,
        paneltests=paneltests,
        id_count=id_count,
        SSB=SSB,
        bestmodelindex=bestmodelindex,
        panel_id_column=panel_id_column,
        datadiff=datadiff,
        panel_id_columndiff=panel_id_columndiff,
        in_sample_mask=in_sample_mask,
        in_sample_maskdiff=in_sample_maskdiff,
        unique_ids=unique_ids,
        unique_times=unique_times,
        time_column=time_column,
        fixedvars=fixedvars,
        fixedvars_colnum=fixedvars_colnum,
        vce=vce,
    )
    if resultscsv !== nothing
        export_csv(resultscsv, result)
    end
    return result
end
