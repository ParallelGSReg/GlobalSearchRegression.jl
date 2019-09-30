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
julia> gsreg("your_dependent_variable *", data)
```
It performs an Ordinary Least Squares - all subset regression (OLS-ASR) approach to choose the best model among 2<sup>n</sup>-1 alternatives (in terms of in-sample accuracy, using the adjusted R<sup>2</sup>), where:
* DelimitedFiles is the Julia buit-in package we use to read data from csv files (throught its readdlm function);
* "path_to_your_data/your_data.csv" is a strign that indentifies your comma-separated database, allowing for missing observations. It's assumed that your database first row is used to identify variable names;
* gsreg is the GlobalSearchRegression function that estimates all-subset-regressions (e.g. all-possible covariate combinations). In its simplest form, it has two arguments separated by a comma;
* The first gsreg argument is the general unrestricted model (GUM). It must be typed between double quotes. Its first string is the dependent variable name (csv-file names must be respected, remember that Julia is case sensitive). After that, you can include as many explanatory variables as you want. Alternative, you can replace covariates by wildcars as in the example above (e.g. * for all other variables in the csv-files, or qwert* for all other variables in the csv-file with names starting by "qwert"); and
* The second gsreg argument is name of the object containing your database. Following the example above, it must match the name you use in dataname = readdlm("path_to_your_data/your_data.csv", ',', header=true)