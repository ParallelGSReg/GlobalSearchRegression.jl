## Advanced usage
### Alternative data input
Databases can also be handled with CSV/DataFrames packages. To do so, remember to install them by using the add command in the Julia's package manager. Once it is done, just type:
```julia
julia> using GlobalSearchRegression, CSV, DataFrames
julia> data = CSV.read("path_to_your_data/your_data.csv")
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
* intercept: by default the GUM includes an intercept as a fixed covariate (e.g. it's included in every model). Alternatively, users can erase it by selecting the intercept=false boolean option.
* outsample: it identify how many observations will be left to forecasting purposes (e.g. outsample=10 indicates that the last 10 observations will not be used in the OLS estimation, remaining avaliable for out-of-sample accuracy calculations).
* criteria: there are 7 different criteria (which must be included as symbols) to evaluate alternative models. For in-sample adjustment, user can choose one or many among the following: Adjusted R<sup>2</sup> (:r2adj, the default), Bayesian information criteria (:bic), Akaike and Corrected Akaike information criteria (:aic and :aicc), Mallows's Cp statistic (:cp), Sum of squared errors (also known as Residual sum of squares, :sse) and the Root mean square error (:rmse). For out-of-sample accuracy, there is available the out-of-sample root mean square error (:rmsout). Users are free to combine in-sample and out-of-sample information criteria, as well as many different in-sample criteria. For each alternative model, GlobalSearchRegrssion will calculate a composite ordering variable defined as the equally-weighted average of normalized (to guarantee equal weights) and harmonized (to ensure that higher values always identify better models) user's specified criteria.
* ttest: by default there is no t-test (to resamble similar R packages), but users can active it by using the boolean option ttest=true.
* method: this option can be used to alternatively run estimations with Float32 of Float64 datatype. The default is Float32 (to speed-up calculations) but users can modify it through the method="precise" string option.
* vectoroperation: it's well known that Julia's packages run faster with [de-vectorized](https://julialang.org/blog/2013/09/fast-numeric) code ([unlike most languages](https://data-flair.training/blogs/r-performance-tuning-techniques/) like R, Python or Matlab). We include this option to switch between vector operations and loops for benchmark purposes. By default, the boolean vectoroperation option is set to false. Users are free to change it through vectoroperation=true.
* modelavg: by default, GlobalSearchRegression identifies the best model in terms of user' specified criteria. Complementarily, by setting the boolean modelavg option to true (modelavg=true), users will be able to obtain across-models' average coefficients, t-tests and additional statistics (using exponential weights based on the -potentially composite- ordering variable defined in the criteria option). Each alternative model has a weight given by w1/sum(w1), where w1 is defined as exp(-delta/2) and delta is equal to max(ordering variable)-(ordering variable).
* time: this option determines which variable will be used to date (and pre-sort) observations. Time variable must be included as a symbol (e.g. time=:x1). Neither, gaps nor missing observations are allowed in this variable (missing observations are allowed in any other variable). By using this option, additional residuals tests are enabled.
* residualtest: White heteroskedasticity and Jarque-Bera normality  test  will be performed when this boolean option is set to true (default is residualtest=false). Additionally, when time variable is defined, a third residual test is calculated (the Breusch-Godfrey test for autocorrelation). For each model, residual tests p-values will be saved into the user defined CSV file.
* csv / resultscsv: the string used in this option will define the name of the CSV file to be created into the working directory with output results. By default, no CSV file is created (only main results are displayed in the REPL).
* orderresults: a boolean option to determine whether models should be sorted (by the user' specified information criteria) or not. By default there is no sorting performed (orderresults=false). It must be noticed that setting orderresults=true, method="precise" and vectoroperation=true will significantly increase execution times. 
* parallel: the most important option. It defines how many workers will be asigned to GlobalSearchRegresssion in order to parallelize calcultions. Using physical cores, speed-up is impressive. It is even superlinear with small databases (exploiting LLC multiplication). Notwidhstanding, speed-up efficiency decreases with logical cores (e.g. enabling hyperthreading). In order to use this option, julia must be initialized with the -p auto option or additional processors must be enables (with the addprocs(#) option, see the example below). Otherwise, Julia will only use one core and the parallel option of GlobalSearchRegression will not be available. 
