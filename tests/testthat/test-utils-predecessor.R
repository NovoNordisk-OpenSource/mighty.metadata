study_domains <- c("ADSL", "ADVS")

test_that("parse_predecessor() and format_predecessor() handle all forms", {
  expect_predecessor <- function(shorthand, expanded, expected) {
    parse_predecessor(shorthand, study_domains) |> expect_identical(expected)
    parse_predecessor(expanded, study_domains) |> expect_identical(expected)
    format_predecessor(expected) |> expect_identical(expanded)
  }

  expect_predecessor(
    "ADSL.AGE",
    "ADSL.AGE",
    list(domain = "ADSL", column = "AGE", filter = NULL)
  )
  expect_predecessor(
    "SUPPDM.EFFICACY.QVAL",
    'SUPPDM.QVAL where QNAM="EFFICACY"',
    list(domain = "SUPPDM", column = "QVAL", filter = list(QNAM = "EFFICACY"))
  )
  expect_predecessor(
    "ADVS.BMI_GRP.AVALC",
    'ADVS.AVALC where PARAMCD="BMI_GRP"',
    list(domain = "ADVS", column = "AVALC", filter = list(PARAMCD = "BMI_GRP"))
  )
  expect_predecessor(
    "VS.SYSBP.VSSTRESN",
    'VS.VSSTRESN where VSTESTCD="SYSBP"',
    list(domain = "VS", column = "VSSTRESN", filter = list(VSTESTCD = "SYSBP"))
  )

  parse_predecessor('ADVS.AVALC WHERE PARAMCD="BMIGRP"', study_domains) |>
    expect_identical(parse_predecessor("ADVS.BMIGRP.AVALC", study_domains))
})

test_that("parse_predecessor() returns NULL for free text", {
  for (method in c("Derived from AE.AESTDTC", "as.numeric(AVAL)", "AGE", NA)) {
    parse_predecessor(method, study_domains) |> expect_null()
  }
  parse_predecessor(NULL, study_domains) |> expect_null()
})

test_that("parse_predecessor() errors on malformed references", {
  for (method in c("A.B.C.D", "A..B", "ADSL.", "ADSL.AGE where available")) {
    parse_predecessor(method, study_domains) |>
      expect_error("Malformed predecessor")
  }

  parse_predecessor('ADVS.AVALC where QNAM="BMIGRP"', study_domains) |>
    expect_error("Expected PARAMCD, got QNAM")
})
