#' Update columns in your metadata
#'
#' Functions to list, remove, add, and move columns in
#' your `mighty_metadata()` objects.
#'
#' @param x `mighty_metadata()` Object to manipulate.
#' @param id `character()` Id of the column(s) to remove, add, or move.
#' @param ... Additional properties to add for the column, e.g. a `label = "my label"`.
#' @param .pos `integer(1)` Position to put or move the column to. Default places the column as the last.
#' @returns `invisible(x)`
#' @examples
#' # Load example configuration
#' x <- mighty_metadata(
#'   file = system.file("examples", "advs.yml", package = "mighty.metadata")
#' )
#'
#' # List all columns defined
#' list_columns(x)
#'
#' # Remove the STUDYID and USUBJID columns
#' x |>
#'   remove_columns(c("STUDYID", "USUBJID")) |>
#'   list_columns()
#'
#' # Add a new column
#' x |>
#'   add_column(id = "NEW") |>
#'   list_columns()
#'
#' # Add new column with label and as the first column
#' y <- x |>
#'   add_column(id = "NEW", label = "My label", .pos = 1)
#'
#' list_columns(y)
#'
#' str(y[["columns"]][[1]])
#'
#' # Move the STUDYID column to the 3rd position
#' x |>
#'   move_column(id = "STUDYID", .pos = 3) |>
#'   list_columns()
#'
#' @name columns
NULL

#' @rdname columns
#' @export
list_columns <- S7::new_generic(
  name = "list_columns",
  dispatch_args = "x",
  fun = \(x) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(list_columns, mighty_metadata) <- function(x) {
  col_list(x)
}

#' @rdname columns
#' @export
remove_columns <- S7::new_generic(
  name = "remove_columns",
  dispatch_args = "x",
  fun = \(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(remove_columns, mighty_metadata) <- function(x, id) {
  col_remove(x, id)
}

#' @rdname columns
#' @export
add_column <- S7::new_generic(
  name = "add_column",
  dispatch_args = c("x"),
  fun = \(x, id, ..., .pos = length(x[["columns"]]) + 1L) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(add_column, mighty_metadata) <- function(
  x,
  id,
  ...,
  .pos = length(x[["columns"]]) + 1L
) {
  col_add(x, id, ..., .pos = .pos)
}

#' @rdname columns
#' @export
move_column <- S7::new_generic(
  name = "move_column",
  dispatch_args = c("x"),
  fun = \(x, id, .pos = length(x[["columns"]])) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(move_column, mighty_metadata) <- function(
  x,
  id,
  .pos = length(x[["columns"]])
) {
  col_move(x, id, .pos = .pos)
}

#' @rdname columns
#' @export
select_column <- S7::new_generic(
  name = "select_column",
  dispatch_args = "x",
  fun = \(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(select_column, mighty_metadata) <- function(x, id) {
  col_select(x, id)
}

#' @noRd
col_list <- function(x) {
  list_ids(x = x[["columns"]])
}

#' @noRd
col_remove <- function(x, id) {
  for (i in rev(which_ids(x = x[["columns"]], id = id))) {
    x[["columns"]][i] <- NULL
  }

  validate(x)
}

#' @noRd
col_add <- function(x, id, ..., .pos) {
  column <- c(
    id = id,
    rlang::list2(...)
  )

  x[["columns"]] <- insert_in_vector(
    x = x[["columns"]],
    y = column,
    pos = .pos
  )

  validate(x)
}

#' @noRd
col_move <- function(x, id, .pos) {
  column <- get_id(x = x[["columns"]], id = id)

  x <- remove_columns(x = x, id = id)

  args <- c(
    list(x = x),
    column,
    list(.pos = .pos)
  )

  do.call(
    what = add_column,
    args = args
  )
}

#' @noRd
col_select <- function(x, id) {
  x[["columns"]][[which_ids(x = x[["columns"]], id = id)]]
}
