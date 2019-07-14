using CSV, GlobalSearchRegression, Distributed

data = CSV.read("test/data/small.csv")

data = GlobalSearchRegression.Preprocessing.input("y x*", data, intercept=true)
result = GlobalSearchRegression.AllSubsetRegression.ols(
    data,
    outsample=10,
    criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :sse, :rmseout],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=false
)
GlobalSearchRegression.OutputDecoration.csv_res(result.results[1], "salida.csv")
