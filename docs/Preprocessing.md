# GlobalSearchRegression Modules: Preprocessing

It performs required transformation on equation definitions and database formats in order to homogenize inputs and allows users to define aditional data tranformation to improve model accuracy and feature selection in the following steps. 

## Features
- Parses a given equation from multiple formats, including R and Stata.
- Reduces database size based on user selected variables.
- Sorts observations by time and panel variables (optional).
- Transforms data format for faster or precise compute (Float32, Float64).
- Validates time and panel variables (if variables exists).
- Includes an intercept as a fixed covariate (optional).
- Decompose the original series into trend, cycle, season and noise. After that it removes the seasonal component (optional).
- Removes extreme observations because of input error or unexpected events (optional).
- Excludes observations/rows with missing or null values in any selected variable (optional)

## Basic usage (equation definition)

```julia
# Stata like
julia> Preprocessing.input("y x1 x2 x3", data)

# R like
julia> Preprocessing.input("y ~ x1 + x2 + x3", data)

# String separated by comma
julia> Preprocessing.input("y,x1,x2,x3", data)
julia> Preprocessing.input("y, x1, x2, x3", data)

# Array of strings
julia> Preprocessing.input(["y", "x1", "x2", "x3"], data)
julia> Preprocessing.input(["y"  "x1"  "x2" "x3"], data)

# Using Stata, R and general wildcards
julia> Preprocessing.input("y *", data)
julia> Preprocessing.input("y x*", data)
julia> Preprocessing.input("y x1 z*", data)
julia> Preprocessing.input("y ~ x*", data)
julia> Preprocessing.input("y ~ .", data)

# Using symbols
julia> Preprocessing.input([:y, :x1, :x2, :x3], data)
julia> Preprocessing.input([:y :x1 :x2 :x3], data)

# Using data key parameter
julia> Preprocessing.input("y x1 x2 x3", data=data)

# If database is an array you should set the header independently
julia> Preprocessing.input("y x1 x2 x3", data, datanames=header)

# If database is a Tuple you should define it using the first element as data and the second as headers
julia> Preprocessing.input("y x1 x2 x3", (data, header))
```

## Advanced usage
* **`intercept`:** by default the GUM includes an intercept as a fixed covariate (it's included in every model). The default is `true`.
* **`method`:** this option can be used to alternatively run estimations with Float32 of Float64 datatype. The default is `FAST` (Float32), to speed-up calculations. The available options are:
    - Float32: `:FAST`, `:fast`, `"FAST"`, `"fast"`
    - Float64: `:PRECISE`, `:precise`, `"PRECISE"`, `"precise"`
* **`time`:** determines which variable will be used to date (and pre-sort) observations. Time variable must be included as a symbol or string (i.e. `time=:x1` or `time="x1"`). Neither, gaps nor missing observations should be allowed in this variable. Calculations will be made assuming no gaps. By using this option, additional residuals tests are enabled.
* **`panel`:** defines which variable will be used as group/cross-section identifier (i.e. `panel=:x1`). Valid panel variables must be numeric without missing values and with the same value for each group observation.
* **`removeoutliers`:** defines if will removes extreme observations because of input error or unexpected events. The default is `false`.
* **`removemissings`:** defines if will excluded observations/rows with missing or null values in any selected variable. The default is `false`.
* **`seasonaladjustment`:** dictionary defines which kind of seasonality should be removed (i.e. `:panel=1`, `:panel=2`, `:panel=12`. The default is `false`.

## Full-syntax example

```julia
# The first four lines are used to simulate data with random variables
julia> using DataFrames
julia> data = DataFrame(Array{Union{Missing,Float64}}(randn(100,16)))
julia> headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
julia> names!(data, headers)
julia> using GlobalSearchRegression.Preprocessing
julia> Preprocessing.input(
    "y x1 x2 x3 x4 x5 x6 x7 x11 x12 x13 x14 x15",
    data, 
    intercept=true, 
    method=:FAST,
    time=:time,
    panel=:panel,
    removeoutliers=true,
    seasonaladjustment=Dict(:panel=>1, :time=>6),
    removemissings=true
    )
```

## Response: GSRegData

```julia
# The response is a GSRegData datatype
julia> response.
datatype       equation        intercept       panel           time
depvar         expvars         nobs            removemissings
depvar_data    expvars_data    options         results

equation::Array      # given formatted equation.
depvar::Symbol       # given dependent variable.
expvars::Array       # given explanatory variables.
depvar_data::Array   # dependent variable observations.
expvars_data::Array  # explanatory variables observations.
intercept::Bool      # if intercept vas defined.
panel::Symbol        # given panel variable (if exists).
time::Symbol         # given time variable (if exists).
removemissings::Bool # if removed missings was applied.
options::Array       # for future step proposes.
results::Array       # for future step proposes.
```

## Credits
Preprocessing module is a sub-module of GlobalSearchRegression, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Adán Mauri Ungaro](https://github.com/adanmauri/), [Nicolás Monzón](https://github.com/nicomzn/) and [Valentín Mari](https://github.com/vmari/). The GlobalSearchRegression.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
