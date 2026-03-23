test_that("resolve_includes() - study - simple", {
  study <- test_path("test_study") |>
    mighty_study()

  study@info$study_id |>
    expect_equal("test_study")

  study |>
    resolve_includes() |>
    expect_equal(study)

  study$ADAE <- update_column(
    study$ADAE,
    id = "TRTEMFL",
    include = "{study_id == 'test_study'}"
  )

  study |>
    resolve_includes() |>
    getElement("ADAE") |>
    list_columns() |>
    expect_contains("TRTEMFL")

  study@info$study_id <- "other_study"

  study |>
    resolve_includes() |>
    getElement("ADAE") |>
    list_columns() |>
    expect_no_match("^TRTEMFL$")

  study2 <- study |>
    resolve_includes(
      info = list(
        study_id = "test_study"
      )
    )

  study2@info$study_id |>
    expect_equal("test_study")

  study$ADAE |>
    list_columns() |>
    expect_contains("TRTEMFL")
})

test_that("resolve_includes() - study - complex", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADSL <- study$ADSL |>
    update_column(
      id = "SEX",
      include = "{study_id == 'test_study'}"
    ) |>
    update_column(
      id = "RACE",
      include = FALSE
    )

  study$ADAE <- study$ADAE |>
    update_column(
      id = "AEBODSYS",
      include = "{study_id == 'different_study'}"
    )

  study$ADVS <- study$ADVS |>
    update_row(
      id = "baseline",
      include = "{impute_baseline_row}"
    ) |>
    add_parameter(
      id = "BMIGRP",
      label = "BMI Group",
      columns = list(
        list(
          id = "AVALC",
          method = "Derived from BMI"
        )
      ),
      include = "{study_id == 'test_study'}"
    )

  study_resolved <- resolve_includes(
    x = study,
    info = list(
      impute_baseline_row = FALSE
    )
  )

  expect_equal(
    object = study_resolved@info,
    expected = list(
      study_id = "test_study",
      impute_baseline_row = FALSE
    )
  )

  study_resolved$ADSL |>
    list_columns() |>
    expect_contains("SEX") |>
    expect_no_match("^RACE$")

  study_resolved$ADAE |>
    list_columns() |>
    expect_no_match("^AEBODSYS$")

  study_resolved$ADVS |>
    list_rows() |>
    expect_length(0L)

  study_resolved$ADVS |>
    list_parameters() |>
    expect_contains(c("BMI", "BMIGRP"))
})

test_that("resolve_includes() - domain", {
  adsl <- test_path("test_study", "adsl.yml") |>
    mighty_domain()

  adsl |>
    resolve_includes() |>
    expect_equal(adsl)

  adsl <- adsl |>
    update_column(
      id = "SITEID",
      include = FALSE
    ) |>
    update_column(
      id = "AGE",
      include = TRUE
    )

  adsl_resolved <- adsl |>
    resolve_includes()

  adsl_resolved |>
    list_columns() |>
    expect_contains("AGE") |>
    expect_no_match("^SITEID$")

  adsl_resolved |>
    select_column(id = "AGE") |>
    names() |>
    expect_no_match("^include$")
})

test_that("eval_include()", {
  info <- list(x = "a", y = 2, z = 10)

  eval_include("{x == 'a'}", info) |>
    expect_true()

  eval_include("{x == 'a' & y > 5}", info) |>
    expect_false()

  eval_include(TRUE, info) |>
    expect_true()

  eval_include(FALSE, info) |>
    expect_false()

  eval_include("{unknown_info}", info) |>
    expect_error()

  eval_include("{y + z > 10}", info) |>
    expect_true()
})
