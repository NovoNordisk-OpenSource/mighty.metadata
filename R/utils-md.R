#' Bind the metadata of each domain in a study
#'
#' Applies `fun` to every domain in `study` and row binds the resulting data
#' frames into a single metadata data set.
#'
#' Set `order = TRUE` to renumber `order` across the whole study. Leave it
#' `FALSE` when `order` is scoped to the parent data set, e.g. columns within
#' a table, as the domain level numbering is then already correct.
#' @noRd
bind_domains <- function(study, fun, order = FALSE) {
  bound <- study |>
    lapply(FUN = fun) |>
    purrr::list_rbind()

  if (order) {
    bound[["order"]] <- seq_len(nrow(bound))
  }

  bound
}

#' Apply a metadata template to a data frame
#'
#' Binds `x` onto `template` so that columns missing from `x` are added with
#' the type defined by the template, and subsets to the template columns to
#' drop any extra columns and enforce the template column order.
#' @noRd
apply_template <- function(x, template) {
  purrr::list_rbind(list(template, x))[names(template)]
}
