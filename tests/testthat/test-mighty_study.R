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

  expect_equal(
    object = study@mighty,
    expected = list(
      external_data = list(
        list(id = "DM", keys = c("STUDYID", "USUBJID"))
      )
    )
  )

  expect_equal(
    object = study@study,
    expected = list(
      study_id = "test_study"
    )
  )

  expect_error(
    study@study <- list(not_study_id = "missing required field"),
    "study_id"
  )

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
