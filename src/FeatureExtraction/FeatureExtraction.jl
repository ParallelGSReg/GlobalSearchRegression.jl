module FeatureExtraction
    using DataFrames
    using Statistics
    using ShiftedArrays
    using ..GlobalSearchRegression

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export featureextraction

end
