# GlobalSearchRegression [![Build Status](https://travis-ci.org/ParallelGSReg/GlobalSearchRegression.jl.svg?branch=master)](https://travis-ci.org/ParallelGSReg/GlobalSearchRegression.jl) [![](https://img.shields.io/badge/docs-latest-blue.svg)](https://parallelgsreg.github.io/GlobalSearchRegression.jl/)

## Abstract
GlobalSearchRegression is both the world-fastest all-subset-regression command (a widespread tool for automatic model/feature selection technique) and a first-step to develop a coeherent framework to merge Machine Learning and Econometric algorithms and building bridges between frequentist and bayesian statistics. 

Written in Julia, it is a High Performance Computing version of the [Stata-gsreg](https://www.researchgate.net/profile/Pablo_Gluzmann/publication/264782750_Global_Search_Regression_A_New_Automatic_Model-selection_Technique_for_Cross-section_Time-series_and_Panel-data_Regressions/links/53eed18a0cf23733e812c10d/Global-Search-Regression-A-New-Automatic-Model-selection-Technique-for-Cross-section-Time-series-and-Panel-data-Regressions.pdf?origin=publication_detail) command (get the code [here](https://ideas.repec.org/c/boc/bocode/s457737.html)). In a multicore personal computer (we use an Threadripper 1950x build for benchmarks), it runs up-to 100 times faster than the original Stata-code and up-to 10 times faster than well-known R-alternatives ([pdredge](https://www.rdocumentation.org/packages/MuMIn/versions/1.42.1/topics/pdredge)).

Notwithstanding, GlobalSearchRegression main focus is not about execution-times but about progressively combining Machine Learning  algorithms with Econometric diagnosis tools to simplify quantitative-research.

In a Machine Learning environment (e.g. problems focusing on predictive analysis / forecasting accuracy) there is an increasing universe of “training/test” algorithms (many of them showing very interesting performance in Julia) to compare alternative results and find-out a suitable model. 

In Econometrics (e.g. problems focusing on causal inference) we require five important features which narrow the set of available alternative approahces: 1) Parsimony (to avoid very large atheoretical models); 2) Interpretability (for causal inference, rejecting “intuition-loss” transformation and/or complex combinations); 3) Across-models sensitivity analysis (economic theory is preferred against “best-model” unique results); 4) Robustness to time series and panel data information (preventing the use of raw bootstrapping or random subsample selection for training and test sets); and 5) advanced residual properties (e.g. going beyond the i.i.d assumption and looking for additional panel structure properties -for each model being evaluated-, which force a departure from many algorithms).

For these reasons, most economists incrasingly prefer flexible all-subset-regression approaches, choosing among alternative models by means of in-sample and/or out-of-sample criteria, model averaging results, theoretical limits on covariates coefficients and residual constraints. While still unfeasible for large problems (choosing among thousand of covariates), hardware and software innovations allow researchers to implement this approach in many different scientific projects and choosing among billion models in a few hours using standard personal computers.




## Installation
GlobalSearchRegression requires [Julia 1.0.1 ](https://julialang.org/downloads/platform.html) (or newer releases) to be previously installed in your computer. Then, start Julia and type "]" (without double quotes) to open the package manager.

```julia
julia> ]
pkg>
```
After that, just install GlobalSearchRegression by typing "add GlobalSearchRegression"

```julia
pkg> add GlobalSearchRegression
```
Optionally, some users could also find interesting to install CSV and DataFrames packages to allow for additional I/O functionalities.

```julia
pkg> add CSV DataFrames
```

## Basic Usage

To run the simplest analysis just type the:

```julia
julia> using GlobalSearchRegression, DelimitedFiles
julia> dataname = readdlm("path_to_your_data/your_data.csv", ',', header=true)
```
and 

```julia
julia> gsreg("your_dependent_variable your_explanatory_variable_1 your_explanatory_variable_2 your_explanatory_variable_3 your_explanatory_variable_4", dataname)
```
or
```julia
julia> gsreg("your_dependent_variable *", data)
```
It performs an Ordinary Least Squares - all subset regression (OLS-ASR) approach to choose the best model among 2<sup>n</sup>-1 alternatives (in terms of in-sample accuracy, using the adjusted R<sup>2</sup>), where:
* DelimitedFiles is the Julia buit-in package we use to read data from csv files (throught its readdlm function);
* "path_to_your_data/your_data.csv" is a strign that indentifies your comma-separated database, allowing for missing observations. It's assumed that your database first row is used to identify variable names;
* gsreg is the GlobalSearchRegression function that estimates all-subset-regressions (e.g. all-possible covariate combinations). In its simplest form, it has two arguments separated by a comma;
* The first gsreg argument is the general equation. It must be typed between double quotes. Its first string is the dependent variable name (csv-file names must be respected, remember that Julia is case sensitive). After that, you can include as many explanatory variables as you want. Alternative, you can replace covariates by wildcars as in the example above (e.g. * for all other variables in the csv-files, or qwert* for all other variables in the csv-file with names starting by "qwert"); and
* The second gsreg argument is name of the object containing your database. Following the example above, it must match the name you use in dataname = readdlm("path_to_your_data/your_data.csv", ',', header=true)



## Other usage methods:

```julia
# Stata like
julia> result = gsreg("y x1 x2 x3", data)

# Stata like with comma
julia> result = gsreg("y,x1,x2,x3", data)

# R like
julia> result = gsreg("y ~ x1 + x2 + x3", data)
julia> result = gsreg("y ~ x1 + x2 + x3", data=data)

# Array of strings
julia> result = gsreg(["y", "x1", "x2", "x3"], data)

# Also, with wildcard
julia> result = gsreg("y *", data)
julia> result = gsreg("y x*", data)
julia> result = gsreg("y x1 z*", data)
julia> result = gsreg("y ~ x*", data)
julia> result = gsreg("y ~ .", data)
```
## Advanced usage syntax

```julia
julia> using CSV, GSReg

julia> data = CSV.read("data.csv")

julia> result = gsreg("y x*", data,
    intercept=true,
    outsample=10,
    criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse],
    ttest=true,
    method="fast", #precise
    vectoroperation=true,
    modelavg=true,
    residualtest=false,
    time=:date,
    summary=false,
    csv="output.csv",
    resultscsv="output.csv",
    orderresults=false
)
```

## Options:

intercept::Bool,
outsample::Int,
criteria::Array,
ttest::Bool,
method{fast,precise},
vectoroperation::Bool,
modelavg::Bool,
residualtest::Bool,
time=Symbol,
summary=Bool,
csv=String,
resultscsv=String (alias),
orderresults=Boolean(false)


## Parallel

You must run julia with -p auto option

 
## Credits

The GSReg module, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Valentín Mari](https://github.com/vmari/) and [Adán Mauri Ungaro](https://github.com/adanmauri/). The GSReg module was inpired by GSReg for Stata, written by Pablo Gluzmann and [Demian Panigo](https://github.com/dpanigo/).
