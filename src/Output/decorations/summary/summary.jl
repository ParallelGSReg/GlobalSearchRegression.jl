function summary(data::GlobalSearchRegression.GSRegData, filename::String; resultnum::Int64=1)
    summary(data, filename=filename, resultnum=resultnum)
end

function summary(data::GlobalSearchRegression.GSRegData; filename::Union{Nothing, String}=nothing, resultnum::Int64=1)
    if size(data.results, 1) > 0
        summary(data, data.results[resultnum], filename=filename)
    end
    return Base.show(data)
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult, filename::String)
    summary(data, result, filename=filename)
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult; filename::Union{Nothing, String}=nothing)
    sum = GlobalSearchRegression.AllSubsetRegression.to_string(data, result)
    if filename != nothing
        file = open(filename, "w")
        write(file, sum)
        close(file)
    else
        println(sum)
    end
end
