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
  idx <- which_ids(x = x, id = id)

  if (length(idx) == 0L) {
    cli::cli_abort("Id {.code {id}} does not exist")
  }

  x[[which_ids(x = x, id = id)]]
}

#' Helper function to get all `ìd`s as a character value`
#' from all elements in a list.
#' @noRd
list_ids <- function(x) {
  if (!length(x)) {
    return(character(0))
  }

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

#' Remove entries by id from a list
#' @noRd
remove_ids <- function(x, id) {
  if (!length(id)) {
    return(x)
  }

  x[which_ids(x, id)] <- NULL

  if (!length(x)) {
    return(NULL)
  }

  x
}

#' Update properties of an entry by id
#' @noRd
update_ids <- function(x, id, ..., .remove = character()) {
  if (!length(id)) {
    return(x)
  }

  updates <- rlang::list2(...)
  for (idx in which_ids(x, id)) {
    x[[idx]][names(updates)] <- updates
    x[[idx]][.remove] <- NULL
  }
  x
}

#' Move an entry to a new position
#' @noRd
move_id <- function(x, id, .pos) {
  item <- get_id(x, id)
  x <- remove_ids(x, id)
  insert_in_vector(x, item, pos = .pos)
}

#' Helper function to get the index of entries
#' with certain id value(s)
#' @noRd
which_ids <- function(x, id) {
  if (!length(x)) {
    return(integer(0))
  }

  which(list_ids(x) %in% id)
}

#' Helper to list all sub-elements with an 'include' entry
#' @noRd
list_includes <- function(x) {
  if (!length(x)) {
    return(character(0))
  }

  is_include <- vapply(
    X = x,
    FUN = \(x) "include" %in% names(x),
    FUN.VALUE = logical(1)
  )
  list_ids(x[is_include])
}

#' Helper to check that all lists have unique `id` entries
#' Note, that it checks uniqueness on the same top-level and not
#' for the entire object.
#' @noRd
check_unique_ids <- function(x) {
  if (!length(x)) {
    return(x)
  }

  flat <- unlist(x)
  flat <- flat[grepl(pattern = "^[^.]+\\.id$", x = names(flat))]

  flatter <- paste(names(flat), flat, sep = ": ")

  duplicates <- unique(flatter[duplicated(flatter)])
  names(duplicates) <- rep("x", times = length(duplicates))

  if (length(duplicates)) {
    cli::cli_abort(
      c("Duplicate `id` entries found:", duplicates)
    )
  }
}

#' Check that no forbidden column-to-column dependencies exist across domains
#'
#' Column dependencies are allowed only on row and parameters levels.
#' Dependencies pointing directly to another column are considered invalid
#' and will terminate execution with a descriptive error.
check_column_dependencies <- function(mighty_domains) {

  all_column_ids <- lapply(mighty_domains, function(domain) {

    flattened_columns <- unlist(domain$columns)
    local_column_ids <- flattened_columns[grepl("id$", names(flattened_columns))]
    paste0(domain$id, ".", local_column_ids)
  }) |> unlist()

  lapply(mighty_domains, function(domain) {

    flattened_columns <- unlist(domain$columns)
    declared_dependencies <- flattened_columns[ grepl("depends", names(flattened_columns))]
    forbidden_dependencies <- intersect( declared_dependencies, all_column_ids)

    if (length(forbidden_dependencies) > 0) {
      cli::cli_abort(paste0("Detected not allowed column to column dependencies: {forbidden_dependencies} in {domain$id} dataset. ",
                            "Please fix this dependency or remove it."))
    }
  })

  invisible(TRUE)
}
