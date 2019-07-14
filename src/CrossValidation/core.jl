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

    db = randperm(data.nobs)
    #db = collect(1:data.nobs)
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
        reduced.nobs = size(dataset, 1)
        _, vars = GlobalSearchRegression.PreliminarySelection.lasso!(reduced)
        
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

    commonvars = []

    @show bestmodels
    for model in bestmodels
        #append!(commonvars, model[:data][GlobalSearchRegression.get_column_index(:rmsout, model[:datanames])])
    end
    

    # mean
    # median

    # commonvars: preguntar en previousresult los params enviados y:
    #     por var: _b _std _t
    #     por model: nobs wtest jbtest bgtest rmsout avg/mediana


    # # sacar media/avg de betas y de errores
    # #schema (panel,time,random)
    # #variables elegidas (entre todos los )
    # #coef y std

    mean = 0
    median = 0

    result = CrossValidationResult(k, 0, mean, median)

    GlobalSearchRegression.addresult!(previousresult, result)

    addextras(previousresult, result)

    return previousresult
end

