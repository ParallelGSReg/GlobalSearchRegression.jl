using CSV, GlobalSearchRegression, Distributed

using DataFrames, CSV
 
data = DataFrame(Array{Union{Missing,Float64}}(randn(100,30)))
data[1,2] = missing
data[2,6] = missing
data[3,2] = missing
data[2,7] = 999999
data[3,6] = 999999
data[4,6] = 999999
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]

headers[3] = :positive
headers[4] = :panel
headers[5] = :time
names!(data, headers)

data[:,3] = data[:,3] .+ 10
data[:,4] = collect(Iterators.flatten(fill(i,25) for i in 1:4))
data[:,5] = collect(Iterators.flatten(1:25 for i in 1:4))

@time data = GlobalSearchRegression.gsr(
    "y x* positive", 
    data,
    method=:precise,
    intercept=true,
    panel=:panel,
    time=:time,
    seasonaladjustment=[:time => 4],
    removeoutliers=true,
    fe_sqr=[:x1],
    fe_log=:positive,
    fe_inv=:positive,
    fe_lag=[:x10 => 1, :x11 => 2],
    interaction=[:x11, :x12],
    preliminaryselection=:lasso,
    fixedvariables=nothing,
    outsample=20,
    criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=true,
    kfoldcrossvalidation=true,
    numfolds=3
    #testsetshare=nothing,
    #exportcsv::Union{Nothing, String}=EXPORTCSV_DEFAULT,
    #exportsummary::Union{Nothing, String}=EXPORTSUMMARY_DEFAULT
)
#GlobalSearchRegression.Output.latex(data, path="./Latex")
