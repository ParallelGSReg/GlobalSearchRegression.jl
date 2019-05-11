module FeatureExtraction

    using DataFrames
    using Statistics
    using ShiftedArrays
    using ..GlobalSearchRegression
    using ..GlobalSearchRegression: get_column_index, in_vector

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export featureextraction

end