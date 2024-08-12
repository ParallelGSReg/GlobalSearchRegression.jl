using Test, Distributed
addprocs()
@everywhere using GlobalSearchRegression, DataFrames, Distributions, LinearAlgebra
n = nworkers()

data = DataFrame([Vector{Union{Float64, Missing}}(rand(100)) for _ in 1:21], :auto)
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data, 2) - 1 ] ]
rename!(data, headers)
println("Data created")

# Perform initial regression
gsreg("y x1 x2", data)
println("Warm-up regression done")


a1 = @elapsed gsreg("y x*", data; method="qr_32", parallel=n)
println("Elapsed time: $a1")

a2 = @elapsed gsreg("y x*", data; method="qr_32", parallel=n)
println("Test 1 passed")

# Additional data manipulations for testing purposes
rename!(data, :x5 => Symbol("weird_name"))
data[1, 2] = missing
data[4, 5] = missing

# Stata like
gsreg("y x1 x2 x3", data)
println("Test 2 passed")
# Stata like with comma
gsreg("y,x1,x2,x3", data)
println("Test 3 passed")
# Unconventional varname
gsreg("y x1 weird_name", data)
println("Test 4 passed")
# R like
gsreg("y ~ x1 + x2 + x3", data)
println("Test 5 passed")
# Array of strings
gsreg(["y", "x1", "x2", "x3"], data)
println("Test 6 passed")
# Also, with wildcard
gsreg("y *", data)
println("Test 7 passed")
gsreg("y x*", data)
println("Test 8 passed")
gsreg("y ~ x*", data)
println("Test 9 passed")
gsreg("y ~ .", data)
println("Test 10 passed")

################ DATA #################

# dataframe with implicit datanames
gsreg("x2 x1 y", data)
println("Test 11 passed")
headers = map(e -> string(e), headers)
# array with explicit datanames
gsreg("x2 x1 y", Matrix(data); datanames = headers)
println("Test 12 passed")
gsreg("x2 x1 y", (Matrix(data), headers))
println("Test 13 passed")


############### ARGUMENTS ##############
gsreg("x2 x1 y", data; intercept = false) # without constant
println("Test 14 passed")
gsreg("x2 x1 y", data; outsample = 10) # expect 88 obs
println("Test 15 passed")
gsreg("x2 x1 y", data; outsample = 10, criteria = [:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse])
println("Test 16 passed")
gsreg("x2 x1 y", data; ttest = true)
println("Test 17 passed")
gsreg("x2 x1 y", data; modelavg = true)
println("Test 18 passed")
gsreg("x2 x1 y", data; ttest=true, modelavg = true)
println("Test 19 passed")
gsreg("x2 x1 y", data; residualtests = true)
println("Test 20 passed")
gsreg("x2 x1 y", data; time = :x4)
println("Test 21 passed")
gsreg("x2 x1 y", Matrix(data); datanames = headers, time = :x4)
println("Test 22 passed")
gsreg("x2 x1 y", (Matrix(data), headers); time = :x4)
println("Test 23 passed")
gsreg("x2 x1 y", data; summary = "summary.txt")
println("Test 24 passed")
gsreg("x2 x1 y", data; orderresults = true)
println("Test 25 passed")
gsreg("x2 x1 y", data; onmessage = message -> (println(message)))
println("Test 26 passed")
gsreg("x2 x1 y", data; method = "cho_32")
println("Test 27 passed")
gsreg("x2 x1 y", data; method = "svd_64")
println("Test 28 passed")
gsreg("x2 x1 y", data; resultscsv = "results.csv")
println("Test 29 passed")
res = gsreg("x2 x1 y", data; resultscsv = "results.csv")
println("Test 30 passed")
@test size(res.results, 1) == 3
println("Test 31 passed")
data[!, :x2] = data[!, :x3] * 2
println("Test 32 passed")
@test_throws ErrorException gsreg("y x1 x2 x3", data)
println("Test 33 passed")


############### PANEL DATA ##############
# NON-COLLINEAR INDEPENDET VARIABLES
#########################################

# Set seed for reproducibility
# Random.seed!(123)
# Create artificial panel data
N = 10  # number of individuals
T = 10  # number of time periods
K = 6   # number of variables including the dependent variable

# Generate random data without missing values
panel_data = DataFrame([rand(Normal(), N * T) for _ in 1:K], :auto)
headers = [:id, :time, :y, :x1, :x2, :x3]
rename!(panel_data, headers)

# Add panel ID and time variables
panel_data[!, :id] = repeat(1:N, inner = T)
panel_data[!, :time] = repeat(1:T, outer = N)


# OLS POOLED VS FIXED EFFECTS
model1=gsreg("y x1 x2 x3", panel_data; estimator = "ols", method="cho_32")
println(model1)
println("Panel Test 34 (POOLED OLS) passed")
model2=gsreg("y x1 x2 x3", panel_data; time = :time, panel_id = :id, estimator = "ols_fe", method="cho_32")
println(model2)
println("Panel Test 35 (FIXED EFFECT ESTIMATOR) passed")


############### PANEL DATA #################
# MODERATELY COLINEAR INDEPENDET VARIABLES
############################################

N = 20  # number of individuals
T = 500  # number of time periods
K = 4   # number of independent variables

# Correlation matrix for the variables
correlation_matrix = [
    1.0  0.8  0.3  0.2
    0.8  1.0  0.4  0.3
    0.3  0.4  1.0  0.2
    0.2  0.3  0.2  1.0
]

# Cholesky decomposition to generate correlated variables
L = cholesky(correlation_matrix).L

# Generate random variables with predefined correlation structure
X = [L * rand(Normal(), K) for _ in 1:(N * T)]
X = reduce(hcat, X)'

# Create a DataFrame
panel_data = DataFrame(X, [:x1, :x2, :x3, :x4])

# Add panel ID and time variables
panel_data[!, :id] = repeat(1:N, inner = T)
panel_data[!, :time] = repeat(1:T, outer = N)

# Create two copies of the panel data for different dependent variables
panel_data1 = copy(panel_data)
panel_data2 = copy(panel_data)

# Generate the dependent variable with a random effect and correlated structure
alpha = rand(Normal(), N) .* 10  # random effects for individuals with mean 0 and sd 1
beta = [1.0, 0.6, 0.3, 0.15]  # coefficients for x1, x2, x3, x4
constant  = 2

panel_data1[!, :y] = [constant + alpha[panel_data1[i, :id]] + dot(beta, panel_data1[i, [:x1, :x2, :x3, :x4]]) + rand(Normal()) for i in 1:(N * T)]
panel_data2[!, :y] = [constant + dot(beta, panel_data2[i, [:x1, :x2, :x3, :x4]]) + rand(Normal()) for i in 1:(N * T)]

# Ensure :y is in the correct position
panel_data1 = select(panel_data1, [:y, :x1, :x2, :x3, :x4,:id, :time])
panel_data2 = select(panel_data2, [:y, :x1, :x2, :x3, :x4,:id, :time])


# OLS POOLED VS FIXED EFFECTS 2
model3=gsreg("y x1 x2 x3 x4", panel_data1; estimator = "ols", method="cho_32", ttest=true, residualtests=true)
println(model3)
println("Panel Test 36 (POOLED OLS WITH CORRELATED DATA) passed")
model4=gsreg("y x1 x2 x3 x4", panel_data1; time = :time, panel_id = :id, estimator = "ols_fe", method="cho_32", ttest=true, residualtests=true)
println(model4)
println("Panel Test 37 (FIXED EFFECT ESTIMATOR WITH CORRELATED DATA) passed")

# Using opting for checking significant fixed-effects using Anova F-test
model5=gsreg("y x*", panel_data1; time = :time, panel_id = :id, estimator = "ols_fe", method="qr_32", ttest=true, paneltests=true, resultscsv="panel_data1.csv")
println(model5)
println("Panel Test 38 (FIXED EFFECT ESTIMATOR WITH SIGNIFICANT FE AND ANOVA F-TEST) passed")

model6=gsreg("y x*", panel_data2; time = :time, panel_id = :id, estimator = "ols_fe", method="qr_32", ttest=true, paneltests=true, resultscsv="panel_data2.csv")
println(model6)
println("Panel Test 39 (FIXED EFFECT ESTIMATOR WITH NON-SIGNIFICANT FE AND ANOVA F-TEST) passed")

model7=gsreg("y x1 x3 x4", panel_data2; fixedvars = :x2, time = :time, panel_id = :id, estimator = "ols_fe", method="qr_32", ttest=true, resultscsv="panel_data3.csv")
println(model7)
println("Panel Test 40 (FIXED EFFECT ESTIMATOR WITH NON-SIGNIFICANT FE,  ANOVA F-TEST AND FIXED VARIABLES) passed")