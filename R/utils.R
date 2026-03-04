#' Null coalescing operator
#' @name null-coalesce
#' @rdname null-coalesce
#' @keywords internal
`%||%` <- function(x, y) if (is.null(x)) y else x

# Global variables to avoid R CMD check notes for non-standard evaluation
# These are column names used in dplyr functions with unquoted variable names
utils::globalVariables(c(
  # Table metadata columns
  "keys", "label", "subclass", "table",

  # Column metadata columns
  "column", "source", "origin", "origindescription", "type", "displayformat",
  "whereclause", "length",

  # Processed/derived columns
  "is_complex_predecessor", "is_predecessor",

  # Source data columns (uppercase naming convention)
  "SOURCE", "SOURCE_1", "SOURCE_2", "COLUMN", "TABLE", "LABEL", "TYPE",
  "LENGTH", "DISPLAYFORMAT", "SLABEL", "STYPE", "SLENGTH", "SDISPLAYFORMAT",
  "ORIGIN", "STABLE", "SCOLUMN", "COREFL", "ORDER",

  # dplyr generated columns
  "n", "tabcol",

  # Internal function names for cross-file usage
  "clean_list", "is_simple_predecessor", "process_values", "process_table"
))
