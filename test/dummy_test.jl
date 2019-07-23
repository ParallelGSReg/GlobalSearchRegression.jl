using CSV, GlobalSearchRegression, Distributed, DataFrames, CSV
 
data = CSV.read("data/fat.csv")
@time data = GlobalSearchRegression.gsr(
    "y *", 
    data,
    intercept=true,
    preliminaryselection=:lasso,
    outsample=10,
    criteria=[:aic, :aicc, :cp],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=true,
    kfoldcrossvalidation=true,
    numfolds=3,
    exportlatex="/home/valentin/GSREG.zip"
)
