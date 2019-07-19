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
    preliminaryselection=:lasso

)
GlobalSearchRegression.Output.latex(data, "./Latex")