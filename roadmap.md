## UI
 - [ ] Graphics

# GlobalSearchRegression

## Implementation

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
 - [X] Create interface methods

### FeatureExtraction
 - [X] Allows to receive GSRegData
 - [X] Feature extraction. Optional creation of non-linear realtionships (sqaure, lag, log, inv, interaction)
 - [X] Option to excludes observations with missing or null values
 - [X] Create interface methods

### PreliminarySelection
 - [X] Normalize data in aux database to process
 - [X] Preselection with GLM.jl based on covariates number
 - [X] Filter data by results
 - [X] Create interface methods

### AllSubsetRegression
 - [X] Parallel processing
 - [X] OLS
 - [X] Create result datatype
 - [X] Create interface methods
 - [X] Adjust selection to interact with feature extraction
 - [X] Compute t-test
 - [X] Outsample
 - [X] Compute selection criteria (aic, cic, bic, r2, r2adj, rmse, rmsout, cp)
 - [X] Model averaging
 - [X] Residual tests
 - [X] Sort by selection criteria
 - [X] Fix parameters datatypes
 - [X] Fix GSRegData datatypes
 - [X] Fix GSRegResult datatypes
 - [X] Fix documentation
 - [X] Change module name
 - [X] Initialize options
 - [ ] Iterative estimators (LOGIT, PROBIT)
 - [ ] Compure z value

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

### OutputDecoration
 - [ ] CSV
 - [ ] JSON
 - [ ] LaTeX
 - [ ] Jupyter plot
 - [ ] Short console text

## Testing and documentation

### Preprocessing
 - [X] Create tests
 - [X] Update Readme
 - [ ] Test of Seasonal adjustment, panel data and time data
 - [ ] Initialize options
 - [ ] Create test data
 - [ ] Refactor tests

### FeatureExtraction
 - [ ] Update Readme
 - [ ] Initialize options
 - [ ] Create test data
 - [ ] Create tests

### Preliminary selection
 - [ ] Create tests
 - [ ] Update readme

### AllSubsetRegression
 - [ ] Create test data
 - [ ] Create tests
 - [ ] Documentation
