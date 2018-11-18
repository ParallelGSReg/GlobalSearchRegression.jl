using Test, GlobalSearchRegression, DataFrames, Distributions

data = DataFrame(Array{Union{Missing,Float64}}(randn(100,6)))
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
names!(data, headers )

rename!(data, :x5 => Symbol("weird_name"))

data[1, 2] = missing
data[4, 5] = missing

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

gsreg("x2 x1 y", data; resultscsv="results.csv")

############# PARALLEL #################
gsreg("x2 x1 y", data; parallel=2)


@test size(res.results,1) == 31
