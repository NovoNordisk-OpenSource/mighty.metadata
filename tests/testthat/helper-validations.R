# Counts how often the mighty_domain validator actually runs while `expr` is
# evaluated. Returns the count `n` and the result `value`.
count_validations <- function(expr) {
  calls <- new.env()
  calls$n <- 0L
  orig <- validate_mighty_domain
  testthat::local_mocked_bindings(
    validate_mighty_domain = function(self) {
      calls$n <- calls$n + 1L
      orig(self)
    }
  )

  value <- force(expr)
  list(n = calls$n, value = value)
}
