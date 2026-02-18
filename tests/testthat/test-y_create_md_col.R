test_that("create_md_col()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse()

  mdcol <- study |>
    create_md_col() |>
    expect_no_condition() |>
    expect_s3_class("tbl_df")

  expect_equal(
    object = names(mdcol),
    expected = c(
      "table_id",
      "table_label",
      "order",
      "id",
      "label",
      "origin",
      "key",
      "core",
      "method",
      "codelist",
      "format_type",
      "format_length",
      "format_display"
    )
  )

  expect_snapshot_value(mdcol, "json2")
})
