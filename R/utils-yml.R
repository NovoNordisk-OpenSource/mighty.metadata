#' Find and validate a YAML configuration file
#'
#' Looks for a single YAML file matching the given name in a directory and
#' validates it against a JSON schema. Returns the validated file path, or
#' `NULL` if no file is found. Errors if more than one matching file exists.
#'
#' @param path `character(1)` Directory to search.
#' @param name `character(1)` File name prefix (e.g. `"_mighty"`).
#' @param schema `character(1)` Path to the JSON schema file.
#' @returns The file path as `character(1)`, or `NULL`.
#' @noRd
find_yml <- function(path, name, schema) {
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

  if (length(files) == 0) {
    zephyr::msg_verbose("No {.code {name}.yml} file found")
    return(NULL)
  }

  S7schema::validate_yaml(files, schema)
}

#' Read a YAML file or return an empty list
#'
#' @param file `character(1)` or `NULL`. Path to a YAML file.
#' @returns A list with the parsed YAML contents, or an empty `list()`.
#' @noRd
read_yml <- function(file) {
  if (is.null(file)) {
    return(list())
  }
  yaml::read_yaml(file = file)
}
