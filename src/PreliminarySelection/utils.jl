"""
Add values to extras
"""
function addextras(data)
    data.extras[GlobalSearchRegression.generate_extra_key(PRELIMINARYSELECTION_EXTRAKEY, data.extras)] = Dict(
        :enabled => true
    )
    return data
end
