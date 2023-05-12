mutable struct GSRegResult
    depvar::Symbol         # Dependant variable names
    expvars::Array{Symbol} # Explanatory variables names
    data                   # Actual data
    intercept              # Include or not the constant
    outsample              # Amount of rows (observations) that will be use as outsample
    criteria               # Ordering criteria (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    ttest                  # Calculate or not the ttest
    method                 # Method to use (precise, standard or fast)
    vectoroperation        # Calculate using vector operations
    modelavg               # Generate model averaging report
    residualtest           # Estimate white noise residual tests
    time                   # Pre-order data by Symbol
    datanames              # Original CSV header names
    datatype               # Float32 or Float64 precision
    nobs                   # Number of observations
    header                 # Header Symbols and positions
    orderresults           # Order or not the results
    onmessage              # handler for feedback messages
    parallel               # Number of workers to use
    results                # Results array
    bestresult             # Best result
    average                # Model averaging array data

    function GSRegResult(
            depvar::Symbol,
            expvars::Array{Symbol},
            data,
            intercept::Bool,
            outsample::Int,
            criteria,
            ttest,
            method,
            vectoroperation,
            modelavg,
            residualtest,
            time,
            datanames,
            datatype,
            orderresults,
            onmessage,
            parallel
        )
        if :r2adj ∉ criteria && size(criteria,1 ) == 0
            push!(criteria, :r2adj)
        end

        if :rmseout ∉ criteria && outsample != OUTSAMPLE_DEFAULT
            push!(criteria, :rmseout)
        end

        nobs = size(data, 1)

        if intercept
            data = Array{datatype}(hcat(data, ones(nobs)))
            push!(expvars, :_cons)
            push!(datanames, :_cons)
        end

        header = get_result_header(expvars, intercept, ttest, residualtest, time, criteria, modelavg)
        new(depvar, expvars, data, intercept, outsample, criteria, ttest, method, vectoroperation, modelavg, residualtest, time, datanames, datatype, nobs, header, orderresults, onmessage, parallel)
    end
end
