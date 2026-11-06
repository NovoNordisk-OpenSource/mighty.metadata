# Runs `fun` twice and expects the second run to return the first result.
expect_idempotent <- function(object, fun, ...) {
  once <- fun(object, ...)
  expect_identical(fun(once, ...), once)
  invisible(once)
}
