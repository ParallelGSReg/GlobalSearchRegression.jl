mutable struct GSRegResult
    depvar                 # Dependant variable names
    expvars                # Explanatory variables names
    data                   # Actual data
    intercept              # Include or not the constant
    outsample              # Amount of rows (observations) that will be use as outsample
    criteria               # Ordering criteria (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    ttest                  # Calculate or not the ttest
    method                 # Method to use ("svd_64", "svd_32", "svd_16", "qr_64", "qr_32", "qr_16", "cho_64", "cho_32", or "cho_16")
    estimator              # Estimator to use ("ols" or "ols_fe")
    modelavg               # Generate model averaging report
    residualtests          # Estimate white noise residual tests
    time                   # Pre-order data by Symbol
    panel_id               # Panel ID Symbol
    datanames              # Original CSV header names
    datatype               # Float32 or Float64 precision
    nobs                   # Number of observations
    header                 # Header Symbols and positions
    orderresults           # Order or not the results
    onmessage              # handler for feedback messages
    parallel               # Number of workers to use
    paneltests             # Perform ANOVA F-test
    id_count               # Number of unique panel IDs
    SSB                    # Sum of Squares Between
    bestmodelindex         # Best model index         # Time column
    panel_id_column        # Panel ID column
    datadiff               # Data in first differences for panel data tests
    panel_id_columndiff    # Panel ID column for first differences
    in_sample_mask         # In-sample mask
    in_sample_maskdiff     # In-sample mask for first differences
    unique_ids             # Unique IDs
    unique_times           # Unique times
    time_column            # Time column
    fixedvars              # Fixed variables
    fixedvars_colnum       # Fixed variables column
    vce                # Variance-covariance matrix
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
            estimator::String,
            modelavg,
            residualtests,
            time,
            panel_id::Union{Nothing, Symbol},
            datanames,
            datatype,
            orderresults,
            onmessage,
            parallel,
            paneltests::Union{Nothing, Bool},
            id_count::Union{Nothing, Int},
            SSB::Union{Nothing, Float64, Float32, Float16},
            bestmodelindex::Int,
            panel_id_column::Union{Nothing, Array{Int}},
            datadiff::Union{Nothing, Array{Float64, 2}, Array{Float32, 2}, Array{Float16, 2}},
            panel_id_columndiff::Union{Nothing, Array{Int}},
            in_sample_mask::BitVector,
            in_sample_maskdiff::Union{Nothing, BitVector},
            unique_ids::Union{Nothing, Array{Int}},
            unique_times::Union{Nothing, Array{Int}},
            time_column::Union{Nothing, Array{Int}},
            fixedvars::Union{Nothing, Symbol, Array{Symbol}},  
            fixedvars_colnum::Union{Nothing, Array{Int}},
            vce::Union{Nothing, String},
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
            if fixedvars !== nothing
                push!(fixedvars, :_cons)
                fixedvars_colnum = push!(fixedvars_colnum, size(data, 2))
            else 
                fixedvars = [:_cons]
                fixedvars_colnum = [size(data, 2)]
            end
            push!(datanames, :_cons)
        end
        header = get_result_header(expvars, fixedvars, ttest, residualtests, time, criteria, modelavg, paneltests)
        new(depvar, expvars, data, intercept, outsample, criteria, ttest, method, estimator, modelavg, residualtests, time, panel_id, datanames, datatype, nobs, header, orderresults, onmessage, parallel, paneltests, id_count, SSB, bestmodelindex, panel_id_column, datadiff, panel_id_columndiff, in_sample_mask, in_sample_maskdiff, unique_ids, unique_times, time_column, fixedvars, fixedvars_colnum, vce)
    end
end
