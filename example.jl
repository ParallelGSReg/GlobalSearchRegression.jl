using GSReg, CSV, DataFrames
# data = CSV.read("test/data/5x10.csv")
data = DataFrame(randn(10,6))
res = gsreg("x2 x3 x6 x1", data, csv="results.csv", keepwnoise=0.06)
#res = gsreg("y x*", data)
println("File saved to results.csv")
