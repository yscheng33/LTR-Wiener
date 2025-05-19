# R Functions for Longitudinal Survival Analysis Using First Hitting Time Threshold Regression: With Applications to Wiener Processes

This repository contains the R functions developed for the paper: "Longitudinal Survival Analysis Using First Hitting Time Threshold Regression: With Applications to Wiener Processes," published in Stats, 8, 32. https://doi.org/10.3390/stats8020032

## Folder Structure
- `LTR_diff.R`: Reformat the longitudinal data into an input data for the function “LTR_Wiener”
- `LTR_Wiener.R`: LTR analysis for the class of Wiener processes
-  docs/ : user guides `LTR_diff.md` and `LTR_Wiener.md`
-  data/ : a sample dataset `longitudinal_dataset.csv` for demonstrating the use of the function “LTR_diff”
## Requirements
R version 4.5.0+
Install required packages using:
```R
install.packages("threg")
install.packages("data.table")
