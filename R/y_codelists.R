#' @details
#' Functions to list, select, define, remove, and update codelists and their
#' values in your `mighty_codelists()` object or directly on a
#' `mighty_study()` object.
#'
#' Codelist level:
#' - `define_codelist()` adds a new sponsor-defined codelist with `values`.
#' - `remove_codelist()` removes codelist(s) and all their contents.
#' - `update_codelist()` updates `label`, `description` and `datatype`.
#' - `select_codelist()` returns a single codelist entry as a list.
#'
#' Value level:
#' - `define_codelist_values()` adds `values` to an existing codelist.
#' - `extend_codelist_values()`, `restore_codelist_values()` and
#'   `subset_codelist_values()` add `extend`, `restore` and `subset` entries,
#'   creating the codelist if it does not exist.
#' - `remove_codelist_value()` removes value(s) from whichever operation group
#'   they belong to. Empty groups are dropped, and a codelist left without any
#'   values is removed.
#' - `move_codelist_value()` moves a value within its operation group.
#' - `update_codelist_value()` updates the decode of a `values` or `extend`
#'   entry.
#'
#' When working on a `mighty_study()`, every codelist must be referenced by a
#' column (`codelist` field), so add the column reference before defining the
#' codelist.
#'
#' @param x A `mighty_codelists()` or `mighty_study()` object.
#' @param id `character(1)` codelist id. `remove_codelist()` accepts
#'   `character()` to remove several codelists.
#' @param codelist_id `character(1)` codelist id.
#' @param label `character(1)` codelist label.
#' @param description `character(1)` codelist description.
#' @param datatype `character(1)` one of `"text"`, `"integer"`, `"float"`.
#' @param code `character()` or `numeric()` coded value(s).
#' @param decode `character()` decode(s), same length as `code`. Optional
#'   (`NULL`) except in `update_codelist_value()`.
#' @param .pos `integer(1)` new position of the value within its group.
#' @param ... Codelist-level fields to update (`label`, `description`,
#'   `datatype`).
#' @examples
#' cl <- mighty_codelists() |>
#'   define_codelist(
#'     id = "REGION",
#'     label = "Region",
#'     description = "Geographical regions used in the study",
#'     datatype = "text",
#'     code = c("EUROPE", "NORTH AMERICA"),
#'     decode = c("Europe", "North America")
#'   ) |>
#'   subset_codelist_values(codelist_id = "AGEU", code = c("MONTHS", "YEARS")) |>
#'   restore_codelist_values(codelist_id = "AGEU", code = "DAYS") |>
#'   extend_codelist_values(
#'     codelist_id = "LOC",
#'     code = "MY CUSTOM LOCATION",
#'     decode = "My Custom Location"
#'   )
#'
#' list_codelists(cl)
#' select_codelist(cl, id = "AGEU")
#'
#' cl <- cl |>
#'   update_codelist(id = "REGION", description = "Regions used in the trial") |>
#'   update_codelist_value(codelist_id = "REGION", code = "EUROPE", decode = "EU") |>
#'   move_codelist_value(codelist_id = "AGEU", code = "YEARS", .pos = 1) |>
#'   remove_codelist_value(codelist_id = "AGEU", code = "MONTHS") |>
#'   remove_codelist(id = "LOC")
#'
#' @name codelists
NULL

# Generics ------------------------------------------------------------------

#' @rdname codelists
#' @export
list_codelists <- S7::new_generic(
  name = "list_codelists",
  dispatch_args = "x",
  fun = function(x) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
select_codelist <- S7::new_generic(
  name = "select_codelist",
  dispatch_args = "x",
  fun = function(x, id) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
define_codelist <- S7::new_generic(
  name = "define_codelist",
  dispatch_args = "x",
  fun = function(x, id, label, description, datatype, code, decode = NULL) {
    S7::S7_dispatch()
  }
)

#' @rdname codelists
#' @export
remove_codelist <- S7::new_generic(
  name = "remove_codelist",
  dispatch_args = "x",
  fun = function(x, id) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
update_codelist <- S7::new_generic(
  name = "update_codelist",
  dispatch_args = "x",
  fun = function(x, id, ...) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
define_codelist_values <- S7::new_generic(
  name = "define_codelist_values",
  dispatch_args = "x",
  fun = function(x, codelist_id, code, decode = NULL) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
extend_codelist_values <- S7::new_generic(
  name = "extend_codelist_values",
  dispatch_args = "x",
  fun = function(x, codelist_id, code, decode = NULL) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
restore_codelist_values <- S7::new_generic(
  name = "restore_codelist_values",
  dispatch_args = "x",
  fun = function(x, codelist_id, code) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
subset_codelist_values <- S7::new_generic(
  name = "subset_codelist_values",
  dispatch_args = "x",
  fun = function(x, codelist_id, code) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
remove_codelist_value <- S7::new_generic(
  name = "remove_codelist_value",
  dispatch_args = "x",
  fun = function(x, codelist_id, code) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
move_codelist_value <- S7::new_generic(
  name = "move_codelist_value",
  dispatch_args = "x",
  fun = function(x, codelist_id, code, .pos) S7::S7_dispatch()
)

#' @rdname codelists
#' @export
update_codelist_value <- S7::new_generic(
  name = "update_codelist_value",
  dispatch_args = "x",
  fun = function(x, codelist_id, code, decode) S7::S7_dispatch()
)

# mighty_codelists methods --------------------------------------------------

S7::method(list_codelists, mighty_codelists) <- function(x) {
  list_ids(S7::S7_data(x))
}

S7::method(select_codelist, mighty_codelists) <- function(x, id) {
  get_id(S7::S7_data(x), id)
}

S7::method(define_codelist, mighty_codelists) <- function(
  x,
  id,
  label,
  description,
  datatype,
  code,
  decode = NULL
) {
  S7::S7_data(x) <- cl_define(
    S7::S7_data(x),
    id = id,
    label = label,
    description = description,
    datatype = datatype,
    code = code,
    decode = decode
  )
  S7::validate(x)
  x
}

S7::method(remove_codelist, mighty_codelists) <- function(x, id) {
  abort_unknown_codelist(S7::S7_data(x), id)
  S7::S7_data(x) <- as_list_or_empty(remove_ids(S7::S7_data(x), id))
  S7::validate(x)
  x
}

S7::method(update_codelist, mighty_codelists) <- function(x, id, ...) {
  S7::S7_data(x) <- cl_update(S7::S7_data(x), id, ...)
  S7::validate(x)
  x
}

S7::method(define_codelist_values, mighty_codelists) <- function(
  x,
  codelist_id,
  code,
  decode = NULL
) {
  abort_unknown_codelist(S7::S7_data(x), codelist_id)
  S7::S7_data(x) <- cl_add_values(
    S7::S7_data(x),
    codelist_id,
    "values",
    code,
    decode
  )
  S7::validate(x)
  x
}

S7::method(extend_codelist_values, mighty_codelists) <- function(
  x,
  codelist_id,
  code,
  decode = NULL
) {
  S7::S7_data(x) <- cl_add_values(
    S7::S7_data(x),
    codelist_id,
    "extend",
    code,
    decode
  )
  S7::validate(x)
  x
}

S7::method(restore_codelist_values, mighty_codelists) <- function(
  x,
  codelist_id,
  code
) {
  S7::S7_data(x) <- cl_add_values(S7::S7_data(x), codelist_id, "restore", code)
  S7::validate(x)
  x
}

S7::method(subset_codelist_values, mighty_codelists) <- function(
  x,
  codelist_id,
  code
) {
  S7::S7_data(x) <- cl_add_values(S7::S7_data(x), codelist_id, "subset", code)
  S7::validate(x)
  x
}

S7::method(remove_codelist_value, mighty_codelists) <- function(
  x,
  codelist_id,
  code
) {
  S7::S7_data(x) <- as_list_or_empty(
    cl_remove_values(S7::S7_data(x), codelist_id, code)
  )
  S7::validate(x)
  x
}

S7::method(move_codelist_value, mighty_codelists) <- function(
  x,
  codelist_id,
  code,
  .pos
) {
  S7::S7_data(x) <- cl_move_value(S7::S7_data(x), codelist_id, code, .pos)
  S7::validate(x)
  x
}

S7::method(update_codelist_value, mighty_codelists) <- function(
  x,
  codelist_id,
  code,
  decode
) {
  S7::S7_data(x) <- cl_update_value(S7::S7_data(x), codelist_id, code, decode)
  S7::validate(x)
  x
}
# mighty_study methods ------------------------------------------------------

#' Codelists of a study, or an empty object when not defined
#' @noRd
study_codelists <- function(x) {
  if (is.null(x@codelists)) mighty_codelists() else x@codelists
}

#' Apply a codelists method to a study and validate the study
#' @noRd
modify_study_codelists <- function(x, generic, ...) {
  cl <- generic(study_codelists(x), ...)
  x@codelists <- if (length(cl)) cl else NULL
  validate(x)
}

S7::method(list_codelists, mighty_study) <- function(x) {
  list_codelists(study_codelists(x))
}

S7::method(select_codelist, mighty_study) <- function(x, id) {
  select_codelist(study_codelists(x), id)
}

S7::method(define_codelist, mighty_study) <- function(
  x,
  id,
  label,
  description,
  datatype,
  code,
  decode = NULL
) {
  modify_study_codelists(
    x,
    define_codelist,
    id = id,
    label = label,
    description = description,
    datatype = datatype,
    code = code,
    decode = decode
  )
}

S7::method(remove_codelist, mighty_study) <- function(x, id) {
  modify_study_codelists(x, remove_codelist, id = id)
}

S7::method(update_codelist, mighty_study) <- function(x, id, ...) {
  modify_study_codelists(x, update_codelist, id = id, ...)
}

S7::method(define_codelist_values, mighty_study) <- function(
  x,
  codelist_id,
  code,
  decode = NULL
) {
  modify_study_codelists(
    x,
    define_codelist_values,
    codelist_id = codelist_id,
    code = code,
    decode = decode
  )
}

S7::method(extend_codelist_values, mighty_study) <- function(
  x,
  codelist_id,
  code,
  decode = NULL
) {
  modify_study_codelists(
    x,
    extend_codelist_values,
    codelist_id = codelist_id,
    code = code,
    decode = decode
  )
}

S7::method(restore_codelist_values, mighty_study) <- function(
  x,
  codelist_id,
  code
) {
  modify_study_codelists(
    x,
    restore_codelist_values,
    codelist_id = codelist_id,
    code = code
  )
}

S7::method(subset_codelist_values, mighty_study) <- function(
  x,
  codelist_id,
  code
) {
  modify_study_codelists(
    x,
    subset_codelist_values,
    codelist_id = codelist_id,
    code = code
  )
}

S7::method(remove_codelist_value, mighty_study) <- function(
  x,
  codelist_id,
  code
) {
  modify_study_codelists(
    x,
    remove_codelist_value,
    codelist_id = codelist_id,
    code = code
  )
}

S7::method(move_codelist_value, mighty_study) <- function(
  x,
  codelist_id,
  code,
  .pos
) {
  modify_study_codelists(
    x,
    move_codelist_value,
    codelist_id = codelist_id,
    code = code,
    .pos = .pos
  )
}

S7::method(update_codelist_value, mighty_study) <- function(
  x,
  codelist_id,
  code,
  decode
) {
  modify_study_codelists(
    x,
    update_codelist_value,
    codelist_id = codelist_id,
    code = code,
    decode = decode
  )
}

# Internal list helpers -----------------------------------------------------

#' @noRd
abort_unknown_codelist <- function(l, id) {
  missing <- setdiff(id, list_ids(l))
  if (length(missing)) {
    cli::cli_abort("Codelist {.val {missing}} does not exist.")
  }
  invisible(l)
}

#' Build value entries from code and decode vectors
#' @noRd
cl_build_values <- function(code, decode = NULL) {
  if (!length(code)) {
    cli::cli_abort("At least one {.arg code} must be supplied.")
  }
  if (!is.null(decode) && length(decode) != length(code)) {
    cli::cli_abort(
      "{.arg decode} must have the same length as {.arg code} ({length(code)}), not {length(decode)}."
    )
  }
  lapply(seq_along(code), \(i) {
    v <- list(code = code[[i]])
    if (!is.null(decode)) {
      v$decode <- decode[[i]]
    }
    v
  })
}

#' @noRd
cl_define <- function(
  l,
  id,
  label,
  description,
  datatype,
  code,
  decode = NULL
) {
  if (id %in% list_ids(l)) {
    cli::cli_abort("Codelist {.val {id}} already exists.")
  }
  cl <- list(
    id = id,
    label = label,
    description = description,
    datatype = datatype,
    values = cl_build_values(code, decode)
  )
  insert_in_vector(l, cl)
}

#' @noRd
cl_update <- function(l, id, ...) {
  abort_unknown_codelist(l, id)
  updates <- rlang::list2(...)
  invalid <- setdiff(names(updates), c("label", "description", "datatype"))
  if (length(invalid)) {
    cli::cli_abort(c(
      "Only {.field label}, {.field description} and {.field datatype} can be updated.",
      x = "Invalid field{?s}: {.field {invalid}}"
    ))
  }
  update_ids(l, id, ...)
}

#' Append values to an operation group, creating the codelist if needed
#' @noRd
cl_add_values <- function(l, codelist_id, group, code, decode = NULL) {
  new_values <- cl_build_values(code, decode)
  idx <- which_ids(l, codelist_id)
  if (!length(idx)) {
    cl <- list(id = codelist_id)
    cl[[group]] <- new_values
    return(insert_in_vector(l, cl))
  }
  l[[idx]][[group]] <- c(l[[idx]][[group]], new_values)
  l[[idx]] <- cl_order_groups(l[[idx]])
  l
}

#' Keep codelist-level fields first and operation groups in canonical order
#' @noRd
cl_order_groups <- function(cl) {
  fields <- setdiff(names(cl), CODELIST_GROUPS)
  cl[c(fields, intersect(CODELIST_GROUPS, names(cl)))]
}

#' Locate the operation group holding a given code
#' @noRd
cl_find_value <- function(cl, code) {
  for (group in intersect(CODELIST_GROUPS, names(cl))) {
    pos <- match(as.character(code), group_codes(cl[[group]]))
    if (!is.na(pos)) {
      return(list(group = group, pos = pos))
    }
  }
  cli::cli_abort(
    "Code {.val {code}} does not exist in codelist {.val {cl$id}}."
  )
}

#' @noRd
cl_remove_values <- function(l, codelist_id, code) {
  abort_unknown_codelist(l, codelist_id)
  idx <- which_ids(l, codelist_id)
  cl <- l[[idx]]
  for (cd in code) {
    loc <- cl_find_value(cl, cd)
    cl[[loc$group]][[loc$pos]] <- NULL
    if (!length(cl[[loc$group]])) {
      cl[[loc$group]] <- NULL
    }
  }
  if (!any(CODELIST_GROUPS %in% names(cl))) {
    cli::cli_inform(
      "Codelist {.val {codelist_id}} has no values left and was removed."
    )
    return(remove_ids(l, codelist_id))
  }
  l[[idx]] <- cl
  l
}

#' @noRd
cl_move_value <- function(l, codelist_id, code, .pos) {
  abort_unknown_codelist(l, codelist_id)
  idx <- which_ids(l, codelist_id)
  loc <- cl_find_value(l[[idx]], code)
  group <- l[[idx]][[loc$group]]
  if (length(.pos) != 1L || .pos < 1L || .pos > length(group)) {
    cli::cli_abort(
      "{.arg .pos} must be a single integer between 1 and {length(group)}."
    )
  }
  item <- group[[loc$pos]]
  group[[loc$pos]] <- NULL
  l[[idx]][[loc$group]] <- insert_in_vector(group, item, pos = .pos)
  l
}

#' @noRd
cl_update_value <- function(l, codelist_id, code, decode) {
  abort_unknown_codelist(l, codelist_id)
  if (length(decode) != length(code)) {
    cli::cli_abort(
      "{.arg decode} must have the same length as {.arg code}."
    )
  }
  idx <- which_ids(l, codelist_id)
  for (i in seq_along(code)) {
    loc <- cl_find_value(l[[idx]], code[[i]])
    if (!loc$group %in% c("values", "extend")) {
      cli::cli_abort(
        "Decode can only be updated for {.field values} or {.field extend} entries; {.val {code[[i]]}} is in {.field {loc$group}}."
      )
    }
    l[[idx]][[loc$group]][[loc$pos]]$decode <- decode[[i]]
  }
  l
}
# Study-level reference checks ----------------------------------------------

#' Collect codelist ids referenced by columns of all domains
#' @noRd
collect_codelist_refs <- function(study) {
  refs <- lapply(study, function(domain) {
    cols <- as_list_or_empty(domain[["columns"]])
    param_cols <- unlist(
      lapply(
        as_list_or_empty(domain[["parameters"]]),
        \(p) as_list_or_empty(p[["columns"]])
      ),
      recursive = FALSE
    )
    vapply(
      c(cols, as_list_or_empty(param_cols)),
      \(col) {
        if (is.null(col[["codelist"]])) NA_character_ else col[["codelist"]]
      },
      character(1)
    )
  })
  refs <- unlist(refs, use.names = FALSE)
  unique(refs[!is.na(refs)])
}

#' Every codelist in `_codelists.yml` must be referenced by a column
#' @noRd
check_codelist_references <- function(study) {
  if (is.null(study@codelists)) {
    return(invisible(study))
  }
  unused <- setdiff(
    list_codelists(study@codelists),
    collect_codelist_refs(study)
  )
  if (length(unused)) {
    cli::cli_abort(c(
      "Codelist{?s} {.val {unused}} {?is/are} not referenced by any column.",
      i = "Reference the codelist in a column {.field codelist} field or remove it from {.path _codelists.yml}."
    ))
  }
  invisible(study)
}
