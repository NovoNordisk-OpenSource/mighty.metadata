#' Update documents in your metadata
#'
#' Functions to list, select, remove, add, and update documents in
#' your `mighty_documents()` object (or through `mighty_study@documents`).
#'
#' @param x A `mighty_documents()` or `mighty_study()` object.
#' @param file `character(1)` path to `documents.yml`.
#' @param id `character()` id of document(s) to select, remove, or update.
#' @param title `character(1)` document title.
#' @param doctype `character(1)` document type.
#' @param href `character(1)` document path/URL.
#' @param .pos `integer(1)` insertion position for a new document.
#' @param ... Additional document properties to update.
#' @returns
#' - `list_documents()`: `character()` vector with document ids.
#' - `select_document()`: selected document entry as a list.
#' - `add_document()`, `update_document()`, `remove_documents()`: modified object (`invisible(x)`).
#'
#' @examples
#' # Load study config
#' s <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#'
#' # Add a document
#' s <- s |>
#'   add_document(
#'     id = "SAP",
#'     title = "Statistical Analysis Plan",
#'     doctype = "suppdoc",
#'     href = "./docs/sap.pdf"
#'   )
#'
#' # List and select documents
#' list_documents(s)
#' select_document(s, id = "SAP")
#'
#' # Update existing document
#' s <- s |>
#'   update_document(
#'     id = "SAP",
#'     title = "Statistical Analysis Plan v2"
#'   )
#'
#' # Remove one or more documents
#' s <- s |>
#'   remove_documents(id = "SAP")
#'
#' # Work directly on mighty_documents
#' docs <- mighty_documents()
#' docs <- docs |>
#'   add_document(
#'     id = "CSR",
#'     title = "Clinical Study Report",
#'     doctype = "SUPPDOC",
#'     href = "./docs/csr.pdf"
#'   )
#'
#' list_documents(docs)
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

#' @rdname documents
#' @export
list_documents <- S7::new_generic(
  name = "list_documents",
  dispatch_args = "x",
  fun = function(x) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(list_documents, mighty_documents) <- function(x) {
  list_ids(x)
}

#' @noRd
S7::method(list_documents, mighty_study) <- function(x) {
  list_documents(x@documents)
}

#' @rdname documents
#' @export
select_document <- S7::new_generic(
  name = "select_document",
  dispatch_args = "x",
  fun = function(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(select_document, mighty_documents) <- function(x, id) {
  get_id(x, id)
}

#' @noRd
S7::method(select_document, mighty_study) <- function(x, id) {
  select_document(x@documents, id)
}

#' @rdname documents
#' @export
remove_documents <- S7::new_generic(
  name = "remove_documents",
  dispatch_args = "x",
  fun = function(x, id) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(remove_documents, mighty_documents) <- function(x, id) {
  S7::S7_data(x) <- remove_ids(S7::S7_data(x), id)
  validate(x)
}

#' @noRd
S7::method(remove_documents, mighty_study) <- function(x, id) {
  x@documents <- remove_documents(x@documents, id)
  validate(x)
}

#' @rdname documents
#' @export
add_document <- S7::new_generic(
  name = "add_document",
  dispatch_args = "x",
  fun = function(
    x,
    id,
    title,
    doctype,
    href,
    .pos = length(list_documents(x)) + 1L
  ) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(add_document, mighty_documents) <- function(
    x,
    id,
    title,
    doctype,
    href,
    .pos = length(list_documents(x)) + 1L
) {
  doc <- list(id = id, title = title, doctype = doctype, href = href)
  S7::S7_data(x) <- insert_in_vector(S7::S7_data(x), doc, pos = .pos)
  validate(x)
}

#' @noRd
S7::method(add_document, mighty_study) <- function(
    x,
    id,
    title,
    doctype,
    href,
    .pos = length(list_documents(x)) + 1L
) {
  x@documents <- add_document(
    x@documents,
    id = id,
    title = title,
    doctype = doctype,
    href = href,
    .pos = .pos
  )
  validate(x)
}

#' @rdname documents
#' @export
update_document <- S7::new_generic(
  name = "update_document",
  dispatch_args = "x",
  fun = function(x, id, ...) {
    S7::S7_dispatch()
  }
)

#' @noRd
S7::method(update_document, mighty_documents) <- function(x, id, ...) {
  S7::S7_data(x) <- update_ids(S7::S7_data(x), id, ...)
  validate(x)
}

#' @noRd
S7::method(update_document, mighty_study) <- function(x, id, ...) {
  x@documents <- update_document(x@documents, id, ...)
  validate(x)
}
