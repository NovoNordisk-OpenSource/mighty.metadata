# Counts how often the mighty_domain validator actually runs while `expr` is evaluated.
# Uses trace() since S7 keeps a reference to the validator function.
count_validations <- function(expr) {
  counter <- new.env()
  counter$n <- 0L

  suppressMessages(trace(
    what = "validate_mighty_domain",
    tracer = bquote(assign("n", .(counter)$n + 1L, envir = .(counter))),
    print = FALSE,
    where = asNamespace("mighty.metadata")
  ))
  withr::defer(
    suppressMessages(untrace(
      what = "validate_mighty_domain",
      where = asNamespace("mighty.metadata")
    ))
  )

  force(expr)
  counter$n
}
