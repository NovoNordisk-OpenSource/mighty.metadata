
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
