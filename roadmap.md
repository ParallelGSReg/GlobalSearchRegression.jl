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
 
### FeatureExtraction
 - [ ] Allows to receive GSRegData
 - [ ] Feature extraction. Optional creation of non-linear realtionships (sqaure, lag, log, inv, interaction)
 - [ ] Option to excludes observations with missing or null values
 - [ ] Create tests
 - [ ] Update Readme

### Preliminary selection
- [ ] Preselection with GLM.jl based on covariates number
 
### Selection
- [-] Parallel processing [TEST]
- [ ] Iterative estimators (LOGIT, PROBIT) *****
- [X] OLS [TEST]
- [X] Adjust selection to interact with feature extraction [TEST]
- [X] Compute t-test [TEST]
- [ ] Compure z value
- [X] Outsample [TEST]
- [X] Compute selection criteria (aic, cic, bic, r2, r2adj, rmse, rmsout, cp)
- [X] Model averaging [TEST]
- [X] Residual tests [TEST]
- [X] Sort by selection criteria
- [ ] Fix parameters datatypes
- [ ] Fix GSRegData datatypes
- [ ] Fix GSRegResult datatypes
- [ ] Fix documentation
- [ ] Change module name

### Output decoration
- [ ] CSV
- [ ] JSON
- [ ] LaTeX
- [ ] Jupyter plot
- [ ] Short console text
