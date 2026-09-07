#' Study Config
#'
#' @description
#' `study_config()` provides a robust way of working with the `_study.yml`
#' configuration file in the `{mighty}` framework.
#'
#' A new object is initialized by supplying the path to a `_study.yml` file.
#' The file is automatically validated against the `study.json` schema when
#' loaded.
#'
#' `study_config()` inherits from `S7schema::S7schema()`. You can validate
#' an object at any time by calling `validate()` and use `write_config()` to
#' save it back as a yaml file.
#'
#' @param file `character(1)` path to a `_study.yml` file.
#'
#' @return A `study_config` S7 object extending [S7schema::S7schema].
#' \describe{
#'   \item{`study_id`}{Unique identifier of the study.}
#'   \item{`study_description`}{Optional description of the study.}
#' }
#'
#' @details
#' The `_study.yml` file is validated against the `study.json` schema on load.
#' The file must contain a `study_id` field. Additional study-level properties
#' are allowed and are kept as-is.
#'
#' Study-level properties are used by [resolve_includes()] to evaluate the
#' `include` conditions of domains, columns, parameters, and rows.
#'
#' @section Write Config:
#' Use [write_config()] to serialize a `study_config()` object back to a
#' `_study.yml` file. Supply `path` to write to a specific file; defaults to
#' the file the object was loaded from.
#'
#' @seealso [mighty_study], [mighty_config], [mighty_domain], [write_config()]
#'
#' @examples
#' x <- study_config(
#'   file = system.file("examples", "_study.yml", package = "mighty.metadata")
#' )
#'
#' # Custom print method gives a small overview
#' print(x)
#'
#' # Underlying object is a `list`
#' str(x)
#'
#' # Write back to a file
#' tmp <- tempfile(fileext = ".yml")
#' write_config(x, path = tmp)
#'
#' @name study_config
NULL

#' @noRd
construct_study_config <- function(file) {
  S7::new_object(
    .parent = S7schema::S7schema(
      file = file,
      schema = system.file("schema", "study.json", package = "mighty.metadata")
    )
  )
}

#' @rdname study_config
#' @export
study_config <- S7::new_class(
  name = "study_config",
  parent = S7schema::S7schema,
  constructor = construct_study_config
)

#' @noRd
S7::method(print, study_config) <- function(x, ...) {
  print_study_config(x)
}

#' @noRd
print_study_config <- function(x, ...) {
  cli::cli_bullets(
    text = c(
      "{.cls {class(x)[[1]]}}",
      "Study ID: {x$study_id}",
      "Fields: {.code {names(x)}}"
    )
  )

  invisible(x)
}
