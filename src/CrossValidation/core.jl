abstract type CrossValGenerator end

struct LOOCV <: CrossValGenerator
    n::Int
end

length(c::LOOCV) = c.n

function iterate(c::LOOCV, s::Int=1)
    (s > c.n) && return nothing
    return (leave_one_out(c.n, s), s + 1)
end

function leave_one_out(n::Int, i::Int)
    @assert 1 <= i <= n
    x = Array{Int}(undef, n - 1)
    for j = 1:i-1
        x[j] = j
    end
    for j = i+1:n
        x[j-1] = j
    end
    return x
end

function split_database(database::Array{Int,1}, k::Int)
    n = size(database, 1)
    [database[(i-1)*(ceil(Int,n/k))+1:min(i*(ceil(Int,n/k)),n)] for i in 1:k]
end

function kfoldcrossvalidation!(
    previousresult::GlobalSearchRegression.GSRegData,
    data::GlobalSearchRegression.GSRegData,
    k::Int,
    s::Float64)
    kfoldcrossvalidation(previousresult, data, k, s)
end


function kfoldcrossvalidation(
    previousresult::GlobalSearchRegression.GSRegData,
    data::GlobalSearchRegression.GSRegData,
    k::Int,
    s::Float64)

    #db = randperm(data.nobs)
    db = collect(1:data.nobs)
    folds = split_database(db, k)

    # if data.time != nothing
    #     if data.panel != nothing
    #         # time & panel -> vemos que pasa acá
    #         folds = []
    #     else
    #         # time -> divisiones sin permutación
    #         folds = []
    #     end
    # else
    #     folds = []
    # end

    bestmodels = []
    
    for obs in LOOCV(k)
        dataset = collect(Iterators.flatten(folds[obs]))
        testset = setdiff(1:data.nobs, dataset)

        reduced = GlobalSearchRegression.copy_data(data)
        reduced.depvar_data = data.depvar_data[dataset]
        reduced.expvars_data = data.expvars_data[dataset, :]

        if reduced.time != nothing
            reduced.time_data = data.time_data[dataset]
        end
        
        if reduced.panel != nothing
            reduced.panel_data = data.panel_data[dataset]
        end

        reduced.nobs = size(dataset, 1)
        _, vars = GlobalSearchRegression.PreliminarySelection.lasso!(reduced, addextrasflag=false)

        backup = GlobalSearchRegression.copy_data(data)
        backup.expvars = data.expvars[vars]
        backup.expvars_data = data.expvars_data[:,vars]
        
        GlobalSearchRegression.AllSubsetRegression.ols!(backup,
            outsample = testset,
            criteria = [ :rmseout ],
            ttest = previousresult.results[1].ttest,
            residualtest = previousresult.results[1].residualtest
        )
        
        push!(bestmodels, Dict(
            :data => backup.results[1].bestresult_data,
            :datanames => backup.results[1].datanames
        ))
    end

    datanames = unique(Iterators.flatten(model[:datanames] for model in bestmodels))

    data = Array{Any,2}(zeros(size(bestmodels,1), size(datanames,1)))

    for (i, model) in enumerate(bestmodels)
        for (f, col) in enumerate(model[:datanames])
            pos = GlobalSearchRegression.get_column_index(col, datanames)
            data[i, pos] = model[:data][f]
        end
    end

    replace!(data, NaN => 0)

    average_data = mean(data, dims=1)
    median_data = median(data, dims=1)

    result = CrossValidationResult(k, 0, previousresult.results[1].ttest, datanames, average_data, median_data, data)

    previousresult = GlobalSearchRegression.addresult!(previousresult, result)

    addextras(previousresult, result)

    return previousresult
end

function to_string(data::GlobalSearchRegression.GSRegData, result::CrossValidationResult)
    datanames_index = GlobalSearchRegression.create_datanames_index(result.datanames)

    out = ""
    out *= @sprintf("\n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                       Cross validation average results                       \n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf("                                     Dependent variable: %s                   \n", data.depvar)
    out *= @sprintf("                                     ─────────────────────────────────────────\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf(" Selected covariates                 Coef.")
    if result.ttest
        out *= @sprintf("        Std.         t-test")
    end
    out *= @sprintf("\n")
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")

    for varname in data.expvars
        if Symbol(string(varname, "_b")) in keys(datanames_index)
            out *= @sprintf(" %-35s", varname)
            out *= @sprintf(" %-10f", result.average_data[datanames_index[Symbol(string(varname, "_b"))]])
            if result.ttest
                out *= @sprintf("   %-10f", result.average_data[datanames_index[Symbol(string(varname, "_bstd"))]])
                out *= @sprintf("   %-10f", result.average_data[datanames_index[Symbol(string(varname, "_t"))]])
            end
            out *= @sprintf("\n")
        end
    end

    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    out *= @sprintf(" Observations                        %-10d\n", result.average_data[datanames_index[:nobs]])
    out *= @sprintf(" RMSE OUT                            %-10f\n", result.average_data[datanames_index[:rmseout]])
    
    out *= @sprintf("\n")
    out *= @sprintf("\n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                       Cross validation median results                        \n")
    out *= @sprintf("══════════════════════════════════════════════════════════════════════════════\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf("                                     Dependent variable: %s                   \n", data.depvar)
    out *= @sprintf("                                     ─────────────────────────────────────────\n")
    out *= @sprintf("                                                                              \n")
    out *= @sprintf(" Covariates                          Coef.")
    if result.ttest
        out *= @sprintf("        Std.         t-test")
    end
    out *= @sprintf("\n")
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")

    for varname in data.expvars
        if Symbol(string(varname, "_b")) in keys(datanames_index)
            out *= @sprintf(" %-35s", varname)
            out *= @sprintf(" %-10f", result.median_data[datanames_index[Symbol(string(varname, "_b"))]])
            if result.ttest
                out *= @sprintf("   %-10f", result.median_data[datanames_index[Symbol(string(varname, "_bstd"))]])
                out *= @sprintf("   %-10f", result.median_data[datanames_index[Symbol(string(varname, "_t"))]])
            end
            out *= @sprintf("\n")
        end
    end

    out *= @sprintf("\n")
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    out *= @sprintf(" Observations                        %-10d\n", result.median_data[datanames_index[:nobs]])
    out *= @sprintf(" RMSE OUT                            %-10f\n", result.median_data[datanames_index[:rmseout]])
    out *= @sprintf("──────────────────────────────────────────────────────────────────────────────\n")
    
    return out
end
