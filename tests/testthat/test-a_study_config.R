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
  expect_error(
    study_config(.data = list(not_study_id = TRUE)),
    regexp = "study_id"
  )
})

test_that("study_config errors on invalid schema (file)", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")
  writeLines("not_study_id: true", file)
  expect_error(study_config(file), regexp = "study_id")
})

test_that("study_config keeps additional properties", {
  x <- study_config(
    .data = list(study_id = "a", study_description = "A study", pooled = TRUE)
  ) |>
    expect_no_condition()

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

test_that("study_config works with in-memory data", {
  x <- study_config(
    .data = list(study_id = "example_study", study_description = "A study")
  )

  expect_true(S7::S7_inherits(x, study_config))
  expect_equal(x$study_id, "example_study")
  expect_equal(x$study_description, "A study")
  expect_null(x@file)
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

test_that("study_config accepts standards and terminology", {
  x <- study_config(
    .data = list(
      study_id = "a",
      standards = list(list(id = "ADaM-IG", version = 1.1)),
      terminology = list(
        list(id = "ADAM", version = "2025-08-06"),
        list(id = "WHODrug", version = "2023 JAN")
      )
    )
  ) |>
    expect_no_condition()

  expect_length(x$standards, 1)
  expect_equal(x$standards[[1]]$id, "ADaM-IG")
  expect_length(x$terminology, 2)
  expect_equal(x$terminology[[2]]$version, "2023 JAN")
})

test_that("write_config() preserves quoted version strings with trailing zeros", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")

  writeLines(
    c("study_id: a", "standards:", "  - id: ADaM-IG", "    version: '1.10'"),
    file
  )

  x <- study_config(file)
  expect_equal(x$standards[[1]]$version, "1.10")

  out <- file.path(tmp, "out.yml")
  write_config(x, path = out)

  expect_equal(study_config(out)$standards[[1]]$version, "1.10")
})

test_that("study_config accepts missing or empty standards and terminology", {
  expect_no_condition(study_config(.data = list(study_id = "a")))

  x <- study_config(
    .data = list(study_id = "a", standards = list(), terminology = list())
  ) |>
    expect_no_condition()

  expect_length(x$standards, 0)
  expect_length(x$terminology, 0)
})

test_that("study_config errors on standards or terminology missing id/version", {
  expect_error(
    study_config(
      .data = list(study_id = "a", standards = list(list(version = "1.1")))
    ),
    regexp = "must have required property 'id'"
  )
  expect_error(
    study_config(
      .data = list(study_id = "a", standards = list(list(id = "ADaM-IG")))
    ),
    regexp = "must have required property 'version'"
  )

  expect_error(
    study_config(
      .data = list(study_id = "a", terminology = list(list(version = "22.1")))
    ),
    regexp = "must have required property 'id'"
  )

  expect_error(
    study_config(
      .data = list(study_id = "a", terminology = list(list(id = "MedDRA")))
    ),
    regexp = "must have required property 'version'"
  )
})

test_that("study_config errors when standards is not an array of objects", {
  expect_error(
    study_config(.data = list(study_id = "a", standards = "ADaM-IG")),
    regexp = "/standards must be array"
  )

  expect_error(
    study_config(.data = list(study_id = "a", terminology = list("MedDRA"))),
    regexp = "must be object"
  )
})

test_that("study_config errors when an entry id is not a string", {
  expect_error(
    study_config(
      .data = list(study_id = "a", standards = list(list(id = 1, version = 1)))
    ),
    regexp = "id must be string"
  )
})

test_that("study_config round-trips standards and terminology", {
  tmp <- withr::local_tempdir()
  file <- file.path(tmp, "_study.yml")

  writeLines(
    c(
      "study_id: a",
      "standards:",
      "  - id: ADaM-IG",
      "    version: 1.1",
      "terminology:",
      "  - id: ADAM",
      "    version: '2025-08-06'",
      "  - id: WHODrug",
      "    version: 2023 JAN"
    ),
    file
  )

  x <- study_config(file)

  out <- file.path(tmp, "out", "_study.yml")
  dir.create(dirname(out))
  write_config(x, path = out)

  expect_equal(S7::S7_data(study_config(out)), S7::S7_data(x))
})
