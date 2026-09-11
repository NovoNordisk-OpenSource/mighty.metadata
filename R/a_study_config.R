#' Study Config
#'
#' @description
#' `study_config()` provides a robust way of working with the `_study.yml`
#' configuration file in the `{mighty}` framework.
#'
#' A new object is initialized by supplying either the path to a `_study.yml`
#' file or an in-memory `list` of the same content. Both are automatically
#' validated against the `study.json` schema.
#'
#' `study_config()` inherits from `S7schema::S7schema()`. You can validate
#' an object at any time by calling `validate()` and use `write_config()` to
#' save it back as a yaml file.
#'
#' @param file `character(1)` path to a `_study.yml` file. Mutually exclusive
#'   with `.data`.
#' @param .data `list` holding a `_study.yml` configuration already in memory.
#'   Mutually exclusive with `file`.
#'
#' @return A `study_config` S7 object extending [S7schema::S7schema].
#' \describe{
#'   \item{`study_id`}{Unique identifier of the study.}
#'   \item{`study_description`}{Optional description of the study.}
#'   \item{`standards`}{Optional list of standards, each with `id` and
#'     `version`.}
#'   \item{`terminology`}{Optional list of controlled terminologies, each with
#'     `id` and `version`.}
#' }
#'
#' @details
#' The `_study.yml` file is validated against the `study.json` schema on load.
#' The file must contain a `study_id` field. Additional study-level properties
#' are allowed and are kept as-is.
#'
#' The optional `standards` and `terminology` fields describe the standards and
#' controlled terminologies applied in the study; see
#' `vignette("study-schema")`.
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
#' # Or build one in memory
#' study_config(
#'   .data = list(study_id = "example_study", study_description = "A study")
#' )
#'
#' @name study_config
NULL

#' @noRd
construct_study_config <- function(file, .data) {
  # `S7schema(file =)` parses the yaml in JavaScript, where js-yaml's default
  # schema resolves `version: 2025-08-06` to a timestamp. Reading it in R
  # keeps such values as strings, so validate the parsed data instead.
  if (!missing(file) && !is.null(file)) {
    if (!file.exists(file)) {
      cli::cli_abort("Illegal file reference {.file {file}}")
    }

    x <- S7schema::S7schema(
      .data = yaml::read_yaml(file),
      schema = system.file("schema", "study.json", package = "mighty.metadata")
    )
    x@file <- file
    return(S7::new_object(.parent = x))
  }

  S7::new_object(
    .parent = S7schema::S7schema(
      file = file,
      schema = system.file("schema", "study.json", package = "mighty.metadata"),
      .data = .data
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
