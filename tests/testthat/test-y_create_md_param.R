test_that("create_md_param()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse()

  mdparam <- study |>
    create_md_param() |>
    expect_no_condition() |>
    expect_s3_class("tbl_df")

  expect_equal(
    object = names(mdparam),
    expected = c(
      "table_id",
      "table_label",
      "order",
      "id",
      "label"
    )
  )

  expect_snapshot_value(mdparam, "json2")
})

test_that("create_md_param() on domains with and without parameters", {
  advs <- test_path("test_study", "advs.yml") |>
    mighty_domain() |>
    create_md_param()

  expect_equal(object = advs[["id"]], expected = "BMI")
  expect_equal(object = advs[["table_id"]], expected = "ADVS")
  expect_equal(object = advs[["order"]], expected = 1L)

  adsl <- test_path("test_study", "adsl.yml") |>
    mighty_domain() |>
    create_md_param()

  expect_equal(object = nrow(adsl), expected = 0L)
  expect_equal(object = names(adsl), expected = names(advs))
})
