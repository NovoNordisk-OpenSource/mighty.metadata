describe("CST - yaml - mdcol - workflow", {
  output_dir <- withr::local_tempdir()

  it("Writes to YAML files", {
    metadata <- load_test_metadata_components()
    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      all_yaml <- lapply(names(adam_metadata), function(domain)  {
        write_adam_domain_yaml(
          domain_data = adam_metadata[[domain]],
          domain_name = domain,
          output_dir = output_dir
        )
      })
    })

    # Test that the non-adsl yaml's live up to the mighty.metadata schema
    expect_no_error({
      lapply(all_yaml[-1], mighty_metadata)
    })

    expect_equal(
      list.files(output_dir),
      c("adadj.yaml", "adae.yaml", "adcgm.yaml", "adcgmen.yaml", "adcm.yaml",
        "adec.yaml", "adecen.yaml", "adeg.yaml", "adhypo.yaml", "adhypoen.yaml",
        "adlb.yaml", "admh.yaml", "adpe.yaml", "adqsdpem.yaml", "adqsdtsq.yaml",
        "adqsipq.yaml", "adresp.yaml", "adsl.yaml", "adsmpg.yaml", "adsmpgen.yaml",
        "advs.yaml", "mdcntry.yaml", "mdcol.yaml", "mdflow.yaml", "mdmq.yaml",
        "mdnr.yaml", "mdparam.yaml", "mdsymbol.yaml", "mdunitcv.yaml",
        "mdvisit.yaml")
    )

    # Test that the adsl yaml lives up to the mighty.metadata schema
    skip("Awaiting implementation of updated schema")
    expect_no_error({
      lapply(all_yaml[1], mighty_metadata)
    })

  })

  it("Builds mdcol", {
    expect_no_error({
      mdcol <- make_mdcol_from_yaml(metadata_directory = output_dir)
    })

    # Test shape of mdcol
    expect_equal(dim(mdcol), c(1605, 11))

    # Test names of mdcol
    expect_equal(names(mdcol),
                 c("TABLE", "KEYS", "TLABEL", "COLUMN", "LABEL", "METHOD", "TYPE",
                   "LENGTH", "FORMAT", "CORE", "ORDER"))

    # Test number of record for each table within mdcol
    expect_equal(mdcol |> dplyr::count(TABLE) |> as.list(),
                 list(TABLE = c("ADADJ", "ADAE", "ADCGM", "ADCGMEN", "ADCM", "ADEC",
                                "ADECEN", "ADEG", "ADHYPO", "ADHYPOEN", "ADLB", "ADMH", "ADPE",
                                "ADQSDPEM", "ADQSDTSQ", "ADQSIPQ", "ADRESP", "ADSL", "ADSMPG",
                                "ADSMPGEN", "ADVS", "MDCNTRY", "MDCOL", "MDFLOW", "MDMQ", "MDNR",
                                "MDPARAM", "MDSYMBOL", "MDUNITCV", "MDVISIT"),
                      n = c(76L, 102L, 64L, 54L, 91L, 54L, 56L, 63L, 72L, 49L,
                            83L, 79L, 64L, 77L, 77L, 77L, 49L, 117L, 73L, 56L,
                            74L, 2L, 11L, 8L, 16L, 16L, 19L, 6L, 8L, 12L)))

  })

})
