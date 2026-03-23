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
    expect_equal("info")

  expect_equal(
    object = study@info,
    expected = list(
      study_id = "test_study"
    )
  )

  expect_snapshot(
    x = print(study),
    transform = \(x) {
      # Robust between S7 versions
      gsub(pattern = "mighty\\.metadata::", replacement = "", x = x)
    }
  )
})

test_that("Error if more than one _mighty file", {
  tmp <- withr::local_tempdir()

  test_path("test_study") |>
    list.files(full.names = TRUE) |>
    file.copy(to = tmp) |>
    all() |>
    expect_true()

  writeLines(
    text = "duplicate file",
    con = file.path(tmp, "_mighty.yaml")
  )

  mighty_study(tmp) |>
    expect_error("Only one _mighty file allowed")
})
