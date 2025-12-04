#' Create ADaM Column Metadata from YAML Files
#'
#' @description
#' Reads and processes YAML files containing table and column metadata information,
#' combining them into a single ADaM column metadata dataset. The function also
#' resolves source references (including inherited core columns that have sources)
#' information, standardizes column names, and provides warnings for potential
#' metadata issues.
#'
#' @param metadata_directory Character string specifying the directory path
#'   containing the YAML metadata files.
#' @param sdtm_columns Data frame containing sdtm metadata information.
#'   Expected columns are table, column, label, type, length.
#'   Can be found in dm/sdtm_map/submit_columns.sas7bdat.
#' @param max_recursion Numeric specifying maximum recursion depth when tracing
#'   column metadata information.
#'
#' @return A tibble containing the processed metadata collection with the following
#'   columns:
#' \itemize{
#'   \item TABLE - Name of the table
#'   \item KEYS - Key columns for the table
#'   \item TLABEL - Table label
#'   \item COLUMN - Column name
#'   \item LABEL - Column label
#'   \item METHOD - Method or source description
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
make_mdcol_from_yaml <- function(metadata_directory,
                                 sdtm_columns = NULL,
                                 max_recursion = 5) {

  # Find all yaml files in metadata directory
  yaml_files <- list.files(metadata_directory, pattern = "\\.(yml|yaml)$", full.names = TRUE)

  # Handle empty directory
  if (length(yaml_files) == 0) {
    stop("Error: No YAML files found in directory '", metadata_directory,
         "'. Please check the directory path and ensure it contains YAML metadata files.")
  }

  # Convert all yaml files to lists with error handling
  all_lists <- purrr::map(yaml_files, \(file) {
    tryCatch(
      yaml::read_yaml(file),
      error = function(e) {
        warning(paste("Error reading YAML file", file, ":", e$message))
        NULL
      }
    )
  }) |>
    purrr::compact()  # Remove NULL entries from failed YAML reads

  # Handle case where no valid YAML files were processed
  if (length(all_lists) == 0) {
    stop("Error: No valid YAML files found or all YAML files failed to parse in directory '",
         metadata_directory, "'. Please check the YAML file syntax and structure.")
  }


  all_table <- purrr::map(all_lists, mighty_list_to_mdcol_df) |>
    purrr::compact() |>  # Remove NULL entries
    # Combine information for all tables into a single dataframe
    dplyr::bind_rows()

  # Handle case where no data was processed
  if (nrow(all_table) == 0) {
    stop("Error: No valid metadata was processed from YAML files in '", metadata_directory,
         "'. Please check that YAML files contain valid table_metadata and 'columns' sections.")
  }

  if (!is.null(sdtm_columns)) {
    expected_sdtm_columns <- c("table", "column", "label", "type", "length")
    missing_sdtm_columns <- setdiff(expected_sdtm_columns, colnames(sdtm_columns))

    if (length(missing_sdtm_columns) > 0) {
      warning("The suppied `sdtm_columns` data frame does not contain the ",
              "expected column(s): ", paste(missing_sdtm_columns, collapse = ", "))
    }

    all_table <- all_table |>
      dplyr::bind_rows(sdtm_columns |>
                         dplyr::select(dplyr::all_of(expected_sdtm_columns)) |>
                         dplyr::mutate(SDTMCOL = TRUE))
  }

  # Step 1: Core Variable Inheritance (First)
  # Get ADSL core column metadata (source of truth for core variables)
  adsl_core_metadata <- all_table |>
    dplyr::filter(table == "ADSL", .data$core) |>
    dplyr::select(-table)

  # Find which non-ADSL datasets want core variables and and which they want
  datasets_requesting_core <- all_table |>
    dplyr::filter(table != "ADSL", .data$usecore) |>
    dplyr::distinct(table)

  potential_core_vars <- datasets_requesting_core |>
    tidyr::expand_grid(adsl_core_metadata |> dplyr::distinct(column))

  needed_core_vars <- potential_core_vars |>
    dplyr::anti_join(all_table |> dplyr::select(table, column),
                     by = c("table", "column"))

  # Check for unneede core columns and message
  unneeded_core_vars <- potential_core_vars |>
    dplyr::anti_join(needed_core_vars |> dplyr::select(table, column),
                     by = c("table", "column"))

  # TODO: Add verbose option to suppress this?
  if (nrow(unneeded_core_vars) > 0) {
    missing_details <- unneeded_core_vars |>
      dplyr::mutate(detail = paste0(table, ".", column, " (already exists in ", table, ")"))

    message(paste("Note: Core variable inheritance issues found:",
                  paste(missing_details$detail, collapse = "; ")))
  }

  # Add ADSL core metadata where requested and available
  # Add the complete core metadata for datasets that request it
  core_additions <- needed_core_vars |>
    dplyr::inner_join(adsl_core_metadata, by = "column")

  # Combine original data (minus core requests) with core additions
  expanded_table <- all_table |>
    dplyr::bind_rows(core_additions)

  # Step 2: Source Reference Resolution (Second)
  # Extract and process source information
  processed_table <- expanded_table |>
    dplyr::mutate(
      source = ifelse(grepl("^Predecessor", .data$method),
                      stringr::str_extract(.data$method, "[A-Z0-9]+\\.[A-Z0-9]+"),
                      NA_character_)
    ) |>
    # Use upper case column names to align with SAS
    dplyr::rename_with(toupper) |>
    # Split source information into source table and source column (safe splitting)
    dplyr::mutate(
      # Validate and split source references
      SOURCE_VALID = !is.na(SOURCE) & stringr::str_detect(SOURCE, "^[A-Z0-9]+\\.[A-Z0-9]+$"),
      SOURCE_SPLIT = ifelse(.data$SOURCE_VALID,
                            stringr::str_split(SOURCE, "\\."),
                            list(c(NA_character_, NA_character_))),
      STABLE = purrr::map_chr(.data$SOURCE_SPLIT, ~ .x[1]),
      SCOLUMN = purrr::map_chr(.data$SOURCE_SPLIT, ~ .x[2])
    ) |>
    dplyr::select(-dplyr::any_of(c("SOURCE_VALID", "SOURCE_SPLIT")))

  for (n in seq_len(max_recursion)) {
    # Resolve source references (including inherited core columns that have sources)
    processed_table_new <- processed_table |>
      dplyr::left_join(processed_table |>
                         dplyr::distinct(TABLE, COLUMN,
                                         LABEL, TYPE, LENGTH, DISPLAYFORMAT) |>
                         dplyr::rename_with(function(x) paste0("S", x)),
                       by = c("STABLE", "SCOLUMN")) |>
      dplyr::mutate(LABEL = dplyr::coalesce(LABEL, SLABEL),
                    TYPE = dplyr::coalesce(TYPE, STYPE),
                    LENGTH = dplyr::coalesce(LENGTH, SLENGTH),
                    DISPLAYFORMAT = dplyr::coalesce(DISPLAYFORMAT, SDISPLAYFORMAT),
                    METHOD = ifelse(is.na(.data$METHOD) & !is.na(STABLE) & !is.na(SCOLUMN),
                                    paste0("Source: ", STABLE, ".", SCOLUMN),
                                    .data$METHOD)) |>
      dplyr::select(-SLABEL, -STYPE, -SLENGTH, -SDISPLAYFORMAT)

    if (identical(processed_table_new, processed_table)) {
      break
    } else {
      processed_table <- processed_table_new
    }

    if (n == max_recursion) {
      warning("Maximum recursion depth of ", max_recursion, " reached.")
    }
  }

  if (!is.null(sdtm_columns)) {
    processed_table_new <- processed_table_new |>
      dplyr::filter(!.data$SDTMCOL | is.na(.data$SDTMCOL)) |>
      dplyr::select(-.data$SDTMCOL)
  }

  upd_table <- processed_table_new |>
    # Preserve source info for warnings before removing columns
    dplyr::mutate(SOURCE_REF = ifelse(!is.na(STABLE) & !is.na(SCOLUMN),
                                      paste0(STABLE, ".", SCOLUMN), NA_character_)) |>
    dplyr::select(-STABLE, -SCOLUMN) |>  # Remove helper columns
    dplyr::rename(FORMAT = DISPLAYFORMAT)

  # Final processing: Add row numbers and arrange
  core_table <- upd_table |>
    dplyr::rowwise() |>
    dplyr::mutate(keymatch = match(COLUMN, stringr::str_split_1(.data$KEYS, " "))) |>
    dplyr::group_by(TABLE) |>
    dplyr::arrange(TABLE, .data$keymatch) |>
    dplyr::mutate(ORDER = dplyr::row_number()) |>
    dplyr::ungroup()

  duplicate_columns <- core_table |>
    dplyr::count(tabcol = paste0(TABLE, ".", COLUMN)) |>
    dplyr::filter(n > 1) |>
    dplyr::pull(tabcol)

  if (length(duplicate_columns) > 0) {
    warning(paste("Warning: Duplicate columns found:",
                  paste(duplicate_columns, collapse = ", ")))
  }

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
