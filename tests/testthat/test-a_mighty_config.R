test_that("mighty_config works", {
  x <- mighty_config(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  ) |>
    expect_no_condition()

  expect_true(S7::S7_inherits(x, mighty_config))
  expect_true(is.list(x$external_data))
  expect_true(length(x$external_data) > 0)
  expect_true(is.character(x$repos))
  expect_true(length(x$repos) > 0)

  print(x) |>
    expect_snapshot(
      transform = \(x) {
        sub(
          pattern = "<mighty.metadata::mighty_config>",
          replacement = "<mighty_config>",
          x = x
        )
      }
    )
})

test_that("mighty_config errors on missing file", {
  tmp <- withr::local_tempdir()
  expect_error(mighty_config(file.path(tmp, "_mighty.yml")))
})

test_that("mighty_config errors on invalid schema (file)", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_mighty.yml")
  writeLines("not_valid_field: true", file)
  expect_error(mighty_config(file), regexp = "external_data")
})

test_that("mighty_config repos field is accessible", {
  x <- mighty_config(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  )

  expect_equal(length(x$repos), 2L)
  expect_equal(
    x$repos[[1]],
    "NovoNordisk-OpenSource/mighty.standards/components@main"
  )
  expect_equal(x$repos[[2]], ".")
})

test_that("mighty_config works with single repos entry", {
  x <- mighty_config(
    .data = list(
      external_data = list(list(id = "DM", keys = "USUBJID")),
      repos = "."
    )
  ) |>
    expect_no_condition()
  expect_true(length(x$repos) > 0)
})

test_that("mighty_config works without repos field", {
  x <- mighty_config(
    .data = list(external_data = list(list(id = "DM", keys = "USUBJID")))
  ) |>
    expect_no_condition()
  expect_null(x$repos)
})

test_that("mighty_config errors on invalid repo entry", {
  expect_error(
    mighty_config(
      .data = list(
        external_data = list(list(id = "DM", keys = "USUBJID")),
        repos = 123
      )
    ),
    regexp = "repos"
  )
})

test_that("mighty_config write_config round-trips", {
  x <- mighty_config(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  )

  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_mighty.yml")
  write_config(x, path = file)

  expect_true(file.exists(file))

  x2 <- mighty_config(file)
  expect_equal(x$external_data, x2$external_data)
  expect_equal(x$repos, x2$repos)
})

test_that("mighty_config works with in-memory data", {
  x <- mighty_config(
    .data = list(
      external_data = list(list(id = "DM", keys = "USUBJID")),
      repos = "."
    )
  )

  expect_true(S7::S7_inherits(x, mighty_config))
  expect_equal(x$external_data[[1]]$id, "DM")
  expect_equal(x$repos, ".")
  expect_null(x@file)
})

test_that("mighty_config in-memory data is validated against the schema", {
  expect_error(
    mighty_config(.data = list(not_valid_field = TRUE)),
    regexp = "external_data"
  )
})

test_that("mighty_config errors on duplicate external_data ids", {
  expect_error(
    mighty_config(
      .data = list(
        external_data = list(
          list(id = "DM", keys = "USUBJID"),
          list(id = "DM", keys = "STUDYID")
        )
      )
    ),
    regexp = "Duplicate"
  )
})

test_that("mighty_config requires exactly one input source", {
  expect_error(
    mighty_config(
      file = system.file(
        "examples",
        "_mighty.yml",
        package = "mighty.metadata"
      ),
      .data = list(external_data = list(list(id = "DM", keys = "USUBJID")))
    ),
    regexp = "Exactly one"
  )
  expect_error(mighty_config(), regexp = "must be supplied")
})

test_that("mighty_config in-memory object requires a path to write", {
  x <- mighty_config(
    .data = list(external_data = list(list(id = "DM", keys = "USUBJID")))
  )
  expect_error(write_config(x), regexp = "path")

  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_mighty.yml")
  write_config(x, path = file)

  expect_equal(mighty_config(file)$external_data, x$external_data)
})

test_that("mighty_config write_config uses @file when path is NULL", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_mighty.yml")
  writeLines(c("external_data:", "  - id: DM", "    keys: USUBJID"), file)

  x <- mighty_config(file)
  x$external_data[[1]]$id <- "VS"
  write_config(x)

  expect_equal(mighty_config(file)$external_data[[1]]$id, "VS")
})
