using Documenter, GSReg

# Build documentation.
# ====================

makedocs(
    # options
    modules = [GlobalSearchRegression],
    doctest = false,
    clean = false,
    sitename = "GlobalSearchRegression.jl",
    format = :html,
    pages = Any[
        "Introduction" => "index.md",
        "API" => Any[
            "Functions" => "lib/functions.md"
        ]
    ]
)

# Deploy built documentation from Travis.
# =======================================

deploydocs(
    repo = "github.com/ParallelGSReg/GlobalSearchRegression.jl.git",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing,
)
