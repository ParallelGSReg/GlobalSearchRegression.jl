mutable struct GSRegData
    depvar::Symbol          # Dependent variable names
    expvars::Array{Symbol}  # Explanatory variables names
    depvar_data             # Dependent data
    expvars_data            # Explanatory data
    intercept               # Include or not the constant
    time                    # Pre-order data by Symbol
    datatype                # Float32 or Float64 precision
    nobs                    # Number of observations

    function GSRegData(
            depvar::Symbol,
            expvars::Array{Symbol},
            depvar_data,
            expvars_data,
            intercept::Bool,
            time,
            datatype,
            nobs
        )

        new(depvar, expvars, depvar_data, expvars_data, intercept, time, datatype, nobs)
    end
end
