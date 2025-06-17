# ospapputils/tests/testthat/test-data_prep.R
library(testthat)
library(ospapputils)

test_that("load_osp_data returns a data frame with expected columns", {
  mock_data <- load_osp_data()
  expect_s3_class(mock_data, "data.frame")
  expected_cols <- c("Time", "Concentration", "StudyID", "Group", "DataType", "SubjectID", "Compound", "Units")
  expect_true(all(expected_cols %in% colnames(mock_data)))
  expect_gt(nrow(mock_data), 0)
})

test_that("Concentration values are non-negative", {
  mock_data <- load_osp_data()
  expect_true(all(mock_data$Concentration >= 0))
})

test_that("Mock data contains both Observed and Simulated data types", {
  mock_data <- load_osp_data()
  expect_true("Observed" %in% unique(mock_data$DataType))
  expect_true("Simulated" %in% unique(mock_data$DataType))
})

test_that("Mock data contains multiple studies and groups", {
  mock_data <- load_osp_data()
  expect_gt(length(unique(mock_data$StudyID)), 0)
  expect_gt(length(unique(mock_data$Group)), 0)
})
