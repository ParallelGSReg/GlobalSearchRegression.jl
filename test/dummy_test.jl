using CSV, GlobalSearchRegression, Distributed

data = CSV.read("visitors.csv")

@time data = GlobalSearchRegression.gsr(
    "australia china japan uk", 
    data,
    method=:precise,
    intercept=true,
    time=:date,
    removeoutliers=true,
    fe_sqr=[:china],
    fe_log=[:japan],
    fe_inv=:uk,
    fe_lag=[:japan => 1],
    preliminaryselection=:lasso,
    outsample=10,
    criteria=[:aic],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=true,
    kfoldcrossvalidation=true,
    numfolds=3
    #exportcsv="salida.csv",
    #exportlatex="/home/valentin/GSREG.zip"
)
