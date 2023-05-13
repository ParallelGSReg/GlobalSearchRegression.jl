using CSV, DataFrames, GlobalSearchRegression, BenchmarkTools
data=CSV.read("15x1000.csv", DataFrame)

@benchmark a1=gsreg("y *", data; method="svd_64")
@benchmark a2=gsreg("y *", data; method="svd_32")
@benchmark a3=gsreg("y *", data; method="svd_16")
@benchmark a4=gsreg("y *", data; method="qr_64")
@benchmark a5=gsreg("y *", data; method="qr_32")
@benchmark a6=gsreg("y *", data; method="qr_16")
@benchmark a7=gsreg("y *", data; method="cho_64")
@benchmark a8=gsreg("y *", data; method="cho_32")
@benchmark a9=gsreg("y *", data; method="cho_16")

