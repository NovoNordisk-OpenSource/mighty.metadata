#' Populate Core Variables Across Datasets
#'
#' Identifies datasets that supply core variables and adds them as predecessors
#' to datasets that use core variables.
#'
#' @param mighty_metadata_list A list of metadata objects, where each element
#'   contains dataset information including columns and metadata.
#'
#' @return A modified version of `mighty_metadata_list` where datasets marked
#'   with `usecore = TRUE` have core variables from supplier datasets added as
#'   predecessor columns.
#'
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Identifies datasets that supply core variables
#'   \item Verifies core variables are unique across datasets (stops if duplicates found)
#'   \item Identifies datasets that use core variables (via `usecore` metadata flag)
#'   \item Adds missing core variables as predecessor columns to datasets that use them
#' }
#'
#' @examples
#' \dontrun{
#' updated_metadata <- populate_core(mighty_metadata_list)
#' }
#'
populate_core <- function(mighty_metadata_list) {
  # Find all datasets that supply core variables
  supply_cores <- vapply(
    X = mighty_metadata_list,
    FUN = \(x) any(list_cores(x[["columns"]])),
    FUN.VALUE = logical(1)
  )

  mighty_cores <- mighty_metadata_list[supply_cores]

  all_cores <- lapply(
    X = mighty_cores,
    FUN = \(x) list_columns(x)[list_cores(x[["columns"]])]
  )

  # Check if core variables are unique
  core_table <- table(all_cores)

  non_unique_cores <- names(core_table)[core_table > 1]

  if (length(non_unique_cores) > 0) {
    stop("non-unique core variable(s) found: ",
         paste(non_unique_cores, collapse = ", "))
  }

  # Find all datasets that use core variables
  use_cores <- vapply(
    X = mighty_metadata_list,
    FUN = \(x) ifelse("usecore" %in% names(x[["metadata"]]),
                      x[["metadata"]][["usecore"]],
                      FALSE),
    FUN.VALUE = logical(1)
  )

  # Add core variables as predecessors to datasets that use them
  mighty_metadata_list_with_cores <- lapply(
    X = mighty_metadata_list[use_cores],
    FUN = \(mighty_dataset) {
      add_cores <- lapply(
        X = all_cores,
        FUN = \(x) setdiff(x, list_columns(mighty_dataset))
      )

      core_sources_vec <- lapply(
        X = seq_along(all_cores),
        FUN = \(x) rep(mighty_cores[[x]][["id"]], length(all_cores[[x]]))
      ) |>
        unlist()

      add_cores_vec <- unlist(add_cores)

      Reduce(
        f = \(init, x) {
          add_column(x = init,
                     id = add_cores_vec[[x]],
                     method = paste0("Predecessor: ", core_sources_vec[[x]],".", add_cores_vec[[x]], "\n"))
        },
        x = seq_along(add_cores_vec),
        init = mighty_dataset
      )
    }
  )

  mighty_metadata_list[use_cores] <- mighty_metadata_list_with_cores

  mighty_metadata_list
}
