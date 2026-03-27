#' Extract origin information from source_values when present
#' @description Helper function for getting origin information for values
#' @param val_filtered A dataframe containing the value definitions for the relevant table
#' @param table_name The name of the table whose origins are being considered
#' @param verbose Logical indicating whether to print messages about conversions (default: TRUE)
#' @return a list containing the origin information from source_values as both a list and a dataframe.
#' @keywords internal
#' @noRd
process_values <- function(val_filtered, table_name, verbose) {
  if (nrow(val_filtered) > 0) {

    # Process value-level metadata similar to column metadata
    val_data <- val_filtered |>
      dplyr::mutate(
        # Clean column names by removing trailing periods
        column = gsub("\\s*\\.\\s*$", "", column),

        # Clean whereclause
        whereclause = gsub("\\s*\\.\\s*$", "", whereclause),

        # Check if origindescription is complex
        is_complex_predecessor = !is.na(origin) &
          tolower(origin) == "predecessor" &
          !is_simple_predecessor(origindescription),

        # Create origin field using the same logic as for columns
        unified_origin = dplyr::case_when(
          is_complex_predecessor ~ paste0("Source: ", origindescription),
          !is.na(origin) & tolower(origin) == "predecessor" ~ paste0("Predecessor: ", origindescription),
          !is.na(origin) & tolower(origin) == "derived" & !is.na(algorithm) ~ algorithm,
          !is.na(origin) & tolower(origin) == "assigned" & !is.na(comment) ~ paste0("Assigned: ", comment),
          TRUE ~ NA_character_
        ),

        # Set origin to derived for complex predecessors
        origin_final = dplyr::case_when(
          is_complex_predecessor ~ "derived",
          TRUE ~ origin
        )
      )

    # Print messages for complex predecessors in value metadata
    if (verbose) {
      complex_preds <-  val_data |>
        dplyr::filter(is_complex_predecessor) |>
        dplyr::select(column, whereclause, origindescription)

      if (nrow(complex_preds) > 0) {
        for (i in seq_len(nrow(complex_preds))) {
          message(paste0("Converting value metadata for column '", complex_preds$column[i],
                         "' with where clause '", complex_preds$whereclause[i],
                         "' in table '", table_name,
                         "' from predecessor to derived due to complex origindescription: '",
                         complex_preds$origindescription[i], "'"))
        }
      }
    }

    # Group columns with same parameter
    val_grouped <- val_data |>
      dplyr::group_by(.data$paramcd, .data$endpoint) |>
      dplyr::summarise(column = list(.data$column),
                       method_text = list(gsub("\r\n", "\n", .data$unified_origin)),
                       comment = list(.data$comment))

    val_meta <- lapply(seq_len(nrow(val_grouped)), function(i) {
      row <- val_grouped[i, ]

      result <- list(
        id = row$paramcd,
        label = row$endpoint,
        columns = purrr::pmap(
          list(id = unlist(row$column), method = unlist(row$method_text), comment = unlist(row$comment)),
          list
        )
      )

      clean_list(result)
    })
  } else {
    val_meta <- list() # Empty list if no value metadata exists
    val_data <- data.frame(NULL)
  }

  list(val_meta, val_data)
}
