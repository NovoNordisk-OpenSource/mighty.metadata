#' @title Options for mighty.metadata
#' @name mighty.metadata-options
#' @description
#' `r zephyr::list_options(as = "markdown", .envir = "mighty.metadata")`
NULL

#' @title Internal parameters for reuse in functions
#' @name mighty.metadata-options-params
#' @eval zephyr::list_options(as = "params", .envir = "mighty.metadata")
#' @details
#' See [mighty.metadata-options] for more information.
#' @keywords internal
NULL

zephyr::create_option(
  name = "verbosity_level",
  default = NA_character_,
  desc = "Verbosity level for functions in mighty.metadata. See [zephyr::verbosity_level] for details." # nolint: line_length_linter
)
