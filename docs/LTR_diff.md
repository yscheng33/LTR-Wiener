Steps to Reformat the Longitudinal Data into an Input Data for the R function “LTR_Wiener”.

The following four steps describe how to convert a longitudinal data set into a sequence of inter-visit data elements as demonstrated in Table 3 so that covariates can be
included in the conditional likelihood (1). 
Results of these 4 steps create the input file for the “LTR_Wiener” R function.

1. Decompose the longitudinal data set into a sequence of inter-visit data elements.
   For each subject i, with baseline visit labeled as visit 0, we denote the first interval as from visit 0 to visit 1,
   corresponding to time 0 to ti,1. Similarly, the jth interval is from visit j − 1 to visit j corresponding to time from ti,j−1 to ti,j.
2. Create a column of time increments diff_{tj} recording the length of time span for each interval.
   For subject i, the time increment in the jth interval is diff_{tj} = t_{i,j} − t_{i,j−1}.
3. Create a column of outcome indicators for an event η_{i,j} at the closing of the jth interval.
   For subject i, label the outcome indicator for the jth interval as η_{i,j} = 1 if subject i encountered an event at time t_{i,j}, and η_{i,j} = 0 otherwise.
4. Label the kth covariates measured at time ti,j−1 and ti,j for the jth interval.
   Covariates measured at time ti,j−1 will be labeled as “CovariateName_L”.
   Similarly, covariate measured at time ti,j, will be labeled as “CovariateName_R”.
   We use covariates at both the left and right end of the interval j in likelihood computations.
   For example, if covariate AGE is included in the LTR model, two columns labeled as “AGE_L” and “AGE_R” are needed in computing the regressions.
   
We provide the “LTR_diff” function to help users create the input file required by the “LTR_Wiener” function. 
The “LTR_diff” function includes three arguments as listed below.
1. file: Specifies the input longitudinal data set, which shouldbe provided as a .csv file.
   The dataset must contain at least columns “ID” (unique identification number for each participant), ”TIME” (number of unit time since baseline exam),
   ”EVENT” (outcome indicator of an event, the censoring variable should be coded as 1 for observed failure and 0 for right censoring) and
   ”EVENTTIME” (number of unit time from baseline exam to first event during the followup or number of unit time from baseline to
   censor time). Additional independent variables relevant to the LTR model may also be included.
2. col_name: Specifies the column names to be included for the LTR analysis.
   The columns “ID”, ”TIME”,”EVENT” and ”EVENTTIME” mentioned in point 1 must be included.
3. col_std: Specifies the column names of covariates to be standardized. The default is NULL.

Below are the sample code for “LTR_diff” function:

R> library(data.table)
R> long.data <- "longitudinal_dataset.csv"
R> col.select <- c("ID","TIME","EVENT","EVENTTIME","AGE")
R> col.scale <- c("AGE","TOTCHOL")
R> LTR.data <- LTR_diff(file = long.data, col_name = col.select, col_std = col.scale)
R> write.table(LTR.data,"LTR-data.csv",sep=",",row.names=F)

