function summary(data::GlobalSearchRegression.GSRegData, filename::String; resultnum::Union{Nothing, Int}=nothing)
    return summary(data, filename=filename, resultnum=resultnum)
end

function summary(data::GlobalSearchRegression.GSRegData; filename::Union{Nothing, String}=nothing, resultnum::Union{Nothing, Int}=nothing)
    addextras(data, :summary, filename, nothing)
    if size(data.results, 1) > 0
        if resultnum != nothing
            return summary(data, data.results[resultnum], filename=filename)
        else
            str = ""
            for i in 1:size(data.results, 1)
                str = string(str, summary(data, data.results[i]))
            end
            writefile(str, filename)
            return str
        end
    end
    return ""
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult, filename::String)
    return summary(data, result, filename=filename)
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.AllSubsetRegression.AllSubsetRegressionResult; filename::Union{Nothing, String}=nothing)
    str = GlobalSearchRegression.AllSubsetRegression.to_string(data, result)
    writefile(str, filename)
    return str
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult, filename::String)
    return summary(data, result, filename=filename)
end

function summary(data::GlobalSearchRegression.GSRegData, result::GlobalSearchRegression.CrossValidation.CrossValidationResult; filename::Union{Nothing, String}=nothing)
    str = GlobalSearchRegression.CrossValidation.to_string(data, result)
    writefile(str, filename)
    return str
end

function writefile(str, filename=nothing)
    if filename != nothing
        file = open(filename, "w")
        write(file, sum)
        close(file)
    end
end

