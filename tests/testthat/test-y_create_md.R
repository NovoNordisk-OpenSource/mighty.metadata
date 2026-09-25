test_that("create_md()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse()

  md <- study |>
    create_md() |>
    expect_no_condition() |>
    expect_type("list")

  expect_equal(
    object = names(md),
    expected = c("mdtable", "mdcol", "mdparam", "mdvalues")
  )

  expect_equal(object = md[["mdtable"]], expected = create_md_table(study))
  expect_equal(object = md[["mdcol"]], expected = create_md_col(study))
  expect_equal(object = md[["mdparam"]], expected = create_md_param(study))
  expect_equal(object = md[["mdvalues"]], expected = create_md_values(study))
})

test_that("create_md() on a single domain", {
  domain <- test_path("test_study", "advs.yml") |>
    mighty_domain()

  md <- domain |>
    create_md() |>
    expect_no_condition()

  expect_equal(
    object = names(md),
    expected = c("mdtable", "mdcol", "mdparam", "mdvalues")
  )

  lapply(X = md, FUN = expect_s3_class, class = "tbl_df")

  expect_equal(object = md[["mdtable"]][["id"]], expected = "ADVS")
  expect_true(object = all(md[["mdcol"]][["table_id"]] == "ADVS"))
})
