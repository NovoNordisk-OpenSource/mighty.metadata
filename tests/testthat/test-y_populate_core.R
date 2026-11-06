test_that("populate_core() adds core variables as predecessors", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADAE |>
    list_columns() |>
    intersect(c("SEX", "RACE")) |>
    expect_length(0)

  study_updated <- study |>
    populate_core() |>
    expect_no_condition() |>
    expect_s7_class(mighty_study)

  study_updated$ADAE |>
    list_columns() |>
    expect_contains(c("SEX", "RACE"))

  select_column(study_updated$ADAE, "SEX") |>
    expect_mapequal(
      list(
        id = "SEX",
        method = "ADSL.SEX",
        origin = "Predecessor"
      )
    )

  select_column(study_updated$ADAE, "RACE") |>
    expect_mapequal(
      list(
        id = "RACE",
        method = "ADSL.RACE",
        origin = "Predecessor"
      )
    )
})

test_that("populate_core() throws error when column already exists", {
  study <- test_path("test_study") |>
    mighty_study()

  i <- which_ids(x = study$ADSL$columns, id = "STUDYID")
  study$ADSL$columns[[i]][["is_core"]] <- TRUE

  populate_core(study) |>
    expect_error(
      "ADAE - Variable\\(s\\) with same name already exists: `ADSL.STUDYID`"
    )
})

test_that("populate_core() is idempotent", {
  test_path("test_study") |>
    mighty_study() |>
    expect_idempotent(fun = populate_core)
})

test_that("populate_core() is idempotent after populate_sparse()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse()

  study |>
    populate_core() |>
    expect_identical(study)
})

test_that("populate_core() errors on same-name column with other method", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  study$ADAE <- update_column(study$ADAE, id = "SEX", method = "ADSL.OTHER")

  populate_core(study) |>
    expect_error(
      "ADAE - Variable\\(s\\) with same name already exists: `ADSL.SEX`"
    )
})

test_that("populate_core() errors on same-name column with other origin", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  study$ADAE <- update_column(study$ADAE, id = "SEX", origin = "Derived")

  populate_core(study) |>
    expect_error(
      "ADAE - Variable\\(s\\) with same name already exists: `ADSL.SEX`"
    )
})

test_that("populate_core() throws error with duplicate core variables", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADSL2 <- study$ADSL

  populate_core(study) |>
    expect_error(
      "Non-unique core variable\\(s\\) found: `ADSL2.SEX` and `ADSL2.RACE`"
    )
})

test_that("populate_core() throws error with non-ADSL core variables", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADSL2 <- study$ADSL
  study$ADSL2 <- remove_columns(study$ADSL2, c("SEX", "RACE"))

  i <- which(list_columns(study$ADSL2) %in% "AGE")
  study$ADSL2$columns[[i]][["is_core"]] <- TRUE

  populate_core(study) |>
    expect_error(
      "Only ADSL is allowed to have core columns. Found: `ADSL2.AGE`"
    )
})

test_that("populate_core() validates each domain once, not once per column", {
  study <- test_path("test_study") |>
    mighty_study()

  n_before <- length(list_columns(study$ADAE))

  res <- count_validations(populate_core(study))

  expect_gt(length(list_columns(res$value$ADAE)) - n_before, 1L)
  expect_equal(res$n, 1L) # only ADAE has `usecore`
})

test_that("populate_core_domain() skips validation if `usecore` is not set", {
  study <- test_path("test_study") |>
    mighty_study()

  expect_false(isTRUE(study$ADSL$usecore))

  res <- count_validations(
    populate_core_domain(domain = study$ADSL, study = study)
  )

  expect_equal(res$n, 0L)
  expect_identical(res$value, study$ADSL)
})

test_that("populate_core_domain() skips validation if no core variables", {
  study <- test_path("test_study") |>
    mighty_study()

  for (i in seq_along(study$ADSL$columns)) {
    study$ADSL$columns[[i]][["is_core"]] <- NULL
  }

  res <- count_validations(
    populate_core_domain(domain = study$ADAE, study = study)
  )

  expect_equal(res$n, 0L)
  expect_identical(res$value, study$ADAE)
})

test_that("populate_core_domain() skips validation when already populated", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core()

  res <- count_validations(
    populate_core_domain(domain = study$ADAE, study = study)
  )

  expect_equal(res$n, 0L)
  expect_identical(res$value, study$ADAE)
})
