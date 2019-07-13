mutable struct GSRegResult
    datanames               # Result variable names
    data                    # Results array
    outsample               # Amount of rows (observations) that will be use as outsample
    criteria                # Ordering criteria (r2adj, caic, aic, bic, cp, rmsein, rmseout)
    ttest
    modelavg                # Generate model averaging report
    residualtest            # Estimate white noise residual tests
    orderresults            # Order or not the results
    bestresult_data         # Best result
    modelavg_datanames      
    modelavg_data           # Model averaging array data
    nobs                    # Number of observations

    function GSRegResult(
            datanames,
            outsample,
            criteria,
            ttest,
            modelavg,
            residualtest,
            orderresults
        )

        if :r2adj ∉ criteria
            push!(criteria, :r2adj)
        end

        if :rmseout ∉ criteria && outsample != OUTSAMPLE_DEFAULT
            push!(criteria, :rmseout)
        end
        
        new(datanames, nothing, outsample, criteria, ttest, modelavg, residualtest, orderresults)
    end
end
