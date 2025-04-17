library(data.table)

LTR_diff <- function(file, col_name, col_std = NULL) {
  # Load the dataset into a data table
  dt <- data.table(read.csv(file))
  
  # Select only the specified columns
  subdt <- dt[, ..col_name]
  
  # Remove rows with missing values
  dt_clean <- subdt[complete.cases(subdt), ]
  
  # Identify unique IDs where CVD == 1
  cvd_id <- unique(dt_clean[which(CVD == 1), RANDID])
  
  # Initialize eta_ij column with 0
  dt_clean[, eta_ij := 0]
  
  # Identify covariate column names, excluding key identifier columns
  var_name <- setdiff(col_name, c("RANDID", "TIME", "CVD", "TIMECVD"))
  
  # Process each ID where CVD == 1
  for (i in 1:length(cvd_id)) {
    if (i == 1) {
      if (length(dt_clean[, (which(RANDID %in% cvd_id[i] & TIME < TIMECVD))]) > 0) {
        # Find the last time point before CVD and the last recorded time
        t_bf_cvd <- dt_clean[, max(which(RANDID %in% cvd_id[i] & TIME < TIMECVD))]
        t_end <- dt_clean[, max(which(RANDID %in% cvd_id[i]))]
        
        # Augment the dataset by duplicating the row before CVD
        dt_augm <- rbind(dt_clean[1:t_bf_cvd, ],
                         dt_clean[t_bf_cvd, ],
                         dt_clean[-(1:t_end), ])
        
        # Modify the newly added row to indicate CVD occurrence
        dt_augm[t_bf_cvd + 1, (var_name) := NA]
        dt_augm[t_bf_cvd + 1, eta_ij := 1]
        dt_augm[t_bf_cvd + 1, TIME := TIMECVD]
      } else {
        # Handle cases where no valid time points exist before CVD occurrence
        t_bf_cvd <- dt_clean[, min(which(RANDID %in% cvd_id[i]))]
        t_end <- dt_clean[, max(which(RANDID %in% cvd_id[i]))]
        
        dt_augm <- rbind(dt_clean[1:t_bf_cvd, ],
                         dt_clean[-(1:t_end), ])
        
        dt_augm[t_bf_cvd, (var_name) := NA]
        dt_augm[t_bf_cvd, eta_ij := 1]
        dt_augm[t_bf_cvd, TIME := TIMECVD]
      }
    } else {
      # Check if there is valid data before CVD occurrence
      if (length(dt_augm[, (which(RANDID %in% cvd_id[i] & TIME < TIMECVD))]) > 0) {
        t_bf_cvd <- dt_augm[, max(which(RANDID %in% cvd_id[i] & TIME < TIMECVD))]
        t_end <- dt_augm[, max(which(RANDID %in% cvd_id[i]))]
        
        dt_augm <- rbind(dt_augm[1:t_bf_cvd, ],
                         dt_augm[t_bf_cvd, ],
                         dt_augm[-(1:t_end), ])
        
        dt_augm[t_bf_cvd + 1, (var_name) := NA]
        dt_augm[t_bf_cvd + 1, eta_ij := 1]
        dt_augm[t_bf_cvd + 1, TIME := TIMECVD]
      } else {
        # Handle cases where no valid time points exist before CVD occurrence
        t_bf_cvd <- dt_augm[, min(which(RANDID %in% cvd_id[i]))]
        t_end <- dt_augm[, max(which(RANDID %in% cvd_id[i]))]
        
        dt_augm <- rbind(dt_augm[1:t_bf_cvd, ],
                         dt_augm[-(1:t_end), ])
        
        dt_augm[t_bf_cvd, (var_name) := NA]
        dt_augm[t_bf_cvd, eta_ij := 1]
        dt_augm[t_bf_cvd, TIME := TIMECVD]
      }
    }
  }
  
  # Standardize selected columns if specified
  if (length(col_std) == 0) {
    var_name_all <- var_name
  } else {
    col_std_name <- paste(col_std, "s", sep = "")
    dt_augm[, (col_std_name) := lapply(.SD, scale), .SDcols = col_std]
    var_name_all <- c(var_name, col_std_name)
  }
  
  # Create lagged covariate columns
  col_L <- paste0(var_name_all, "_L")
  dt_augm[, (col_L) := 
            lapply(.SD, function(x) {
              result <- shift(x, type = "lag")
              result[1] <- Inf # Set the first data entry to Inf
              return(result)
            }), by = RANDID, .SDcols = var_name_all]
  
  # Compute time difference between consecutive observations per ID
  dt_augm[, diff_t := diff(c(0, TIME)), by = RANDID]
  
  # Create visit count per ID
  dt_augm[, visit := seq_along(TIME) - 1, by = RANDID]
  
  # Rename columns for clarity
  col_R <- paste0(var_name_all, "_R")
  setnames(dt_augm, old = var_name_all, new = col_R)
  setnames(dt_augm, old = "RANDID", new = "ID")
  setnames(dt_augm, old = "TIME", new = "t_ij")
  
  # Select relevant columns for the final dataset
  dt_final <- dt_augm[t_ij != 0, c("ID", "visit", "t_ij", "diff_t", "eta_ij",
                                   col_L, col_R), with = FALSE]
  
  # Remove rows where any value is Inf
  dt_out <- dt_final[-unique(which(dt_final == Inf, arr.ind = TRUE)[, 1]), ]
  
  return(dt_out)
}
