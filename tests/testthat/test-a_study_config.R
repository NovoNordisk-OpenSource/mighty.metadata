test_that("study_config works", {
  x <- study_config(
    file = system.file("examples", "_study.yml", package = "mighty.metadata")
  ) |>
    expect_no_condition()

  expect_true(S7::S7_inherits(x, study_config))
  expect_equal(x$study_id, "example_study")

  print(x) |>
    expect_snapshot(
      transform = \(x) {
        sub(
          pattern = "<mighty.metadata::study_config>",
          replacement = "<study_config>",
          x = x
        )
      }
    )
})

test_that("study_config errors on missing file", {
  tmp <- withr::local_tempdir()
  expect_error(study_config(file.path(tmp, "_study.yml")))
})

test_that("study_config errors on invalid schema", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")
  writeLines("not_study_id: true", file)
  expect_error(study_config(file), regexp = "study_id")
})

test_that("study_config keeps additional properties", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")
  writeLines(
    c("study_id: a", "study_description: A study", "pooled: yes"),
    file
  )

  x <- study_config(file) |> expect_no_condition()

  expect_equal(x$study_description, "A study")
  expect_true(x$pooled)
})

test_that("study_config write_config round-trips", {
  x <- study_config(
    file = system.file("examples", "_study.yml", package = "mighty.metadata")
  )

  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")
  write_config(x, path = file)

  expect_true(file.exists(file))

  x2 <- study_config(file)
  expect_equal(S7::S7_data(x2), S7::S7_data(x))
})

test_that("study_config write_config uses @file when path is NULL", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")
  writeLines("study_id: a", file)

  x <- study_config(file)
  x$study_id <- "b"
  write_config(x)

  expect_equal(study_config(file)$study_id, "b")
})
