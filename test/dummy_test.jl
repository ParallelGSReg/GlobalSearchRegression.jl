using CSV, GlobalSearchRegression, Distributed

println(nprocs())
println(nworkers())

data = CSV.read("20x100000.csv")
#datanames = names(data)
#data = convert(Array, data)

function old(data)
    result = gsreg(
        "y x*",
        data,
        datanames=datanames,
        intercept=true, 
        outsample=10, 
        criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :sse], 
        ttest=true, 
        modelavg=true,
        residualtest=true,
        orderresults=false,
        time=:time
    )
    println(result)
end

function new(data)
    data = GlobalSearchRegression.Preprocessing.input("y x*", data, intercept=true)
    result = GlobalSearchRegression.AllSubsetRegression.run_ols(
        data,
        outsample=10,
        criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :sse, :rmseout],
        ttest=true,
        modelavg=true,
        residualtest=true,
        orderresults=false
    )
    println(GlobalSearchRegression.AllSubsetRegression.to_string(result))
end

#@time old(data)
@time new(data)

#data2 = GlobalSearchRegression.AllSubsetRegression.run_ols(data1, orderresults=true, ttest=true, criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse], residualtest=true, modelavg=true, )
