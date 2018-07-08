type GSRegResult
    depvar::Symbol          # Dependant variable names
    expvars::Array{Symbol}  # Explanatory variables names
    data                    # Actual data
    intercept               # Include or not the constant
    outsample               # Amount of rows (observations) that will be use as outsample
    samesample              # Each combination uses the same sample
    criteria                # Ordering criteria (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    ttest::Bool             # Calculate or not the ttest
    results                 # Results array
    nobs                    # Number of observations
    datanames               # Original CSV header names
    datatype                # Float32 or Float64 precision
    header
    function GSRegResult(
            depvar::Symbol,
            expvars::Array{Symbol},
            data,
            intercept::Bool,
            outsample::Int,
            samesample::Bool,
            criteria,
            ttest,
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
        new(depvar, expvars, data, intercept, outsample, samesample, criteria, ttest, nothing, nobs, datanames, datatype, header)
    end
end