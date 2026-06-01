#' Mighty Config
#'
#' @description
#' `mighty_config()` provides a dedicated S7 class for the `_mighty.yml`
#' configuration file used in the `{mighty}` framework.
#'
#' A new object is initialized by supplying a directory path containing a
#' `_mighty.yml` file. The file is automatically validated against the
#' `mighty.json` schema when loaded.
#'
#' `mighty_config()` inherits from `S7schema::S7schema()`. You can validate
#' an object at any time by calling `validate()` and use `write_config()` to
#' save it back as a yaml file.
#'
#' @param path `character(1)` path to a directory containing a `_mighty.yml`
#'   file.
#'
#' @return A `mighty_config` S7 object extending [S7schema::S7schema].
#'   The underlying list contains the parsed and validated YAML configuration
#'   including `external_data`.
#'
#' @examples
#' x <- mighty_config(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#'
#' # Custom print method gives a small overview
#' print(x)
#'
#' # Underlying object is a `list`
#' str(x)
#'
#' @name mighty_config
NULL

#' @noRd
construct_mighty_config <- function(path) {
  schema <- system.file("schema", "mighty.json", package = "mighty.metadata")
  file <- find_yml(path = path, name = "_mighty", schema = schema)

  S7::new_object(
    .parent = S7schema::S7schema(
      file = file,
      schema = schema
    )
  )
}

#' @rdname mighty_config
#' @export
mighty_config <- S7::new_class(
  name = "mighty_config",
  parent = S7schema::S7schema,
  constructor = construct_mighty_config
)

#' @noRd
S7::method(print, mighty_config) <- function(x, ...) {
  print_mighty_config(x)
}

#' @noRd
print_mighty_config <- function(x, ...) {
  n <- length(x$external_data)

  cli::cli_bullets(
    text = c(
      "{.cls {class(x)[[1]]}}",
      "External data: {n} source{?s} ({.code {vapply(x$external_data, \\(e) e$id, character(1))}})"
    )
  )

  invisible(x)
}
