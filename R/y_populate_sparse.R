#' Populate Predecessor Metadata
#'
#' @description
#' Populates column metadata from predecessor references. Columns with a
#' `method` in the format `domain.column` (e.g., `ADSL.USUBJID`) inherit
#' metadata from the referenced predecessor.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#' @param ... Additional arguments passed to methods.
#'
#' @return A modified [mighty_study] or [mighty_domain] with predecessor
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
S7::method(populate_sparse, mighty_domain) <- function(x, study) {
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
  Reduce(
    f = \(init, x) {
      update_predecessor(
        x = init,
        id = x,
        study = study
      )
    },
    x = list_predecessors(domain),
    init = domain
  )
}

#' Helper function to updated a single column list entry with its predecessor information.
#' For consistency it does not change the properties in `discard`.
#' @noRd
update_predecessor <- function(
  x,
  id,
  study,
  discard = c("id", "is_core", "method", "origin", "component", "depends")
) {
  column <- select_column(x = x, id = id)

  predecessor_pattern <- "^[a-zA-Z0-9]+\\.[a-zA-Z0-9]+$"
  if (!isTRUE(grepl(pattern = predecessor_pattern, x = column$method))) {
    cli::cli_abort(
      "{id}: Non standard predecessor method {.code {column$method}}.
      Must be in the {.code {{domain}}.{{column}}} format."
    )
  }

  pred_table <- gsub(pattern = "\\..*$", replacement = "", x = column$method)
  pred_column <- gsub(pattern = "^.*\\.", replacement = "", x = column$method)

  if (!pred_table %in% names(study)) {
    zephyr::msg_debug(
      "{column$id}: Predecessor domain {.code {pred_table}} not found in study"
    )
    return(
      update_column(
        x = x,
        id = id,
        origin = "Predecessor"
      )
    )
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

  do.call(
    what = update_column,
    args = c(
      x = list(x),
      id = list(id),
      origin = list("Predecessor"),
      pred[updated_values]
    )
  )
}
