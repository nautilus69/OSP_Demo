#' Load OSP Suite Simulation and Observed Data
#'
#' This function loads mock Open Systems Pharmacology (OSP) Suite simulation
#' and observed clinical data for demonstration purposes. In a real
#' application, this would parse actual OSP outputs (e.g., from PK-Sim, MoBi).
#' It simulates a typical concentration-time profile for a compound.
#'
#' @param file_path (Optional) Path to a file to simulate loading. Not used for mock data.
#' @return A data frame containing mock PBPK/QSP simulation and observed data,
#'   with columns `Time`, `Concentration`, `StudyID`, `Group`, `DataType`,
#'   `SubjectID`, `Compound`, and `Units`.
#' @export
#' @importFrom tibble tibble
#' @importFrom dplyr bind_rows mutate
#' @examples
#' # Generate mock data
#' mock_data <- load_osp_data()
#' head(mock_data)
load_osp_data <- function(file_path = NULL) {
  # Define mock observed data for Study 1, Group A
  observed_data_s1ga <- tibble::tibble(
    Time = c(0.25, 0.5, 1, 2, 4, 6, 8, 12, 24),
    Concentration = c(10, 25, 35, 30, 20, 15, 10, 5, 2) + stats::rnorm(9, 0, 2),
    StudyID = "Clinical_Study_01",
    Group = "Group A",
    DataType = "Observed"
  )
  observed_data_s1ga$Concentration[observed_data_s1ga$Concentration < 0] <- 0

  # Define mock observed data for Study 1, Group B
  observed_data_s1gb <- tibble::tibble(
    Time = c(0.25, 0.5, 1, 2, 4, 6, 8, 12, 24),
    Concentration = c(8, 20, 30, 25, 18, 12, 8, 4, 1) + stats::rnorm(9, 0, 1.5),
    StudyID = "Clinical_Study_01",
    Group = "Group B",
    DataType = "Observed"
  )
  observed_data_s1gb$Concentration[observed_data_s1gb$Concentration < 0] <- 0

  # Define mock simulated data for Model 1, Group A (e.g., from PK-Sim)
  simulated_data_m1ga <- tibble::tibble(
    Time = seq(0, 24, by = 0.1),
    Concentration = 40 * exp(-0.5 * Time) - 40 * exp(-1.5 * Time), # Simple 2-comp IV bolus model
    StudyID = "Simulated_Model_01",
    Group = "Group A",
    DataType = "Simulated"
  )
  simulated_data_m1ga$Concentration[simulated_data_m1ga$Concentration < 0] <- 0

  # Define mock simulated data for Model 1, Group B
  simulated_data_m1gb <- tibble::tibble(
    Time = seq(0, 24, by = 0.1),
    Concentration = 35 * exp(-0.6 * Time) - 35 * exp(-1.8 * Time),
    StudyID = "Simulated_Model_01",
    Group = "Group B",
    DataType = "Simulated"
  )
  simulated_data_m1gb$Concentration[simulated_data_m1gb$Concentration < 0] <- 0

  # Combine all mock data
  combined_data <- dplyr::bind_rows(
    observed_data_s1ga, observed_data_s1gb,
    simulated_data_m1ga, simulated_data_m1gb
  ) %>%
    dplyr::mutate(
      SubjectID = paste0(StudyID, "_", Group),
      Compound = "Compound A", # Placeholder for compound
      Units = "ng/mL" # Placeholder for units
    )

  message("Mock OSP data loaded for demonstration.")
  return(combined_data)
}
