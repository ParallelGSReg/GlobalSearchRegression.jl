function summary(data::GlobalSearchRegression.GSRegData, filename::String; resultnum::Int64=nothing)
    return summary(data, filename=filename, resultnum=resultnum)
end

function summary(data::GlobalSearchRegression.GSRegData; filename::Union{Nothing, String}=nothing, resultnum::Int64=nothing)
    if size(data.results, 1) > 0
        if resultnum != nothing
            return summary(data, data.results[resultnum], filename=filename)
        else
            output = []
            for i in size(data.results, 1)
                push!(output, summary(data, data.results[i], filename=filename))
            end
        end
    end
    return ""
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult, filename::String)
    return summary(data, result, filename=filename)
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult; filename::Union{Nothing, String}=nothing)
    sum = GlobalSearchRegression.AllSubsetRegression.to_string(data, result)
    if filename != nothing
        file = open(filename, "w")
        write(file, sum)
        close(file)
    end
    return sum
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult, filename::String)
    return summary(data, result, filename=filename)
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult; filename::Union{Nothing, String}=nothing)
    sum = GlobalSearchRegression.CrossValidation.to_string(data, result)
    if filename != nothing
        file = open(filename, "w")
        write(file, sum)
        close(file)
    end
    return sum
end
