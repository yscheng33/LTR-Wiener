# R Functions for Longitudinal First-hitting Time Threshold Regression for Survival Data: with Applications to Wiener Processes

This repository contains the R functions used for the paper "Longitudinal First-hitting Time Threshold Regression for Survival Data: with Applications to Wiener Processes" submitted to Stats.

## Folder Structure
- `LTR_diff.R`: Reformat the longitudinal data into an input data for the function “LTR_Wiener”
- `LTR_Wiener.R`: LTR analysis for the class of Wiener processes
project-root/
├── main.R                # Main script for running the analysis
├── functions/            # User-defined functions
│   └── function1.R       # Example of a user-defined function
├── data/                 # Sample data used in the example
│   └── example_data.csv  # Example data file
├── docs/                 # Documentation and user guide
│   ├── user_guide.md     # Step-by-step instructions for using the functions
│   └── usage_example.R   # Sample code demonstrating typical usage
└── README.md

## Requirements
R version 4.4.2+
Install required packages using:
```R
install.packages("threg")
install.packages("data.table")
