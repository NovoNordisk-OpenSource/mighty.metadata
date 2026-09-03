#' Apply a metadata template to a data frame
#'
#' Binds `x` onto `template` so that columns missing from `x` are added with
#' the type defined by the template, and subsets to the template columns to
#' drop any extra columns and enforce the template column order.
#' @noRd
apply_template <- function(x, template) {
  purrr::list_rbind(list(template, x))[names(template)]
}
