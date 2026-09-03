#' Create Metadata Value Table
#'
#' @description
#' Converts a [mighty_study] or [mighty_domain] object into a flat dataframe
#' of value level definitions, i.e. the columns defined inside each BDS
#' parameter.
#'
#' Parameters without any `columns` entry contribute no rows. Use
#' [create_md_param()] for the full list of parameters.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#'
#' @return A tibble with one row per parameter column containing:
#' \describe{
#'   \item{table_id}{Table identifier}
#'   \item{table_label}{Table label/description}
#'   \item{param_order}{Parameter order within table}
#'   \item{param_id}{Parameter code (`PARAMCD`)}
#'   \item{param_label}{Parameter label (`PARAM`)}
#'   \item{order}{Column order within parameter}
#'   \item{id}{Column name}
#'   \item{label}{Column label}
#'   \item{origin}{Origin type (e.g., "Predecessor", "Derived")}
#'   \item{method}{Derivation method}
#'   \item{codelist}{Codelist reference}
#'   \item{format_type}{Data type}
#'   \item{format_length}{Maximum length}
#'   \item{format_display}{Display format}
#'   \item{comment}{Comment}
#' }
#'
#' @seealso [mighty_study], [create_md_table()], [create_md_col()],
#'   [create_md_param()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' create_md_values(study)
#'
#' @export
create_md_values <- S7::new_generic(
  name = "create_md_values",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @noRd
S7::method(create_md_values, mighty_study) <- function(x) {
  create_md_values_study(study = x)
}

#' @noRd
S7::method(create_md_values, mighty_domain) <- function(x) {
  create_md_values_domain(domain = x)
}

#' @noRd
create_md_values_study <- function(study) {
  study |>
    lapply(create_md_values) |>
    purrr::list_rbind()
}

#' @noRd
create_md_values_domain <- function(domain) {
  parameters <- domain[["parameters"]]

  mdvalues <- seq_along(parameters) |>
    lapply(FUN = \(i) create_md_values_param(parameters[[i]], order = i)) |>
    Filter(f = Negate(is.null)) |>
    purrr::list_rbind()

  if (!nrow(mdvalues)) {
    return(mdvalues_template)
  }

  mdvalues[["table_id"]] <- domain[["id"]]
  mdvalues[["table_label"]] <- domain[["label"]]

  purrr::list_rbind(list(mdvalues_template, mdvalues))
}

#' @noRd
create_md_values_param <- function(parameter, order) {
  if (!length(parameter[["columns"]])) {
    return(NULL)
  }

  mdvalues_cols <- names(mdvalues_template)

  mdvalues <- parameter[["columns"]] |>
    lapply(FUN = \(x) {
      x <- purrr::list_flatten(x)
      do.call(
        what = tibble::tibble,
        args = x[names(x) %in% mdvalues_cols]
      )
    }) |>
    purrr::list_rbind()

  mdvalues[["param_order"]] <- order
  mdvalues[["param_id"]] <- parameter[["id"]]
  mdvalues[["param_label"]] <- parameter[["label"]] %||% NA_character_
  mdvalues[["order"]] <- seq_len(nrow(mdvalues))

  mdvalues
}

#' @noRd
mdvalues_template <- tibble::tibble(
  table_id = character(),
  table_label = character(),
  param_order = integer(),
  param_id = character(),
  param_label = character(),
  order = integer(),
  id = character(),
  label = character(),
  origin = character(),
  method = character(),
  codelist = character(),
  format_type = character(),
  format_length = integer(),
  format_display = character(),
  comment = character()
)
