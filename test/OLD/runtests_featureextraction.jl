using Test, GlobalSearchRegression.FeatureExtraction

using DataFrames, DelimitedFiles, CSV

filename = "panel_database.csv"

function load_from_dataframe()
    # Loading data from DataFrame variable
    data = DataFrame(Array{Union{Missing,Float64}}(rand(1:1000, 1000, 6)))
    headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
    names!(data, headers)
    return FeatureExtraction.featureextraction(
        "*",
        data=data,
        intercept=true, 
        method=:fast, 
        time=:x1,
        fe_sqr=[:x1, :x2],
        fe_log=[:x1, :x2],
        fe_inv=[:x1, :x2],
        fe_lag=[:x1=>2, :x2=>5],
        fixedeffect=true,
        panel=:y,
        interaction=[:x1, :x2, :x3]
    )
end

function load_from_array()
    # Loading data from array variable
    data = rand(1:1000, 1000, 6)
    datanames = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
    gsreg_data = FeatureExtraction.featureextraction(
        "*",
        data=data,
        datanames=datanames,
        intercept=true, 
        method=:fast, 
        time=:x1,
        fe_sqr=[:x1, :x2],
        fe_log=[:x1, :x2],
        fe_inv=[:x1, :x2],
        fe_lag=[:x1=>2, :x2=>5],
        fixedeffect=true,
        panel=:y,
        interaction=[:x1, :x2, :x3]
    )
end

function load_from_csv(filename)
    # Loading data from csv file using CSV package and DataFrames
    data = CSV.read(filename)
    return FeatureExtraction.featureextraction(
        "*",
        data=data,
        intercept=true, 
        method=:fast, 
        time=:time,
        fe_sqr=[:x1, :x2],
        fe_log=[:x1, :x2],
        fe_inv=[:x1, :x2],
        fe_lag=[:x1=>2, :x2=>5],
        fixedeffect=true,
        panel=:panel,
        interaction=[:x1, :x2, :x3]
    )
end

function load_from_readdlm(filename)
    # Loading data from csv file using readdlm
    data = readdlm(filename, ',', header=true)
    return FeatureExtraction.featureextraction(
        "*",
        data=data,
        intercept=true, 
        method="fast", 
        time="time",
        fe_sqr=["x1", "x2"],
        fe_log=["x1", "x2"],
        fe_inv=["x1", "x2"],
        fe_lag=["x1"=>2, "x2"=>5],
        fixedeffect=true,
        panel=:panel,
        interaction=["x1", "x2", "x3"]
    )
end

#println("load_from_dataframe")
#load_from_dataframe()

#println("load_from_array")
#load_from_array()

#println("load_from_csv")
#println(load_from_csv(filename))

#println("load_from_readdlm")
println(load_from_readdlm(filename))