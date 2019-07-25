"""
Add values to extras
"""
function addextras(data, result)
    data.extras[GlobalSearchRegression.generate_extra_key(CROSSVALIDATION_EXTRAKEY, data.extras)] = Dict(
        :ttest => result.ttest,
        :kfolds => result.k,
        :tsetsize => result.s,
        :panel => data.panel,
        :time => data.time,
        :datanames => result.datanames,
        :median => result.median_data,
        :average => result.average_data
    )
    return data
end
