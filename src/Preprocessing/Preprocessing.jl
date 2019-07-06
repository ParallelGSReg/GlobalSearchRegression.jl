module Preprocessing
    using DataFrames
    using Statistics
    using SingularSpectrumAnalysis
    using ..GlobalSearchRegression
    using ..GlobalSearchRegression: get_column_index, in_vector, filter_raw_data_by_empty_values, convert_raw_data

    include("const.jl")
    include("utils.jl")
    include("strings.jl")
    include("core.jl")

    export input
end