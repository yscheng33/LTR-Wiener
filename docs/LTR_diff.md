Steps to Reformat the Longitudinal Data into an Input Data for the R function “LTR_Wiener”.

The following four steps describe how to convert a longitudinal data set into a sequence of inter-visit data elements as demonstrated in Table 3 so that covariates can be
included in the conditional likelihood (1). 
Results of these 4 steps create the input file for the “LTR_Wiener” R function.

1. Decompose the longitudinal data set into a sequence of inter-visit data elements.
   For each subject $i$, with baseline visit labeled as visit 0, we denote the first interval as from visit 0 to visit 1,
   corresponding to time 0 to $t_{i,1}$. Similarly, the jth interval is from visit $j − 1$ to visit $j$ corresponding to time from $t_{i,j−1}$ to $t_{i,j}$.
2. Create a column of time increments $diff_{t_j}$ recording the length of time span for each interval.
   For subject $i$, the time increment in the $j$-th interval is $diff_{t_j} = t_{i,j} − t_{i,j−1}$.
3. Create a column of outcome indicators for an event $\eta_{i,j}$ at the closing of the $j$-th interval.
   For subject $i$, label the outcome indicator for the $j$-th interval as $\eta_{i,j} = 1$ if subject $i$ encountered an event at time $t_{i,j}$, and $\eta_{i,j} = 0$ otherwise.
4. Label the $k$-th covariates measured at time $t_{i,j−1}$ and $t_{i,j}$ for the jth interval.
   Covariates measured at time $t_{i,j−1}$ will be labeled as “CovariateName_L”.
   Similarly, covariate measured at time $t_{i,j}$, will be labeled as “CovariateName_R”.
   We use covariates at both the left and right end of the interval $j$ in likelihood computations.
   For example, if covariate AGE is included in the LTR model, two columns labeled as “AGE_L” and “AGE_R” are needed in computing the regressions.
   
We provide the “LTR_diff” function to help users create the input file required by the “LTR_Wiener” function. 
The “LTR_diff” function includes three arguments as listed below.
1. file: Specifies the input longitudinal data set, which should be provided as a .csv file.
   The dataset must contain at least columns “ID” (unique identification number for each participant), ”TIME” (number of unit time since baseline exam),
   ”EVENT” (outcome indicator of an event, the censoring variable should be coded as 1 for observed failure and 0 for right censoring) and
   ”EVENTTIME” (number of unit time from baseline exam to first event during the followup or number of unit time from baseline to
   censor time). Additional independent variables relevant to the LTR model may also be included.
2. col_name: Specifies the column names to be included for the LTR analysis.
   The columns “ID”, ”TIME”,”EVENT” and ”EVENTTIME” mentioned in point 1 must be included.
3. col_std: Specifies the column names of covariates to be standardized. The default is NULL.
   A suffix “s” after the name of the covariate will be added in the output column name, i.e., “CovariateNames_L” and “CovariateNames_R”.

Below are the sample code for “LTR_diff” function:

library(data.table)

long.data <- "longitudinal_dataset.csv"

col.select <- c("ID","TIME","EVENT","EVENTTIME","AGE","TOTCHOL")

col.scale <- c("AGE","TOTCHOL")

LTRdata <- LTR_diff(file = long.data, col_name = col.select, col_std = col.scale)

save(LTR.data, file = "LTRdata.Rdata", sep=",", row.names=F)

