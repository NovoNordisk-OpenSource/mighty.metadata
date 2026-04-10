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
    expect_equal(c("mighty", "study"))

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
