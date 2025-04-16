LTR_Wiener <- function (formula, data, init_value=NA,
option="optim",alg="Nelder-Mead") 
{
  # Capture the function call
  cl <- match.call()
  # Find the index of 'formula' and 'data' arguments in the function call
  indx <- match(c("formula", "data"), names(cl), nomatch = 0)
  
  # If 'formula' argument is not provided, stop with an error
  if (indx[1] == 0) 
    stop("A formula argument is required")
  
  # Convert the provided 'formula' into a Formula object
  f <- Formula(formula)
  
  # Extract the left-hand side (lhs) of the formula for 'f'
  f1 <- formula(f, lhs = 1)
  
  # Convert the lhs of f1 into a Formula object
  f1 <- Formula(f1)
  
  # Extract the right-hand side (rhs) of the formula for 'f1' and 
  # check if it's properly specified
  f2 <- formula(f1, lhs = 0)
  if (length(f2[[2]]) != 3) 
    stop(paste("Predictors for both y0 and mu should be specified"))
  
  # Extract the formula for the initial status
  f_y <- formula(f1, lhs = 0, rhs = 1)
  
  # Extract the formula for the mean
  f_mu <- formula(f1, lhs = 0, rhs = 2)
  
  if(f_mu=="~1"){
    # If the formula for 'mu' is just "~1" (intercept), 
    # create a matrix of ones
    x_mu <- matrix(1,dim(data)[1],1)
  }else{
    # Find the column index corresponding to 'mu'
    cl_mu <- match(paste(all.vars(f_mu),"_L",sep=""), 
                   names(data), nomatch = 0)
    
    # If the column index corresponding to 'mu' is not found, 
    # stop with an error
    if(any(cl_mu==0)) stop("The _L variable name is incorrect.")
    
    # Create the covariate matrix 'x_mu' to match the selected columns 
    # from input data to conduct regression for mu
    x_mu <- as.matrix(data.frame(1,data[,cl_mu]))
  }
  
  # For simplicity, for each interval j, we let 'y0' 
  # to represent the left end state y_{j-1} and 
  # 'y' to represent the right end state y_j.
  if(f_y=="~1"){
    # If the formula for 'y' is just "~1" (intercept), 
    # create a matrix of ones
    x_y <- matrix(1,dim(data)[1],1)
    x_y0 <- matrix(1,dim(data)[1],1)
  }else{
    # Find the column index corresponding to 'y'
    cl_y <- match(paste(all.vars(f_y),"_R",sep=""), 
                  names(data), nomatch = 0)
    
    # If the column index corresponding to 'y' is not found, 
    # stop with an error
    if(any(cl_y==0)) stop("The _R variable name is incorrect.")
    
    # Create the covariate matrix 'x_y' to match the selected columns 
    # from input data to conduct regression for 'y'
    x_y <- as.matrix(data.frame(1,data[,cl_y]))
    
    # Find the column index corresponding to 'y0'
    cl_y0 <- match(paste(all.vars(f_y),"_L",sep=""), 
                   names(data), nomatch = 0)
    
    # If the column index corresponding to 'y0' is not found, 
    # stop with an error
    if(any(cl_y0==0)) stop("The _L variable name is incorrect.")
    
    # Create the covariate matrix 'x_y0' to match the selected columns 
    # from input data to conduct regression for 'y0'
    x_y0 <- as.matrix(data.frame(1,data[,cl_y0]))
  }
  
  # Define the function for 'y' that calculates the product of x_y matrix 
  # and para_y0 vector
  y <- function(para_y0) {
    x_y %*% para_y0
  }
  # Define the function for 'y0' that calculates the product of x_y0 matrix 
  # and para_y0 vector
  y0 <- function(para_y0) {
    x_y0 %*% para_y0
  }
  # Define the function for 'mu' that calculates the product of x_mu matrix 
  # and para_mu vector
  mu <- function(para_mu) {
    x_mu %*% para_mu
  }
  
  # Define the log-likelihood function 'logf' which computes the log 
  # of the likelihood
  logf <- function(para) {
    # If 'f_y' contains variables, split the parameters accordingly; 
    # otherwise, use the first parameter for y0
    if(length(all.vars(f_y))>0){
      para_y0 <- as.matrix(para[1:(length(all.vars(f_y))+1)])
    }else{
      para_y0 <- as.matrix(para[1])
    }
    
    # If 'f_mu' contains variables, split the parameters accordingly; 
    # otherwise, use the next parameter for mu
    if(length(all.vars(f_mu))>0){
      para_mu <- as.matrix(para[(length(all.vars(f_y)) + 2):
          (length(all.vars(f_y)) + length(all.vars(f_mu)) + 2)])
    }else{
      para_mu <- as.matrix(para[length(all.vars(f_y)) + 2])
    }
    
    # Set variance s2 to 1 (could be adjusted later if needed)
    s2 <- 1
    
    # Calculate the log-likelihood:
    # The first part computes the likelihood for the 'failure' event
    # The second part computes the likelihood for the non-failure event
    -sum(failure * (log(y0(para_y0))-log(2*pi*s2*dt^3)/2-
      (y0(para_y0)+mu(para_mu)*dt)^2/(2*s2*dt))) -
      sum((1 - failure) * (-log(2*pi*s2*dt)/2-(y(para_y0)-y0(para_y0)-
       mu(para_mu)*dt)^2/(2*s2*dt)+
       log(1-exp(-2*y0(para_y0)*y(para_y0)/(s2*dt)))
      ),na.rm=T)
  }
  
  # Initialize parameters based on 'init_value' or default to a vector of 0s 
  # if 'init_value' is NA
  if(any(is.na(init_value))){
    p <- c(1,rep(0, (length(all.vars(f_y)) + length(all.vars(f_mu)))+1))  
  }else{
    p <- init_value
  }
  # Extract the "diff_t" variable from the data frame and 
  # convert it to a matrix
  dt <- as.matrix(data.frame(data[,match("diff_t", 
   names(data), nomatch = 0)]))
  
  # Extract the "eta_ij" variable from the data frame and 
  # convert it to a matrix
  failure <- as.matrix(data.frame(data[,match("eta_ij", 
   names(data), nomatch = 0)]))
  
  # The optimization method selected is "optim"
  if(option=="optim"){
    # Use the 'optim' function to perform the optimization, 
    # passing initial parameters (p), the log-likelihood function (logf),
    # setting hessian=T to compute the Hessian matrix, 
    # and specifying the optimization method (alg)
    est <- optim(p,logf,hessian=T,method=alg)
    
    # Name the estimated parameters: Add "y0" and "mu" labels along with 
    # their corresponding intercept and variables
    names(est$par) <- c(paste("y0:", c("(Intercept)",all.vars(f_y))), 
                        paste("  mu:", c("(Intercept)",all.vars(f_mu))))
    
    # Calculate the log-likelihood (negative of the objective function value)
    loglik = (-1) * est$value
    
    # Create a list with the estimated coefficients, 
    # variance (inverse of the Hessian), log-likelihood,
    # AIC (Akaike Information Criterion), iteration count, 
    # function call, and variable names for 'y0' and 'mu'
    fit <- list(coefficients = est$par, var = solve(est$hessian), 
                loglik = loglik, 
                AIC = (-2) * loglik + 2 * (length(all.vars(f_y)) + 
                 length(all.vars(f_mu))), iter = est$counts[1], 
                call = cl, y0 = all.vars(f_y), mu = all.vars(f_mu))
  }
  
  # The optimization method selected is "nlm", and the details are 
  # similar to the "optim" option
  if(option=="nlm"){
    est <- nlm(logf, p, hessian = TRUE)
    names(est$estimate) <- c(paste("y0:", c("(Intercept)",all.vars(f_y))), 
                             paste("  mu:", c("(Intercept)",all.vars(f_mu))))
    loglik = (-1) * est$minimum
    fit <- list(coefficients = est$estimate, var = solve(est$hessian),
                loglik = loglik, 
                AIC = (-2) * loglik + 2 * (length(all.vars(f_y)) +
                 length(all.vars(f_mu))), iter = est$iterations,
                call = cl, y0 = all.vars(f_y), mu = all.vars(f_mu))
  }
  
  # Assign the class "threg" to the resulting list 'fit' for 
  # custom processing or output handling
  class(fit) <- "threg"
  
  # Return the final fitted result
  fit
}