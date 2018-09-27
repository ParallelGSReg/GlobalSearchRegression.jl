function gsreg(
    equation::String;
    data=nothing,
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    outsample=OUTSAMPLE_DEFAULT,
    samesample=SAMESAMPLE_DEFAULT,
    criteria=CRITERIA_DEFAULT,
    ttest=TTEST_DEFAULT,
    method=METHOD_DEFAULT,
    vectoroperation=VECTOR_OPERATION_DEFAULT,
    modelavg=MODEL_AVG_DEFAULT,
    residualtest=RESIDUAL_TEST_DEFAULT,
    time=TIME_DEFAULT,
    summary=SUMMARY_DEFAULT,
    csv=CSV_DEFAULT,
    resultscsv=CSV_DEFAULT,
    orderresults=ORDER_RESULTS_DEFAULT,
    onmessage=ON_MESSAGE_DEFAULT,
    parallel=PARALLEL_DEFAULT
    )

    return gsreg(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        time=time,
        summary=summary,
        resultscsv=resultscsv,
        csv=csv,
        orderresults=orderresults,
        onmessage=onmessage,
        parallel=parallel
    )
end

function gsreg(
    equation::String,
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    outsample=OUTSAMPLE_DEFAULT,
    samesample=SAMESAMPLE_DEFAULT,
    criteria=CRITERIA_DEFAULT,
    ttest=TTEST_DEFAULT,
    method=METHOD_DEFAULT,
    vectoroperation=VECTOR_OPERATION_DEFAULT,
    modelavg=MODEL_AVG_DEFAULT,
    residualtest=RESIDUAL_TEST_DEFAULT,
    time=TIME_DEFAULT,
    summary=SUMMARY_DEFAULT,
    csv=CSV_DEFAULT,
    resultscsv=CSV_DEFAULT,
    orderresults=ORDER_RESULTS_DEFAULT,
    onmessage=ON_MESSAGE_DEFAULT,
    parallel=PARALLEL_DEFAULT
    )

    equation = equation_str_to_strarr(equation)

    return gsreg(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        time=time,
        summary=summary,
        resultscsv=resultscsv,
        csv=csv,
        orderresults=orderresults,
        onmessage=onmessage,
        parallel=parallel
    )
end

function gsreg(
    equation::Array{String},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    outsample=OUTSAMPLE_DEFAULT,
    samesample=SAMESAMPLE_DEFAULT,
    criteria=CRITERIA_DEFAULT,
    ttest=TTEST_DEFAULT,
    method=METHOD_DEFAULT,
    vectoroperation=VECTOR_OPERATION_DEFAULT,
    modelavg=MODEL_AVG_DEFAULT,
    residualtest=RESIDUAL_TEST_DEFAULT,
    time=TIME_DEFAULT,
    summary=SUMMARY_DEFAULT,
    csv=CSV_DEFAULT,
    resultscsv=CSV_DEFAULT,
    orderresults=ORDER_RESULTS_DEFAULT,
    onmessage=ON_MESSAGE_DEFAULT,
    parallel=PARALLEL_DEFAULT
    )

    equation = equation_strarr_to_symarr(equation, data, datanames)

    if isempty(equation)
        error(VARIABLES_NOT_OR_VALID_OR_NOT_DEFINED)
    end

    return gsreg(
        equation,
        data,
        datanames=datanames,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        time=time,
        summary=summary,
        resultscsv=resultscsv,
        csv=csv,
        orderresults=orderresults,
        onmessage=onmessage,
        parallel=parallel
    )
end

function gsreg(
    equation::Array{Symbol},
    data;
    datanames=nothing,
    intercept=INTERCEPT_DEFAULT,
    outsample=OUTSAMPLE_DEFAULT,
    samesample=SAMESAMPLE_DEFAULT,
    criteria=CRITERIA_DEFAULT,
    ttest=TTEST_DEFAULT,
    method=METHOD_DEFAULT,
    vectoroperation=VECTOR_OPERATION_DEFAULT,
    modelavg=MODEL_AVG_DEFAULT,
    residualtest=RESIDUAL_TEST_DEFAULT,
    time=TIME_DEFAULT,
    summary=SUMMARY_DEFAULT,
    csv=CSV_DEFAULT,
    resultscsv=CSV_DEFAULT,
    orderresults=ORDER_RESULTS_DEFAULT,
    onmessage=ON_MESSAGE_DEFAULT,
    parallel=PARALLEL_DEFAULT
    )

    data = data[equation]
    data, datanames = parse_data(data, datanames)
    datanames = datanames_strarr_to_symarr!(datanames)

    return gsreg(
        equation,
        data,
        datanames;
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        time=time,
        summary=summary,
        resultscsv=resultscsv,
        csv=csv,
        orderresults=orderresults,
        onmessage=onmessage,
        parallel=parallel
    )
end

function gsreg(
    equation::Array{Symbol},
    data,
    datanames::Array;
    intercept=INTERCEPT_DEFAULT,
    outsample=OUTSAMPLE_DEFAULT,
    samesample=SAMESAMPLE_DEFAULT,
    criteria=CRITERIA_DEFAULT,
    ttest=TTEST_DEFAULT,
    method=METHOD_DEFAULT,
    vectoroperation=VECTOR_OPERATION_DEFAULT,
    modelavg=MODEL_AVG_DEFAULT,
    residualtest=RESIDUAL_TEST_DEFAULT,
    time=TIME_DEFAULT,
    summary=SUMMARY_DEFAULT,
    csv=CSV_DEFAULT,
    resultscsv=CSV_DEFAULT,
    orderresults=ORDER_RESULTS_DEFAULT,
    onmessage=ON_MESSAGE_DEFAULT,
    parallel=PARALLEL_DEFAULT
    )

    if method == "precise"
        datatype = Float64
    elseif method == "fast"
        datatype = Float32
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

    if time != nothing && time ∉ datanames
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
    if parallel != nothing
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

    if time != nothing
        pos = findfirst(isequal(time), datanames)
        data = gsregsortrows(data, [pos])
    end

    result = gsreg(
        equation[1],
        equation[2:end],
        data,
        datanames=datanames,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        time=time,
        summary=summary,
        datatype=datatype,
        orderresults=orderresults,
        onmessage=onmessage,
        parallel=parallel
    )
    if resultscsv != nothing
        export_csv(resultscsv, result)
    end
    return result
end
