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
#' @return A named list of domain metadata.
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

      comparator_symbol <- "\\b(EQ|LT|LE|GT|GE|NE|IN|NOTIN)\\b"

      if (anyNA(source_values$whereclause)) {
        stop("WHERECLAUSE column in source_values tab contains missing values.")
      }

      source_values <- source_values |>
        dplyr::mutate(
          post = purrr::map(.data$whereclause, \(x) stringr::str_split_1(x, comparator_symbol)[-1]),
          comparator = stringr::str_extract_all(.data$whereclause, comparator_symbol)
        ) |>
        tidyr::unnest(c("post", "comparator")) |>
        dplyr::rowwise() |>
        dplyr::mutate(
          joiner = stringr::str_extract(.data$post, "\\b(AND|OR)\\b"),
          post = stringr::str_remove_all(.data$post, paste0("\\b", .data$joiner, "\\b.*")),
          paramcd = paste(unlist(stringr::str_extract_all(.data$post, "[A-Z0-9_]+")), collapse = "_"),
          paramcd = ifelse(.data$comparator == "EQ", .data$paramcd, paste0(.data$comparator, "_", .data$paramcd)),
          paramcd = ifelse(is.na(.data$joiner), .data$paramcd, paste0(.data$paramcd, "_", .data$joiner))
        ) |>
        dplyr::group_by(dplyr::across(
          c("include_in_trial", "table", "endpoint", "column", "whereclause",
            "origin", "origindescription", "algorithm", "comment", "order")
        )) |>
        dplyr::summarise(paramcd = paste(.data$paramcd, collapse = "_")) |>
        dplyr::ungroup()

      source_values_missing <- source_values |>
        dplyr::filter(is.na(.data$paramcd))

      if (nrow(source_values_missing) > 0) {
        source_values_missing_string <- source_values_missing |>
          dplyr::count(table) |>
          dplyr::mutate(count_string = paste0(table, ": ", n)) |>
          dplyr::pull(.data$count_string) |>
          paste(collapse = ", ")


        stop("PARAMCD could not be determined for some records in source_values: ",
             source_values_missing_string)
      }

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

  # Drop domains without column data (already warned by process_table)
  result <- Filter(function(x) !is.null(x$columns), result)

  schema <- system.file("schema", "adam.json", package = "mighty.metadata")
  for (domain_name in names(result)) {
    S7schema::validate_list(result[[domain_name]], schema)
  }

  result
}
