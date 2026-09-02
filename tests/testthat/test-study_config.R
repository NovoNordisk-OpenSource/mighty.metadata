test_that("study_config works", {
  x <- study_config(
    path = system.file("examples", package = "mighty.metadata")
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

test_that("study_config errors on missing _study.yml", {
  tmp <- withr::local_tempdir()
  expect_error(study_config(path = tmp))
})

test_that("study_config errors on invalid schema", {
  tmp <- withr::local_tempdir()
  writeLines("not_study_id: true", file.path(tmp, "_study.yml"))
  expect_error(study_config(path = tmp), regexp = "study_id")
})

test_that("study_config errors on multiple _study files", {
  tmp <- withr::local_tempdir()
  writeLines("study_id: a", file.path(tmp, "_study.yml"))
  writeLines("study_id: b", file.path(tmp, "_study.yaml"))

  expect_error(study_config(path = tmp), regexp = "Only one")
})

test_that("study_config keeps additional properties", {
  tmp <- withr::local_tempdir()
  writeLines(
    c("study_id: a", "study_description: A study", "pooled: yes"),
    file.path(tmp, "_study.yml")
  )

  x <- study_config(path = tmp) |> expect_no_condition()

  expect_equal(x$study_description, "A study")
  expect_true(x$pooled)
})

test_that("study_config write_config round-trips", {
  x <- study_config(
    path = system.file("examples", package = "mighty.metadata")
  )

  tmp <- withr::local_tempdir()
  write_config(x, path = tmp)

  expect_true(file.exists(file.path(tmp, "_study.yml")))

  x2 <- study_config(path = tmp)
  expect_equal(S7::S7_data(x2), S7::S7_data(x))
})

test_that("study_config write_config uses @file when path is NULL", {
  tmp <- withr::local_tempdir()
  writeLines("study_id: a", file.path(tmp, "_study.yml"))

  x <- study_config(path = tmp)
  x$study_id <- "b"
  write_config(x)

  expect_equal(study_config(path = tmp)$study_id, "b")
})
