#' Update parameters in your metadata
#'
#' Functions to list, select, remove, add, update, and move parameters in
#' your `mighty_metadata()` objects.
#'
#' @param x `mighty_metadata()` Object to manipulate.
#' @param id `character()` Id of the parameter(s) to remove, add, or move.
#' @param label `character(1)` Parameter label.
#' @param columns `list()` Columns to set for the parameter.
#' @param ... Additional properties to add for the parameter, e.g. a component reference.
#' @param .pos `integer(1)` Position to put or move the parameter to. Default places the parameter as the last.
#' @returns `invisible(x)`
#' @examples
#' # Load example configuration
#' x <- mighty_metadata(
#'   file = system.file("examples", "advs.yml", package = "mighty.metadata")
#' )
#'
#' # List all parameters defined
#' list_parameters(x)
#'
#' # Remove the BMIGRP parameter
#' x |>
#'   remove_parameters("BMIGRP") |>
#'   list_parameters()
#'
#' # Add a new parameter
#' x |>
#'   add_parameter(
#'     id = "NEW",
#'     label = "My new parameter",
#'     columns = list(list(id = "AVAL"))
#'   ) |>
#'   list_parameters()
#'
#' # Move the BMIGRP parameter to the 1st position
#' x |>
#'   move_parameter(id = "BMIGRP", .pos = 1) |>
#'   list_parameters()
#'
#' # Update an existing parameter
#' x |>
#'   update_parameter(id = "BMI", label = "Updated BMI Label") |>
#'   select_parameter(id = "BMI") |>
#'   str()
#'
#' # Select a specific parameter
#' select_parameter(x, id = "BMI")
#'
#' @name parameters
NULL

#' @rdname parameters
#' @export
list_parameters <- S7::new_generic(
  name = "list_parameters",
  dispatch_args = "x",
  fun = \(x) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(list_parameters, mighty_metadata) <- function(x) {
  param_list(x)
}

#' @rdname parameters
#' @export
remove_parameters <- S7::new_generic(
  name = "remove_parameters",
  dispatch_args = "x",
  fun = \(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(remove_parameters, mighty_metadata) <- function(x, id) {
  param_remove(x, id)
}

#' @rdname parameters
#' @export
add_parameter <- S7::new_generic(
  name = "add_parameter",
  dispatch_args = c("x"),
  fun = \(x, id, label, columns, ..., .pos = length(x[["parameters"]]) + 1L) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(add_parameter, mighty_metadata) <- function(
  x,
  id,
  label,
  columns,
  ...,
  .pos = length(x[["parameters"]]) + 1L
) {
  param_add(x, id, label, columns, ..., .pos = .pos)
}

#' @rdname parameters
#' @export
move_parameter <- S7::new_generic(
  name = "move_parameter",
  dispatch_args = c("x"),
  fun = \(x, id, .pos = length(x[["parameters"]])) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(move_parameter, mighty_metadata) <- function(
  x,
  id,
  .pos = length(x[["parameters"]])
) {
  param_move(x, id, .pos = .pos)
}

#' @rdname parameters
#' @export
update_parameter <- S7::new_generic(
  name = "update_parameter",
  dispatch_args = "x",
  fun = \(x, id, ...) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(update_parameter, mighty_metadata) <- function(x, id, ...) {
  param_update(x, id, ...)
}

#' @rdname parameters
#' @export
select_parameter <- S7::new_generic(
  name = "select_parameter",
  dispatch_args = "x",
  fun = \(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(select_parameter, mighty_metadata) <- function(x, id) {
  param_select(x, id)
}

#' @noRd
param_list <- function(x) {
  list_ids(x = x[["parameters"]])
}

#' @noRd
param_remove <- function(x, id) {
  for (i in rev(which_ids(x = x[["parameters"]], id = id))) {
    x[["parameters"]][i] <- NULL
  }

  validate(x)
}

#' @noRd
param_add <- function(x, id, label, columns, ..., .pos) {
  parameter <- c(
    id = id,
    label = label,
    columns = list(columns),
    rlang::list2(...)
  )

  x[["parameters"]] <- insert_in_vector(
    x = x[["parameters"]],
    y = parameter,
    pos = .pos
  )

  validate(x)
}

#' @noRd
param_move <- function(x, id, .pos) {
  parameter <- get_id(x = x[["parameters"]], id = id)

  x <- remove_parameters(x = x, id = id)

  args <- c(
    list(x = x),
    parameter,
    list(.pos = .pos)
  )

  do.call(
    what = add_parameter,
    args = args
  )
}

#' @noRd
param_update <- function(x, id, ...) {
  idx <- which_ids(x = x[["parameters"]], id = id)
  updates <- rlang::list2(...)
  x[["parameters"]][[idx]][names(updates)] <- updates

  validate(x)
}

#' @noRd
param_select <- function(x, id) {
  get_id(x = x[["parameters"]], id = id)
}
