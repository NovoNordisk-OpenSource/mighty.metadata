study_domains <- c("ADSL", "ADVS")

test_that("parse_predecessor() parses the two-part form", {
  parse_predecessor("ADSL.AGE", study_domains) |>
    expect_identical(list(domain = "ADSL", column = "AGE", filter = NULL))
})

test_that("parse_predecessor() derives the filter key of the three-part form", {
  parse_predecessor("SUPPDM.EFFICACY.QVAL", study_domains) |>
    expect_identical(
      list(domain = "SUPPDM", column = "QVAL", filter = list(QNAM = "EFFICACY"))
    )

  parse_predecessor("ADVS.BMIGRP.AVALC", study_domains) |>
    expect_identical(
      list(domain = "ADVS", column = "AVALC", filter = list(PARAMCD = "BMIGRP"))
    )

  parse_predecessor("VS.SYSBP.VSSTRESN", study_domains) |>
    expect_identical(
      list(
        domain = "VS",
        column = "VSSTRESN",
        filter = list(VSTESTCD = "SYSBP")
      )
    )

  parse_predecessor("ADVS.BMI_GRP.AVALC", study_domains) |>
    getElement("filter") |>
    expect_identical(list(PARAMCD = "BMI_GRP"))
})

test_that("parse_predecessor() parses the expanded form as the shorthand", {
  parse_predecessor('SUPPDM.QVAL where QNAM="EFFICACY"', study_domains) |>
    expect_identical(parse_predecessor("SUPPDM.EFFICACY.QVAL", study_domains))

  parse_predecessor('ADVS.AVALC where PARAMCD="BMIGRP"', study_domains) |>
    expect_identical(parse_predecessor("ADVS.BMIGRP.AVALC", study_domains))

  parse_predecessor('VS.VSSTRESN where VSTESTCD="SYSBP"', study_domains) |>
    expect_identical(parse_predecessor("VS.SYSBP.VSSTRESN", study_domains))

  parse_predecessor('ADVS.AVALC WHERE PARAMCD="BMIGRP"', study_domains) |>
    expect_identical(parse_predecessor("ADVS.BMIGRP.AVALC", study_domains))

  parse_predecessor('ADVS.AVALC Where PARAMCD="BMIGRP"', study_domains) |>
    expect_identical(parse_predecessor("ADVS.BMIGRP.AVALC", study_domains))
})

test_that("parse_predecessor() round trips format_predecessor()", {
  methods <- c(
    "ADSL.AGE",
    "SUPPDM.EFFICACY.QVAL",
    "ADVS.BMIGRP.AVALC",
    "VS.SYSBP.VSSTRESN"
  )

  for (method in methods) {
    x <- parse_predecessor(method, study_domains)
    x |>
      format_predecessor() |>
      parse_predecessor(study_domains) |>
      expect_identical(x)
  }

  expanded <- 'SUPPDM.QVAL where QNAM="EFFICACY"'
  expanded |>
    parse_predecessor(study_domains) |>
    format_predecessor() |>
    expect_identical(expanded)
})

test_that("parse_predecessor() returns NULL for free text", {
  parse_predecessor("Derived from AE.AESTDTC", study_domains) |>
    expect_null()
  parse_predecessor("as.numeric(AVAL)", study_domains) |>
    expect_null()
  parse_predecessor("AGE", study_domains) |>
    expect_null()
  parse_predecessor(NULL, study_domains) |>
    expect_null()
  parse_predecessor(NA, study_domains) |>
    expect_null()
})

test_that("parse_predecessor() errors on malformed references", {
  for (method in c("A.B.C.D", "A..B", "ADSL.", "ADSL.AGE where available")) {
    parse_predecessor(method, study_domains) |>
      expect_error("Malformed predecessor")
  }

  parse_predecessor('ADVS.AVALC where QNAM="BMIGRP"', study_domains) |>
    expect_error("Expected PARAMCD, got QNAM")
})
