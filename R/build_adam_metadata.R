# Functions for building ADaM metadata

#' Build ADaM metadata structure from source metadata components
#'
#' @description Transforms raw ADaM metadata components into a structured format
#' suitable for YAML output.
#'
#' @details
#' The function produces a clean YAML-compatible structure with the following
#' behaviors:
#'
#' Column handling by type:
#' - For predecessor variables (origin = "Predecessor"):
#'   - If not renamed: Only the column field is included (e.g., "DM.USUBJID")
#'     This follows CDISC requirements that predecessor columns inherit metadata
#'     from parent
#'   - If renamed: Only column and source fields are included
#'     Example: column: AAGE, source: DM.AGE
#'   - If origindescription is complex (contains filtering or additional text):
#'     Converted to derived column with origindescription as origin
#'
#' - For derived variables (origin = "Derived"):
#'   - Includes column, label, xmlcodelist (if applicable), and origin fields
#'   Origin is formatted as "Derived: \[algorithm\]"
#'
#' - For assigned variables (origin = "Assigned"):
#'   - Includes column, label, xmlcodelist (if applicable), and origin fields
#'   - Origin is formatted as "Assigned: \[comment\]"
#'
#' Additional features:
#' - NULL/NA fields are omitted from the output for cleaner YAML
#' - Value-level metadata is included only if available for the dataset
#' - Referenced domains are automatically created to track predecessor
#'   relationships
#'   from both direct references and origin text
#' - Origin fields are formatted for multi-line text in YAML
#' - Parameter value level metadata is properly processed and linked to parent
#'   variables
#'
#' @param metadata A list containing source_tables, source_columns, and
#'   (optionally) source_values components
#' @param verbose Logical indicating whether to print messages about conversions
#'   (default: TRUE)
#' @return A nested list structure containing ADaM metadata organized by dataset
#' @export
build_adam_metadata <-  function(metadata, verbose = TRUE) {

  valid_classes <- c("SUBJECT LEVEL ANALYSIS DATASET",
                     "BASIC DATA STRUCTURE",
                     "OCCURRENCE DATA STRUCTURE")

  valid_subclasses <- c("ADVERSE EVENT", "TIME-TO-EVENT")

  # Check if metadata has expected structure
  required_components <- c("source_tables", "source_columns")
  missing_components <- setdiff(required_components, names(metadata))
  if (length(missing_components) > 0) {
    stop("Missing required components: ",
         paste(missing_components, collapse = ", "))
  }

  # Extract source data with error handling
  source_tables <-  tryCatch(
    metadata$source_tables |> dplyr::rename_all(tolower),
    error = function(e) stop("Error processing source_tables: ", e$message)
  )

  source_columns <-  tryCatch(
    metadata$source_columns |> dplyr::rename_all(tolower),
    error = function(e) stop("Error processing source_columns: ", e$message)
  )


  recommended_components <- c("source_values")
  absent_components <- setdiff(recommended_components, names(metadata))
  if (length(absent_components) > 0) {
    warning("Absent recommended components: ",
            paste(absent_components, collapse = ", "))
    source_values <- dplyr::tibble(table = character(0))
  } else {
    source_values <- tryCatch({
      metadata$source_values |> dplyr::rename_all(tolower)
    }, error = function(e) {
      stop("Error processing source_values: ", e$message)
    }
    )
  }

  # Pre-process source_values if applicable
  if (nrow(source_values) > 0) {
    if (!"whereclause" %in% names(source_values)) {
      stop("WHERECLAUSE column not found in source_values tab.")
    }

    if (!"paramcd" %in% names(source_values)) {
      if (verbose) {
        message("PARAMCD column not found in source_values tab. A best guess ",
                "will be inferred from WHERECLAUSE column.")
      }

      source_values <- source_values |>
        dplyr::mutate(paramcd = ifelse(grepl("(EQ|=)", .data$whereclause),
                                       gsub(".*(EQ|=) +", "", .data$whereclause),
                                       NA_character_),
                      paramcd = gsub("[^A-Z0-9]", "", .data$paramcd))

    }

    source_values_empty <- source_values |>
      dplyr::filter(is.na(.data$paramcd))

    if (nrow(source_values_empty) > 0) {
      warning("PARAMCD could not be found for all rows in source_values. ",
              "Values without a valid PARAMCD will not be included in yaml files.\n",
              paste(utils::capture.output(print(source_values_empty)), collapse = "\n"))
    }

    source_values <- source_values |>
      dplyr::filter(!is.na(.data$paramcd))

  }

  # Process all tables
  tables <- unique(source_tables$table)
  result <- lapply(tables, function(table_name) {
    process_table(table_name,
                  source_tables,
                  source_columns,
                  source_values,
                  valid_classes,
                  valid_subclasses,
                  verbose)
  })
  names(result) <- tables

  result
}
