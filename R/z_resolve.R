#' Resolve conditional metadata items
#'
#' Evaluates `include` fields on metadata items (columns, rows, parameters)
#' and removes items where the condition evaluates to `FALSE`.
#'
#' Include conditions are R expressions with `{glue}` syntax for variable
#' substitution and evaluation. The `info` list provides the values used
#' to do this.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#' @param info `list()` Named list of values used to evaluate `include`
#'   expressions. For [mighty_study], merged into `x@study`.
#' @returns The input object with conditional items resolved.
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#'
#' # Add a conditional column
#' study$ADVS <- update_column(
#'   study$ADVS,
#'   id = "STUDYID",
#'   include = "{study_id == 'my_study'}"
#' )
#'
#' # Condition TRUE: column kept (study_id is "my_study" in @study)
#' study |>
#'   resolve_includes() |>
#'   getElement("ADVS") |>
#'   list_columns()
#'
#' # Condition FALSE: column removed
#' study |>
#'   resolve_includes(info = list(study_id = "other")) |>
#'   getElement("ADVS") |>
#'   list_columns()
#'
#' @export
resolve_includes <- S7::new_generic(
  name = "resolve_includes",
  dispatch_args = "x",
  fun = function(x, info = list()) S7::S7_dispatch()
)

#' @noRd
S7::method(resolve_includes, mighty_study) <- function(x, info = list()) {
  includes_resolve_study(study = x, info = info)
}

#' @noRd
S7::method(resolve_includes, mighty_domain) <- function(x, info = list()) {
  includes_resolve_domain(domain = x, info = info)
}

#' @noRd
includes_resolve_study <- function(study, info = list()) {
  study@study[names(info)] <- info

  S7::S7_data(study) <- lapply(
    X = study,
    FUN = resolve_includes,
    info = study@study
  )

  study
}

#' @noRd
includes_resolve_domain <- function(domain, info = list()) {
  domain$columns <- includes_resolve_list(domain$columns, info)
  domain$rows <- includes_resolve_list(domain$rows, info)
  domain$parameters <- includes_resolve_list(domain$parameters, info)
  validate(domain)
}

#' @noRd
includes_resolve_list <- function(x, info) {
  if (is.null(x)) {
    return(NULL)
  }

  ids <- list_includes(x)

  if (length(ids) == 0L) {
    return(x)
  }

  include <- vapply(
    X = ids,
    FUN = \(id) eval_include(get_id(x, id)[["include"]], info),
    FUN.VALUE = logical(1)
  )

  x |>
    update_ids(id = ids[include], .remove = "include") |>
    remove_ids(id = ids[!include])
}

#' @noRd
eval_include <- function(include, info) {
  if (is.logical(include)) {
    return(include)
  }

  glue::glue_data(.x = info, include) |>
    as.logical() |>
    isTRUE()
}
