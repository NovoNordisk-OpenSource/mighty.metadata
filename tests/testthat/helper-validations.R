# Counts how often the mighty_domain validator actually runs while `expr` is evaluated.
count_validations <- function(expr) {
  n <- 0L
  orig <- validate_mighty_domain
  testthat::local_mocked_bindings(
    validate_mighty_domain = function(self) {
      n <<- n + 1L
      orig(self)
    }
  )

  force(expr)
  n
}
