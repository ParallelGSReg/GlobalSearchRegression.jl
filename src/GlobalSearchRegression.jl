module GlobalSearchRegression
using DataFrames, Distributions, Distributed, Printf, SharedArrays, LinearAlgebra, DelimitedFiles, GLMNet

include("structs/gsreg_data.jl")
include("datatypes/gsreg_result.jl")
include("utils.jl")

#include("strings.jl")
#include("interface.jl")
#include("core.jl")
include("Preprocessing/Preprocessing.jl")
include("FeatureExtraction/FeatureExtraction.jl")
include("CrossValidation/CrossValidation.jl")
include("PreliminarySelection/PreliminarySelection.jl")
#include("OutputDecoration/OutputDecoration.jl")
include("AllSubsetRegression/AllSubsetRegression.jl")

using ..Preprocessing
using ..FeatureExtraction
using ..PreliminarySelection
using ..AllSubsetRegression
#using ..OutputDecoration

export GSRegData, GSRegResult

export Preprocessing, FeatureExtraction, PreliminarySelection#, OutputDecoration

end # module GlobalSearchRegression
