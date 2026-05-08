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
#'   \item{`@study`}{Study-level properties from `_study.yml`, or empty list
#'     if no properties file exists.}
#'   \item{`@mighty`}{Mighty framework configuration from `_mighty.yml`, or empty list
#'     if no configuration file exists.}
#' }
#'
#' @details
#' The function scans the directory for files matching `*.yaml` or `*.yml`:
#' - Files named `_study.yml` or `_study.yaml` are treated as study properties
#' - Files named `_mighty.yml` or `_mighty.yaml` are treated as mighty framework config
#' - All other YAML files are loaded as [mighty_domain] objects
#' - Only one `_mighty.yml` and one `_study.yml` file is allowed per directory
#'
#' @seealso [mighty_domain], [populate_sparse()], [populate_core()], [create_md_col()]
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

  entries <- lapply(X = entries, FUN = mighty_domain)

  names(entries) <- vapply(
    X = entries,
    FUN = \(x) x$id,
    FUN.VALUE = character(1)
  )

  study <- S7::new_object(
    .parent = entries,
    mighty = read_yml(file = mighty_file),
    study = read_yml(file = study_file),
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
validate_mighty <- function(value) {
  if (length(value) > 0) {
    schema <- system.file(
      "schema",
      "mighty.json",
      package = "mighty.metadata"
    )
    S7schema::validate_list(value, schema)
    check_unique_ids(value)
  }
  NULL
}

#' @noRd
validate_study <- function(value) {
  if (length(value) > 0) {
    schema <- system.file(
      "schema",
      "study.json",
      package = "mighty.metadata"
    )
    S7schema::validate_list(value, schema)
  }
  NULL
}

#' @noRd
validate_path <- function(value) {
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
      class = S7::class_list,
      validator = \(value) {
        validate_mighty(value = value)
      }
    ),
    study = S7::new_property(
      class = S7::class_list,
      validator = \(value) {
        validate_study(value = value)
      }
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
  if (length(x@mighty)) {
    mighty <- "@ mighty: {.code {names(x@mighty)}}"
  }

  study <- NULL
  if (length(x@study)) {
    study <- "@ study: {.code {names(x@study)}}"
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
