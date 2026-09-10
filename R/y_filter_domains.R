#' Filter domains in a study
#'
#' @description
#' Returns a `mighty_study` object containing only domains whose names start
#' with the given prefix(es).
#'
#' @param x `mighty_study()` Object to filter.
#' @param prefix `character()` one or more prefixes to keep (case-insensitive).
#'   Defaults to `"AD"` to keep only ADaM domains.
#'
#' @returns `invisible(x)`
#'
#' @examples
#' study <- mighty_study(
#'   path = system.file("examples", package = "mighty.metadata")
#' )
#'
#' # Keep only ADaM domains (default)
#' study |>
#'   filter_domains()
#'
#' @name filter_domains
NULL

#' @rdname filter_domains
#' @export
filter_domains <- S7::new_generic(
  name = "filter_domains",
  dispatch_args = "x",
  fun = function(x, prefix = "AD") S7::S7_dispatch()
)

#' @noRd
S7::method(filter_domains, mighty_study) <- function(x, prefix = "AD") {
  domains_to_remove <- purrr::discard(
    names(x),
    \(domain_name) has_prefix(domain_name, prefix)
  )

  x[domains_to_remove] <- NULL

  x
}
