#' Mighty Domain
#'
#' @description
#' `mighty_domain()` provides a robust way of working with ADaM metadata in the `{mighty}` framework.
#'
#' A new object is initialized by supplying an existing yaml metadata file.
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
#' @name mighty_domain
NULL

#' @noRd
construct_mighty_domain <- function(file) {
  S7::new_object(
    .parent = S7schema::S7schema(
      file = file,
      schema = system.file("schema", "adam.json", package = "mighty.metadata")
    )
  )
}

#' @noRd
validate_mighty_domain <- function(self) {
  check_column_dependencies(self)
  check_unique_ids(self)
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
