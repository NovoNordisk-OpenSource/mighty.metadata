# Helper functions

#' Null coalescing operator
#' @keywords internal
`%||%` <- function(x, y) if (is.null(x)) y else x
