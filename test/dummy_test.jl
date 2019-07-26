using CSV, GlobalSearchRegression

data = CSV.read("visitors.csv")

data = GlobalSearchRegression.gsr(
    "australia china japan uk", 
    data,
    intercept=true,
    time=:date,
    fe_sqr=[:uk, :china],
    fe_log=[:japan],
    fe_inv=:uk,
    preliminaryselection=:lasso,
    outsample=10,
    criteria=[:aic, :aicc],
    ttest=true,
    modelavg=true,
    residualtest=true,
    orderresults=true,
    kfoldcrossvalidation=true,
    numfolds=10,
    exportcsv="visitors_output.csv",
    exportlatex="latex.zip"
)