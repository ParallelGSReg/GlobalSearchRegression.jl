module GlobalSearchRegression
using DataFrames, Distributions, Distributed, Printf, SharedArrays, LinearAlgebra, DelimitedFiles

include("structs/gsreg_data.jl")
include("structs/gsreg_result.jl")
include("utils.jl")

#include("strings.jl")
#include("interface.jl")
#include("core.jl")
include("FeatureExtraction/FeatureExtraction.jl")
include("AllSubsetRegression/AllSubsetRegression.jl")

using ..FeatureExtraction
using ..AllSubsetRegression

export gsreg, export_csv, to_dict, to_string, GSRegData, GSRegResult, featureextration, ols

end # module GlobalSearchRegression
