# S7SCHEMA-WORKAROUND -- delete this whole file once S7schema parses yaml in R.
#
# S7schema (<= 0.1.2) validates yaml by parsing it in JavaScript, where
# js-yaml resolves an unquoted `version: 2025-08-06` to a timestamp and the
# schema's `"type": "string"` check fails. We instead read the file with
# `yaml::read_yaml()` and validate the resulting list.
#
# `construct_study_config()` therefore reimplements the upstream constructor.
# The risk is drift: dropping a check that `S7schema()` performs. These tests
# pin the bug and assert parity with upstream on everything else.

study_schema <- function() {
  system.file("schema", "study.json", package = "mighty.metadata")
}

# Study yaml whose `version` is an unquoted ISO date -- the trigger case.
write_dated_study <- function(dir, env = parent.frame()) {
  if (missing(dir)) {
    dir <- withr::local_tempdir(.local_envir = env)
  }
  file <- file.path(dir, "_study.yml")
  writeLines(
    c("study_id: s", "standards:", "  - id: sdtm", "    version: 2025-08-06"),
    file
  )
  file
}

test_that("upstream S7schema still mis-parses unquoted dates (bug is live)", {
  # When this FAILS the bug is fixed: drop the `S7SCHEMA-WORKAROUND` blocks
  # in R/a_study_config.R and R/utils-yml.R, plus this file.
  file <- write_dated_study()

  expect_error(S7schema::validate_yaml(file, study_schema()), "must be string")
  expect_equal(study_config(file = file)$standards[[1]]$version, "2025-08-06")
})

test_that("find_yml() accepts unquoted date versions", {
  # `utils-yml.R` carries a second, independent workaround block.
  file <- write_dated_study()

  find_yml(dirname(file), "_study", study_schema()) |>
    expect_equal(file)
})

test_that("write_config() quotes dates so the round-trip survives", {
  # If `to_yaml()` ever stops quoting, files written by this package would no
  # longer parse back as strings.
  x <- study_config(file = write_dated_study())
  out <- file.path(withr::local_tempdir(), "_study.yml")

  write_config(x, path = out)

  expect_match(readLines(out), "version: '2025-08-06'", all = FALSE)
  expect_equal(study_config(file = out)$standards[[1]]$version, "2025-08-06")
})

test_that("workaround constructor matches S7schema() on argument handling", {
  # Every check upstream performs before parsing must still be performed here.
  expect_error(study_config(), "must be supplied")
  expect_error(
    study_config(file = "a.yml", .data = list(study_id = "a")),
    "Exactly one"
  )
  expect_error(study_config(file = c("a.yml", "b.yml")), "exactly .*one")
  expect_error(study_config(file = "absent.yml"), "File does not exist")

  txt <- withr::local_tempfile(fileext = ".txt")
  writeLines("study_id: a", txt)
  expect_error(study_config(file = txt), "Extension must be one of")
})

test_that("workaround still enforces the schema and sets properties", {
  # Validating ourselves risks silently skipping validation altogether.
  expect_error(study_config(.data = list(not_study_id = "x")), "study_id")
  expect_error(study_config(.data = list(study_id = 1L)), "study_id")

  file <- test_path("test_study", "_study.yml")
  x <- study_config(file = file)
  expect_equal(x@file, file)
  expect_equal(x@schema, study_schema())
  expect_null(study_config(.data = list(study_id = "in_memory"))@file)
})
