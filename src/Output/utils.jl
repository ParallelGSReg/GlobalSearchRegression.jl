"""
Add values to extras
"""
function addextras(data, outputtype, filename, path)
    data.extras[GlobalSearchRegression.generate_extra_key(OUTPUT_EXTRAKEY, data.extras)] = Dict(
        :outputtype => outputtype,
        :filename => filename,
        :path => path
    )
    return data
end