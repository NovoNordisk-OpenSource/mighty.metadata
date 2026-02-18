#' Populate Predecessor Metadata
#'
#' @description
#' Populates column metadata from predecessor references. Columns with a
#' `method` in the format `domain.column` (e.g., `ADSL.USUBJID`) inherit
#' metadata from the referenced predecessor.
#'
#' @param x A [mighty_study] or [mighty_metadata] object.
#' @param ... Additional arguments passed to methods.
#'
#' @return A modified [mighty_study] or [mighty_metadata] with predecessor
#'   column metadata populated.
#'
#' @seealso [mighty_study], [populate_core()], [create_md_col()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' study <- populate_sparse(study)
#'
#' @export
populate_sparse <- S7::new_generic(
  name = "populate_sparse",
  dispatch_args = "x"
)

#' @noRd
S7::method(populate_sparse, mighty_study) <- function(x) {
  populate_sparse_study(study = x)
}

#' @noRd
S7::method(populate_sparse, mighty_metadata) <- function(x, study) {
  populate_sparse_domain(domain = x, study = study)
}

#' @noRd
populate_sparse_study <- function(study) {
  study[] <- lapply(
    X = study,
    FUN = populate_sparse_domain,
    study = study
  )

  study
}

#' @noRd
populate_sparse_domain <- function(domain, study) {
  predecessors <- which_ids(
    x = domain[["columns"]],
    id = list_predecessors(domain)
  )

  domain[["columns"]][predecessors] <- lapply(
    X = domain[["columns"]][predecessors],
    FUN = \(x) {
      update_predecessor(column = x, study = study)
    }
  )

  domain
}

#' Helper function to updated a single column list entry with its predecessor information.
#' For consistency it does not change the properties in `discard`.
#' @noRd
update_predecessor <- function(
  column,
  study,
  discard = c("id", "core", "method", "origin", "component", "depends")
) {
  predecessor_pattern <- "^[a-zA-Z0-9]+\\.[a-zA-Z0-9]+$"
  if (!isTRUE(grepl(pattern = predecessor_pattern, x = column$method))) {
    cli::cli_abort(
      "{column$id}: Non standard predecessor method {.code {column$method}}.
      Must be in the {.code {{domain}}.{{column}}} format."
    )
  }

  pred_table <- gsub(pattern = "\\..*$", replacement = "", x = column$method)
  pred_column <- gsub(pattern = "^.*\\.", replacement = "", x = column$method)

  column$origin <- "Predecessor"

  if (!pred_table %in% names(study)) {
    zephyr::msg_debug(
      "{column$id}: Predecessor domain {.code {pred_table}} not found in study"
    )
    return(column)
  }

  if (!pred_column %in% list_columns(x = study[[pred_table]])) {
    cli::cli_abort(
      "{column$id}: Predecessor {.code {column$method}} not found in study"
    )
  }

  pred <- study[[pred_table]] |>
    select_column(id = pred_column)

  updated_values <- names(pred) |>
    setdiff(y = discard) |>
    setdiff(y = names(column))

  column[updated_values] <- pred[updated_values]

  column
}
