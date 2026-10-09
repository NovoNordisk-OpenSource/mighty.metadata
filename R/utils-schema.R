#' Construct an S7schema object for a metadata class
#'
#' Shared by constructors of objects backed by a single YAML file; the result
#' is used as the `.parent` in `S7::new_object()`.
#' Without `file` and `.data`, an empty object is created.
#'
#' @param file `character(1)` path to the YAML file. Optional.
#' @param .data `list()` of entries. Optional.
#' @param schema_name `character(1)` file name of the JSON schema in
#'   `inst/schema`.
#' @noRd
construct_s7schema <- function(file, .data, schema_name) {
  schema <- system.file("schema", schema_name, package = "mighty.metadata")
  if (rlang::is_missing(file) && rlang::is_missing(.data)) {
    .data <- list()
  }
  S7schema::S7schema(file = file, schema = schema, .data = .data)
}
