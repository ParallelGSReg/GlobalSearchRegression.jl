using CSV, GlobalSearchRegression, Distributed

data = CSV.read("database.csv")

data = GlobalSearchRegression.gsr(
    "y x*", 
    data,
    method=:precise,
    intercept=true,
    removeoutliers=true,
    fe_sqr=[:x1],
    fe_log=[:x2],
    fe_inv=:x3,
    preliminaryselection=:lasso,
    outsample=10,
    criteria=[:aic, :aicc],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=true,
    exportlatex="GSREG.zip"
)
