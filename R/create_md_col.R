#' Create Metadata Column Definition Table
#'
#' @description
#' Converts a list of mighty-compatible metadata into a standardized metadata
#' column (mdcol) dataframe. This function processes table and column metadata,
#' arranges columns by key order, and performs validation checks for duplicate
#' columns across tables.
#'
#' @param mighty_metadata_list A list of lists containing mighty-compatible
#'   metadata. Each element should represent a table with the following structure:
#'   \itemize{
#'     \item \code{id}: Table identifier (required)
#'     \item \code{label}: Table label/description (required)
#'     \item \code{keys}: Character vector of key column names
#'     \item \code{columns}: List of column definitions, each containing:
#'       \itemize{
#'         \item \code{id}: Column name (required)
#'         \item \code{label}: Column label/description
#'         \item \code{type}: Data type ("text", "integer", "float", "datetime", "date", "time")
#'         \item \code{method}: Derivation or calculation method
#'         \item \code{core}: Logical indicating if column is a core variable
#'         \item \code{length}: Maximum length for character variables
#'         \item \code{displayformat}: Display format specification
#'       }
#'   }
#'
#' @return A dataframe with uppercase column names containing the following columns:
#'   \describe{
#'     \item{TABLE}{Table identifier}
#'     \item{TLABEL}{Table label/description}
#'     \item{KEYS}{Space-separated string of key column names}
#'     \item{COLUMN}{Column name}
#'     \item{LABEL}{Column label/description}
#'     \item{METHOD}{Derivation or calculation method (trailing newlines removed)}
#'     \item{TYPE}{Data type: "C" for character, "N" for numeric}
#'     \item{CORE}{Logical indicating if column is a core variable}
#'     \item{LENGTH}{Maximum length for character variables}
#'     \item{FORMAT}{Display format specification}
#'     \item{ORDER}{Integer row number within each table, ordered by key position}
#'   }
#'
#'   Rows are ordered by TABLE and key column position. Helper columns
#'   (SOURCE, SOURCE_REF, USECORE, keymatch) are removed from the output.
#'
#' @details
#' The function performs the following operations:
#' \enumerate{
#'   \item Converts each table's metadata to a dataframe using helper functions
#'   \item Removes NULL entries (from tables with missing required metadata)
#'   \item Combines all tables into a single dataframe
#'   \item Filters out rows with missing column names
#'   \item Converts all column names to uppercase for SAS compatibility
#'   \item Renames DISPLAYFORMAT to FORMAT
#'   \item Orders columns by their position in the KEYS specification
#'   \item Adds an ORDER column with row numbers within each table
#'   \item Checks for and warns about duplicate column definitions
#'   \item Removes trailing newlines from METHOD field
#'   \item Removes internal helper columns
#' }
#'
#' @section Warnings:
#' The function will issue warnings for:
#' \itemize{
#'   \item Duplicate columns (same TABLE.COLUMN combination appearing multiple times)
#'   \item Tables missing required metadata fields (via helper functions)
#'   \item Tables missing column definitions (via helper functions)
#' }
#'
#' @examples
#' # Example metadata structure
#' metadata <- list(
#'   ADSL = list(
#'     id = "ADSL",
#'     label = "Subject-Level Analysis",
#'     keys = c("STUDYID", "USUBJID"),
#'     columns = list(
#'       list(id = "STUDYID", label = "Study Identifier", core = TRUE,
#'            format = list(type = "text", length = 40)),
#'       list(id = "USUBJID", label = "Unique Subject Identifier", core = TRUE,
#'            format = list(type = "text", length = 40)),
#'       list(id = "AGE", label = "Age", format = list(type = "float", length = 8))
#'     )
#'   )
#' )
#'
#' # Create metadata column table
#' mdcol <- create_md_col(metadata)
#' mdcol
#'
#' @export
create_md_col <- function(mighty_metadata_list) {
  all_table <- purrr::map(mighty_metadata_list, mighty_list_to_mdcol_df) |>
    purrr::compact() |>  # Remove NULL entries
    # Combine information for all tables into a single dataframe
    dplyr::bind_rows() |>
    dplyr::filter(!is.na(.data$column)) |>
    # Use upper case column names to align with SAS
    dplyr::rename_with(toupper) |>
    # Rename format column
    dplyr::rename(FORMAT = DISPLAYFORMAT)

  # Final processing: Add row numbers and arrange
  core_table <- all_table |>
    dplyr::rowwise() |>
    dplyr::mutate(keymatch = match(COLUMN, stringr::str_split_1(.data$KEYS, " "))) |>
    dplyr::group_by(TABLE) |>
    dplyr::arrange(TABLE, .data$keymatch) |>
    dplyr::mutate(ORDER = dplyr::row_number()) |>
    dplyr::ungroup()

  # Look for duplicate entries
  duplicate_columns <- core_table |>
    dplyr::count(tabcol = paste0(TABLE, ".", COLUMN)) |>
    dplyr::filter(n > 1) |>
    dplyr::pull(tabcol)

  if (length(duplicate_columns) > 0) {
    warning(paste("Warning: Duplicate columns found:",
                  paste(duplicate_columns, collapse = ", ")))
  }

  # Look for missing metadata
  missing_info_details <- core_table |>
    dplyr::filter(dplyr::if_any(c("LABEL", "TYPE", "LENGTH"), is.na)) |>
    dplyr::mutate(
      tabcol = paste0(TABLE, ".", COLUMN),
      missing_fields = dplyr::case_when(
        is.na(LABEL) & is.na(TYPE) & is.na(LENGTH) ~ "all metadata (LABEL, TYPE, LENGTH)",
        is.na(LABEL) & is.na(TYPE) ~ "LABEL and TYPE",
        is.na(LABEL) & is.na(LENGTH) ~ "LABEL and LENGTH",
        is.na(TYPE) & is.na(LENGTH) ~ "TYPE and LENGTH",
        is.na(LABEL) ~ "LABEL",
        is.na(TYPE) ~ "TYPE",
        is.na(LENGTH) ~ "LENGTH",
        TRUE ~ "unknown"
      ),
      SOURCE_REF = stringr::str_extract(.data$METHOD, "(?<=Predecessor: )[A-Za-z0-9]+\\.[A-Za-z0-9]+"),
      source_info = dplyr::case_when(
        !is.na(.data$SOURCE_REF) ~ paste0(" (references ", .data$SOURCE_REF, " - check for typos or missing source)"),
        TRUE ~ " (no source reference)"
      )
    ) |>
    dplyr::mutate(detail = paste0(tabcol, " missing ", .data$missing_fields, .data$source_info))

  if (nrow(missing_info_details) > 0) {
    warning(paste("Warning: Columns with missing metadata found:",
                  paste(missing_info_details$detail, collapse = "; ")))
  }

  # Remove helper columns and return final result
  core_table |>
    dplyr::mutate(METHOD = gsub("\\n$", "", .data$METHOD)) |>
    dplyr::select(-dplyr::any_of(
      c("SOURCE", "SOURCE_REF", "USECORE", "keymatch")
    ))
}


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
  # Pull usecore out of metadata if present
  if ("metadata" %in% names(table_list)) {
    if ("usecore" %in% names(table_list$metadata)) {
      table_list$usecore <- table_list$metadata$usecore
    }
  }

  table_names <- setdiff(names(table_list), "columns")

  # Remove value metadata
  non_list_elements <- lapply(table_names,
                              \(x) !inherits(table_list[[x]], "list")) |>
    unlist()

  table_names <- table_names[non_list_elements]

  is_table_metadata_missing <- length(table_names) == 0
  are_required_fields_missing <- !any(c("id", "label") %in% table_names)
  if (is_table_metadata_missing || are_required_fields_missing) {
    warning("mighty_metadata for ", tolower(table_list$id), " missing required table metadata fields")
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
    warning(paste("mighty_metadata for", tolower(table_list$id), "missing 'columns'"))
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
        is.na(.data$length) | .data$length == "" ~ NA_real_,
        TRUE ~ as.numeric(.data$length)
      ),
      displayformat = dplyr::if_else(is.na(.data$displayformat) | .data$displayformat == "", NA_character_, .data$displayformat)
    )

  column_table
}
