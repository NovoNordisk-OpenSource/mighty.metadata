#' Convert mighty-compatible list to mdcol dataframe
#' @description Helper function to convert a list to a dataframe
#' @param table_list A list containing (at least) table and column information
#' @return A corresponding dataframe
#' @keywords internal
#' @noRd
mighty_list_to_mdcol_df <- function(table_list) {
  table_table <- mighty_list_extract_table(table_list)

  column_table <- mighty_list_extract_columns(table_list)

  # Combine table and column information
  table_table |>
    tidyr::expand_grid(column_table)

}

#' Extract table-level information from mighty-compatible list
#' @description Helper function to extract table-level information
#' @param table_list A list containing (at least) table information
#' @return A corresponding dataframe
#' @keywords internal
#' @noRd
mighty_list_extract_table <- function(table_list) {
  table_names <- setdiff(names(table_list), "columns")

  # Remove value metadata
  non_list_elements <- lapply(table_names,
                              \(x) !inherits(table_list[[x]], "list")) |>
    unlist()

  table_names <- table_names[non_list_elements]

  is_table_metadata_missing <- length(table_names) == 0
  are_required_fields_missing <- !any(c("id", "label") %in% table_names)
  if (is_table_metadata_missing || are_required_fields_missing) {
    warning("YAML file ", tolower(table_list$id), " missing required table metadata fields")
    return(NULL)
  }

  table_list_list <- table_list[table_names]

  if ("keys" %in% table_names) {
    table_list_list$keys <- paste(table_list_list$keys, collapse = " ")
  }

  # Extract table information for each table
  table_table <- dplyr::bind_rows(table_list_list) |>
    dplyr::select(dplyr::any_of(c("id", "keys", "label", "usecore"))) |>
    dplyr::rename(table = dplyr::any_of("id"),
                  tlabel = dplyr::any_of("label"))

  # Ensure usecore variable exists in table
  if (!"usecore" %in% names(table_table)) {
    table_table["usecore"] <- FALSE
  }

  table_table
}

#' Extract column-level information from mighty-compatible list
#' @description Helper function to extract column-level information
#' @param table_list A list containing (at least) table information
#' @return A corresponding dataframe
#' @keywords internal
#' @noRd
mighty_list_extract_columns <- function(table_list) {
  # Check if columns exists
  if (is.null(table_list$columns) || length(table_list$columns) == 0) {
    warning(paste("YAML file", name, "missing 'columns'"))
    return(NULL)
  }

  # Extract column information for each table and flatten format information
  column_table <- lapply(table_list$columns,
                         \(x) purrr::list_flatten(x, name_spec = "{inner}")) |>
    dplyr::bind_rows() |>
    dplyr::rename(column = dplyr::any_of("id")) |>
    dplyr::mutate(type = dplyr::case_when(
      type == "text" ~ "C",
      type %in% c("integer", "float", "datetime", "date", "time") ~ "N",
      TRUE ~ type
    ))

  # Handle only the columns that exist to avoid issues
  if ("length" %in% names(column_table)) {
    column_table$length <- as.character(column_table$length)
  }

  if ("displayformat" %in% names(column_table)) {
    column_table$displayformat <- as.character(column_table$displayformat)
  }

  column_table <- column_table |>
    dplyr::select(dplyr::any_of(c("column", "label", "method", "type",
                                  "core", "length", "displayformat")))

  # Ensure all expected columns exist (add them if missing with NA values)
  expected_cols <- c("column", "label", "method", "type", "core", "length", "displayformat")
  missing_cols <- setdiff(expected_cols, names(column_table))

  column_table[missing_cols] <- NA_character_  # Use character for all to avoid type conflicts

  # Now clean up the columns
  column_table <- column_table |>
    dplyr::mutate(
      core = dplyr::if_else(is.na(.data$core), FALSE, as.logical(.data$core)),
      length = dplyr::case_when(
        is.na(length) | length == "" ~ NA_real_,
        TRUE ~ as.numeric(length)
      ),
      displayformat = dplyr::if_else(is.na(displayformat) | displayformat == "", NA_character_, displayformat)
    )

  # Ensure all expected columns exist (add them if missing with NA values)
  expected_cols <- c("column", "label", "method", "type", "core", "length", "displayformat")
  missing_cols <- setdiff(expected_cols, names(column_table))

  column_table[missing_cols] <- NA_character_  # Use character for all to avoid type conflicts

  # Now clean up the columns
  column_table <- column_table |>
    dplyr::mutate(
      core = dplyr::if_else(is.na(core), FALSE, as.logical(core)),
      length = dplyr::case_when(
        is.na(length) | length == "" ~ NA_real_,
        TRUE ~ as.numeric(length)
      ),
      displayformat = dplyr::if_else(is.na(displayformat) | displayformat == "", NA_character_, displayformat)
    )

  column_table
}
