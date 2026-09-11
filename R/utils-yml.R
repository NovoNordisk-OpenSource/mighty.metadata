# YAML Utilities
#
# Internal helpers for locating and validating YAML files.
#
# @param path `character(1)` Directory to search or write to.
# @param name `character(1)` File name prefix (e.g. `"_mighty"`).
# @param schema `character(1)` Path to the JSON schema file.

#' @noRd
list_yml <- function(path, name) {
  files <- list.files(
    path = path,
    pattern = paste0("^", name, "\\.(yaml|yml)$"),
    full.names = TRUE
  )

  if (length(files) > 1) {
    cli::cli_abort(
      "Only one {.code {name}} file allowed. Found: {.file {files}}"
    )
  }

  files
}

#' @noRd
find_yml <- function(path, name, schema) {
  files <- list_yml(path, name)

  if (length(files) == 0) {
    zephyr::msg_verbose("No {.code {name}.yml} file found")
    return(NULL)
  }

  # Validate the R-parsed list rather than calling
  # `S7schema::validate_yaml()`, which parses in JavaScript where js-yaml
  # resolves values like `version: 2025-08-06` to a timestamp and then fails
  # the string check. Reading in R keeps such values as strings.
  S7schema::validate_list(yaml::read_yaml(files), schema)

  files
}

#' @noRd
match_yml <- function(path, name) {
  files <- list_yml(path, name)

  if (!length(files)) {
    return(file.path(path, paste0(name, ".yml")))
  }

  files
}
