test_that("create_md_values()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse()

  mdvalues <- study |>
    create_md_values() |>
    expect_no_condition() |>
    expect_s3_class("tbl_df")

  expect_equal(
    object = names(mdvalues),
    expected = c(
      "table_id",
      "table_label",
      "param_order",
      "param_id",
      "param_label",
      "order",
      "id",
      "label",
      "origin",
      "method",
      "codelist",
      "format_type",
      "format_length",
      "format_display",
      "comment"
    )
  )

  expect_snapshot_value(mdvalues, "json2")
})

test_that("create_md_values() on domains without value level metadata", {
  adsl <- test_path("test_study", "adsl.yml") |>
    mighty_domain() |>
    create_md_values()

  expect_equal(object = nrow(adsl), expected = 0L)

  advs <- test_path("test_study", "advs.yml") |>
    mighty_domain()

  advs[["parameters"]] <- c(
    advs[["parameters"]],
    # A parameter without columns contributes no rows
    list(list(id = "NOCOLS")),
    # A parameter without a label gives a missing param_label
    list(list(id = "NOLABEL", columns = list(list(id = "AVAL"))))
  )

  mdvalues <- advs |>
    validate() |>
    create_md_values()

  expect_equal(object = names(mdvalues), expected = names(adsl))
  expect_equal(object = mdvalues[["param_id"]], expected = c("BMI", "NOLABEL"))
  expect_equal(object = mdvalues[["param_order"]], expected = c(1L, 3L))
  expect_equal(
    object = mdvalues[["param_label"]],
    expected = c("Body Mass Index (kg/m^2)", NA_character_)
  )
})
