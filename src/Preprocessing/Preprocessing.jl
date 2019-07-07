module Preprocessing
    using DataFrames
    using Statistics
    using SingularSpectrumAnalysis
    using ..GlobalSearchRegression

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export input
end
