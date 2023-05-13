using GlobalSearchRegression, DataFrames, Distributions, CSV, Random
# Insert here your working directory path
data = DataFrame(rand(100, 26), :auto)
headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
rename!(data, headers)
gsreg("y x1 x2", data)
a1=@elapsed gsreg("y x*", data; method="svd_32")
a2=@elapsed gsreg("y x*", data; method="qr_32")
a3=@elapsed gsreg("y x*", data; method="cho_32")
println("svd_32: ", a1,  " seconds")
println("qr_32: ", a2,  " seconds")
println("cho_32: ", a3,  " seconds")


