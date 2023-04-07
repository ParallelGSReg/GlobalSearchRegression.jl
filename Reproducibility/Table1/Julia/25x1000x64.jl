using GlobalSearchRegression, DataFrames, Distributions, CSV
# Insert here your working directory path
data = DataFrame(Array{Union{Missing,Float64}}(randn(1000,26)), :auto)
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
rename!(data, headers)
b=@elapsed gsreg("y x*", data; ttest=true, criteria=[:aic], parallel=64, csv="25x1000x64.csv")
t=DataFrame(A=Float64[0.0])
t[1,1]=b
CSV.write("juliatimmings.csv", t; append=true)
exit()

