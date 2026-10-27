#' Update rows in your metadata
#'
#' Functions to list, select, remove, add, update, and move row operations in
#' your `mighty_domain()` objects.
#'
#' @param x `mighty_domain()` Object to manipulate.
#' @param id `character()` Id of the row(s) to remove, add, or move.
#' @param ... Additional properties to add for the row, e.g. a `label = "my row"`.
#' @param .pos `integer(1)` Position to put or move the row to. Default places the row as the last.
#' @returns `invisible(x)`
#' @examples
#' # Load example configuration
#' x <- mighty_domain(
#'   file = system.file("examples", "advs.yml", package = "mighty.metadata")
#' )
#'
#' # List all rows defined
#' list_rows(x)
#'
#' # Add a new row
#' y <- x |>
#'   add_row(id = "NEW")
#'
#' list_rows(y)
#'
#' # Remove the new row again
#' y |>
#'   remove_rows("NEW") |>
#'   list_rows()
#'
#' # Update an existing row
#' x |>
#'   update_row(id = "BASELINE", method = "Updated method") |>
#'   select_row(id = "BASELINE") |>
#'   str()
#'
#' # Select a specific row
#' select_row(x, id = "BASELINE") |>
#'   str()
#'
#' @name rows
NULL

#' @rdname rows
#' @export
list_rows <- S7::new_generic(
  name = "list_rows",
  dispatch_args = "x",
  fun = \(x) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(list_rows, mighty_domain) <- function(x) {
  row_list(x)
}

#' @rdname rows
#' @export
remove_rows <- S7::new_generic(
  name = "remove_rows",
  dispatch_args = "x",
  fun = \(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(remove_rows, mighty_domain) <- function(x, id) {
  row_remove(x, id)
}

#' @rdname rows
#' @export
add_row <- S7::new_generic(
  name = "add_row",
  dispatch_args = c("x"),
  fun = \(x, id, ..., .pos = length(x[["rows"]]) + 1L) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(add_row, mighty_domain) <- function(
  x,
  id,
  ...,
  .pos = length(x[["rows"]]) + 1L
) {
  row_add(x, id, ..., .pos = .pos)
}

#' @rdname rows
#' @export
move_row <- S7::new_generic(
  name = "move_row",
  dispatch_args = c("x"),
  fun = \(x, id, .pos = length(x[["rows"]])) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(move_row, mighty_domain) <- function(
  x,
  id,
  .pos = length(x[["rows"]])
) {
  row_move(x, id, .pos = .pos)
}

#' @rdname rows
#' @export
update_row <- S7::new_generic(
  name = "update_row",
  dispatch_args = "x",
  fun = \(x, id, ...) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(update_row, mighty_domain) <- function(x, id, ...) {
  row_update(x, id, ...)
}

#' @rdname rows
#' @export
select_row <- S7::new_generic(
  name = "select_row",
  dispatch_args = "x",
  fun = \(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(select_row, mighty_domain) <- function(x, id) {
  row_select(x, id)
}

#' @noRd
row_list <- function(x) {
  list_ids(x[["rows"]])
}

#' @noRd
row_remove <- function(x, id) {
  x[["rows"]] <- remove_ids(x[["rows"]], id)
  validate(x)
}

#' @noRd
row_add <- function(x, id, ..., .pos) {
  row <- c(id = id, rlang::list2(...))
  x[["rows"]] <- insert_in_vector(x[["rows"]], row, pos = .pos)
  validate(x)
}

#' @noRd
row_move <- function(x, id, .pos) {
  x[["rows"]] <- move_id(x[["rows"]], id, .pos)
  validate(x)
}

#' @noRd
row_update <- function(x, id, ...) {
  x[["rows"]] <- update_ids(x[["rows"]], id, ...)
  validate(x)
}

#' @noRd
row_select <- function(x, id) {
  get_id(x[["rows"]], id)
}
