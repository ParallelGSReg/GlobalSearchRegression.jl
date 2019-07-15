using CSV, GlobalSearchRegression, Distributed

data = CSV.read("data/small.csv")
@time data = GlobalSearchRegression.gsr("y x*", data, kfoldcrossvalidation=true)