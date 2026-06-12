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
#'     doctype = "suppdoc",
#'     href = "./docs/csr.pdf"
#'   )
#'
#' list_documents(docs)
#'
#' @name documents
NULL


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


#' @noRd
as_list_or_empty <- function(x) {
  if (length(x)) {
    x
  } else {
    list()
  }
}

#' @noRd
build_document_refs <- function(
  documents,
  level,
  comment = NULL,
  origin = NULL
) {
  if (!length(documents)) {
    return(list())
  }

  lapply(documents, function(doc) {
    list(
      id = doc[["id"]],
      level = level,
      comment = comment,
      origin = origin
    )
  })
}

#' @noRd
collect_domain_document_refs <- function(domain) {
  build_document_refs(
    documents = domain[["documents"]],
    level = paste0("domain ", domain$id),
    comment = domain[["comment"]]
  )
}

#' @noRd
collect_column_document_refs <- function(columns, domain_id) {
  columns <- as_list_or_empty(columns)

  unlist(
    lapply(columns, function(col) {
      build_document_refs(
        documents = col[["documents"]],
        level = paste0("domain ", domain_id, " column ", col$id),
        comment = col[["comment"]],
        origin = col[["origin"]]
      )
    }),
    recursive = FALSE
  )
}

#' @noRd
collect_parameter_document_refs <- function(parameters, domain_id) {
  parameters <- as_list_or_empty(parameters)

  unlist(
    lapply(parameters, function(param) {
      param_cols <- as_list_or_empty(param[["columns"]])

      unlist(
        lapply(param_cols, function(col) {
          build_document_refs(
            documents = col[["documents"]],
            level = paste0(
              "domain ",
              domain_id,
              " parameter ",
              param$id,
              " column ",
              col$id
            ),
            comment = col[["comment"]],
            origin = col[["origin"]]
          )
        }),
        recursive = FALSE
      )
    }),
    recursive = FALSE
  )
}

#' @noRd
collect_document_refs <- function(domain) {
  domain_id <- domain$id

  domain_refs <- collect_domain_document_refs(domain)
  column_refs <- collect_column_document_refs(domain[["columns"]], domain_id)
  parameter_refs <- collect_parameter_document_refs(
    domain[["parameters"]],
    domain_id
  )

  unlist(list(domain_refs, column_refs, parameter_refs), recursive = FALSE)
}

#' @noRd
is_missing_comment <- function(x) {
  is.null(x) || !nzchar(trimws(x))
}



#' @noRd
build_doc_types <- function(documents) {
  doc_ids <- list_ids(documents)
  doc_types <- vapply(documents, function(x) x[["doctype"]], character(1))
  names(doc_types) <- doc_ids
  doc_types
}

#' @noRd
abort_on_unknown_document_refs <- function(refs, doc_ids) {
  ref_ids <- vapply(refs, function(x) x[["id"]], character(1))
  missing_ids <- setdiff(unique(ref_ids), doc_ids)

  if (!length(missing_ids)) {
    return(invisible(NULL))
  }

  missing_refs <- refs[vapply(
    refs,
    function(x) x[["id"]] %in% missing_ids,
    logical(1)
  )]

  bullets <- vapply(
    missing_refs,
    function(ref) {
      cli::format_inline(
        "Unknown document id {.val {ref$id}} referenced in {.field {ref$level}}."
      )
    },
    character(1)
  )
  names(bullets) <- rep("x", length(bullets))

  available <- if (length(doc_ids)) {
    cli::format_inline("Available document ids: {.val {doc_ids}}")
  } else {
    "No documents are currently defined in documents.yml."
  }

  cli::cli_abort(c(
    "Unknown document references detected.",
    bullets,
    "Add this id to {.path documents.yml} or update the reference id in metadata.",
    i = available
  ))
}

#' @noRd
find_invalid_method_refs <- function(refs, ref_types) {
  refs[
    vapply(
      seq_along(refs),
      function(i) {
        identical(ref_types[[i]], "method") &&
          !identical(refs[[i]][["origin"]], "Derived")
      },
      logical(1)
    )
  ]
}

#' @noRd
abort_on_invalid_method_refs <- function(invalid_method_refs) {
  if (!length(invalid_method_refs)) {
    return(invisible(NULL))
  }

  bullets <- vapply(
    invalid_method_refs,
    function(ref) {
      origin_value <- ref[["origin"]]
      if (is.null(origin_value) || !nzchar(trimws(origin_value))) {
        origin_value <- "<missing>"
      }

      cli::format_inline(
        "METHOD document {.val {ref$id}} referenced in {.field {ref$level}}
        has origin {.val {origin_value}}. METHOD is allowed only when {.field origin} is exactly {.val Derived}."
      )
    },
    character(1)
  )
  names(bullets) <- rep("x", length(bullets))

  cli::cli_abort(c("Invalid METHOD document references detected.", bullets))
}

#' @noRd
warn_on_missing_comment_refs <- function(refs, ref_types) {
  missing_comment_refs <- refs[
    vapply(
      seq_along(refs),
      function(i) {
        identical(ref_types[[i]], "comment") &&
          is_missing_comment(refs[[i]][["comment"]])
      },
      logical(1)
    )
  ]

  if (!length(missing_comment_refs)) {
    return(invisible(NULL))
  }

  bullets <- vapply(
    missing_comment_refs,
    function(ref) {
      cli::format_inline(
        "COMMENT document {.val {ref$id}} referenced in {.field {ref$level}} has
        empty or missing comment text. Add non-empty {.field comment} in this metadata location."
      )
    },
    character(1)
  )
  names(bullets) <- rep("!", length(bullets))

  cli::cli_warn(c(
    "Missing comment text for COMMENT document references.",
    bullets
  ))
}

#' @noRd
check_document_references <- function(study) {
  if (!length(study@documents) > 0) {
    return(study)
  }

  refs <- unlist(lapply(study, collect_document_refs), recursive = FALSE)

  if (!length(refs)) {
    return(study)
  }

  docs <- S7::S7_data(study@documents)
  doc_ids <- list_ids(docs)
  doc_types <- build_doc_types(docs)

  abort_on_unknown_document_refs(refs, doc_ids)

  ref_ids <- vapply(refs, function(x) x[["id"]], character(1))
  ref_types <- doc_types[ref_ids]

  invalid_method_refs <- find_invalid_method_refs(refs, ref_types)

  abort_on_invalid_method_refs(invalid_method_refs)

  warn_on_missing_comment_refs(refs, ref_types)

  study
}
