# GlobalSearchRegression [![Build Status](https://travis-ci.org/ParallelGSReg/GlobalSearchRegression.jl.svg?branch=master)](https://travis-ci.org/ParallelGSReg/GlobalSearchRegression.jl) [![codecov](https://codecov.io/gh/ParallelGSReg/GlobalSearchRegression.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ParallelGSReg/GlobalSearchRegression.jl) [![](https://img.shields.io/badge/docs-latest-blue.svg)](https://parallelgsreg.github.io/GlobalSearchRegression.jl/) [![DOI](https://zenodo.org/badge/127349945.svg)](https://zenodo.org/badge/latestdoi/127349945)

## Abstract
GlobalSearchRegression is both the world-fastest all-subset-regression command (a widespread tool for automatic model/feature selection) and a first-step to develop a coherent framework to [merge](http://web.stanford.edu/class/ee380/Abstracts/140129-slides-Machine-Learning-and-Econometrics.pdf) Machine Learning and Econometric algorithms.

Written in Julia, it is a High Performance Computing version of the [Stata-gsreg](https://www.researchgate.net/profile/Pablo_Gluzmann/publication/264782750_Global_Search_Regression_A_New_Automatic_Model-selection_Technique_for_Cross-section_Time-series_and_Panel-data_Regressions/links/53eed18a0cf23733e812c10d/Global-Search-Regression-A-New-Automatic-Model-selection-Technique-for-Cross-section-Time-series-and-Panel-data-Regressions.pdf?origin=publication_detail) command (get the original code [here](https://ideas.repec.org/c/boc/bocode/s457737.html)). In a multicore personal computer (we use a Threadripper 1950x build for benchmarks), it runs up-to 3165 times faster than the original Stata-code and up-to 197 times faster than well-known R-alternatives ([pdredge](https://www.rdocumentation.org/packages/MuMIn/versions/1.42.1/topics/pdredge)).

Notwithstanding, GlobalSearchRegression main focus is not only on execution-times but also on progressively combining Machine Learning  algorithms with Econometric diagnosis tools into a friendly Graphical User Interface ([GUI](https://github.com/ParallelGSReg/GlobalSearchRegressionGUI.jl)) to simplify embarrassingly parallel quantitative-research.

In a Machine Learning environment (e.g. problems focusing on predictive analysis / forecasting accuracy) there is an increasing universe of “training/test” algorithms (many of them showing very interesting performance in Julia) to compare alternative results and find-out a suitable model.

However, problems focusing on causal inference require five important econometric features: 1) Parsimony (to avoid very large atheoretical models); 2) Interpretability (for causal inference, rejecting “intuition-loss” transformation and/or complex combinations); 3) Across-models sensitivity analysis (uncertainty is the only certainty; parameter distributions are preferred against “best-model” unique results); 4) Robustness to time series and panel data information (preventing the use of raw bootstrapping or random subsample selection for training and test sets); and 5) advanced residual properties (e.g. going beyond the i.i.d assumption and looking for additional panel structure properties -for each model being evaluated-, which force a departure from many traditional machine learning algorithms).

For all these reasons, researchers increasingly prefer advanced all-subset-regression approaches, choosing among alternative models by means of in-sample and/or out-of-sample criteria, model averaging results, bayesian priors for theoretical bounds on covariates coefficients and different residual constraints. While still unfeasible for large problems (choosing among hundreds of covariates), hardware and software innovations allow researchers to implement this approach in many different scientific projects, choosing among one billion models in a few hours using standard personal computers.

## Installation
GlobalSearchRegression requires [Julia 1.6.7 ](https://julialang.org/downloads/platform.html) (or newer releases) to be previously installed in your computer. Then, start Julia and type "]" (without double quotes) to open the package manager.

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
To run the simplest analysis just type:

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
julia> gsreg("your_dependent_variable *", dataname)
```
It performs an Ordinary Least Squares - all subset regression (OLS-ASR) approach to choose the best model among 2<sup>n</sup>-1 alternatives (in terms of in-sample accuracy, using the adjusted R<sup>2</sup>), where:
* DelimitedFiles is the Julia buit-in package we use to read data from csv files (throught its readdlm function);
* "path_to_your_data/your_data.csv" is a string that indentifies your comma-separated database, allowing for missing observations. It's assumed that your database first row is used to identify variable names;
* gsreg is the GlobalSearchRegression function that estimates all-subset-regressions (e.g. all-possible covariate combinations). In its simplest form, it has two arguments separated by a comma;
* The first gsreg argument is the general unrestricted model (GUM). It must be typed between double quotes. Its first string is the dependent variable name (csv-file names must be respected, remember that Julia is case sensitive). After that, you can include as many explanatory variables as you want. Alternative, you can replace covariates by wildcars as in the example above (e.g. * for all other variables in the csv-files, or qwert* for all other variables in the csv-file with names starting by "qwert"); and
* The second gsreg argument is name of the object containing your database. Following the example above, it must match the name you use in dataname = readdlm("path_to_your_data/your_data.csv", ',', header=true)

## Advanced usage
### Alternative data input
Databases can also be handled with CSV/DataFrames packages. To do so, remember to install them by using the add command in the Julia's package manager. Once it is done, just type:
```julia
]
pkg> add CSV, DataFrames
```
then return with backspace to main REPL interface
```julia
julia> using GlobalSearchRegression, CSV, DataFrames
julia> data = CSV.read("path_to_your_data/your_data.csv", DataFrame)
julia> gsreg("y *", data)
```

### Alternative GUM syntax
The general unrestricted model (GUM; the gsreg function first argument) can be written in many different ways, looking for a smooth transition for R and Stata users.
```julia
# Stata like
julia> gsreg("y x1 x2 x3", data)

# R like
julia> gsreg("y ~ x1 + x2 + x3", data)
julia> gsreg("y ~ x1 + x2 + x3", data=data)

# Strings separated with comma
julia> gsreg("y,x1,x2,x3", data)

# Array of strings
julia> gsreg(["y", "x1", "x2", "x3"], data)

# Using wildcards
julia> gsreg("y *", data)
julia> gsreg("y x*", data)
julia> gsreg("y x1 z*", data)
julia> gsreg("y ~ x*", data)
julia> gsreg("y ~ .", data)
```
### Additional options
GlobalSearchRegression advanced properties include almost all Stata-GSREG options but also additional features. Overall, our Julia's version has the following options:
* intercept::Union{Nothing, Bool}: by default the GUM includes an intercept as a fixed covariate (e.g. it's included in every model). Alternatively, users can erase it by selecting the intercept=false boolean option.
* estimator::Union{Nothing, String}: can be either "ols" or "ols_fe". The latter performs the OLS estimator on the modified panel dataset obtained from applying the "within transformation" to the original data. panel_id and time options must be identified to use estimator="ols_fe".
* fixedvars::Union{Nothing, Symbol, Vector{Symbol}}: if you have some interest variables that should remain ubiquitous, use this gsreg option to identify variables that will be used in all regressions (i.e. fixedvars = [:x1, x2]). fixedvars cannot be also included in the equation.
* outsample::Union{Nothing, Int}: it identify how many observations will be left to forecasting purposes (e.g. outsample = 10 indicates that the last 10 observations will not be used in the OLS estimation, remaining available for out-of-sample accuracy calculations). In a panel data context, outsample observations will be identified on a panel_id basis (i.e. the last 10 observations of each panel group).
* criteria::Union{Nothing, Symbol, Vector{Symbol}}: there are 7 different criteria (which must be included as symbols) to evaluate alternative models. For in-sample adjustment, user can choose one or many among the following: Adjusted R<sup>2</sup> (:r2adj, the default), Bayesian information criteria (:bic), Akaike and Corrected Akaike information criteria (:aic and :aicc), Mallows's Cp statistic (:cp), Sum of squared errors (also known as Residual sum of squares, :sse) and the Root mean square error (:rmse). For out-of-sample accuracy, there is available the out-of-sample root mean square error (:rmsout). Users are free to combine in-sample and out-of-sample information criteria, as well as many different in-sample criteria. For each alternative model, GlobalSearchRegrssion will calculate a composite ordering variable defined as the equally-weighted average of normalized (to guarantee equal weights) and harmonized (to ensure that higher values always identify better models) user's specified criteria.
* ttest::Union{Nothing, Bool}: by default there is no t-test (to resamble similar R packages), but users can active it by using the boolean option ttest=true.
* vce::Union{Nothing, String}: if ttest=true, you can also use available covariance corrections to improve ttest calculations. For cross-section and time series data, you can set vce="robust" to use the White correction. For panel data it is also available the option vce="cluster" to adjust for correlated errors within clusters (panel_id units).
* method::Union{Nothing, String}:this option has 9 valid entries ("qr_64", "cho_64", "svd_64", "qr_32", "cho_32", "svd_32", "qr_16", "cho_16", "svd_16") that can be used to alternatively run estimations with three different matrix factorization alternatives (QR, Cholesky and Single Value Decomposition) and three different datatypes alternatives (Float16, Float32 of Float64). The default is method="qr_32". It must be notice that Float16 only improves performance in those architectures where FPU allows Float16 arithmetic operations without conversions to Float32 (like Aarch64).
* modelavg::Union{Nothing, Bool}: by default, GlobalSearchRegression identifies the best model in terms of user' specified criteria. Complementarily, by setting the boolean modelavg option to true (modelavg=true), users will be able to obtain across-models' average coefficients, t-tests and additional statistics (using exponential weights based on the -potentially composite- ordering variable defined in the criteria option). Each alternative model has a weight given by w1/sum(w1), where w1 is defined as exp(-delta/2) and delta is equal to max(ordering variable)-(ordering variable).
* time::Union{Nothing, Symbol, String}: this option determines which variable will be used to date (and pre-sort) observations. Time variable must be included as a Symbol or String (e.g. time=:x1 or time="x1"). Neither, gaps nor missing observations are allowed in this variable (missing observations are allowed in any other variable). By using this option, additional residuals tests are enabled.
* panel_id::Union{Nothing, Symbol, String}: this option identifies the name of the variable containing panel groups identifiers (receives the argument both as a String or a Symbol). The content of this variable must be of an Integer type (with the same -and unique- identifier for each element of the same group).
* residualtests::Union{Nothing, Bool}: normality, heteroskedasticity and serial correlation tests will be performed when this boolean option is set to true (default is residualtests = nothing). Jarque-Bera statistic will be used to test for gaussian residuals. If panel_id is not defined, data will be treated as cross-section or time-series  (depending on time option values) and the White test will be used to check for heteroskedasticity. Otherwise, the modified Wald statistic will be computed to test for heteroskedasticity in a panel data context (as in the xttest3 Stata package). If time variable is defined (in the time option), serial correlation test will also be estimated: the Breusch-Godfrey for time series and the Wooldridge test for panel data (as in the xtserial Stata package). For each model, residual tests p-values will be saved into the model results that can be exported to a csv file using the resultscsv option.
* paneltests::Union{Nothing, Bool}: if panel_id is identified, fixed-effects estimations can include additional tests. When paneltests=true, the (ANOVA) F-test (to check if all u_i = 0) and the Breusch-Pagan Lagrange Multiplier test (to check for cross-sectional independence, as in the xttest2 Stata package) will be computed and stored in model results.
* resultscsv::Union{Nothing, String}: the string used in this option will define the name of the CSV file to be created into the working directory with output results. By default, no CSV file is created (only main results are displayed in the REPL).
* orderresults::Union{Nothing, Bool}: a boolean option to determine whether models should be sorted (by the user' specified information criteria) or not. By default there is no sorting performed (orderresults=false). It must be noticed that setting orderresults=true and method="svd_64" will significantly increase execution times.
* parallel::Union{Nothing, Int}: the most important option. It defines how many workers will be asigned to GlobalSearchRegresssion in order to parallelize calcultions. Using physical cores, speed-up is impressive. It is even superlinear with small databases (exploiting LLC multiplication). Notwidhstanding, speed-up efficiency decreases with logical cores (e.g. enabling hyperthreading). In order to use this option, julia must be initialized with the -p auto option or additional processors must be enables (with the addprocs(#) option, see the example below). Otherwise, Julia will only use one core and the parallel option of GlobalSearchRegression will not be available.

    
## Full-syntax example
This is a full-syntax example, assuming Julia 1.0.1 (or newer version), GlobalSearchRegression and DataFrames are already installed in a quad-core personal computer.
To enable parallelism, the Distributed package (including its addprocs command) must be activated before GlobalSearchRegression (in three different lines, one for Distributed, one for addprocs() and the other for GlobalSearchRegreesion, see the example below).

* For simulated time series data

```julia
# The first four lines are used to simulate data with random variables
julia> using DataFrames

julia> data = DataFrame([Vector{Union{Float64, Missing}}(rand(100)) for _ in 1:16], :auto)
julia> headers = [ :y ; [ Symbol("x$i") for i = 1:size(data, 2) - 1 ] ]
julia> rename!(data, headers)

# The following two lines enable multicore calculations
julia> using Distributed
julia> addprocs(4)
# Next line defines the working directory (where output results will be saved), for example:
julia> cd("c:\\")  # in Windows, or
julia> cd("/home/")  # in Linux
# Final two lines are used to perform all-subset-regression
julia> using GlobalSearchRegression
julia> gsreg(
       "y x2 x3 x4 x5 x6 x7 x8 x9 x10 x11 x12 x13 x14 x15", data,
       intercept=true,
       outsample=10,
       criteria=[:r2adj, :bic, :aic, :aicc, :cp, :rmse, :rmseout, :sse],
       ttest=true,
       method="svd_64",
       modelavg=true,
       residualtests=true,
       time=:x1,
       resultscsv="output.csv",
       parallel=4,
       orderresults=false
       )
```

* For panel data

```julia
julia> using DataFrames, Distributions, LinearAlgebra

# Artificial panel database creation
julia> N, T, K= 20, 500, 4
julia> correlation_matrix = [
       1.0  0.8  0.3  0.2
       0.8  1.0  0.4  0.3
       0.3  0.4  1.0  0.2
       0.2  0.3  0.2  1.0
       ]
julia> L = cholesky(correlation_matrix).L
julia> X = [L * rand(Normal(), K) for _ in 1:(N * T)]
julia> X = reduce(hcat, X)'
julia> panel_data = DataFrame(X, [:x1, :x2, :x3, :x4])
julia> panel_data[!, :id] = repeat(1:N, inner = T)
julia> panel_data[!, :time] = repeat(1:T, outer = N)
julia> alpha = rand(Normal(), N) .* 10  
julia> beta = [1.0, 0.6, 0.3, 0.15]  
julia> constant  = 2
julia> panel_data[!, :y] = [constant + alpha[panel_data1[i, :id]] + dot(beta, panel_data1[i, [:x1, :x2, :x3, :x4]]) + rand(Normal()) for i in 1:(N * T)]

# Parallel execution settings
julia> using Distributed
julia> addprocs()
julia> n = nworkers()

# GlobalSearchRegression implementation
julia> using GlobalSearchRegression, 
julia> model=gsreg(
                   "y x1 x3", 
                   panel_data; 
                   fixedvars = [:x2, :x4], 
                   time = :time, 
                   panel_id = :id, 
                   estimator = "ols_fe", 
                   method="cho_32", 
                   ttest=true, 
                   residualtests = true, 
                   paneltests = true, 
                   criteria=[:r2adj, :bic, :aic],
                   modelavg=true,
                   resultscsv="panel_data4.csv",
                   parallel=2
                   )
julia> println(model)
```
## Limitations
GlobalSearchRegression.jl is not able to handle databases with perfectly-collinear covariates. An error message will be retreived and users will have to select a new database with just one of these perfectly-colllinear variables. Similarly, it is not possible yet to include categorical variables as potential covariates. They should be transformed into dummmy variables before using GlobalSearchRegression.jl. Finally, string variables are not allowed.

## Credits
The GSReg module, which perform regression analysis, was written primarily by [Demian Panigo](https://github.com/dpanigo/), [Pablo Gluzmann](https://github.com/gluzmanngmail), [Valentín Mari](https://github.com/vmari/), [Adán Mauri Ungaro](https://github.com/adanmauri/) and [Nicolas Monzon](https://github.com/nicomzn) with the collaboration of [Esteban Mocskos](https://github.com/emocskos). The GlobalSearchRegression.jl module was inpired by GSReg for Stata, written by [Pablo Gluzmann](https://github.com/gluzmanngmail) and [Demian Panigo](https://github.com/dpanigo/).
