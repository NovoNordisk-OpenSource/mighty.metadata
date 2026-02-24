#' Create Metadata Column Table
#'
#' @description
#' Converts a [mighty_study] or [mighty_metadata] object into a flat dataframe
#' of column definitions.
#'
#' @param x A [mighty_study] or [mighty_metadata] object.
#'
#' @return A tibble with one row per column containing:
#' \describe{
#'   \item{table_id}{Table identifier}
#'   \item{table_label}{Table label/description}
#'   \item{order}{Column order within table}
#'   \item{id}{Column name}
#'   \item{label}{Column label}
#'   \item{origin}{Origin type (e.g., "Predecessor", "Derived")}
#'   \item{key}{Logical, whether column is a key}
#'   \item{is_core}{Logical, whether column is a core variable}
#'   \item{core}{String, whether a column is Req, Cond or Perm}
#'   \item{method}{Derivation method}
#'   \item{codelist}{Codelist reference}
#'   \item{format_type}{Data type ("C" or "N")}
#'   \item{format_length}{Maximum length}
#'   \item{format_display}{Display format}
#' }
#'
#' @seealso [mighty_study], [populate_sparse()], [populate_core()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' mdcol <- create_md_col(study)
#'
#' @export
create_md_col <- S7::new_generic(
  name = "create_md_col",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @noRd
S7::method(create_md_col, mighty_study) <- function(x) {
  create_md_col_study(study = x)
}

#' @noRd
S7::method(create_md_col, mighty_metadata) <- function(x) {
  create_md_col_domain(domain = x)
}

#' @noRd
create_md_col_study <- function(study) {
  study |>
    lapply(create_md_col) |>
    purrr::list_rbind()
}

#' @noRd
create_md_col_domain <- function(domain) {
  mdcol_cols <- names(mdcol_template)

  mdcol <- domain$columns |>
    lapply(FUN = \(x) {
      x <- purrr::list_flatten(x)
      do.call(
        what = tibble::tibble,
        args = x[names(x) %in% mdcol_cols]
      )
    }) |>
    purrr::list_rbind()

  mdcol[["table_id"]] <- domain[["id"]]
  mdcol[["table_label"]] <- domain[["label"]]
  mdcol[["key"]] <- mdcol[["id"]] %in% domain[["keys"]]
  mdcol[["order"]] <- seq_len(nrow(mdcol))

  purrr::list_rbind(list(mdcol_template, mdcol))
}

#' @noRd
mdcol_template <- tibble::tibble(
  table_id = character(),
  table_label = character(),
  order = integer(),
  id = character(),
  label = character(),
  origin = character(),
  key = logical(),
  is_core = logical(),
  core = character(),
  method = character(),
  codelist = character(),
  format_type = character(),
  format_length = integer(),
  format_display = character()
)
