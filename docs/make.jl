using Documenter, GSReg

# Build documentation.
# ====================

makedocs(
    # options
    modules = [GSReg],
    doctest = false,
    clean = false,
    sitename = "GSReg.jl",
    format = :html,
    pages = Any[
        "Introduction" => "index.md",
        "User Guide" => Any[
            "Getting Started" => "man/getting_started.md",
        ],
        "API" => Any[
            "Functions" => "lib/functions.md"
        ]
    ]
)

# Deploy built documentation from Travis.
# =======================================

deploydocs(
    # options
    repo = "github.com/JuliaData/DataFrames.jl.git",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing,
)