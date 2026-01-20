#' Populate columns with predecessor metadata in a mighty_metadata list
#'
#' Iterate over a list of table metadata (mighty_metadata_list) and for each
#' column entry call update_predecessor to populate missing metadata from a
#' predecessor source. The source can be the same list (default) or an external
#' data frame with column definitions.
#'
#' @param mighty_metadata_list A named list of table metadata. Each element is
#' expected to be a list containing a "columns" element; "columns" should be a
#' list of column metadata entries (lists).
#' @param source Either the same list as mighty_metadata_list (default) or an
#' alternative source containing predecessor information. The source may be a
#' data.frame (with rows for table/column definitions) or a list structured
#' like mighty_metadata_list.
#'
#' @return A list with the same structure as mighty_metadata_list where each
#' column entry may have been updated with predecessor metadata.
#'
#' @examples
#' # Assume mighty_meta is a list of tables with a "columns" element
#' # populate_sparse(mighty_meta)
#'
#' @export
populate_sparse <- function(mighty_metadata_list, source = mighty_metadata_list) {
  lapply(mighty_metadata_list, \(x) {
    x[["columns"]] <- lapply(x[["columns"]], \(y) {
      update_predecessor(y, source = source)
    })
    x
  })
}


#' Helper function to extract a column list entry from an external data.frame
#' @noRd
column_as_list <- function(ds, table_filter, column_filter) {
  row <- ds |>
    dplyr::filter(table == table_filter, column == column_filter)

  if (nrow(row) == 0) {
    return(NULL)
  } else if (nrow(row) > 1) {
    stop(table_filter, ".", column_filter, " is not unique")
  }

  list(
    id = row$column,
    label = row$label,
    format = list(
      type = row$type,
      length = row$length
    )
  )
}

#' Helper function to updated a single column list entry with its predecessor information
#' @noRd
update_predecessor <- function(x, source) {
  if (!"method" %in% names(x)) {
    return(x)
  }
  if (!grepl("^Predecessor: ", x$method)) {
    return(x)
  }

  predecessor <- gsub("^Predecessor: ([A-Za-z0-9]+\\.[A-Za-z0-9]+).*", "\\1", x$method)

  pred_table <- strsplit(predecessor, "\\.")[[1]][1]
  pred_column <- strsplit(predecessor, "\\.")[[1]][2]

  if (inherits(source, "data.frame")) {
    expected_source_columns <- c("table", "column", "label", "type", "length")
    missing_source_columns <- setdiff(expected_source_columns, colnames(source))

    if (length(missing_source_columns) > 0) {
      stop("The suppied `source` data.frame does not contain the ",
           "expected column(s): ", paste(missing_source_columns, collapse = ", "))
    }

    out <- column_as_list(source, pred_table, pred_column)
  } else if (inherits(source, "list")) {
    # Check that the predecessor table and column exist in the source list
    if (pred_table %in% names(source)) {
      if (pred_column %in% list_columns(source[[pred_table]])) {
        out <- source[[pred_table]][["columns"]] |>
          get_id(pred_column)

        if ("core" %in% names(out)) {
          out[["core"]] <- NULL
        }
      } else {
        return(x)
      }
    } else {
      return(x)
    }
  } else {
    stop("No recognized source given")
  }

  if (is.null(out)) {
    return(x)
  }

  updated_values <- setdiff(names(out), names(x))

  if ("format" %in% names(out) & "format" %in% names(x)) {
    updated_formats <- setdiff(names(out$format), names(x$format))

    x$format[updated_formats] <- out$format[updated_formats]
  }

  x[updated_values] <- out[updated_values]

  x
}
