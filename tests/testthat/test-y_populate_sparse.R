test_that("populate_sparse() - works with intended input", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse() |>
    expect_no_condition() |>
    expect_s7_class(mighty_study)

  expect_equal(
    select_column(study$ADAE, "SEX")[["label"]],
    select_column(study$ADSL, "SEX")[["label"]]
  )

  study |>
    populate_sparse() |>
    expect_equal(study)
})

test_that("populate_sparse() - works on a single mighty_domain", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  populate_sparse(study$ADAE, study = study) |>
    expect_no_condition() |>
    expect_s7_class(mighty_domain)
})

test_that("populate_sparse() - errors when predecessor does not exist", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  i <- which_ids(study$ADSL$columns, "RACE")
  study$ADSL$columns[[i]] <- NULL

  populate_sparse(study) |>
    expect_error(
      "RACE: Predecessor `ADSL.RACE` not found in study"
    )
})

test_that("populate_sparse() - debug info for predecessors not in study (e.g. SDTM)", {
  withr::local_options(
    .new = list(mighty.metadata.verbosity_level = "debug")
  )

  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  populate_sparse(study) |>
    capture_messages() |>
    expect_match("Predecessor domain `[A-Z]+` not found in study")
})

test_that("populate_sparse() - errors on non-standard predecessor method", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  i <- which_ids(study$ADAE$columns, "SEX")
  study$ADAE$columns[[i]]$method <- "invalid_method"
  study$ADAE$columns[[i]]$origin <- "Predecessor"

  populate_sparse(study) |>
    expect_error("Non standard predecessor method")
})
