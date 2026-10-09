#' Mighty Codelists
#'
#' @description
#' `mighty_codelists()` creates an S7 object for storing codelist metadata.
#' The class represents the contents of `_codelists.yml` as a list of codelist
#' entries. Each codelist is referenced from column metadata via its `id`
#' (the `codelist` field of a column).
#'
#' A codelist can contain the following operation groups:
#' - `values`: values of a sponsor-defined (non-standard) codelist,
#' - `subset`: values kept from a standard controlled terminology codelist,
#' - `restore`: SDTM controlled terminology values included in the ADaM
#'   codelist even when they are not used in the SDTM define.xml,
#' - `extend`: values added to an extensible codelist.
#'
#' `values` is meant for codelists that are not part of standard controlled
#' terminology, while `subset`, `restore` and `extend` modify a standard
#' codelist retrieved from an external source.
#'
#' The object is validated on creation and when `validate()` is called.
#' Validation includes:
#' - schema compliance with `inst/schema/codelists.json`,
#' - uniqueness of codelist identifiers (`id`),
#' - uniqueness of `code` within a codelist across all operation groups,
#' - `values` being mutually exclusive with `subset` and `restore`,
#' - consistent use of `decode` within an operation group (all or none).
#'
#' When part of a [mighty_study()], every codelist must also be referenced
#' by at least one column in the domain metadata.
#'
#' @param file `character(1)` path to `_codelists.yml`. Optional; mutually
#'   exclusive with `.data`.
#' @param .data `list()` of codelist entries. Optional; mutually exclusive
#'   with `file`. Supplying neither returns an empty `mighty_codelists`.
#'
#' @returns
#' - `mighty_codelists()`: an object of class `mighty_codelists`.
#' - `list_codelists()`: `character()` vector with codelist ids.
#' - `select_codelist()`: selected codelist entry as a list.
#' - All other functions: the modified object.
#'
#' @examples
#' cl <- mighty_codelists(
#'   .data = list(
#'     list(
#'       id = "REGION",
#'       label = "Region",
#'       description = "Geographical regions",
#'       datatype = "text",
#'       values = list(list(code = "EUROPE", decode = "Europe"))
#'     ),
#'     list(
#'       id = "AGEU",
#'       subset = list(list(code = "YEARS")),
#'       restore = list(list(code = "MONTHS"))
#'     )
#'   )
#' )
#'
#' print(cl)
#'
#' @name codelists
NULL

#' Operation groups of a codelist, in the order they are written.
#' @noRd
CODELIST_GROUPS <- c("values", "subset", "restore", "extend")

#' Operation groups whose entries may carry a `decode`.
#' @noRd
CODELIST_DECODE_GROUPS <- c("values", "extend")

#' @noRd
construct_mighty_codelists <- function(file, .data) {
  rlang::check_exclusive(file, .data, .require = FALSE)
  codelists_schema <- system.file(
    "schema",
    "codelists.json",
    package = "mighty.metadata"
  )
  parent <- if (!rlang::is_missing(file)) {
    S7schema::S7schema(file = file, schema = codelists_schema)
  } else {
    # Without input, an empty codelists object is created
    S7schema::S7schema(
      .data = if (rlang::is_missing(.data)) list() else .data,
      schema = codelists_schema
    )
  }
  S7::new_object(.parent = parent)
}

#' @noRd
validate_mighty_codelists <- function(self) {
  x <- S7::S7_data(self)
  check_unique_codelist_ids(x)
  for (cl in x) {
    check_codelist_groups(cl)
    check_unique_codes(cl)
    check_consistent_decodes(cl)
  }
  NULL
}

#' @noRd
check_unique_codelist_ids <- function(x) {
  ids <- list_ids(x)
  duplicates <- unique(ids[duplicated(ids)])
  if (length(duplicates)) {
    cli::cli_abort(
      "Duplicate codelist {.field id} entries found: {.val {duplicates}}"
    )
  }
  invisible(x)
}

#' @noRd
check_codelist_groups <- function(cl) {
  has_values <- length(cl[["values"]]) > 0
  has_gcmd_overrides <- length(cl[["subset"]]) > 0 ||
    length(cl[["restore"]]) > 0
  if (has_values && has_gcmd_overrides) {
    cli::cli_abort(c(
      paste(
        "Codelist {.val {cl$id}} cannot combine {.field values}",
        "with {.field subset} or {.field restore}."
      ),
      i = paste(
        "{.field values} defines a non-standard codelist, while {.field subset}",
        "and {.field restore} modify a standard controlled terminology codelist."
      )
    ))
  }
  invisible(cl)
}

#' @noRd
check_unique_codes <- function(cl) {
  codes <- list_codelist_codes(cl)
  duplicates <- unique(codes[duplicated(codes)])
  if (length(duplicates)) {
    cli::cli_abort(
      "Duplicate {.field code} values in codelist {.val {cl$id}}: {.val {duplicates}}"
    )
  }
  invisible(cl)
}

#' @noRd
check_consistent_decodes <- function(cl) {
  for (group in intersect(CODELIST_DECODE_GROUPS, names(cl))) {
    has_decode <- vapply(
      cl[[group]],
      \(v) !is.null(v[["decode"]]),
      logical(1)
    )
    if (length(unique(has_decode)) > 1L) {
      cli::cli_abort(
        "Either all or none of the {.field {group}} entries in codelist {.val {cl$id}} must have a {.field decode}."
      )
    }
  }
  invisible(cl)
}

#' Codes of a single operation group, as character.
#' @noRd
group_codes <- function(group) {
  vapply(group, \(v) as.character(v[["code"]]), character(1))
}

#' All codes of a codelist across operation groups, as character.
#' @noRd
list_codelist_codes <- function(cl) {
  unlist(
    lapply(cl[intersect(CODELIST_GROUPS, names(cl))], group_codes),
    use.names = FALSE
  ) |>
    as.character()
}

#' @rdname codelists
#' @export
mighty_codelists <- S7::new_class(
  name = "mighty_codelists",
  parent = S7schema::S7schema,
  constructor = construct_mighty_codelists,
  validator = function(self) {
    validate_mighty_codelists(self)
  }
)

#' @noRd
S7::method(print, mighty_codelists) <- function(x, ...) {
  print_mighty_codelists(x)
}

#' @noRd
print_mighty_codelists <- function(x, ...) {
  ids <- list_ids(S7::S7_data(x))

  cli::cli_bullets(
    text = c(
      "{.cls {class(x)[[1]]}}",
      "Codelists: {length(ids)} entr{?y/ies}",
      "IDs: {.code {ids}}"
    )
  )

  invisible(x)
}
