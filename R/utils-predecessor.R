#' Parse a predecessor reference
#'
#' Accepts `DOMAIN.COLUMN`, `DOMAIN.VALUE.COLUMN` and
#' `DOMAIN.COLUMN where KEY="VALUE"`. The filter key is derived from the
#' domain, see `predecessor_filter_key()`.
#' @param method `character(1)` method to parse.
#' @param study_domains `character()` domain ids in the study.
#' @returns `list(domain, column, filter)` with `filter` either `NULL` or a
#'   named list with one element. `NULL` if `method` is not a reference.
#' @noRd
parse_predecessor <- function(method, study_domains) {
  if (!rlang::is_string(method)) {
    return(NULL)
  }

  short <- regmatches(
    method,
    regexec(
      "^([A-Za-z0-9]+)\\.(?:([A-Za-z0-9_]+)\\.)?([A-Za-z0-9]+)$",
      method,
      perl = TRUE
    )
  )[[1]]

  if (length(short)) {
    filter <- NULL
    if (nzchar(short[[3]])) {
      key <- predecessor_filter_key(short[[2]], study_domains)
      filter <- stats::setNames(list(short[[3]]), key)
    }
    return(list(domain = short[[2]], column = short[[4]], filter = filter))
  }

  reference <- "^([A-Za-z0-9]+)\\.([A-Za-z0-9]+) (?i:where) "
  expanded <- regmatches(
    method,
    regexec(
      paste0(reference, "([A-Za-z0-9]+)=\"([A-Za-z0-9_]+)\"$"),
      method,
      perl = TRUE
    )
  )[[1]]

  if (length(expanded)) {
    key <- predecessor_filter_key(expanded[[2]], study_domains)
    if (expanded[[4]] != key) {
      cli::cli_abort(c(
        "Wrong filter key in predecessor {.val {method}}.",
        "i" = "Expected {.field {key}}, got {.field {expanded[[4]]}}."
      ))
    }
    return(list(
      domain = expanded[[2]],
      column = expanded[[3]],
      filter = stats::setNames(list(expanded[[5]]), key)
    ))
  }

  is_malformed <- grepl("^[A-Za-z0-9_.]*\\.[A-Za-z0-9_.]*$", method) ||
    grepl(reference, method, perl = TRUE)

  if (is_malformed) {
    cli::cli_abort(c(
      "Malformed predecessor {.val {method}}.",
      "i" = paste(
        "Use {.code DOMAIN.COLUMN}, {.code DOMAIN.VALUE.COLUMN} or",
        "{.code DOMAIN.COLUMN where KEY=\"VALUE\"}."
      )
    ))
  }

  NULL
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
    "%s where %s=\"%s\"",
    reference,
    names(x[["filter"]]),
    x[["filter"]][[1]]
  )
}

#' Filter key for a predecessor domain
#' @param domain `character(1)` domain id.
#' @param study_domains `character()` domain ids in the study.
#' @returns `character(1)`: `QNAM` for `SUPP--` domains, `PARAMCD` for
#'   domains in the study, otherwise `<DOMAIN>TESTCD`.
#' @noRd
predecessor_filter_key <- function(domain, study_domains) {
  if (has_prefix(domain, "SUPP")) {
    return("QNAM")
  }

  if (domain %in% study_domains) {
    return("PARAMCD")
  }

  paste0(domain, "TESTCD")
}
