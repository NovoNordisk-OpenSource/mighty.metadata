# Shared test helper: count records per table and format for snapshot
snapshot_table_counts <- function(mdcol) {
  res <- dplyr::count(mdcol, table_id)
  paste(res$table_id, res$n, sep = " - ") |>
    cat(sep = "\n")
}

# Shared test helper: write all domains to YAML and validate against schema
write_and_validate_yaml <- function(adam_metadata, output_dir) {
  all_yaml <- lapply(names(adam_metadata), function(domain) {
    path <- file.path(output_dir, paste0(tolower(domain), ".yml"))
    write_safe_yaml(adam_metadata[[domain]], path)
  })
  lapply(all_yaml, mighty_domain)
  invisible(all_yaml)
}

describe("CST - yaml - mdcol - workflow", {
  output_dir <- withr::local_tempdir()

  it("Writes to YAML files", {
    metadata <- load_test_metadata_components()
    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      write_and_validate_yaml(adam_metadata, output_dir)
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
    expect_equal(dim(mdcol), c(1605, 15))

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
        "format_display",
        "comment"
      )
    )

    snapshot_table_counts(mdcol) |> expect_snapshot()
  })

  it("Runs entire flow with core variables", {
    output_dir <- withr::local_tempdir()

    metadata <- load_test_metadata_components(usecore = TRUE)
    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      write_and_validate_yaml(adam_metadata, output_dir)
    })

    mdcol <- mighty_study(output_dir) |>
      populate_core() |>
      populate_sparse() |>
      create_md_col() |>
      expect_no_error()

    snapshot_table_counts(mdcol) |> expect_snapshot()
  })

  it("Runs entire flow with predecessors", {
    output_dir <- withr::local_tempdir()

    metadata <- load_test_metadata_components(usesdtm = TRUE)
    adam_metadata <- build_adam_metadata(metadata, verbose = FALSE)

    expect_no_error({
      write_and_validate_yaml(adam_metadata, output_dir)
    })

    mdcol <- mighty_study(output_dir) |>
      populate_sparse() |>
      create_md_col() |>
      expect_no_error()

    snapshot_table_counts(mdcol) |> expect_snapshot()
  })
})
