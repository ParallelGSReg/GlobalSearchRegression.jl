using GSReg, DelimitedFiles

data = readdlm("testdata.csv", ',', header=true)
data = gsreg("x2 x1 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15", data[1], datanames=data[2], ttest=true, residualtest=true, criteria=[:aic, :bic])
println(data)