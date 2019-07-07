# using Mustache, DataFrames, Statistics, Printf, GLMNet, Pkg

function lasso(data::GlobalSearchRegression.GSRegData; keepdata=KEEPDATA_DEFAULT)
    data = GlobalSearchRegression.filter_data_by_empty_values(data)
    data = GlobalSearchRegression.convert_data(data)

    path = glmnet(data.expvars_data, data.depvar_data; nlambda=1000)
    nvars = min(Int(floor(log(2,Sys.total_memory()/2 ^30) + 21)), size(data.expvars, 1)-1)
    best = findfirst( x -> x == nvars, nactive(path.betas))
    
    # TODO check if BEST is nothing (adjust lambda and execute glmnet again)
    vars = map(b -> b != 0, path.betas[:, best])
    # TODO keep a copy of the previous data if keepdata == true
    data.expvars = data.expvars[vars]
    data.expvars_data = data.expvars_data[:,vars]
    return data
end

# data = DataFrame(Array{Union{Missing,Float64}}(randn(88,16)))
# data[1,2] = missing
# data[2,2] = missing
# data[3,2] = missing
# headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
# names!(data, headers)

# function get_variable_summary(data)
#     result = []

#     for var in names(data)
#         orig = data[var]
#         obs = collect(skipmissing(orig))
#         push!(result, Dict(
#             "name" => string(var),
#             "nobs" => length(obs),
#             "mean" => @sprintf("%.2f", mean(obs)),
#             "std"  => @sprintf("%.2f", std(obs)),
#             "max"  => @sprintf("%.2f", maximum(obs)),
#             "min"  => @sprintf("%.2f", minimum(obs)),
#             "miss" => @sprintf("%.2f", 100 - (length(obs) / length(orig))*100 )
#         ))
#     end

#     return result
# end

# function get_lasso_summary(selectedvars)
#     selectedvars = lasso.betas[:,113]
#     result = []

#     for var in headers[[false; map(v -> v > 0, selectedvars)]]
#         push!(result, Dict(
#             "var" => var,
#             "coef" => 1
#         ))
#     end

#     return result
# end

# dropmissing!(data)

# y = data[:,1]
# X = Array{Float64,2}(data[:,2:end])

# lasso = glmnet(X, y; nlambda=1000)

# d = Dict(
#     "indep" => "y",
#     "depvar" => "xasxasx", 
#     "var_summary" => get_variable_summary(data),
#     # "lasso" => Dict(
#     #     "summary" => get_lasso_summary(lasso)
#     # )
# )
# #use Pkg.dir("GlobalSearchRegression")
# cp(string(dirname(@__FILE__),"/tpl"), "./Latex")
# using Mustache, DataFrames, Statistics, Printf, GLMNet, Pkg
       
# data = DataFrame(Array{Union{Missing,Float64}}(randn(88,16)))
# data[1,2] = missing
# data[2,2] = missing
# data[3,2] = missing
# headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
# names!(data, headers)

# function get_variable_summary(data)
#     result = []

#     for var in names(data)
#         orig = data[var]
#         obs = collect(skipmissing(orig))
#         push!(result, Dict(
#             "name" => string(var),
#             "nobs" => length(obs),
#             "mean" => @sprintf("%.2f", mean(obs)),
#             "std"  => @sprintf("%.2f", std(obs)),
#             "max"  => @sprintf("%.2f", maximum(obs)),
#             "min"  => @sprintf("%.2f", minimum(obs)),
#             "miss" => @sprintf("%.2f", 100 - (length(obs) / length(orig))*100 )
#         ))
#     end

#     return result
# end

# function get_lasso_summary(selectedvars)
#     selectedvars = lasso.betas[:,113]
#     result = []

#     for var in headers[[false; map(v -> v > 0, selectedvars)]]
#         push!(result, Dict(
#             "var" => var,
#             "coef" => 1
#         ))
#     end

#     return result
# end

# dropmissing!(data)

# y = data[:,1]
# X = Array{Float64,2}(data[:,2:end])

# lasso = glmnet(X, y; nlambda=1000)

# d = Dict(
#     "indep" => "y",
#     "depvar" => "xasxasx", 
#     "var_summary" => get_variable_summary(data),
#     # "lasso" => Dict(
#     #     "summary" => get_lasso_summary(lasso)
#     # )
# )
# #use Pkg.dir("GlobalSearchRegression")
# cp(string(dirname(@__FILE__),"/tpl"), "./Latex")
# io = open("./Latex/main.tex", "w")
# write(io, render_from_file(string(dirname(@__FILE__),"/tpl.tex"), d))
# close(io)
# io = open("./Latex/main.tex", "w")
# write(io, render_from_file(string(dirname(@__FILE__),"/tpl.tex"), d))
# close(io)