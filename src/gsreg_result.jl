type GSRegResult
    depvar::Symbol          # Dependant variable names
    expvars::Array{Symbol}  # Explanatory variables names
    data                    # Actual data
    intercept               # Include or not the constant
    outsample               # Amount of rows (observations) that will be use as outsample
    samesample              # Each combination uses the same sample
    criteria                # Ordering criteria (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    ttest::Bool             # Calculate or not the ttest
    vectoroperation         # Calculate using vector operations
    results                 # Results array
    datanames               # Original CSV header names
    datatype                # Float32 or Float64 precision
    nobs                    # Number of observations
    header                  # Header Symbos and positions

    function GSRegResult(
            depvar::Symbol,
            expvars::Array{Symbol},
            data,
            intercept::Bool,
            outsample::Int,
            samesample::Bool,
            criteria,
            ttest,
            vectoroperation,
            datanames,
            datatype
        )
        if :r2adj ∉ criteria
            push!(criteria, :r2adj)
        end
        nobs = size(data, 1)

        if intercept
            data = Array{datatype}(hcat(data, ones(nobs)))
            push!(expvars, :_cons)
            push!(datanames, :_cons)
        end

        header = get_result_header(expvars, intercept, ttest, criteria)
        new(depvar, expvars, data, intercept, outsample, samesample, criteria, ttest, vectoroperation, nothing, datanames, datatype, nobs, header)
    end
end