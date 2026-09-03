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
  bind_entries(study, create_md_values)
}

#' @noRd
create_md_values_domain <- function(domain) {
  mdparam <- create_md_param(domain)

  mdvalues <- bind_entries(
    x = seq_len(nrow(mdparam)),
    fun = \(i) {
      create_md_values_param(
        parameter = domain[["parameters"]][[i]],
        param = mdparam[i, ]
      )
    }
  )

  apply_template(mdvalues, mdvalues_template)
}

#' @noRd
create_md_values_param <- function(parameter, param) {
  if (!length(parameter[["columns"]])) {
    return(NULL)
  }

  mdvalues <- bind_entries(
    x = parameter[["columns"]],
    fun = apply_template,
    template = mdvalues_template,
    order = TRUE
  )

  mdvalues[["table_id"]] <- param[["table_id"]]
  mdvalues[["table_label"]] <- param[["table_label"]]
  mdvalues[["param_order"]] <- param[["order"]]
  mdvalues[["param_id"]] <- param[["id"]]
  mdvalues[["param_label"]] <- param[["label"]]

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
