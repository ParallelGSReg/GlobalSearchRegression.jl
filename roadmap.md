## UI
- [ ] Graphics

## gsreg

### Inteface
- [ ] Do all the next steps in one single call.

### DataTransformation
- [X] Parse a given equation from multiple formats, including R, Stata and DataFrames
- [X] Reduce the database based on the equation (Including time if it is not included)
- [X] Order the database by time and panel variables then remove time if is not used as covariate
- [X] Transforms data representation for faster compute (Float64, Float32)
- [-] Feature extraction. Optional creation of non-linear realtionships (sqaure, lag, log, inv, [interaction])
- [X] Fixed effect
- [ ] [TODO: Explain better] First differences
- [X] Excludes observations with missing or null values
- [X] Adds the intercept if it was expecified
- [ ] Time validation
- [ ] Fixed effect or first differences validation

### Preliminary selection
- [ ] Preselection with Lasso.jl based on covariates number
 
### Selection
- [ ] Parallel processing
- [ ] Iterative estimators (LOGIT, PROBIT) *****
- [ ] OLS
- [ ] Adjust selection to interact with feature extraction
- [ ] Compute t-test/z value
- [ ] Outsample
- [ ] Compute selection criteria (aic, cic, bic, r2, r2adj, rmse, rmsout, cp)
- [ ] Model averaging
- [ ] Residual tests
- [ ] Sort by selection criteria
 
### Output decoration
- [ ] CSV
- [ ] JSON
- [ ] LaTeX
- [ ] Jupyter plot
- [ ] Short console text