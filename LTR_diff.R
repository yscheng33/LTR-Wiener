library(data.table)

LTR_diff <- function(file, col_name, col_std = NULL) {
  # Load the dataset into a data table
  dt <- data.table(read.csv(file))
  
  # Select only the specified columns
  subdt <- dt[, ..col_name]
  
  # Remove rows with missing values
  dt_clean <- subdt[complete.cases(subdt), ]
  
  # Identify unique IDs where EVENT == 1
  EVENT_id <- unique(dt_clean[which(EVENT == 1), ID])
  
  # Initialize eta_ij column with 0
  dt_clean[, eta_ij := 0]
  
  # Identify covariate column names, excluding key identifier columns
  var_name <- setdiff(col_name, c("ID", "TIME", "EVENT", "EVENTTIME"))
  
  # Process each ID where EVENT == 1
  for (i in 1:length(EVENT_id)) {
    if (i == 1) {
      if (length(dt_clean[, (which(ID %in% EVENT_id[i] & TIME < EVENTTIME))]) > 0) {
        # Find the last time point before EVENT and the last recorded time
        t_bf_EVENT <- dt_clean[, max(which(ID %in% EVENT_id[i] & TIME < EVENTTIME))]
        t_end <- dt_clean[, max(which(ID %in% EVENT_id[i]))]
        
        # Augment the dataset by duplicating the row before EVENT
        dt_augm <- rbind(dt_clean[1:t_bf_EVENT, ],
                         dt_clean[t_bf_EVENT, ],
                         dt_clean[-(1:t_end), ])
        
        # Modify the newly added row to indicate EVENT occurrence
        dt_augm[t_bf_EVENT + 1, (var_name) := NA]
        dt_augm[t_bf_EVENT + 1, eta_ij := 1]
        dt_augm[t_bf_EVENT + 1, TIME := EVENTTIME]
      } else {
        # Handle cases where no valid time points exist before EVENT occurrence
        t_bf_EVENT <- dt_clean[, min(which(ID %in% EVENT_id[i]))]
        t_end <- dt_clean[, max(which(ID %in% EVENT_id[i]))]
        
        dt_augm <- rbind(dt_clean[1:t_bf_EVENT, ],
                         dt_clean[-(1:t_end), ])
        
        dt_augm[t_bf_EVENT, (var_name) := NA]
        dt_augm[t_bf_EVENT, eta_ij := 1]
        dt_augm[t_bf_EVENT, TIME := EVENTTIME]
      }
    } else {
      # Check if there is valid data before EVENT occurrence
      if (length(dt_augm[, (which(ID %in% EVENT_id[i] & TIME < EVENTTIME))]) > 0) {
        t_bf_EVENT <- dt_augm[, max(which(ID %in% EVENT_id[i] & TIME < EVENTTIME))]
        t_end <- dt_augm[, max(which(ID %in% EVENT_id[i]))]
        
        dt_augm <- rbind(dt_augm[1:t_bf_EVENT, ],
                         dt_augm[t_bf_EVENT, ],
                         dt_augm[-(1:t_end), ])
        
        dt_augm[t_bf_EVENT + 1, (var_name) := NA]
        dt_augm[t_bf_EVENT + 1, eta_ij := 1]
        dt_augm[t_bf_EVENT + 1, TIME := EVENTTIME]
      } else {
        # Handle cases where no valid time points exist before EVENT occurrence
        t_bf_EVENT <- dt_augm[, min(which(ID %in% EVENT_id[i]))]
        t_end <- dt_augm[, max(which(ID %in% EVENT_id[i]))]
        
        dt_augm <- rbind(dt_augm[1:t_bf_EVENT, ],
                         dt_augm[-(1:t_end), ])
        
        dt_augm[t_bf_EVENT, (var_name) := NA]
        dt_augm[t_bf_EVENT, eta_ij := 1]
        dt_augm[t_bf_EVENT, TIME := EVENTTIME]
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
            }), by = ID, .SDcols = var_name_all]
  
  # Compute time difference between consecutive observations per ID
  dt_augm[, diff_t := diff(c(0, TIME)), by = ID]
  
  # Create visit count per ID
  dt_augm[, visit := seq_along(TIME) - 1, by = ID]
  
  # Rename columns for clarity
  col_R <- paste0(var_name_all, "_R")
  setnames(dt_augm, old = var_name_all, new = col_R)
  setnames(dt_augm, old = "ID", new = "ID")
  setnames(dt_augm, old = "TIME", new = "t_ij")
  
  # Select relevant columns for the final dataset
  dt_final <- dt_augm[t_ij != 0, c("ID", "visit", "t_ij", "diff_t", "eta_ij",
                                   col_L, col_R), with = FALSE]
  
  # Remove rows where any value is Inf
  dt_out <- dt_final[-unique(which(dt_final == Inf, arr.ind = TRUE)[, 1]), ]
  
  return(dt_out)
}
