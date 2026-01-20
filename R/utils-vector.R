#' Inserts element into existing vector.
#' Default behaviour inserts `y` as the last element.
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

#' Helper function to get all `cores`s as a logical value`
#' from all elements in a list.
#' @noRd
list_cores <- function(x) {
  vapply(
    X = x,
    FUN = \(x) ifelse("core" %in% names(x), x[["core"]], FALSE),
    FUN.VALUE = logical(1)
  )
}

#' Helper function to get the index of entries
#' with certain id value(s)
#' @noRd
which_ids <- function(x, id) {
  which(list_ids(x) %in% id)
}
