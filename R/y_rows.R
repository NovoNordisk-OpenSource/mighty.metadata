#' Update rows in your metadata
#'
#' Functions to list, remove, add, and move row operations in
#' your `mighty_metadata()` objects.
#'
#' @param x `mighty_metadata()` Object to manipulate.
#' @param id `character()` Id of the row(s) to remove, add, or move.
#' @param ... Additional properties to add for the row, e.g. a `label = "my row"`.
#' @param .pos `integer(1)` Position to put or move the row to. Default places the row as the last.
#' @returns `invisible(x)`
#' @examples
#' # Load example configuration
#' x <- mighty_metadata(
#'   file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
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
S7::method(list_rows, mighty_metadata) <- function(x) {
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
S7::method(remove_rows, mighty_metadata) <- function(x, id) {
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
S7::method(add_row, mighty_metadata) <- function(
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
S7::method(move_row, mighty_metadata) <- function(
  x,
  id,
  .pos = length(x[["rows"]])
) {
  row_move(x, id, .pos = .pos)
}

#' @noRd
row_list <- function(x) {
  list_ids(x = x[["rows"]])
}

#' @noRd
row_remove <- function(x, id) {
  for (i in rev(which_ids(x = x[["rows"]], id = id))) {
    x[["rows"]][i] <- NULL
  }

  validate(x)
}

#' @noRd
row_add <- function(x, id, ..., .pos) {
  row <- c(
    id = id,
    rlang::list2(...)
  )

  x[["rows"]] <- insert_in_vector(
    x = x[["rows"]],
    y = row,
    pos = .pos
  )

  validate(x)
}

#' @noRd
row_move <- function(x, id, .pos) {
  row <- get_id(x = x[["rows"]], id = id)

  x <- remove_rows(x = x, id = id)

  args <- c(
    list(x = x),
    row,
    list(.pos = .pos)
  )

  do.call(
    what = add_row,
    args = args
  )
}
