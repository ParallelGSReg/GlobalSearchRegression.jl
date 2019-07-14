function csv(data::GlobalSearchRegression.GSRegData, filename::String; resultnum::Int64=1)
    csv(data, filename=filename, resultnum=resultnum)
end

function csv(data::GlobalSearchRegression.GSRegData; filename::Union{Nothing, String}=nothing, resultnum::Int64=1)
    csv(data, data.results[resultnum], filename=filename)
end

function csv(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult, filename::String)
    csv(data, result, filename=filename)
end

function csv(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult; filename::Union{Nothing, String}=nothing)
    header = []
    for dataname in result.datanames
        push!(header, String(dataname))
    end

    res = vcat(permutedims(header), result.data)
    
    if filename != nothing
        file = open(filename, "w")
        writedlm(file, res, ',')
        close(file)
    else
        for row in eachrow(res)
            print(join(row, ','))
        end
    end
end
