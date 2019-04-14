mutable struct GSRegData
    depvar::Symbol          # Dependant variable names
    expvars::Array{Symbol}  # Explanatory variables names
    data                    # Actual data
    intercept               # Include or not the constant
    time                    # Pre-order data by Symbol
    datanames               # Header of the data
    datatype                # Float32 or Float64 precision
    nobs                    # Number of observations

    function GSRegData(
            depvar::Symbol,
            expvars::Array{Symbol},
            data,
            intercept::Bool,
            time,
            datanames,
            datatype,
            nobs
        )

        new(depvar, expvars, data, intercept, time, datanames, datatype, nobs)
    end
end
