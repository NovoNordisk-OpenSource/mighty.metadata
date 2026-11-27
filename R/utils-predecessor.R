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
#' Accepts `DOMAIN.COLUMN`, `DOMAIN.VALUE.COLUMN` and
#' `DOMAIN.COLUMN where KEY="VALUE"`. The filter key is derived from the
#' domain, see `predecessor_filter_key()`. Domain and column must be
#' uppercase names starting with a letter.
#' @param method `character(1)` method to parse.
#' @param study_domains `character()` domain ids in the study.
#' @returns `list(domain, column, filter)` with `filter` either `NULL` or a
#'   named list with one element. `NULL` if `method` is not a reference.
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
#' @param x `list(domain, column, filter)` from `parse_predecessor()`.
#' @returns `character(1)`.
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
#' @param domain `character(1)` domain id.
#' @param study_domains `character()` domain ids in the study.
#' @returns `character(1)`: `QNAM` for `SUPP--` domains, `PARAMCD` for
#'   domains in the study, otherwise `<DOMAIN>TESTCD`.
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
