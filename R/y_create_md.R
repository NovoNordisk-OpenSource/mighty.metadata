#' Create All Metadata Data Sets
#'
#' @description
#' Converts a [mighty_study] or [mighty_domain] object into all four metadata
#' data sets at once, as a convenience wrapper around [create_md_table()],
#' [create_md_col()], [create_md_param()] and [create_md_values()].
#'
#' @param x A [mighty_study] or [mighty_domain] object.
#'
#' @return A named list of tibbles:
#' \describe{
#'   \item{mdtable}{Table definitions, see [create_md_table()]}
#'   \item{mdcol}{Column definitions, see [create_md_col()]}
#'   \item{mdparam}{BDS parameter definitions, see [create_md_param()]}
#'   \item{mdvalues}{Value level definitions, see [create_md_values()]}
#' }
#'
#' @seealso [mighty_study], [create_md_table()], [create_md_col()],
#'   [create_md_param()], [create_md_values()]
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' create_md(study)
#'
#' @export
create_md <- S7::new_generic(
  name = "create_md",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @noRd
S7::method(create_md, mighty_study) <- function(x) {
  create_md_all(x)
}

#' @noRd
S7::method(create_md, mighty_domain) <- function(x) {
  create_md_all(x)
}

#' @noRd
create_md_all <- function(x) {
  list(
    mdtable = create_md_table(x),
    mdcol = create_md_col(x),
    mdparam = create_md_param(x),
    mdvalues = create_md_values(x)
  )
}
