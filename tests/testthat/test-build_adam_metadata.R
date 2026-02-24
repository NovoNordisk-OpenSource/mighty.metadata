describe("build_adam_metadata", {
  it("Builds ADaM metadata structure", {
    # Read test metadata
    metadata <- load_test_metadata_components()
    metadata$source_columns <- metadata$source_columns |>
      dplyr::filter(!is.na(.data$core))

    expect_no_error({
      adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)
    })

    expect_no_warning({
      adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)
    })

    expect_message({
      adam_metadata <- build_adam_metadata(metadata)
    })

    # Check that names are correct
    expect_equal(
      names(adam_metadata),
      c("ADSL", "ADADJ", "ADAE", "ADCM", "ADHYPO", "ADMH", "ADEG",
        "ADEC", "ADECEN", "ADLB", "ADPE", "ADRESP", "ADSMPG", "ADSMPGEN",
        "ADCGM", "ADCGMEN", "ADVS", "ADHYPOEN", "ADQSDPEM", "ADQSIPQ",
        "ADQSDTSQ", "MDFLOW", "MDPARAM", "MDVISIT", "MDNR", "MDSYMBOL",
        "MDUNITCV", "MDCOL", "MDCNTRY", "MDMQ")
    )

    # Check that names of elements are correct
    expect_equal(
      lapply(adam_metadata, names),
      list(ADSL = c("table_metadata", "column_metadata"),
           ADADJ = c("table_metadata", "column_metadata"),
           ADAE = c("table_metadata", "column_metadata"),
           ADCM = c("table_metadata", "column_metadata"),
           ADHYPO = c("table_metadata", "column_metadata"),
           ADMH = c("table_metadata", "column_metadata"),
           ADEG = c("table_metadata", "column_metadata"),
           ADEC = c("table_metadata", "column_metadata"),
           ADECEN = c("table_metadata", "column_metadata", "value_metadata"),
           ADLB = c("table_metadata", "column_metadata", "value_metadata"),
           ADPE = c("table_metadata", "column_metadata"),
           ADRESP = c("table_metadata", "column_metadata", "value_metadata"),
           ADSMPG = c("table_metadata", "column_metadata"),
           ADSMPGEN = c("table_metadata", "column_metadata", "value_metadata"),
           ADCGM = c("table_metadata", "column_metadata"),
           ADCGMEN = c("table_metadata", "column_metadata", "value_metadata"),
           ADVS = c("table_metadata", "column_metadata", "value_metadata"),
           ADHYPOEN = c("table_metadata", "column_metadata", "value_metadata"),
           ADQSDPEM = c("table_metadata", "column_metadata"),
           ADQSIPQ = c("table_metadata", "column_metadata"),
           ADQSDTSQ = c("table_metadata", "column_metadata", "value_metadata"),
           MDFLOW = c("table_metadata", "column_metadata"),
           MDPARAM = c("table_metadata", "column_metadata"),
           MDVISIT = c("table_metadata", "column_metadata"),
           MDNR = c("table_metadata", "column_metadata"),
           MDSYMBOL = c("table_metadata", "column_metadata"),
           MDUNITCV = c("table_metadata", "column_metadata"),
           MDCOL = c("table_metadata", "column_metadata"),
           MDCNTRY = c("table_metadata", "column_metadata"),
           MDMQ = c("table_metadata", "column_metadata"))
    )
  })

  it("Builds ADaM metadata structure with column information missing", {
    metadata <- load_test_metadata_components(
      table_filter = table %in% c("ADSL", "ADAE"),
      column_filter = table == "ADSL",
      value_filter = table == "ADSL")

    expect_no_error({
      adam_metadata <- suppressWarnings(build_adam_metadata(metadata, verbose = FALSE))
    })

    expect_warning({
      adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)
    })

    expect_message({
      adam_metadata <- suppressWarnings(build_adam_metadata(metadata))
    })

  })

  it("builds ADaM metadata including 'core' column", {
    metadata <- load_test_metadata_components(
      table_filter = table == "ADSL",
      column_filter = table == "ADSL",
      value_filter = table == "ADSL"
    )

    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    column_metadata <- adam_metadata$ADSL$column_metadata
    have_core <- purrr::map_lgl(column_metadata, \(x) "core" %in% names(x))
    expect_true(all(have_core))
  })
})
