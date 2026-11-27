#' Pattern for a domain or column name in a predecessor reference
#' @noRd
predecessor_name <- "[A-Z][A-Z0-9]*"

#' Pattern for a filter value in a predecessor reference
#' @noRd
predecessor_value <- "[A-Za-z0-9_]+"

#' Regular expressions for predecessor references
#' @noRd
predecessor_regex <- list(
  shorthand = sprintf(
    fmt = "^(?<domain>%1$s)\\.(?:(?<value>%2$s)\\.)?(?<column>%1$s)$",
    predecessor_name,
    predecessor_value
  ),
  reference = sprintf(
    fmt = "^(?<domain>%1$s)\\.(?<column>%1$s) (?i:where) ",
    predecessor_name
  ),
  filter = sprintf(
    fmt = "(?<key>[A-Za-z0-9]+)=\"(?<value>%s)\"$",
    predecessor_value
  ),
  dotted = "^[A-Za-z0-9_.]*\\.[A-Za-z0-9_.]*$"
)

#' Parse a predecessor reference
#'
#' Maps a `method` to `list(domain, column, filter)`. Shorthand and expanded
#' forms give the same result:
#'
# nolint start: line_length_linter.
#' | Form     | Shorthand              | Expanded                             | Filter key       |
#' |----------|------------------------|--------------------------------------|------------------|
#' | Plain    | `ADSL.AGE`             | `ADSL.AGE`                           | none             |
#' | SUPP--   | `SUPPDM.EFFICACY.QVAL` | `SUPPDM.QVAL where QNAM="EFFICACY"`  | `QNAM`           |
#' | BDS      | `ADVS.BMIGRP.AVALC`    | `ADVS.AVALC where PARAMCD="BMIGRP"`  | `PARAMCD`        |
#' | Findings | `VS.SYSBP.VSSTRESN`    | `VS.VSSTRESN where VSTESTCD="SYSBP"` | `<DOMAIN>TESTCD` |
# nolint end
#'
#' The filter key depends on the domain: `SUPP--` domains use `QNAM`, domains
#' in `study_domains` use `PARAMCD`, and any other domain uses
#' `<DOMAIN>TESTCD`. The expanded form must use that key, otherwise it errors.
#'
#' Domain and column must be uppercase names starting with a letter. Filter
#' values may contain letters, digits and `_`. `where` is case-insensitive.
#'
#' Other input:
#' - Free text (e.g. `Derived from AE.AESTDTC`), `NA` or `NULL` returns `NULL`.
#' - Dotted tokens that don't match a form (e.g. `A.B.C.D`, `ADSL.age`) or
#'   `DOMAIN.COLUMN where ...` not ending in `KEY="VALUE"` error.
#'
#' `format_predecessor()` turns the result back into the expanded form.
#'
#' @param method `character(1)` method to parse.
#' @param study_domains `character()` domain ids in the study.
#' @returns `list(domain, column, filter)` with `filter` either `NULL` or a
#'   named list with one element, e.g. `list(QNAM = "EFFICACY")`. `NULL` if
#'   `method` is not a reference.
#' @noRd
parse_predecessor <- function(method, study_domains) {
  if (!rlang::is_string(method)) {
    return(NULL)
  }

  shorthand <- match_groups(
    pattern = predecessor_regex[["shorthand"]],
    text = method
  )

  if (length(shorthand)) {
    return(new_predecessor(
      domain = shorthand[["domain"]],
      column = shorthand[["column"]],
      value = shorthand[["value"]],
      study_domains = study_domains
    ))
  }

  expanded <- match_groups(
    pattern = paste0(
      predecessor_regex[["reference"]],
      predecessor_regex[["filter"]]
    ),
    text = method
  )

  if (length(expanded)) {
    key <- predecessor_filter_key(
      domain = expanded[["domain"]],
      study_domains = study_domains
    )
    actual <- expanded[["key"]]
    if (actual != key) {
      cli::cli_abort(message = c(
        "Wrong filter key in predecessor {.val {method}}.",
        "i" = "Expected {.field {key}}, got {.field {actual}}."
      ))
    }
    return(new_predecessor(
      domain = expanded[["domain"]],
      column = expanded[["column"]],
      value = expanded[["value"]],
      study_domains = study_domains
    ))
  }

  is_malformed <- grepl(pattern = predecessor_regex[["dotted"]], x = method) ||
    grepl(
      pattern = predecessor_regex[["reference"]],
      x = method,
      ignore.case = TRUE,
      perl = TRUE
    )

  if (is_malformed) {
    cli::cli_abort(message = c(
      "Malformed predecessor {.val {method}}.",
      "i" = paste(
        "Use {.code DOMAIN.COLUMN}, {.code DOMAIN.VALUE.COLUMN} or",
        "{.code DOMAIN.COLUMN where KEY=\"VALUE\"}."
      )
    ))
  }

  NULL
}

#' Extract named capture groups of the first match
#' @noRd
match_groups <- function(pattern, text) {
  regmatches(
    x = text,
    m = regexec(pattern = pattern, text = text, perl = TRUE)
  ) |>
    unlist()
}

#' Build a parsed predecessor reference
#' @noRd
new_predecessor <- function(domain, column, value, study_domains) {
  filter <- NULL
  if (nzchar(value)) {
    key <- predecessor_filter_key(
      domain = domain,
      study_domains = study_domains
    )
    filter <- stats::setNames(object = list(value), nm = key)
  }
  list(domain = domain, column = column, filter = filter)
}

#' Format a parsed predecessor reference in the expanded form
#' @noRd
format_predecessor <- function(x) {
  reference <- paste(x[["domain"]], x[["column"]], sep = ".")

  if (is.null(x[["filter"]])) {
    return(reference)
  }

  sprintf(
    fmt = "%s where %s=\"%s\"",
    reference,
    names(x[["filter"]]),
    unlist(x[["filter"]], use.names = FALSE)
  )
}

#' Filter key for a predecessor domain
#' @noRd
predecessor_filter_key <- function(domain, study_domains) {
  if (has_prefix(x = domain, prefix = "SUPP")) {
    return("QNAM")
  }

  if (domain %in% study_domains) {
    return("PARAMCD")
  }

  paste0(domain, "TESTCD")
}
