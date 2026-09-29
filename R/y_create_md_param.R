#' Create Metadata Parameter Table
#'
#' @description
#' Converts a [mighty_study] or [mighty_domain] object into a flat dataframe
#' of BDS parameter definitions.
#'
#' Only the parameters themselves are returned. Use [create_md_values()] to
#' get the column definitions nested inside each parameter.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#'
#' @return A tibble with one row per parameter containing:
#' \describe{
#'   \item{table_id}{Table identifier}
#'   \item{table_label}{Table label/description}
#'   \item{order}{Parameter order within table}
#'   \item{id}{Parameter code (`PARAMCD`)}
#'   \item{label}{Parameter label (`PARAM`)}
#' }
#'
#' @seealso [mighty_study], [create_md()], [create_md_table()],
#'   [create_md_col()], [create_md_values()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' create_md_param(study)
#'
#' @export
create_md_param <- S7::new_generic(
  name = "create_md_param",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @noRd
S7::method(create_md_param, mighty_study) <- function(x) {
  create_md_param_study(study = x)
}

#' @noRd
S7::method(create_md_param, mighty_domain) <- function(x) {
  create_md_param_domain(domain = x)
}

#' @noRd
create_md_param_study <- function(study) {
  bind_entries(study, create_md_param)
}

#' @noRd
create_md_param_domain <- function(domain) {
  if (!length(domain[["parameters"]])) {
    return(mdparam_template)
  }

  mdtable <- create_md_table(domain)

  domain[["parameters"]] |>
    bind_entries(
      fun = apply_template,
      template = mdparam_template,
      order = TRUE
    ) |>
    copy_columns(y = mdtable, cols = c("id", "label"), prefix = "table_") |>
    apply_template(template = mdparam_template)
}

#' @noRd
mdparam_template <- tibble::tibble(
  table_id = character(),
  table_label = character(),
  order = integer(),
  id = character(),
  label = character()
)
