# GlobalSearchRegression Modules

## FeatureExtraction
This module has multiple objetives. First, it performs required transformation on equation definitions and database formats in order to homogenize inputs. Second, it allows users to define aditional data tranformation to improve model accuracy and feature selection in the following steps. 

### Features
- Parses a given equation from multiple formats, including R and Stata
- Reduces database size based on user selected variables
- Sorts observations by time and panel variables
- Transforms data format for faster or precise compute (Float32, Float64)
- Creation of lags, interactions and non-linear representations
- Computes within tranformations for fixed effect estimators 
- Excludes observations/rows with missing or null values in any selected variable

### Basic usage (equation definition)

```julia
# Stata like
julia> featureextraction("y x1 x2 x3", data)

# R like
julia> featureextraction("y ~ x1 + x2 + x3", data)

# String separated by comma
julia> featureextraction("y,x1,x2,x3", data)
julia> featureextraction("y, x1, x2, x3", data)

# Array of strings
julia> featureextraction(["y", "x1", "x2", "x3"], data)
julia> featureextraction(["y"  "x1"  "x2" "x3"], data)

# Using Stata, R and general wildcards
julia> featureextraction("y *", data)
julia> featureextraction("y x*", data)
julia> featureextraction("y x1 z*", data)
julia> featureextraction("y ~ x*", data)
julia> featureextraction("y ~ .", data)

# Using symbols
julia> featureextraction([:y, :x1, :x2, :x3], data)

# Using data key parameter
julia> featureextraction("y x1 x2 x3", data=data)

# If database is an array you should set the header independently
julia> featureextraction("y x1 x2 x3", data, datanames=header)

# If database is a Tuble you should define it using the first element as data and the second as headers
julia> featureextraction("y x1 x2 x3", (data, header))
```

### Advanced usage
* **`intercept`:** by default the GUM includes an intercept as a fixed covariate (it's included in every model). The default is `true`.
* **`method`:** this option can be used to alternatively run estimations with Float32 of Float64 datatype. The default is `FAST` (Float32), to speed-up calculations. The available options are:
    - Float32: `:FAST`, `:fast`, `"FAST"`, `"fast"`
    - Float64: `:PRECISE`, `:precise`, `"PRECISE"`, `"precise"`
* **`time`:** determines which variable will be used to date (and pre-sort) observations. Time variable must be included as a symbol or string (i.e. `time=:x1` or `time="x1"`). Neither, gaps nor missing observations should be allowed in this variable. Calculations will be made assuming no gaps. By using this option, additional residuals tests are enabled.
* **`fe_sqr`:** defines which variables will be squared (i.e. `fe_sqr=:x1` or `fe_sqr=[:x1, :x2]`).
* **`fe_log`:** defines which variables will also be included in logarithms (i.e. `fe_log=:x1` or `fe_log=[:x1, :x2]`).
* **`fe_inv`:** defines which variables will be inversed (i.e. `fe_inv=:x1` or `fe_inv=[:x1, :x2]`).
* **`fe_lag`:** defines which variables will be included for the lag structure (i.e. `fe_lag=:x1=>2` or `fe_lag=[:x1=>2, :x2=>5]`).
* **`panel`:** defines which variable will be used as group/cross-section identifier (i.e. `panel=:x1`). Valid panel variables must be numeric without missing values and with the same value for each group observation.
* **`fixedeffect`:** applies the within transformation for fixed effectimations (i.e. fixedeffect=true). The default is `false` but it automaticaly changes to true when a valid panel variable is defined.
* **`interaction`**: creates every possible multiplication between each pair of selected variables (i.e. `interaction=[x1, :x2, :x3]`).

### Full-syntax example

```julia
# The first four lines are used to simulate data with random variables
julia> using DataFrames
julia> data = DataFrame(Array{Union{Missing,Float64}}(randn(100,16)))
julia> headers = [ :y ; [ Symbol("x$i") for i = 1:size(data,2) - 1 ] ]
julia> names!(data, headers)
julia> using GlobalSearchRegression.FeatureExtraction
julia> FeatureExtraction.featureextraction(
    "y x1 x2 x3 x4 x5 x6 x7 x11 x12 x13 x14 x15",
    data, 
    intercept=true, 
    method=:FAST,
    time=:time,
    fe_sqr=[:x1, :x2],
    fe_log=[:x1, :x2],
    fe_inv=[:x1, :x2],
    fe_lag=[:x1=>2, :x2=>5],
    fixedeffect=true,
    panel=:panel,
    interaction=[x1, :x2, :x3]
    )
```

## Response

```julia
# The response is a GSRegData datatype
julia> response.
        equation    depvar    expvars    depvar_data    expvars_data    intercept    time   panel    datatype
        nobs    original_nobs    fe_sqr    fe_log    fe_inv    fe_lag    fixedeffect    interaction     results
```

## Credits
The FeatureExtraction module is a sub-module of GlobalSearchRegression, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Adán Mauri Ungaro](https://github.com/adanmauri/) and [Valentín Mari](https://github.com/vmari/). The GlobalSearchRegression.jl module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
