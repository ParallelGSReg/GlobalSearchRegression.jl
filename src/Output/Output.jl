module Output
    using DelimitedFiles,
            Printf,
            Mustache, 
            KernelDensity,
            StatsPlots,
            ZipFile,
            InfoZIP,
            Statistics, 
            StatsPlots,
            DataFrames,
            Distributions,
            Distributed
    using Plots
    using ..GlobalSearchRegression

    export csv, summary, latex

    include("const.jl")
    include("strings.jl")
    include("utils.jl")
    include("decorations/csv/csv.jl")
    include("decorations/summary/summary.jl")
    include("decorations/latex/latex.jl")
    include("core.jl")
end
