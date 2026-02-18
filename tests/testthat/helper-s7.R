# Helper function to mimic testthat::expect_s7_class()
# since it is not available in older R versions (e.g. 4.4.1)
if (!"expect_s7_class" %in% getNamespaceExports(ns = "testthat")) {
  expect_s7_class <- function(object, class) {
    stopifnot(inherits(x = class, what = "S7_class"))
    stopifnot(S7::S7_inherits(x = object))
    stopifnot(S7::S7_inherits(x = object, class = class))
    invisible(object)
  }
}
