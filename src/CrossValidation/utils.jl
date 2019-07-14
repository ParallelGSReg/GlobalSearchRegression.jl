"""
Add values to extras
"""
function addextras(data, result)
    data.extras[GlobalSearchRegression.generate_extra_key(CROSSVALIDATION_EXTRAKEY, data.extras)] = Dict(
        :k => result.k,
        :s => result.s,
    )
    return data
end