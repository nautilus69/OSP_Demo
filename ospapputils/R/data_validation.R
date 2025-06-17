# ospapputils/R/data_validation.R

#' Validate OSP Data Structure
#'
#' Checks if the uploaded data frame contains the minimum required columns
#' and if key columns have appropriate data types.
#'
#' @param df A data frame to validate.
#' @return A list with `isValid` (TRUE/FALSE) and `messages` (character vector).
#' @export
#' @importFrom dplyr select all_of
validate_osp_data <- function(df) {
  messages <- c()
  is_valid <- TRUE

  required_cols <- c("Time", "Concentration", "StudyID", "Group", "DataType")
  if (!all(required_cols %in% colnames(df))) {
    missing_cols <- setdiff(required_cols, colnames(df))
    messages <- c(messages, paste0("Missing required columns: ", paste(missing_cols, collapse = ", "), "."))
    is_valid <- FALSE
  } else {
    # Check data types for critical columns
    if (!is.numeric(df$Time)) {
      messages <- c(messages, "Column 'Time' must be numeric.")
      is_valid <- FALSE
    }
    if (!is.numeric(df$Concentration)) {
      messages <- c(messages, "Column 'Concentration' must be numeric.")
      is_valid <- FALSE
    }
    if (any(df$Concentration < 0, na.rm = TRUE)) {
      messages <- c(messages, "Column 'Concentration' contains negative values.")
      is_valid <- FALSE
    }
    if (!is.character(df$StudyID) &&!is.factor(df$StudyID)) {
      messages <- c(messages, "Column 'StudyID' must be character or factor.")
      is_valid <- FALSE
    }
    if (!is.character(df$Group) &&!is.factor(df$Group)) {
      messages <- c(messages, "Column 'Group' must be character or factor.")
      is_valid <- FALSE
    }
    if (!all(unique(df$DataType) %in% c("Observed", "Simulated"))) {
      messages <- c(messages, "Column 'DataType' must only contain 'Observed' or 'Simulated'.")
      is_valid <- FALSE
    }
  }

  if (is_valid && nrow(df) == 0) {
    messages <- c(messages, "Uploaded data is empty.")
    is_valid <- FALSE
  }

  return(list(isValid = is_valid, messages = messages))
}
