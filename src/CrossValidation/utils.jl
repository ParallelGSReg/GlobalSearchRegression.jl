"""
Add values to extras
"""
function addextras(data, result)
    data.extras[GlobalSearchRegression.generate_extra_key(CROSSVALIDATION_EXTRAKEY, data.extras)] = Dict(
        :datanames => result.datanames,
        :ttest => result.ttest
    )
    return data
end