#' Inserts element into existing vector.
#' Default behavior inserts `y` as the last element.
#' Position is changed with pos argument.
#' @noRd
insert_in_vector <- function(x, y, pos = length(x) + 1L) {
  stopifnot(pos > 0L && length(pos) == 1L)

  if (pos <= length(x)) {
    i <- seq(from = pos, to = length(x))
    x[i + 1L] <- x[i]
  }

  x[[pos]] <- y

  x
}

#' Helper function to retrieve entry with a certain id
#' @noRd
get_id <- function(x, id) {
  x[[which_ids(x = x, id = id)]]
}

#' Helper function to get all `ìd`s as a character value`
#' from all elements in a list.
#' @noRd
list_ids <- function(x) {
  vapply(
    X = x,
    FUN = \(x) x[["id"]],
    FUN.VALUE = character(1)
  )
}

#' Helper function to list all `core` columns
#' @noRd
list_cores <- function(x) {
  vapply(
    X = x[["columns"]],
    FUN = \(x) list(x[["id"]][isTRUE(x[["is_core"]])]),
    FUN.VALUE = list(1)
  ) |>
    unlist()
}

# Helper to check if a columns is a predecessor
#' @noRd
is_predecessor <- function(col) {
  has_predecessor_origin <- isTRUE(col[["origin"]] == "Predecessor")

  has_method_reference <- isTRUE(
    grepl(
      pattern = "^[a-zA-Z0-9]+\\.[a-zA-Z0-9]+$",
      x = col[["method"]]
    )
  )

  has_predecessor_origin || has_method_reference
}

# Helper to list all predecessor columns
#' @noRd
list_predecessors <- function(x) {
  cols <- x[["columns"]]
  is_pred <- vapply(X = cols, FUN = is_predecessor, FUN.VALUE = logical(1))
  list_ids(cols[is_pred])
}

#' Helper function to get the index of entries
#' with certain id value(s)
#' @noRd
which_ids <- function(x, id) {
  which(list_ids(x) %in% id)
}
