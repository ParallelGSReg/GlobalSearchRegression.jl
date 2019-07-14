using CSV, GlobalSearchRegression, Distributed

data = CSV.read("data/small.csv")
@time data = GlobalSearchRegression.gsr("y x*", data, intercept=true, fe_sqr=:x1, preliminaryselection=:lasso, exportcsv="lalala.csv", exportsummary="salida.txt")
