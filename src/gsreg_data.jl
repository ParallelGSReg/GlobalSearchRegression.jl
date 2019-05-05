mutable struct GSRegData
    depvar::Symbol          # Dependent variable names
    expvars::Array{Symbol}  # Explanatory variables names
    depvar_data             # Dependent data
    expvars_data            # Explanatory data
    intercept               # Include or not the constant
    time                    # Pre-order data by Symbol
    panel
    datatype                # Float32 or Float64 precision
    nobs                    # Number of observations
    fe_sqr                  # Square feature extraction
    fe_log                  # Logarithm feature extraction
    fe_inv                  # Inverse feature extraction
    fe_lag                  # Lag feature extraction

    function GSRegData(
            depvar::Symbol,
            expvars::Array{Symbol},
            depvar_data,
            expvars_data,
            intercept::Bool,
            time,
            panel,
            datatype,
            nobs,
            fe_sqr,
            fe_log,
            fe_inv,
            fe_lag
        )

        new(depvar, expvars, depvar_data, expvars_data, intercept, time, panel, datatype, nobs, fe_sqr, fe_log, fe_inv, fe_lag)
    end
end
