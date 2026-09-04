#' Mighty Domain
#'
#' @description
#' `mighty_domain()` provides a robust way of working with ADaM metadata in the `{mighty}` framework.
#'
#' A new object is initialized by supplying either an existing yaml metadata
#' file or an in-memory `list` of the same content.
#' This package provides helpers to update column, parameter, and row entries.
#' See the references below for help:
#'
#' * `help("columns")`
#' * `help("parameters")`
#' * `help("rows")`
#'
#' `mighty_domain()` inherits from `S7schema::S7schema()` and the yaml file is
#' automatically validated when loaded. The helper functions above also always validates
#' the new configuration before returning.
#'
#' You can at anytime validate an object by calling `validate()` and use
#' `write_config()` to save it as a yaml file again.
#'
#' @param file `character(1)` path to a yaml file defining an ADaM dataset.
#'   Mutually exclusive with `.data`.
#' @param .data `list` holding an ADaM dataset specification already in memory.
#'   Mutually exclusive with `file`. The resulting object has `@file` set to
#'   `NULL`, so [write_config()] requires an explicit `path`.
#'
#' @return A `mighty_domain` S7 object extending [S7schema::S7schema].
#'   The underlying list contains the parsed and validated YAML metadata
#'   including `id`, `label`, `class`, `keys`, `columns`, `parameters`,
#'   and `rows`.
#'
#' @examples
#' x <- mighty_domain(
#'   file = system.file("examples", "advs.yml", package = "mighty.metadata")
#' )
#'
#' # Custom print method gives a small overview
#' print(x)
#'
#' # Underlying object is a `list`
#' str(x)
#'
#' # Or build one in memory
#' y <- mighty_domain(
#'   .data = list(
#'     id = "ADVS",
#'     label = "Vital Signs Analysis Dataset",
#'     class = "BASIC DATA STRUCTURE",
#'     structure = "One record per parameter, per visit, per subject",
#'     keys = c("USUBJID", "PARAMCD"),
#'     columns = list(
#'       list(id = "USUBJID", label = "Unique Subject Identifier")
#'     )
#'   )
#' )
#'
#' # In-memory objects have no file, so `write_config()` needs a `path`
#' y@file
#'
#' @name mighty_domain
NULL

#' @noRd
construct_mighty_domain <- function(file, .data) {
  S7::new_object(
    .parent = S7schema::S7schema(
      file = file,
      schema = system.file("schema", "adam.json", package = "mighty.metadata"),
      .data = .data
    )
  )
}

#' @noRd
validate_mighty_domain <- function(self) {
  self |>
    check_unique_ids() |>
    check_column_dependencies()
  return(NULL)
}

#' @rdname mighty_domain
#' @export
mighty_domain <- S7::new_class(
  name = "mighty_domain",
  parent = S7schema::S7schema,
  constructor = construct_mighty_domain,
  validator = function(self) {
    validate_mighty_domain(self)
  }
)

#' @noRd
S7::method(print, mighty_domain) <- function(x, ...) {
  print_mighty_domain(x)
}

#' @noRd
print_mighty_domain <- function(x, ...) {
  cli::cli_bullets(
    text = c(
      "{.cls {class(x)[[1]]}}",
      "{x$id}: {x$label}",
      "Class: {x$class}",
      "Keys: {x$keys}"
    )
  )

  invisible(x)
}
