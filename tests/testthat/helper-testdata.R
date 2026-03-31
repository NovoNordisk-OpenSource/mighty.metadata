# Helper functions for loading and processing test data
# These functions are shared across all test files to avoid duplication

#' Load test metadata components from anonymized Excel file
#'
#' This function loads the test data from the anonymized Excel file and applies
#' the standard filtering logic used across all tests.
#'
#' @return A list with three components: source_tables, source_columns, source_values
load_test_metadata_components <- function(
  usecore = FALSE,
  usesdtm = FALSE,
  table_filter = TRUE,
  column_filter = TRUE,
  value_filter = TRUE
) {
  test_file <- testthat::test_path("testdata", "anonymized_test_data.xlsx")

  # Load the raw data and filter for phase_3 = "Y" to avoid duplicates
  source_tables <- openxlsx::read.xlsx(test_file, sheet = "source_tables") |>
    dplyr::rename_all(tolower) |>
    dplyr::filter(
      phase_3 == "Y",
      include_in_trial == "Y",
      include_in_submission == "Y",
      {{ table_filter }}
    )

  source_columns <- openxlsx::read.xlsx(test_file, sheet = "source_columns") |>
    dplyr::rename_all(tolower) |>
    dplyr::filter(
      phase_3 == "Y",
      include_in_trial == "Y",
      include_in_submission == "Y",
      {{ column_filter }}
    )

  source_values <- openxlsx::read.xlsx(test_file, sheet = "source_values") |>
    dplyr::rename_all(tolower) |>
    dplyr::filter(include_in_trial == "Y", {{ value_filter }})

  # Update datasets if core variable functionality is to be tested
  if (usecore) {
    corevars <- source_columns |>
      dplyr::filter(corefl == "Y") |>
      dplyr::pull(column)

    usecoretbls <- source_columns |>
      dplyr::filter(
        column %in% corevars,
        table != "ADSL",
        grepl("^A", table)
      ) |>
      dplyr::pull(table) |>
      unique()

    source_columns <- source_columns |>
      dplyr::filter(!(table %in% usecoretbls & column %in% corevars))

    source_tables <- source_tables |>
      dplyr::mutate(usecore = table %in% usecoretbls)
  }

  if (usesdtm) {
    cols_from_sdtm <- testthat::test_path("testdata", "cols_from_sdtm.csv") |>
      utils::read.csv()

    source_columns <- source_columns |>
      dplyr::left_join(
        cols_from_sdtm |>
          dplyr::mutate(predecessor_exists = TRUE),
        by = c("table", "column")
      ) |>
      dplyr::mutate(
        label = ifelse(is.na(.data$predecessor_exists), label, NA_character_),
        type = ifelse(is.na(.data$predecessor_exists), type, NA_character_),
        length = ifelse(is.na(.data$predecessor_exists), length, NA_real_),
        displayformat = ifelse(
          is.na(.data$predecessor_exists),
          displayformat,
          NA_real_
        )
      )
  }

  list(
    source_tables = source_tables,
    source_columns = source_columns,
    source_values = source_values
  )
}

#' Construct minimal sdtm submit_columns dataset from anonymized Excel file
#'
#'
#' @return A dataframe with five columns: table, column, label, type, length
load_test_sdtm_submit_columns <- function() {
  test_file <- testthat::test_path("testdata", "anonymized_test_data.xlsx")

  # Load the raw data and filter for phase_3 = "Y" to avoid duplicates
  source_columns <- openxlsx::read.xlsx(test_file, sheet = "source_columns") |>
    dplyr::rename_all(tolower)

  source_columns |>
    dplyr::filter(
      grepl("^[A-Z]{2,3}\\.[A-Z]+ ?\\.?$", .data$origindescription),
      column != "AVISITN"
    ) |>
    dplyr::mutate(
      table = stringr::str_extract(.data$origindescription, "^[A-Z]+"),
      column = stringr::str_extract(.data$origindescription, "(?<=\\.)[A-Z]+")
    ) |>
    dplyr::distinct(table, column, label, type, length) |>
    dplyr::arrange(table, column)
}
