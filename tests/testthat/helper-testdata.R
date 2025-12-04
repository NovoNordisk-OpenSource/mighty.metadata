# Helper functions for loading and processing test data
# These functions are shared across all test files to avoid duplication

#' Load test metadata components from anonymized Excel file
#'
#' This function loads the test data from the anonymized Excel file and applies
#' the standard filtering logic used across all tests.
#'
#' @return A list with three components: source_tables, source_columns, source_values
load_test_metadata_components <- function() {
  test_file <- testthat::test_path("testdata", "anonymized_test_data.xlsx")

  # Load the raw data and filter for phase_3 = "Y" to avoid duplicates
  source_columns <- openxlsx::read.xlsx(test_file, sheet = "source_columns") |>
    dplyr::rename_all(tolower) |>
    dplyr::filter(phase_3 == "Y", include_in_trial == "Y", include_in_submission == "Y")

  list(
    source_tables = openxlsx::read.xlsx(test_file, sheet = "source_tables") |>
      dplyr::rename_all(tolower) |>
      dplyr::filter(phase_3 == "Y", include_in_trial == "Y", include_in_submission == "Y"),
    source_columns = source_columns,
    source_values = openxlsx::read.xlsx(test_file, sheet = "source_values") |>
      dplyr::rename_all(tolower) |>
      dplyr::filter(include_in_trial == "Y")
  )
}
