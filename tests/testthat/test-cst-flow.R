describe("CST - yaml - mdcol - workflow", {
  output_dir <- withr::local_tempdir()

  it("Writes to YAML files", {
    metadata <- load_test_metadata_components()
    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      all_yaml <- lapply(names(adam_metadata), function(domain) {
        write_adam_domain_yaml(
          domain_data = adam_metadata[[domain]],
          domain_name = domain,
          output_dir = output_dir
        )
      })
    })

    # Test that the yaml's live up to the mighty.metadata schema
    expect_no_error({
      lapply(all_yaml, mighty_metadata)
    })

    list.files(output_dir) |>
      cat(sep = "\n") |>
      expect_snapshot()
  })

  it("Builds mdcol", {
    study <- mighty_study(output_dir)

    # Populate internal references
    expect_no_error({
      updated_metadata_internal <- study |> populate_sparse()
    })

    # Produce mdcol
    expect_no_error({
      mdcol <- updated_metadata_internal |> create_md_col()
    })

    # Test shape of mdcol
    expect_equal(dim(mdcol), c(1605, 14))

    # Test names of mdcol
    expect_equal(
      names(mdcol),
      c(
        "table_id",
        "table_label",
        "order",
        "id",
        "label",
        "origin",
        "key",
        "is_core",
        "core",
        "method",
        "codelist",
        "format_type",
        "format_length",
        "format_display"
      )
    )

    # Test number of records for each table within mdcol
    res <- dplyr::count(mdcol, table_id)
    paste(res$table_id, res$n, sep = " - ") |>
      cat(sep = "\n") |>
      expect_snapshot()
  })

  it("Runs entire flow with core variables", {
    output_dir <- withr::local_tempdir()

    metadata <- load_test_metadata_components(usecore = TRUE)
    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      all_yaml <- lapply(names(adam_metadata), function(domain) {
        write_adam_domain_yaml(
          domain_data = adam_metadata[[domain]],
          domain_name = domain,
          output_dir = output_dir
        )
      })
    })

    # Test that the yaml's live up to the mighty.metadata schema
    expect_no_error({
      lapply(all_yaml, mighty_metadata)
    })

    # Load as mighty_study and populate core variables
    expect_no_error({
      updated_metadata <- mighty_study(output_dir) |> populate_core()
    })

    # Populate internal references
    expect_no_error({
      updated_metadata_internal <- updated_metadata |> populate_sparse()
    })

    # Produce mdcol
    expect_no_error({
      mdcol <- updated_metadata_internal |> create_md_col()
    })

    # Test number of records for each table within mdcol
    res <- dplyr::count(mdcol, table_id)
    paste(res$table_id, res$n, sep = " - ") |>
      cat(sep = "\n") |>
      expect_snapshot()
  })

  it("Runs entire flow with predecessors", {
    output_dir <- withr::local_tempdir()

    metadata <- load_test_metadata_components(usesdtm = TRUE)
    sdtm_columns <- load_test_sdtm_submit_columns()

    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      all_yaml <- lapply(names(adam_metadata), function(domain) {
        write_adam_domain_yaml(
          domain_data = adam_metadata[[domain]],
          domain_name = domain,
          output_dir = output_dir
        )
      })
    })

    # Test that the yaml's live up to the mighty.metadata schema
    expect_no_error({
      lapply(all_yaml, mighty_metadata)
    })

    # Load as mighty_study and populate sparse references
    expect_no_error({
      updated_metadata_internal <- mighty_study(output_dir) |>
        populate_sparse()
    })

    # Produce mdcol
    expect_no_error({
      mdcol <- updated_metadata_internal |> create_md_col()
    })

    # Test number of records for each table within mdcol
    res <- dplyr::count(mdcol, table_id)
    paste(res$table_id, res$n, sep = " - ") |>
      cat(sep = "\n") |>
      expect_snapshot()
  })
})
