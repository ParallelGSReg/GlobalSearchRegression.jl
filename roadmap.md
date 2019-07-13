## UI
 - [ ] Graphics

## gsreg

### Inteface
 - [ ] Do all the next steps in one single call.

### Preprocessing
 - [X] Parse a given equation from multiple formats, including R, Stata and DataFrames
 - [X] Reduce the database based on the equation (Including time if it is not included)
 - [X] Order the database by time and panel variables then remove time if is not used as covariate
 - [X] Panel validation
 - [X] Time validation
 - [X] Transforms data representation for faster compute (Float64, Float32)
 - [X] Adds the intercept if it was expecified
 - [X] Sort by time and panel
 - [X] Seasonal adjustment
 - [X] Remove outliers
 - [X] Fixed effect
 - [X] Option to excludes observations with missing or null values
 - [X] Create tests
 - [X] Update Readme
 - [ ] Test of Seasonal adjustment, panel data and time data
 - [ ] Initialize options
 - [ ] Create test data
 - [ ] Refactor tests

### FeatureExtraction
 - [X] Allows to receive GSRegData
 - [X] Feature extraction. Optional creation of non-linear realtionships (sqaure, lag, log, inv, interaction)
 - [X] Option to excludes observations with missing or null values
 - [ ] Keep data
 - [ ] Update Readme
 - [ ] Initialize options
 - [ ] Create test data
 - [ ] Create tests

### Preliminary selection
 - [ ] Normalize data in aux database to process
 - [X] Preselection with GLM.jl based on covariates number
 - [X] Filter data by results
 - [ ] Keep data
 - [ ] Create tests
 - [ ] Update readme

### Selection
 - [ ] Parallel processing [TEST]
 - [ ] Iterative estimators (LOGIT, PROBIT) *****
 - [ ] OLS [TEST]
 - [ ] Adjust selection to interact with feature extraction [TEST]
 - [ ] Compute t-test [TEST]
 - [ ] Compure z value
 - [ ] Outsample [TEST]
 - [ ] Compute selection criteria (aic, cic, bic, r2, r2adj, rmse, rmsout, cp)
 - [ ] Model averaging [TEST]
 - [ ] Residual tests [TEST]
 - [ ] Sort by selection criteria
 - [ ] Fix parameters datatypes
 - [ ] Fix GSRegData datatypes
 - [ ] Fix GSRegResult datatypes
 - [ ] Fix documentation
 - [ ] Change module name
 - [ ] Initialize options
 - [ ] Create test data
 - [ ] Create tests
  
### K-fold cross-validation ✌
 kcross = true
 rehacer todo pero en muestras divididas en porciones k iguales, randomly, si tiene time, las divisiones son contiguas, 
 si tiene panel y time (pais, prov), tienen que ser contiguas y no se puede partir el panel 

k = 4

60       | 40       | 20
k11 = 15 | k21 = 10 | k31 = 5   ===> 30 
k12 = 15 | 
k13 = 15
k14 = 15

  - usas todas - 1 porcion
  - rmse outsample con la restante n-1
  - repetir por todas las combinaciones, siempre de a 1
  - avg(rmse)
  - avg(b)
  - salida: tabla
  - sequential

### Output decoration
 - [ ] CSV
 - [ ] JSON
 - [ ] LaTeX
 - [ ] Jupyter plot
 - [ ] Short console text
