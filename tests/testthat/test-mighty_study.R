test_that("mighty_study(populate = FALSE) does not populate", {
  study <- test_path("test_study") |>
    mighty_study(populate = FALSE) |>
    expect_no_condition() |>
    expect_s7_class(mighty_study)

  study$ADAE |>
    list_columns() |>
    intersect(c("SEX", "RACE")) |>
    expect_length(0)
})

test_that("mighty_study(populate = TRUE) populates core and sparse", {
  study <- test_path("test_study") |>
    mighty_study(populate = TRUE) |>
    expect_no_condition() |>
    expect_s7_class(mighty_study)

  study$ADAE |>
    list_columns() |>
    expect_contains(c("SEX", "RACE"))

  expect_equal(
    select_column(study$ADAE, "SEX")[["label"]],
    select_column(study$ADSL, "SEX")[["label"]]
  )
})

test_that("mighty_study()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    expect_no_condition() |>
    expect_s7_class(mighty_study)

  study |>
    lapply(
      FUN = expect_s7_class,
      class = mighty_domain
    ) |>
    names() |>
    expect_equal(c("ADAE", "ADSL", "ADVS"))

  S7::prop_names(study) |>
    expect_equal(c("mighty", "study", "path"))

  expect_true(S7::S7_inherits(study@mighty, mighty_config))
  expect_equal(
    object = study@mighty$external_data,
    expected = list(
      list(id = "DM", keys = c("STUDYID", "USUBJID"))
    )
  )

  expect_true(S7::S7_inherits(study@study, study_config))
  expect_equal(
    object = study@study$study_id,
    expected = "test_study"
  )

  expect_snapshot(
    x = print(study),
    transform = \(x) {
      # Robust between S7 versions
      gsub(pattern = "mighty\\.metadata::", replacement = "", x = x)
    }
  )
})

test_that("@mighty accepts NULL and rejects invalid types", {
  study <- test_path("test_study") |> mighty_study()

  study@mighty <- NULL
  expect_null(study@mighty)

  expect_error(study@mighty <- "not a mighty_config")
  expect_error(study@mighty <- list(external_data = list()))
})

test_that("@study accepts NULL and rejects invalid types", {
  study <- test_path("test_study") |> mighty_study()

  study@study <- NULL
  expect_null(study@study)

  expect_error(study@study <- "not a study_config")
  expect_error(study@study <- list(study_id = "test_study"))
})

test_that("mighty_study() without _study.yml has NULL @study", {
  tmp <- withr::local_tempdir()
  file.copy(
    from = test_path("test_study", c("_mighty.yml", "adsl.yml")),
    to = tmp
  )

  study <- mighty_study(path = tmp) |> expect_no_condition()

  expect_null(study@study)
  expect_snapshot(
    x = print(study),
    transform = \(x) {
      # Robust between S7 versions
      gsub(pattern = "mighty\\.metadata::", replacement = "", x = x)
    }
  )
})

test_that("validate_path() errors when @path set to non-existent directory", {
  study <- test_path("test_study") |>
    mighty_study()

  expect_error(
    study@path <- "/nonexistent/path",
    "Directory does not exist"
  )
})

test_that("validate_path() accepts existing directory", {
  study <- test_path("test_study") |> mighty_study()
  tmp <- withr::local_tempdir()
  study@path <- tmp
  expect_equal(study@path, tmp)
})

test_that("validate_path() errors on character(0)", {
  study <- test_path("test_study") |> mighty_study()
  expect_error(study@path <- character(0), "single non-NA string")
})

test_that("validate_path() errors on NA", {
  study <- test_path("test_study") |> mighty_study()
  expect_error(study@path <- NA_character_, "single non-NA string")
})

test_that("validate_datasets() error on incorrect file name", {
  files <- c("example/adae.yaml", "example/advs.yaml", "example/_test.yaml")
  expect_error(validate_datasets(files))
})
