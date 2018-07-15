function gsreg(
        equation::String;
        data::DataFrame=nothing,
        intercept::Bool=INTERCEPT_DEFAULT,
        outsample::Int=OUTSAMPLE_DEFAULT,
        samesample::Bool=SAMESAMPLE_DEFAULT,
        criteria=CRITERIA_DEFAULT,
        ttest=TTEST_DEFAULT,
        method=METHOD_DEFAULT,
        vectoroperation=VECTOR_OPERATION_DEFAULT,
        modelavg=MODEL_AVG_DEFAULT,
        residualtest=RESIDUAL_TEST_DEFAULT,
        keepwnoise=KEEP_WHITE_NOISE_DEFAULT,
        time=TIME_DEFAULT,
        summary=SUMMARY_DEFAULT,
        csv=CSV_DEFAULT,
        resultscsv=CSV_DEFAULT,
        orderresults=ORDER_RESULTS_DEFAULT
    )
    return gsreg(
            equation,
            data,
            intercept=intercept,
            outsample=outsample,
            samesample=samesample,
            criteria=criteria,
            ttest=ttest,
            method=method,
            vectoroperation=vectoroperation,
            modelavg=modelavg,
            residualtest=residualtest,
            keepwnoise=keepwnoise,
            time=time,
            summary=summary,
            resultscsv=resultscsv,
            csv=csv,
            orderresults=orderresults
        )
end

function gsreg(
        equation::String,
        data::DataFrame;
        intercept::Bool=INTERCEPT_DEFAULT,
        outsample::Int=OUTSAMPLE_DEFAULT,
        samesample::Bool=SAMESAMPLE_DEFAULT,
        criteria=CRITERIA_DEFAULT,
        ttest=TTEST_DEFAULT,
        method=METHOD_DEFAULT,
        vectoroperation=VECTOR_OPERATION_DEFAULT,
        modelavg=MODEL_AVG_DEFAULT,
        residualtest=RESIDUAL_TEST_DEFAULT,
        keepwnoise=KEEP_WHITE_NOISE_DEFAULT,
        time=TIME_DEFAULT,
        summary=SUMMARY_DEFAULT,
        resultscsv=CSV_DEFAULT,
        csv=CSV_DEFAULT,
        orderresults=ORDER_RESULTS_DEFAULT
    )
    
    if contains(equation, "~")
        equation = replace(equation, r"\s+|\s+$/g", "")
        dep_indep = split(equation, "~")
        equation = [String(ss) for ss in vcat(dep_indep[1], split(dep_indep[2], "+"))]
    else
        equation = [String(ss) for ss in split(replace(equation, r"\s+|\s+$/g", ","), ",")]
    end

    return gsreg(
        equation,
        data,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        keepwnoise=keepwnoise,
        time=time,
        summary=summary,
        resultscsv=resultscsv,
        csv=csv,
        orderresults=orderresults
    )
end

function gsreg(
        equation::Array{String},
        data::DataFrame;
        intercept::Bool=INTERCEPT_DEFAULT,
        outsample::Int=OUTSAMPLE_DEFAULT,
        samesample::Bool=SAMESAMPLE_DEFAULT,
        criteria=CRITERIA_DEFAULT,
        ttest=TTEST_DEFAULT,
        method=METHOD_DEFAULT,
        vectoroperation=VECTOR_OPERATION_DEFAULT,
        modelavg=MODEL_AVG_DEFAULT,
        residualtest=RESIDUAL_TEST_DEFAULT,
        keepwnoise=KEEP_WHITE_NOISE_DEFAULT,
        time=TIME_DEFAULT,
        summary=SUMMARY_DEFAULT,
        resultscsv=CSV_DEFAULT,
        csv=CSV_DEFAULT,
        orderresults=ORDER_RESULTS_DEFAULT
    )

    keys = names(data)
    n_equation = []
    for e in equation
        replace("*", ".", e)
        if e[end] == '*'
            append!(n_equation, filter!(x->x!=nothing, [String(key)[1:length(e[1:end-1])] == e[1:end-1]?String(key):nothing for key in keys]))
        else
            append!(n_equation, [e])
        end
    end

    return gsreg(
        map(Symbol, unique(n_equation)),
        data,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        method=method,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        keepwnoise=keepwnoise,
        time=time,
        summary=summary,
        resultscsv=resultscsv,
        csv=csv,
        orderresults=orderresults
    )
end

function gsreg(
        equation::Array{Symbol},
        data::DataFrame;
        intercept::Bool=INTERCEPT_DEFAULT,
        outsample::Int=OUTSAMPLE_DEFAULT,
        samesample::Bool=SAMESAMPLE_DEFAULT,
        criteria=CRITERIA_DEFAULT,
        ttest=TTEST_DEFAULT,
        method=METHOD_DEFAULT,
        vectoroperation=VECTOR_OPERATION_DEFAULT,
        modelavg=MODEL_AVG_DEFAULT,
        residualtest=RESIDUAL_TEST_DEFAULT,
        keepwnoise=KEEP_WHITE_NOISE_DEFAULT,
        time=TIME_DEFAULT,
        summary=SUMMARY_DEFAULT,
        resultscsv=CSV_DEFAULT,
        csv=CSV_DEFAULT,
        orderresults=ORDER_RESULTS_DEFAULT
    )

    if method == "fast"
        for c = eachcol(data)
            data[c[1]] = map(Float32,c[2])
        end
        datatype = Float32
    elseif method == "precise"
        datatype = Float64
    else
        error(METHOD_INVALID)
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

    if keepwnoise == true && residualtest == false
        error(RESIDUALTEST_EXCEPTION)
    end

    if keepwnoise
        residualtest = true
    end

    if time != nothing && time ∉ names(data)
        error(TIME_VARIABLE_INEXISTENT)
    end

    #if residualtest == true &&

    if criteria == CRITERIA_DEFAULT
        if outsample != OUTSAMPLE_DEFAULT
            criteria = CRITERIA_DEFAULT_OUTSAMPLE
        else
            criteria = CRITERIA_DEFAULT_INSAMPLE
        end
    end

    if resultscsv != csv
        if resultscsv != CSV_DEFAULT && csv != CSV_DEFAULT
            error(CSV_DUPLICATED_PARAMETERS)
        elseif csv != CSV_DEFAULT
            resultscsv = csv
        end
    end

    if size(data, 1) < size(equation[2:end], 1) + 1
        error(NO_ENOUGH_OBSERVATIONS)
    end

    if !in_vector(equation, names(data))
        error(SELECTED_VARIABLES_DOES_NOT_EXISTS)
    end

    if time != nothing
        sort!(data, time)
    end

    data = data[equation]
    datanames = names(data)
    data = convert(Array{datatype}, data)
    result = gsreg(
        equation[1],
        equation[2:end],
        data,
        intercept=intercept,
        outsample=outsample,
        samesample=samesample,
        criteria=criteria,
        ttest=ttest,
        vectoroperation=vectoroperation,
        modelavg=modelavg,
        residualtest=residualtest,
        keepwnoise=keepwnoise,
        time=time,
        summary=summary,
        datanames=datanames,
        datatype=datatype,
        orderresults=orderresults
    )
    if resultscsv != nothing
        export_csv(resultscsv, result)
    end
    return result
end
