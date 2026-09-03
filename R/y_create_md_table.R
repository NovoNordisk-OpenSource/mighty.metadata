#' Create Metadata Dataset Table
#'
#' @description
#' Converts a [mighty_study] or [mighty_domain] object into a flat dataframe
#' of table (dataset) definitions.
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#'
#' @return A tibble with one row per table containing:
#' \describe{
#'   \item{order}{Table order within the study}
#'   \item{id}{Table identifier}
#'   \item{label}{Table label/description}
#'   \item{class}{CDISC class of the dataset}
#'   \item{subclass}{CDISC subclass of the dataset}
#'   \item{structure}{Description of the structure of the dataset}
#'   \item{keys}{List column of key variables}
#'   \item{comment}{Comment}
#' }
#'
#' @seealso [mighty_study], [create_md_col()], [create_md_param()],
#'   [create_md_values()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' create_md_table(study)
#'
#' @export
create_md_table <- S7::new_generic(
  name = "create_md_table",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @noRd
S7::method(create_md_table, mighty_study) <- function(x) {
  create_md_table_study(study = x)
}

#' @noRd
S7::method(create_md_table, mighty_domain) <- function(x) {
  create_md_table_domain(domain = x)
}

#' @noRd
create_md_table_study <- function(study) {
  bind_domains(study, create_md_table, order = TRUE)
}

#' @noRd
create_md_table_domain <- function(domain) {
  entries <- domain[names(domain) %in% names(mdtable_template)]
  entries[["keys"]] <- list(unlist(entries[["keys"]], use.names = FALSE))

  mdtable <- do.call(what = tibble::tibble, args = entries)
  mdtable[["order"]] <- 1L

  apply_template(mdtable, mdtable_template)
}

#' @noRd
mdtable_template <- tibble::tibble(
  order = integer(),
  id = character(),
  label = character(),
  class = character(),
  subclass = character(),
  structure = character(),
  keys = list(),
  comment = character()
)
