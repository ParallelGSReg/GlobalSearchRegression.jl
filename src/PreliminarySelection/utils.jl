"""
Add values to extras
"""
function addextras(data, lassonumvars)
    data.extras[GlobalSearchRegression.generate_extra_key(PRELIMINARYSELECTION_EXTRAKEY, data.extras)] = Dict(
        :enabled => true,
        :lassonumvars => lassonumvars
    )
    return data
end
