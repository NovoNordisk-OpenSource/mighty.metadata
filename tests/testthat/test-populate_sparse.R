describe("populate_sparse() and helper functions", {
  it("extracts a list from a data.frame", {

    testdf <- data.frame(
      table = "ADSL",
      column = "USUBJID",
      label = "Unique Subject Identifier",
      type = c("C", "N"),
      length = 40
    )

    expect_no_error(column_as_list(testdf[1,], "ADSL", "USUBJID"))

    expect_error(column_as_list(testdf, "ADSL", "USUBJID"))

    expect_null(column_as_list(testdf, "ADSL", "SUBJID"))

    expect_equal(column_as_list(testdf[1,], "ADSL", "USUBJID"),
                 list(id = "USUBJID", label = "Unique Subject Identifier",
                      format = list(type = "C", length = 40)))

  })

  it("updates a list when method is predecessor and source is dataframe", {
    testdf <- data.frame(
      table = c("ADSL", "ADLB"),
      column = "AGEGR1",
      label = "Pooled Age Group 1",
      type = "C",
      length = 80,
      method = c("Derived: Grouping of ages into age group 1; See ADRG.",
                 "Predecessor: ADSL.AGEGR1")
    )

    expect_no_error(list(id = "AGEGR1", method = "Predecessor: ADSL.AGEGR1") |>
                      update_predecessor(testdf))

    expect_equal(list(id = "AGEGR1", method = "Predecessor: ADSL.AGEGR1") |>
                   update_predecessor(testdf),
                 list(id = "AGEGR1", method = "Predecessor: ADSL.AGEGR1",
                      label = "Pooled Age Group 1",
                      format = list(type = "C", length = 80)))

  })

  it("behaves correctly when given irregular input", {
    testdf <- data.frame(
      table = c("ADSL", "ADLB"),
      column = "AGEGR1",
      label = "Pooled Age Group 1",
      type = "C",
      length = 80,
      method = c("Derived: Grouping of ages into age group 1; See ADRG.",
                 "Predecessor: ADSL.AGEGR1")
    )

    expect_error(list(id = "AGEGR1", method = "Predecessor: ADSL.AGEGR1") |>
                   update_predecessor("error"))

    expect_error(list(id = "AGEGR1", method = "Predecessor: ADSL.AGEGR1") |>
                   update_predecessor(testdf[, 1:2]))

    expect_equal(list(id = "AGEGR2", method = "Predecessor: ADSL.AGEGR2") |>
                   update_predecessor(testdf),
                 list(id = "AGEGR2", method = "Predecessor: ADSL.AGEGR2"))

    expect_equal(list(id = "AGEGR1", method = "Derived: Grouping of ages into age group 1; See ADRG.") |>
                   update_predecessor(NULL),
                 list(id = "AGEGR1", method = "Derived: Grouping of ages into age group 1; See ADRG."))

    expect_equal(list(id = "AGEGR1") |>
                   update_predecessor(NULL),
                 list(id = "AGEGR1"))
  })
})
