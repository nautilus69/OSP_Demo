#' Load OSP Suite Simulation and Observed Data
#'
#' This function loads mock Open Systems Pharmacology (OSP) Suite simulation
#' and observed clinical data for demonstration purposes. In a real
#' application, this would parse actual OSP outputs (e.g., from PK-Sim, MoBi).
#'
#' @param file_path (Optional) Path to a file to simulate loading.
#' @return A data frame containing mock PBPK/QSP simulation and observed data.
#' @export
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows mutate
#' @examples
#' # Generate mock data
#' mock_data <- load_osp_data()
#' head(mock_data)
load_osp_data <- function(file_path = NULL) {
  # Define mock observed data
  observed_data <- tibble::tibble(
    Time = c(0.25, 0.5, 1, 2, 4, 6, 8, 12, 24),
    Concentration = c(10, 25, 35, 30, 20, 15, 10, 5, 2) + rnorm(9, 0, 2),
    StudyID = "Observed_Study_01",
    Group = "A",
    DataType = "Observed"
  )
  observed_data$Concentration[observed_data$Concentration < 0] <- 0 # No negative concentrations
  
  # Define mock simulated data (e.g., from PK-Sim)
  simulated_data <- tibble::tibble(
    Time = seq(0, 24, by = 0.1),
    Concentration = 40 * exp(-0.5 * Time) - 40 * exp(-1.5 * Time), # Simple 2-comp IV bolus model
    StudyID = "Simulated_Model_01",
    Group = "A",
    DataType = "Simulated"
  )
  simulated_data$Concentration[simulated_data$Concentration < 0] <- 0
  
  # Combine and add common required columns for visualization
  combined_data <- dplyr::bind_rows(observed_data, simulated_data) %>%
    dplyr::mutate(
      SubjectID = paste0(StudyID, "_", Group),
      # Placeholder for population/individual. In real app, would expand.
      Compound = "Compound A",
      Units = "ng/mL"
    )
  
  message("Mock OSP data loaded for demonstration.")
  return(combined_data)
}