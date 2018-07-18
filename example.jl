using GSReg, CSV
data = CSV.read("test/data/5x10.csv")
res = gsreg("y x*", data, csv="results.csv", ttest=true, residualtest=true)
#res = gsreg("y x*", data)
println("File saved to results.csv")