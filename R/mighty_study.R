#' Mighty Study
#'
#' @description
#' Creates a `mighty_study` object by loading all YAML metadata files from a
#' directory. Each YAML file (except `_mighty.yaml`) is parsed as a
#' [mighty_metadata] object. The optional `_mighty.yaml` file provides
#' study-level properties.
#'
#' @param path `character(1)` path to a directory containing YAML metadata files.
#'
#' @return A `mighty_study` S7 object extending `list`:
#' \describe{
#'   \item{List elements}{[mighty_metadata] objects, named by their `id` field.
#'     Access via e.g. `study$adsl`.}
#'   \item{`@info`}{Study-level properties from `_mighty.yaml`, or empty list
#'     if no properties file exists.}
#' }
#'
#' @details
#' The function scans the directory for files matching `*.yaml` or `*.yml`:
#' - Files named `_mighty.yaml` or `_mighty.yml` are treated as study properties
#' - All other YAML files are loaded as [mighty_metadata] objects
#' - Only one `_mighty.yaml` file is allowed per directory
#'
#' @seealso [mighty_metadata], [populate_sparse()], [populate_core()], [create_md_col()]
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
#' study@info
#'
#' @name mighty_study
NULL

#' @noRd
construct_mighty_study <- function(path) {
  properties <- list.files(
    path = path,
    pattern = "^_mighty\\.(yaml|yml)$",
    full.names = TRUE
  )

  if (length(properties) > 1) {
    cli::cli_abort("Only one _mighty file allowed. Found: {.file {properties}}")
  }

  entries <- list.files(
    path = path,
    pattern = "\\.(yaml|yml)$",
    full.names = TRUE
  ) |>
    setdiff(properties)

  entries <- lapply(X = entries, FUN = mighty_metadata)

  names(entries) <- vapply(
    X = entries,
    FUN = \(x) x$id,
    FUN.VALUE = character(1)
  )

  if (length(properties) == 0) {
    zephyr::msg_debug("No _mighty.yml file found")
    properties = list()
  } else {
    properties <- yaml::read_yaml(properties)
  }

  S7::new_object(
    .parent = entries,
    info = properties
  )
}

#' @rdname mighty_study
#' @export
mighty_study <- S7::new_class(
  name = "mighty_study",
  parent = S7::class_list,
  properties = list(
    info = S7::class_list
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

  info <- NULL
  if (length(x@info)) {
    info <- "@ info: {.code {names(x@info)}}"
  }

  cli::cli_bullets(
    text = c(
      "{.cls {class(x)}}",
      info,
      entries
    )
  )

  invisible(x)
}
