Source Code of “LTR_Wiener” Function for LTR Model with Latent Wiener processes

The function “threg” developed in [10] was originally designed to conduct TR analysis for cross sectional data. 
To conduct LTR, one should decomposed the longitudinal data into a sequence of inter-visit data elements as demonstrated in sections 1 to 3. 
Using the library of the “threg” function for TR models, we create the R function for LTR and name it as “LTR_Wiener”. 
In the “LTR_Wiener” function, we use the reformated longitudinal data as the input file, 
we use the likelihood functions defined by equations (5) and (16) described in subsections 3.2 and 3.3. 
We conduct simultaneous regressions using matrix defined in Equations (17) and (18). 
We also add options to allow users to input initial values and switch between optimization methods. 
These modifications facilitate the iteration process during the estimation of regression coefficients in the LTR model.

Specifically, the “LTR_Wiener” function includes five arguments as listed below.

1. formula: A ‘formula’ object where the response variable appears on the left of the ˜ operator and the independent variables are specified on the right. 
   The response must be a ‘Surv’ object, as returned by the “Surv” function in the survival package. 
   For subject $i$, at visit $j$, we include time increment variables diff$_{t_j} = t_{i,j} − t_{i,j−1}$ and an outcome indicator $\eta_{i,j} = I(CVD)$. 
   On the right of the ˜ operator, the | operator is used to separate independent variables for linear regression functions of $y_{j−1}$ and $\mu_j$ in the LTR model. 
   With $Z_{i,1,j}=1$ for each subject $i$ and visit $j$, the intercept is included in the model by default. 
2. data: Specifies input data set, which must include at least the time increments variable diff$_{t_j}$ and outcome indicator $\eta_{i,j}$. 
   The censoring variable should be coded as 1 for observed failure and 0 for right censoring. 
   The dataset can also contain other independent variables relevant to the LTR model. 
3. init_value: Initial values for the parameters to be optimized over. 
   The sequence of initial values follows the order of the independent variables specified on the right side of the ˜ operator in the formula (as described in item 1). 
   The length of the initial values should match the number of regression coefficients. 
   By default, the initial values are set to a zero vector. 
4. option: Specifies the optimization function to be used. The options available are “optim” or “nlm”, referring to the respective functions in the base stats package in R. 
   The default option is “optim”. 
5. alg: Specifies the minimization method to be used when option = “optim”. 
   The available methods are “Nelder-Mead”, “BFGS”, “CG”, “L-BFGS-B”, “SANN” or “Brent” as provided by the “optim” function. The default method is “Nelder-Mead”. 
   For more details on each method, please refer to the R documentation for “optim”.

Note that, to improve the optimization process, users may consider implementing iterative procedures, 
where the estimation results from one fitting are utilized as the initial values for subsequent iterations, 
and alternate optimization algorithms are applied.
