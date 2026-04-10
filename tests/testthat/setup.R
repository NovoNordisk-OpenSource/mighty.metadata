# Minimal prints to make it easier to read test output

withr::local_options(
  list(mighty.metadata.verbosity_level = "quiet"),
  .local_envir = teardown_env()
)
