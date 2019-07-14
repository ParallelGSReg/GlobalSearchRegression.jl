mutable struct AllSubsetRegressionResult <: GlobalSearchRegression.GSRegResult

    datanames
    modelavg_datanames
    
    data
    bestresult_data
    modelavg_data

    fixedvariables
    outsample
    criteria
    modelavg
    ttest
    residualtest
    orderresults
    nobs

    function AllSubsetRegressionResult(
            datanames,
            modelavg_datanames,
            fixedvariables,
            outsample,
            criteria,
            modelavg,
            ttest,
            residualtest,
            orderresults
        )

        new(datanames, modelavg_datanames, nothing, nothing, nothing, fixedvariables, outsample, criteria, modelavg, ttest, residualtest, orderresults, 0)
    end
end
