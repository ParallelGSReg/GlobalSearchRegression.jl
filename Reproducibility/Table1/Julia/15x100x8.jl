using GlobalSearchRegression, DataFrames, Distributions, CSV
# Insert here your working directory path
data = DataFrame(Array{Union{Missing,Float64}}(randn(100,16)),:auto)
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
rename!(data, headers)
b=@elapsed gsreg("y x*", data; ttest=true, criteria=[:aic], parallel=8, csv="15x100x8.csv")
t=DataFrame(A=Float64[0.0])
t[1,1]=b
CSV.write("juliatimmings.csv", t; append=true)
exit()