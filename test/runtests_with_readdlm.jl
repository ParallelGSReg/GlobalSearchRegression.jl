using GSReg, DelimitedFiles

data = readdlm("testdata.csv", ',', header=true)
data = gsreg("x2 x1 x3 x4 x5 x6 x7 x8 x9 x10", data; ttest=true, residualtest=true, criteria=[:bic])
println(data)
