#' Resolve row subsets
#'
#' Rewrites row actions that carry a `subset` field into equivalent `component`
#' actions that operate on a filtered subset of the source domain. The `subset`
#' field is removed after resolution.
#'
#' The row's `component.with.domain` is rewritten to
#' `.mighty_subset(<domain>, "<subset>")`, a marker call that
#' `mighty.component::mighty_component$render()` recognizes and expands into
#' code that applies the action only to rows matching the R expression given
#' in `subset`. A `component` with a `with.domain` entry is required.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#' @returns The input object with row subsets resolved.
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#'
#' # Add a row action restricted to a subset of source rows
#' study$ADAE <- add_row(
#'   study$ADAE,
#'   id = "TRTEMFL_STUDY1",
#'   component = list(
#'     id = "STUDY1_COMPONENT",
#'     with = list(domain = "ADAE")
#'   ),
#'   subset = "STUDYID == 'STUDY1'"
#' )
#'
#' # `subset` is folded into `component.with.domain` as a `.mighty_subset()` marker call
#' study |>
#'   resolve_subsets() |>
#'   getElement("ADAE") |>
#'   select_row("TRTEMFL_STUDY1") |>
#'   str()
#'
#' @export
resolve_subsets <- S7::new_generic(
  name = "resolve_subsets",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @noRd
S7::method(resolve_subsets, mighty_study) <- function(x) {
  resolve_subsets_study(study = x)
}

#' @noRd
S7::method(resolve_subsets, mighty_domain) <- function(x) {
  resolve_subsets_domain(domain = x)
}

#' @noRd
resolve_subsets_study <- function(study) {
  S7::S7_data(study) <- lapply(
    X = study,
    FUN = resolve_subsets
  )

  study
}

#' @noRd
resolve_subsets_domain <- function(domain) {
  rows <- resolve_subsets_list(domain$rows)

  if (
    !identical(rows, domain$rows) &&
      !rlang::is_installed("mighty.component", version = "0.1.0.9003")
  ) {
    zephyr::msg_warning(
      "Resolving row subsets requires {.pkg mighty.component} (>= 0.1.0.9003)"
    )
  }

  domain$rows <- rows
  validate(domain)
}

#' @noRd
resolve_subsets_list <- function(x) {
  if (is.null(x)) {
    return(NULL)
  }

  ids <- which_ids(
    x = x,
    id = list_with_element(x = x, name = "subset")
  )

  if (length(ids) == 0L) {
    return(x)
  }

  x[ids] <- lapply(
    X = x[ids],
    FUN = resolve_subset_entry
  )

  x
}

#' @noRd
resolve_subset_entry <- function(x) {
  if (is.null(x[["component"]])) {
    cli::cli_abort(
      "{.field {x$id}}: Subsetting a row requires that a {.code component} entry is specified"
    )
  }

  x[["component"]] <- resolve_subset_component(
    component = x[["component"]],
    subset = x[["subset"]]
  )

  x[["subset"]] <- NULL

  x
}

#' @noRd
resolve_subset_component <- function(component, subset) {
  if (is.null(component[["with"]][["domain"]])) {
    cli::cli_abort(
      "{.field {component$id}}: Subsetting a component requires that a {.code with.domain} entry is specified"
    )
  }

  component[["with"]][["domain"]] <- glue::glue_data(
    .x = list(
      domain = component[["with"]][["domain"]],
      subset = subset
    ),
    '.mighty_subset({domain}, "{subset}")'
  ) |>
    as.character()

  component
}
