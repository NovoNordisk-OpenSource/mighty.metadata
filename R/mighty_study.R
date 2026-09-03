#' Mighty Study
#'
#' @description
#' Creates a `mighty_study` object by loading all YAML metadata files from a
#' directory. Each YAML file (except `_mighty.yml` and `_study.yml`) is parsed
#' as a [mighty_domain] object. The optional `_study.yml` file provides
#' study-level properties and the optional `_mighty.yml` file provides
#' mighty framework configuration.
#'
#' @param path `character(1)` path to a directory containing YAML metadata files.
#' @param populate `logical(1)` if `TRUE`, calls [populate_core()] then
#'   [populate_sparse()] before returning. Default is `FALSE`.
#'
#' @return A `mighty_study` S7 object extending `list`:
#' \describe{
#'   \item{List elements}{[mighty_domain] objects, named by their `id` field.
#'     Access via e.g. `study$adsl`.}
#'   \item{`@study`}{A [study_config] object loaded from `_study.yml`, or
#'     `NULL` if no properties file exists.}
#'   \item{`@mighty`}{A [mighty_config] object loaded from `_mighty.yml`, or
#'     `NULL` if no configuration file exists.}
#'   \item{`@path`}{The source directory path as `character(1)`.}
#' }
#'
#' @details
#' The function scans the directory for files matching `*.yaml` or `*.yml`:
#' - Files named `_study.yml` or `_study.yaml` are treated as study properties
#' - Files named `_mighty.yml` or `_mighty.yaml` are treated as mighty framework config
#' - All other YAML files must follow ADaM naming conventions (starting with
#'   `ad`) and are loaded as [mighty_domain] objects
#' - Only one `_mighty.yml` and one `_study.yml` file is allowed per directory
#'
#' @section Write Study Metadata:
#' Use [write_config()] to serialize a `mighty_study()` object back to YAML
#' files. Each domain is written as a separate file, plus `_mighty.yml` and
#' `_study.yml` when `@mighty` and `@study` are not `NULL`. If `path` is
#' `NULL`, files are written to `x@path`.
#'
#' @seealso [mighty_domain], [mighty_config], [study_config],
#'   [write_config()], [populate_sparse()], [populate_core()],
#'   [create_md_col()]
#'
#' @examples
#' # Load example study
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#'
#' # List tables with metadata
#' names(study)
#'
#' # Access ADVS
#' study$ADVS
#'
#' # Access study-level properties
#' study@study
#'
#' # Access mighty framework configuration
#' study@mighty
#'
#' # Load and populate in one step
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata"),
#'   populate = TRUE
#' )
#'
#' # Write study back to YAML
#' tmp <- tempdir()
#' write_config(study, path = tmp)
#'
#' @name mighty_study
NULL

#' @noRd
construct_mighty_study <- function(path, populate = FALSE) {
  mighty_schema <- system.file(
    "schema",
    "mighty.json",
    package = "mighty.metadata"
  )
  study_schema <- system.file(
    "schema",
    "study.json",
    package = "mighty.metadata"
  )

  mighty_file <- find_yml(path = path, name = "_mighty", schema = mighty_schema)
  study_file <- find_yml(path = path, name = "_study", schema = study_schema)

  entries <- list.files(
    path = path,
    pattern = "\\.(yaml|yml)$",
    full.names = TRUE
  ) |>
    setdiff(c(mighty_file, study_file))

  validate_datasets(entries)

  entries <- lapply(X = entries, FUN = mighty_domain)

  names(entries) <- vapply(
    X = entries,
    FUN = \(x) x$id,
    FUN.VALUE = character(1)
  )

  study <- S7::new_object(
    .parent = entries,
    mighty = if (is.null(mighty_file)) NULL else mighty_config(mighty_file),
    study = if (is.null(study_file)) NULL else study_config(study_file),
    path = path
  )

  if (!isTRUE(populate)) {
    return(study)
  }

  study |>
    populate_core() |>
    populate_sparse()
}

#' @noRd
validate_datasets <- function(files) {
  files_names <- files[!startsWith(toupper(basename(files)), "AD")]

  if (length(files_names) > 0) {
    cli::cli_abort(paste0(
      "Incorrect file name detected: ",
      "{.list {basename(files_names)}}",
      " in (path: {.path {unique(dirname(files_names))}}). ",
      "Please change the file name or remove file from specifications directory."
    ))
  }
}

#' @noRd
validate_path <- function(value) {
  if (length(value) != 1L || is.na(value)) {
    return("@path must be a single non-NA string")
  }
  if (!dir.exists(value)) {
    return("Directory does not exist")
  }
}

#' @rdname mighty_study
#' @export
mighty_study <- S7::new_class(
  name = "mighty_study",
  parent = S7::class_list,
  properties = list(
    mighty = S7::new_property(
      class = NULL | mighty_config
    ),
    study = S7::new_property(
      class = NULL | study_config
    ),
    path = S7::new_property(
      class = S7::class_character,
      validator = \(value) {
        validate_path(value = value)
      }
    )
  ),
  constructor = construct_mighty_study
)

#' @noRd
S7::method(print, mighty_study) <- function(x, ...) {
  print_mighty_study(x)
}

#' @noRd
print_mighty_study <- function(x, ...) {
  entries <- paste0(
    "$ ",
    names(x),
    ": {.cls ",
    vapply(
      X = x,
      FUN = \(x) class(x)[[1]],
      FUN.VALUE = character(1)
    ),
    "}"
  )

  mighty <- NULL
  if (!is.null(x@mighty)) {
    mighty <- "@ mighty: {.cls {class(x@mighty)[[1]]}}"
  }

  study <- NULL
  if (!is.null(x@study)) {
    study <- "@ study: {.cls {class(x@study)[[1]]}}"
  }

  cli::cli_bullets(
    text = c(
      "{.cls {class(x)}}",
      mighty,
      study,
      entries
    )
  )

  invisible(x)
}
