#' Null coalescing operator
#' @name null-coalesce
#' @rdname null-coalesce
#' @keywords internal
`%||%` <- function(x, y) if (is.null(x)) y else x
