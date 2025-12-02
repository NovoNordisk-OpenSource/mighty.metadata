#' Mighty metadata
#'
#' @description
#' `mighty_metadata()` provides a robust way of working with ADaM metadata in the `{mighty}` framework.
#'
#' A new object is initialised by supplying an existing yaml metadata file.
#' This package provides helpers to update column, parameter, and row entries.
#' See the references below for help:
#'
#' * `help("columns")`
#' * `help("parameters")`
#' * `help("rows")`
#'
#' `mighty_metadata()` inherits from `S7schema::S7schema()` and the yaml file is
#' automatically validated when loaded. The helper functions above also always validates
#' the new configuration before returning.
#'
#' You can at anytime validate an object by calling `validate()` and use
#' `write_config()` to save it as a yaml file again.
#'
#' @param file `character(1)` path to a yaml file defining a ADaM dataset.
#' @examples
#' x <- mighty_metadata(
#'   file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
#' )
#'
#' # Custom print method gives a small overview
#' print(x)
#'
#' # Underlying object is a `list`
#' str(x)
#'
#' @name mighty_metadata
NULL

#' @noRd
construct_mighty_metadata <- function(file) {
  S7::new_object(
    .parent = S7schema::S7schema(
      file = file,
      schema = system.file("schema", "adam.json", package = "mighty.metadata")
    )
  )
}

#' @rdname mighty_metadata
#' @export
mighty_metadata <- S7::new_class(
  name = "mighty_metadata",
  parent = S7schema::S7schema,
  constructor = construct_mighty_metadata
)

#' @noRd
S7::method(print, mighty_metadata) <- function(x, ...) {
  print_mighty_metadata(x)
}

#' @noRd
print_mighty_metadata <- function(x, ...) {
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
