module Preprocessing
    using DataFrames
    using Statistics
    using SingularSpectrumAnalysis
    using ..GlobalSearchRegression

    export input, PREPROCESSING_EXTRAKEY

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("core.jl")    
end
