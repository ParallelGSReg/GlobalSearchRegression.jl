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

function kfoldcrossvalidation(
    data::GlobalSearchRegression.GSRegData,
    k::Int)

    db = randperm(data.nobs)
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

        backup = GlobalSearchRegression.copy_data(data)
        backup.depvar_data = backup.depvar_data[dataset]
        backup.expvars_data = backup.expvars_data[dataset, :]
        backup.nobs = size(dataset, 1)
        
        GlobalSearchRegression.PreliminarySelection.lasso!(backup)
        res = GlobalSearchRegression.AllSubsetRegression.ols(backup; outsample=testset)
        append!(bestmodels, Dict(
            :data => res.bestresult_data,
            :datanames => res.datanames
        ))
    end

    for model in bestmodels 
        # promedio pepe
        model[:data][GlobalSearchRegression.get_column_index(:rmsout, model[:datanames])]
    end
    # sacar media/avg de betas y de errores

    return data
end

