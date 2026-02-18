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
  study$ADSL$columns[[i]][["core"]] <- TRUE

  populate_core(study) |>
    expect_error(
      "ADAE - Variable\\(s\\) with same name already exists: `ADSL.STUDYID`"
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
  study$ADSL2$columns[[i]][["core"]] <- TRUE

  populate_core(study) |>
    expect_error(
      "Only ADSL is allowed to have core columns. Found: `ADSL2.AGE`"
    )
})
