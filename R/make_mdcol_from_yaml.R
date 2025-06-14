#' Create ADaM Column Metadata from YAML Files
#'
#' @description
#' Reads and processes YAML files containing table and column metadata information,
#' combining them into a single ADaM column metadata dataset. The function processes source
#' information, standardizes column names, and provides warnings for potential
#' metadata issues.
#'
#' @param metadata_directory Character string specifying the directory path
#'   containing the YAML metadata files.
#'
#' @return A tibble containing the processed metadata collection with the following
#'   columns:
#' \itemize{
#'   \item TABLE - Name of the table
#'   \item KEYS - Key columns for the table
#'   \item TLABEL - Table label
#'   \item COLUMN - Column name
#'   \item LABEL - Column label
#'   \item ORIGIN - Origin or source description
#'   \item TYPE - Data type
#'   \item LENGTH - Field length
#'   \item FORMAT - Display format
#'   \item ORDER - Column order within the table
#' }
#'
#' @details
#' The function performs several steps:
#' 1. Reads all YAML files from the specified directory
#' 2. Extracts and combines table and column metadata
#' 3. Processes source information and standardizes column names to upper case
#' 4. Links source and target metadata information
#' 5. Checks for and warns about potential metadata issues
#'
#' @note
#' The function will generate warnings in two cases:
#' * When duplicate columns are found in the metadata
#' * When columns have missing label or formatting information
#'
#' @examples
#' \dontrun{
#' # Create metadata collection from YAML files in a directory
#' metadata_col <- make_mdcol_from_yaml("path/to/yaml/files")
#'
#' # Check the resulting metadata collection
#' head(metadata_col)
#' }
#'
#' @export
make_mdcol_from_yaml <- function(metadata_directory) {

  # Find all yaml files in metadata directory
  all_names <- list.files(metadata_directory) |>
    stringr::str_remove("\\.yaml$")

  # Convert all yaml files to lists
  all_lists <- purrr::map(all_names, \(name) {
    yaml::read_yaml(file.path(metadata_directory, paste0(name, ".yaml")))
  }) |>
    purrr::set_names(all_names)


  all_table <- purrr::map2(all_lists, names(all_lists), \(table_list, name) {

    # Extract table information for each table
    table_table <- dplyr::bind_rows(table_list$table_metadata) |>
      dplyr::select(table, keys, tlabel = label)

    # Extract column information for each table and flatten format information
    column_table <- lapply(table_list$column_metadata, purrr::flatten) |>
      dplyr::bind_rows() |>
      dplyr::select(dplyr::any_of(c("column", "label", "source", "origin", "type",
                                    "corefl", "length", "displayformat")))

    # Combine table and column information
    table_table |>
      tidyr::expand_grid(column_table)
  }) |>
    # Combine information for all tables into a single dataframe
    dplyr::bind_rows() |>
    # Extract source information for each column where appropriate
    dplyr::mutate(source = ifelse(stringr::str_detect(column, "[A-Z0-9]+\\.") & is.na(source), column, source),
                  column = stringr::str_remove(column, "[A-Z0-9]+\\.")) |>
    # Use upper case column names to align with SAS
    dplyr::rename_with(toupper) |>
    # Split source information into source table and source column
    dplyr::mutate(SOURCE = stringr::str_split(SOURCE, "\\.")) |>
    tidyr::unnest_wider(SOURCE, names_sep = "_") |>
    dplyr::rename(STABLE = SOURCE_1, SCOLUMN = SOURCE_2)

  # Add label and format information where appropriate. NB: Not recursively.
  upd_table <- all_table |>
    dplyr::left_join(all_table |>
                       dplyr::distinct(COLUMN, TABLE,
                                       LABEL, TYPE, LENGTH, DISPLAYFORMAT) |>
                       dplyr::rename_with(function(x) paste0("S", x)),
                     by = c("STABLE", "SCOLUMN")) |>
    dplyr::mutate(LABEL = dplyr::coalesce(LABEL, SLABEL),
                  TYPE = dplyr::coalesce(TYPE, STYPE),
                  LENGTH = dplyr::coalesce(LENGTH, SLENGTH),
                  DISPLAYFORMAT = dplyr::coalesce(DISPLAYFORMAT, SDISPLAYFORMAT),
                  ORIGIN = ifelse(is.na(ORIGIN) & !is.na(STABLE) & !is.na(SCOLUMN),
                                  paste0("Source: ", STABLE, ".", SCOLUMN), ORIGIN)) |>
    dplyr::select(-dplyr::matches("^S")) |>
    dplyr::rename(FORMAT = DISPLAYFORMAT)

  # Add core variables
  core_table <- upd_table |>
    dplyr::bind_rows(
      upd_table |>
        dplyr::filter(TABLE == "ADSL", COREFL == "Y") |>
        dplyr::select(-TABLE, -COREFL) |>
        tidyr::expand_grid(upd_table |>
                             dplyr::filter(grepl("^AD", TABLE)) |>
                             dplyr::distinct(TABLE)) |>
        dplyr::anti_join(upd_table, by = c("COLUMN", "TABLE"))
    ) |>
    dplyr::group_by(TABLE) |>
    dplyr::mutate(ORDER = dplyr::row_number()) |>
    dplyr::ungroup() |>
    dplyr::arrange(TABLE, ORDER)

  duplicate_columns <- core_table |>
    dplyr::count(tabcol = paste0(TABLE, ".", COLUMN)) |>
    dplyr::filter(n > 1) |>
    dplyr::pull(tabcol)

  if (length(duplicate_columns) > 0) {
    warning(paste("Warning: Duplicate columns found:",
                  paste(duplicate_columns, collapse = ", ")))
  }

  missing_info_columns <- core_table |>
    dplyr::filter(dplyr::if_any(c("LABEL", "TYPE", "LENGTH"), is.na)) |>
    dplyr::mutate(tabcol = paste0(TABLE, ".", COLUMN)) |>
    dplyr::pull(tabcol)

  if (length(missing_info_columns) > 0) {
    warning(paste("Warning: Columns with missing label or formatting information found:",
                  paste(missing_info_columns, collapse = ", ")))
  }

  core_table

}
