"""
Add values to extras
"""
function addextras(data, lassonumvars, betas, lambda)
    data.extras[GlobalSearchRegression.generate_extra_key(PRELIMINARYSELECTION_EXTRAKEY, data.extras)] = Dict(
        :preliminaryselection => :lasso,
        :lassonumvars => lassonumvars,
        :lassobetas => betas,
        :lassolambda => lambda,
        :nobs => data.nobs
    )
    return data
end
