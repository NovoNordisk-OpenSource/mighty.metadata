test_that("resolve_subsets() - no subsets - no change", {
  study <- test_path("test_study") |>
    mighty_study()

  study |>
    resolve_subsets() |>
    expect_equal(study)
})

test_that("resolve_subsets() - subsetting works", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADAE <- study$ADAE |>
    add_row(
      id = "TRTEMFL_STUDY1",
      component = list(
        id = "STUDY1_COMPONENT",
        with = list(domain = "ADAE")
      ),
      subset = "STUDYID == 'STUDY1'"
    )

  study <- study |>
    resolve_subsets() |>
    expect_no_condition()

  study$ADAE |>
    list_rows() |>
    expect_equal("TRTEMFL_STUDY1")

  study$ADAE |>
    select_row("TRTEMFL_STUDY1") |>
    purrr::pluck("component", "with", "domain") |>
    expect_equal("ADAE[with(ADAE, STUDYID == 'STUDY1'), ]")

  study$ADAE |>
    select_row("TRTEMFL_STUDY1") |>
    names() |>
    expect_no_match("^subset$")
})

test_that("resolve_subsets() - multiple domains and rows", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADSL <- study$ADSL |>
    add_row(
      id = "UPDATE_AGE",
      component = list(
        id = "SET",
        with = list(domain = "ADSL", variable = "AGE", value = 50)
      ),
      subset = "AGE > 50"
    )

  study$ADAE <- study$ADAE |>
    add_row(
      id = "TRTEMFL_STUDY1",
      component = list(
        id = "STUDY1_COMPONENT",
        with = list(domain = "ADAE")
      ),
      subset = "STUDYID == 'STUDY1'"
    ) |>
    add_row(
      id = "TRTEMFL_STUDY2",
      component = list(
        id = "STUDY2_COMPONENT",
        with = list(domain = "ADAE")
      ),
      subset = "STUDYID == 'STUDY2'"
    )

  study <- study |>
    resolve_subsets() |>
    expect_no_condition()

  elements <- unlist(study)

  expect_no_match(
    object = names(elements),
    regexp = "subset"
  )

  elements[grepl(pattern = "with\\.domain$", x = names(elements))] |>
    expect_snapshot()
})

test_that("resolve_subsets() - error handling", {
  study <- test_path("test_study") |>
    mighty_study()

  study$ADAE <- study$ADAE |>
    add_row(
      id = "TRTEMFL_STUDY1"
    )

  study |>
    resolve_subsets() |>
    expect_equal(study)

  study$ADAE <- study$ADAE |>
    update_row(
      id = "TRTEMFL_STUDY1",
      subset = "STUDYID == 'STUDY1'"
    )

  study |>
    resolve_subsets() |>
    expect_error(
      regexp = "TRTEMFL_STUDY1.*component.*specified"
    )

  study$ADAE <- study$ADAE |>
    update_row(
      id = "TRTEMFL_STUDY1",
      component = list(
        id = "STUDY1_COMPONENT"
      )
    )

  study |>
    resolve_subsets() |>
    expect_error(
      regexp = "STUDY1_COMPONENT.*with\\.domain.*specified"
    )
})
