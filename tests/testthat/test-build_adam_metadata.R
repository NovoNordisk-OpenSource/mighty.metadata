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

    # Check that schema-compliant keys are present per domain
    schema_keys_base <- c(
      "id", "label", "class", "structure", "keys", "columns"
    )
    schema_keys_params <- c(schema_keys_base, "parameters")

    domains_with_params <- c("ADECEN", "ADLB", "ADRESP", "ADSMPGEN",
                             "ADCGMEN", "ADVS", "ADHYPOEN", "ADQSDTSQ")

    for (domain in names(adam_metadata)) {
      if (domain %in% domains_with_params) {
        expect_true(all(schema_keys_params %in% names(adam_metadata[[domain]])),
                    info = paste("Missing schema keys in", domain))
      } else {
        expect_true(all(schema_keys_base %in% names(adam_metadata[[domain]])),
                    info = paste("Missing schema keys in", domain))
      }
    }
  })

  it("Builds ADaM metadata structure with column information missing", {
    metadata <- load_test_metadata_components(
      table_filter = table %in% c("ADSL", "ADAE"),
      column_filter = table == "ADSL",
      value_filter = table == "ADSL"
    )

    expect_warning(
      adam_metadata <- build_adam_metadata(metadata, verbose = FALSE),
      "no column information for ADAE; domain dropped from output"
    )

    expect_equal(names(adam_metadata), "ADSL")
  })

  it("builds ADaM metadata including 'core' column", {
    metadata <- load_test_metadata_components(
      table_filter = table == "ADSL",
      column_filter = table == "ADSL",
      value_filter = table == "ADSL"
    )

    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    column_metadata <- adam_metadata$ADSL$columns
    have_core <- purrr::map_lgl(column_metadata, \(x) "core" %in% names(x))
    expect_true(all(have_core))
  })

  it("builds ADaM metadata including 'comment' field at column level", {
    metadata <- load_test_metadata_components(
      table_filter = table == "ADAE",
      column_filter = table == "ADAE",
      value_filter = table == "ADAE"
    )

    source_columns_with_comment <- metadata$source_columns |>
      dplyr::filter(!is.na(comment)) |>
      dplyr::pull(column)

    has_columns_with_comment <- length(source_columns_with_comment) > 0
    if (!has_columns_with_comment) {
      stop("source_columns should have at least one column with a comment")
    }

    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)
    column_metadata <- adam_metadata$ADAE$columns

    all_matching_columns_have_comment <- column_metadata |>
      purrr::keep(\(x) x$id %in% source_columns_with_comment) |>
      purrr::every(\(x) "comment" %in% names(x))

    expect_true(all_matching_columns_have_comment)
  })

  it("builds ADaM metadata including 'comment' field at parameter level", {
    metadata <- load_test_metadata_components(
      table_filter = table == "ADLB",
      column_filter = table == "ADLB",
      value_filter = table == "ADLB"
    )

    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)
    parameter_metadata <- adam_metadata$ADLB$parameters

    all_parameters_have_comment <- parameter_metadata |>
      purrr::every(\(parameter) purrr::every(parameter$columns, \(column) "comment" %in% names(column)))

    expect_true(all_parameters_have_comment)
  })
})
