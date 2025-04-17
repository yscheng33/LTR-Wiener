# R Functions for Longitudinal First-hitting Time Threshold Regression for Survival Data: with Applications to Wiener Processes

This repository contains the R functions used for the paper "Longitudinal First-hitting Time Threshold Regression for Survival Data: with Applications to Wiener Processes" submitted to Stats.

## Folder Structure
- `LTR_diff.R`: Reformat the longitudinal data into an input data for the function “LTR_Wiener”
- `LTR_Wiener.R`: LTR analysis for the class of Wiener processes

## Requirements
R version 4.4.2+
Install required packages using:
```R
install.packages("threg")
install.packages("data.table")
