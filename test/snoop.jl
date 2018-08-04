using GSReg, CSV, HTTP, DataFrames
data = DataFrame(randn(10,6))

res = gsreg("x1 x2 x3 x4 x5 x6", data; ttest=true, residualtest=true, criteria=[:aic, :bic], modelavg=true)
@async gui()
HTTP.request("GET", "http://localhost:45872/server-info")
HTTP.request("GET", "http://localhost:45872/")
HTTP.request("GET", "http://localhost:45872/solve/mi/e30=")
HTTP.request("GET", "http://localhost:45872/upload")
