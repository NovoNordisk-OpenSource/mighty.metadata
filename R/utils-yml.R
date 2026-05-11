# YAML Utilities
#
# Internal helpers for finding, reading, and writing YAML files.
#
# @param path `character(1)` Directory to search or write to.
# @param name `character(1)` File name prefix (e.g. `"_mighty"`).
# @param schema `character(1)` Path to the JSON schema file.
# @param file `character(1)` or `NULL`. Path to a YAML file.
# @param x Object to write (converted via `S7schema::to_yaml()`).

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

  S7schema::validate_yaml(files, schema)
}

#' @noRd
read_yml <- function(file) {
  if (is.null(file)) {
    return(list())
  }
  yaml::read_yaml(file = file)
}

#' @noRd
match_yml <- function(path, name) {
  files <- list_yml(path, name)

  if (!length(files)) {
    return(file.path(path, paste0(name, ".yml")))
  }

  files
}

#' @noRd
write_yml <- function(x, path, name) {
  cat(
    S7schema::to_yaml(x),
    file = match_yml(path, name),
    sep = ""
  )

  invisible(x)
}
