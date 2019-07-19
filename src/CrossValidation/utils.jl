"""
Add values to extras
"""
function addextras(data, result)
    data.extras[GlobalSearchRegression.generate_extra_key(CROSSVALIDATION_EXTRAKEY, data.extras)] = Dict(
        :datanames => result.datanames,
        :ttest => result.ttest,
        :kfolds => result.k,
        :tsetsize => result.s,
        :panel => data.panel,
        :time => data.time,
        :median => result.median_data, #TODO: Add expvars
        :average => result.average_data #TODO: Add expvars
    )
    return data
end
