#' Populate Core Variables
#'
#' @description
#' Adds core variables from supplier datasets as predecessor columns to
#' datasets that use them (marked with `usecore = TRUE`).
#'
#' Note: Currently only accepts core variables from ADSL.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#' @param ... Additional arguments passed to methods.
#'
#' @return A modified [mighty_study] or [mighty_domain] with core variables
#'   added as predecessor columns.
#'
#' @seealso [mighty_study], [populate_sparse()], [create_md_col()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' study <- populate_core(study)
#'
#' @export
populate_core <- S7::new_generic(
  name = "populate_core",
  dispatch_args = "x"
)

#' @noRd
S7::method(populate_core, mighty_study) <- function(x) {
  populate_core_study(study = x)
}

#' @noRd
S7::method(populate_core, mighty_domain) <- function(x, study) {
  populate_core_domain(domain = x, study = study)
}

#' @noRd
populate_core_study <- function(study) {
  study[] <- lapply(
    X = study,
    FUN = populate_core,
    study = study
  )

  study
}

#' Adds core variables from ADSL
#' and checks for duplicate column specifications.
#' Note: If we later want to allow non-ADSL core variables
#' just remove the check.
#' @noRd
populate_core_domain <- function(domain, study) {
  if (!isTRUE(domain$usecore)) {
    return(domain)
  }

  study[[which(names(study) %in% domain$id)]] <- NULL

  core_vars <- lapply(X = study, FUN = list_cores) |>
    lapply(FUN = \(x) stats::setNames(nm = x)) |>
    unlist() |>
    toupper()

  dup_core_vars <- which(duplicated(core_vars))
  if (length(dup_core_vars)) {
    cli::cli_abort(
      "Non-unique core variable(s) found: {.code {names(core_vars)[dup_core_vars]}}"
    )
  }

  non_adsl_core_vars <- which(
    !grepl(pattern = "^ADSL\\.", x = names(core_vars))
  )
  if (length(non_adsl_core_vars)) {
    cli::cli_abort(
      "Only ADSL is allowed to have core columns.
      Found: {.code {names(core_vars)[non_adsl_core_vars]}}"
    )
  }

  dup_vars <- which(core_vars %in% list_columns(domain))
  if (length(dup_vars)) {
    cli::cli_abort(
      "{domain$id} - Variable(s) with same name already exists: {.code {names(core_vars)[dup_vars]}}"
    )
  }

  predecessor <- names(core_vars)

  for (i in seq_along(core_vars)) {
    domain <- add_column(
      x = domain,
      id = core_vars[[i]],
      method = predecessor[[i]],
      origin = "Predecessor"
    )
  }

  domain
}
