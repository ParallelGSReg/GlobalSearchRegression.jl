using CSV, GlobalSearchRegression, Distributed

data = CSV.read("data/small.csv")
@time data = GlobalSearchRegression.gsr("y x*", 
    data, 
    ttest=true, 
    kfoldcrossvalidation=true, 
    residualtest=true,
    removeoutliers=true,
    outsample=10,
    modelavg=true,
    fe_sqr=:x1,
    fe_inv=[:x2, :x3],
    criteria=[:aic],
    preliminaryselection=:lasso,
    orderresults=true
)
GlobalSearchRegression.Output.latex(data, path="./Latex")
