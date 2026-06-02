test_that("mighty_config works", {
  x <- mighty_config(
    path = system.file("examples", package = "mighty.metadata")
  ) |>
    expect_no_condition()

  expect_true(S7::S7_inherits(x, mighty_config))
  expect_true(is.list(x$external_data))
  expect_true(length(x$external_data) > 0)

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

test_that("mighty_config errors on duplicate external_data ids", {
  tmp <- withr::local_tempdir()
  writeLines(
    c("external_data:",
      "  - id: DM", "    keys: USUBJID",
      "  - id: DM", "    keys: STUDYID"),
    file.path(tmp, "_mighty.yml")
  )
  expect_error(mighty_config(path = tmp), regexp = "Duplicate")
})

test_that("mighty_config errors on missing _mighty.yml", {
  tmp <- withr::local_tempdir()
  expect_error(mighty_config(path = tmp))
})

test_that("mighty_config errors on invalid schema", {
  tmp <- withr::local_tempdir()
  writeLines("not_valid_field: true", file.path(tmp, "_mighty.yml"))
  expect_error(mighty_config(path = tmp), regexp = "external_data")
})

test_that("mighty_config write_config round-trips", {
  x <- mighty_config(
    path = system.file("examples", package = "mighty.metadata")
  )

  tmp <- withr::local_tempdir()
  write_config(x, path = tmp)

  expect_true(file.exists(file.path(tmp, "_mighty.yml")))

  x2 <- mighty_config(path = tmp)
  expect_equal(x$external_data, x2$external_data)
})
