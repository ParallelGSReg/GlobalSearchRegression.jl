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


function get_array_details(arr)
    dict = Dict(arr)
    Dict(
        ((length(arr) == 1) ? "var" : "vars") => Dict(
            "names" => map(string, collect(keys(dict))),
            "values" => collect(values(dict))
        ),
        ((length(arr) == 1) ? "vars" : "var") => false
    )
end

function get_array_simple_details(arr)
    Dict(
        ((length(arr) == 1) ? "var" : "vars") => Dict(
            "names" => map(string, arr)
        ),
        ((length(arr) == 1) ? "vars" : "var") => false
    )
end