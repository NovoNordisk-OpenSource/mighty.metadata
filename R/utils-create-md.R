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

#' Apply a metadata template to a metadata entry
#'
#' Binds `x` onto `template` so that columns missing from `x` are added with
#' the type defined by the template, and subsets to the template columns to
#' drop any extra columns and enforce the template column order.
#'
#' `x` is either a data frame, or a single metadata entry such as a
#' [mighty_domain] or a column definition. Entries are turned into a one row
#' data frame by [new_md_row()] first. An `x` without any rows returns the
#' empty `template`.
#' @noRd
apply_template <- function(x, template) {
  if (!is.data.frame(x)) {
    x <- new_md_row(x, template)
  }

  if (!nrow(x)) {
    return(template)
  }

  purrr::list_rbind(list(template, x))[names(template)]
}

#' Turn a single metadata entry into a one row data frame
#'
#' Nested entries such as `format` are flattened into `format_type`,
#' `format_length` and so on, entries matching a list column of `template` are
#' wrapped by [wrap_list_entries()], and everything not named in `template` is
#' dropped.
#' @noRd
new_md_row <- function(x, template) {
  x <- as.list(x)
  list_cols <- names(template)[
    vapply(X = template, FUN = is.list, FUN.VALUE = logical(1))
  ]

  entries <- c(
    purrr::list_flatten(x[!names(x) %in% list_cols]),
    wrap_list_entries(x[names(x) %in% list_cols])
  )

  do.call(
    what = tibble::tibble,
    args = entries[names(entries) %in% names(template)]
  )
}

#' Wrap metadata entries destined for a list column
#'
#' Collapses each entry to a single vector and wraps it in a list, so that
#' [tibble::tibble()] stores it as one list column element rather than
#' expanding it into several rows.
#' @noRd
wrap_list_entries <- function(x) {
  lapply(X = x, FUN = \(entry) list(unlist(entry, use.names = FALSE)))
}
