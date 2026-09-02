#' Mighty Config
#'
#' @description
#' `mighty_config()` provides a robust way of working with the `_mighty.yml`
#' configuration file in the `{mighty}` framework.
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
#' \describe{
#'   \item{`external_data`}{A list of external data source specifications,
#'     each with an `id` and `keys` field.}
#'   \item{`repos`}{Optional character vector of component repository
#'     locations, or `NULL` if not specified.}
#' }
#'
#' @details
#' The `_mighty.yml` file is validated against the `mighty.json` schema on
#' load. The file must contain an `external_data` array declaring the primary
#' keys of any datasets external to the ADaM study (e.g. SDTM or reference
#' datasets) that ADaM domain specifications may depend on.
#'
#' The optional `repos` field specifies where `mighty.component` should look
#' for shared components. Each entry is either a local path (e.g. `"."`) or a
#' GitHub reference in `owner/repo/subdir@ref` format (e.g.
#' `"NovoNordisk-OpenSource/mighty.standards/components@main"`).
#'
#' @section Write Config:
#' Use [write_config()] to serialize a `mighty_config()` object back to a
#' `_mighty.yml` file. Supply `path` to write to a specific directory;
#' defaults to the directory the object was loaded from.
#'
#' @seealso [mighty_study], [study_config], [mighty_domain], [write_config()]
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
#' # Write back to a directory
#' tmp <- tempdir()
#' write_config(x, path = tmp)
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

#' @noRd
validate_mighty_config <- function(self) {
  self |>
    check_unique_ids()
  return(NULL)
}

#' @rdname mighty_config
#' @export
mighty_config <- S7::new_class(
  name = "mighty_config",
  parent = S7schema::S7schema,
  constructor = construct_mighty_config,
  validator = function(self) {
    validate_mighty_config(self)
  }
)

#' @noRd
S7::method(print, mighty_config) <- function(x, ...) {
  print_mighty_config(x)
}

#' @noRd
print_mighty_config <- function(x, ...) {
  n <- length(x$external_data)
  ids <- vapply(x$external_data, \(e) e$id, character(1))

  bullets <- c(
    "{.cls {class(x)[[1]]}}",
    "External data: {n} source{?s} ({.code {ids}})"
  )
  if (length(x$repos) > 0) {
    bullets <- c(bullets, "Repos: {length(x$repos)} ({.code {x$repos}})")
  }
  cli::cli_bullets(bullets)

  invisible(x)
}
