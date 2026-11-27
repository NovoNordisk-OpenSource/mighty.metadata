study_domains <- c("ADSL", "ADVS")

expect_predecessor <- function(shorthand, expanded, expected) {
  parse_predecessor(method = shorthand, study_domains = study_domains) |>
    expect_identical(expected = expected)
  parse_predecessor(method = expanded, study_domains = study_domains) |>
    expect_identical(expected = expected)
  format_predecessor(x = expected) |>
    expect_identical(expected = expanded)
}

test_that("parse_predecessor() and format_predecessor() handle all forms", {
  expect_predecessor(
    shorthand = "ADSL.AGE",
    expanded = "ADSL.AGE",
    expected = list(domain = "ADSL", column = "AGE", filter = NULL)
  )
  expect_predecessor(
    shorthand = "SUPPDM.EFFICACY.QVAL",
    expanded = 'SUPPDM.QVAL where QNAM="EFFICACY"',
    expected = list(
      domain = "SUPPDM",
      column = "QVAL",
      filter = list(QNAM = "EFFICACY")
    )
  )
  expect_predecessor(
    shorthand = "ADVS.BMI_GRP.AVALC",
    expanded = 'ADVS.AVALC where PARAMCD="BMI_GRP"',
    expected = list(
      domain = "ADVS",
      column = "AVALC",
      filter = list(PARAMCD = "BMI_GRP")
    )
  )
  expect_predecessor(
    shorthand = "VS.SYSBP.VSSTRESN",
    expanded = 'VS.VSSTRESN where VSTESTCD="SYSBP"',
    expected = list(
      domain = "VS",
      column = "VSSTRESN",
      filter = list(VSTESTCD = "SYSBP")
    )
  )
})

test_that("parse_predecessor() accepts upper case WHERE", {
  parse_predecessor(
    method = 'ADVS.AVALC WHERE PARAMCD="BMIGRP"',
    study_domains = study_domains
  ) |>
    expect_identical(
      expected = parse_predecessor(
        method = "ADVS.BMIGRP.AVALC",
        study_domains = study_domains
      )
    )
})

test_that("parse_predecessor() returns NULL for free text", {
  free_text <- list(
    "Derived from AE.AESTDTC",
    "as.numeric(AVAL)",
    "AGE",
    NA,
    NULL
  )
  for (method in free_text) {
    parse_predecessor(method = method, study_domains = study_domains) |>
      expect_null()
  }
})

test_that("parse_predecessor() errors on malformed references", {
  malformed <- c(
    "A.B.C.D",
    "A..B",
    "ADSL.",
    "ADSL.AGE where available",
    "adsl.age",
    "ADSL.age",
    "1.5",
    "ADSL.1X",
    'advs.AVALC where PARAMCD="X"'
  )
  for (method in malformed) {
    parse_predecessor(method = method, study_domains = study_domains) |>
      expect_error(regexp = "Malformed predecessor")
  }
})

test_that("parse_predecessor() errors on wrong filter key", {
  parse_predecessor(
    method = 'ADVS.AVALC where QNAM="BMIGRP"',
    study_domains = study_domains
  ) |>
    expect_error(regexp = "Expected PARAMCD, got QNAM")
})
