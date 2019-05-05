using Test, DataFrames, GlobalSearchRegression.DataTransformation

data = DataFrame(Array{Union{Missing,Float64}}(randn(6,5)))
data[1] = [1, 2, 1, 1, 2, 2]
data[2] = [21, 22, 23, 24, 25, 12]
data[3] = [31, 32, 33, 34, 35, 12]
data[4] = [41, 42, 43, 44, 45, 12]
data[5] = [51, 51, 52, 53, 53, 52]
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
names!(data, headers)
rename!(data, :x4 => Symbol("weird_name"))

println(data)

res = DataTransformation.datatransformation("x2 x1 y", data=data, time=:weird_name, panel=:y, fe_sqr=["x1"], fe_log =[:x1], fe_inv=:x1, fe_lag=["x1"=>1, "x2"=>2], fixedeffect=true)
dt = convert(DataFrame, hcat(res.depvar_data, res.expvars_data))
names!(dt, vcat([res.depvar], res.expvars))
println(dt)
println(res)

# fd  TIME (first diffence)
# fe  TIME (fixed effect)  => x1 - (mean x1)
# lag TIME (el anterior)
"""
d = convert(DataFrame, res.expvars_data)
names!(d, res.expvars)

println(d)
"""

"""


############# EQUATION #################

# unsorted (x2 -the firstone- is the depvar)
gsreg("x2 x1 y", data)

# Stata like
gsreg("y x1 x2 x3", data)

# Stata like with comma
gsreg("y,x1,x2,x3", data)

# Unconventional varname
gsreg("y x1 weird_name", data)

# R like
gsreg("y ~ x1 + x2 + x3", data)
gsreg("y ~ x1 + x2 + x3", data = data)

# Array of strings
gsreg(["y", "x1", "x2", "x3"], data)

# Also, with wildcard
gsreg("y *", data)

gsreg("y x*", data)

gsreg("y ~ x*", data)
gsreg("y ~ .", data)

################ DATA #################

# dataframe with implicit datanames
gsreg("x2 x1 y", data)


headers = map(e->string(e),headers)

# array with explicit datanames
gsreg("x2 x1 y", convert(Array,data); datanames=headers)


# tuple with explcit datanames
gsreg("x2 x1 y", (convert(Array,data), headers) )


############### ARGUMENTS ##############

gsreg("x2 x1 y", data; intercept=false) # without constant

gsreg("x2 x1 y", data; outsample=10) # expect 88 obs

gsreg("x2 x1 y", data; outsample=10, criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse])

gsreg("x2 x1 y", data; ttest=true)

gsreg("x2 x1 y", data; vectoroperation=true)

gsreg("x2 x1 y", data; modelavg=true)

gsreg("x2 x1 y", data; residualtest=true)

gsreg("x2 x1 y", data; time=:x4)
gsreg("x2 x1 y", convert(Array,data); datanames=headers, time=:x4)
gsreg("x2 x1 y", (convert(Array,data), headers); time=:x4)

gsreg("x2 x1 y", data; summary="summary.txt")

gsreg("x2 x1 y", data; orderresults=true)

gsreg("x2 x1 y", data; onmessage= message -> (println(message)))

gsreg("x2 x1 y", data; method="fast")

gsreg("x2 x1 y", data; method="precise")

gsreg("x2 x1 y", data; csv="results.csv")

res = gsreg("x2 x1 y", data; resultscsv="results.csv")

@test size(res.results,1) == 3
"""
