#' Mighty Documents
#'
#' @description
#' `mighty_documents()` creates an S7 object for storing document metadata.
#' The class inherits from `S7::class_list` and represents the contents of
#' `documents.yml` as a list of document entries.
#'
#' The object is validated on creation and when `validate()` is called.
#' Validation includes:
#' - schema compliance with `inst/schema/documents.json`,
#' - uniqueness of document identifiers (`id`).
#'
#' Writing to YAML is done via `write_config()` on a `mighty_study()` object,
#' where documents are saved to `documents.yml`.
#'
#' @param file `character(1)` path to `documents.yml`.
#' @param x `list()` of document entries.
#'
#' @return An object of class `mighty_documents`.
#'
#' @examples
#' docs <- mighty_documents(
#'   x = list(
#'     list(
#'       id = "DOC001",
#'       title = "Statistical Analysis Plan",
#'       doctype = "suppdoc",
#'       href = "./docs/sap.pdf"
#'     )
#'   )
#' )
#'
#' # Custom print method gives a small overview
#' print(docs)
#'
#' # Write documents.yml through mighty_study
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#' study@documents <- docs
#'
#' @name documents
NULL

#' @noRd
construct_mighty_documents <- function(file = NULL, x = NULL) {
  if (!is.null(file)) {
    x <- read_yml(file)
  }

  if (is.null(x)) {
    x <- list()
  }

  S7::new_object(.parent = x)
}

#' @noRd
validate_mighty_documents <- function(self) {
  if (!length(self)) {
    return(NULL)
  }

  schema <- system.file("schema", "documents.json", package = "mighty.metadata")
  S7schema::validate_list(S7::S7_data(self), schema)
  check_unique_ids(S7::S7_data(self))

  NULL
}

#' @rdname documents
#' @export
mighty_documents <- S7::new_class(
  name = "mighty_documents",
  parent = S7::class_list,
  constructor = construct_mighty_documents,
  validator = function(self) {
    validate_mighty_documents(self)
  }
)

#' @noRd
S7::method(print, mighty_documents) <- function(x, ...) {
  print_mighty_documents(x)
}

#' @noRd
print_mighty_documents <- function(x, ...) {
  ids <- list_documents(x)

  cli::cli_bullets(
    text = c(
      "{.cls {class(x)[[1]]}}",
      "Documents: {length(ids)} entr{?y/ies}",
      "IDs: {.code {ids}}"
    )
  )

  invisible(x)
}
