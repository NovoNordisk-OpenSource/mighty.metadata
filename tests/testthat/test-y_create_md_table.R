test_that("create_md_table()", {
  study <- test_path("test_study") |>
    mighty_study() |>
    populate_core() |>
    populate_sparse()

  mdtable <- study |>
    create_md_table() |>
    expect_no_condition() |>
    expect_s3_class("tbl_df")

  expect_equal(
    object = names(mdtable),
    expected = c(
      "order",
      "id",
      "label",
      "class",
      "subclass",
      "structure",
      "keys",
      "comment"
    )
  )

  expect_equal(object = nrow(mdtable), expected = length(study))
  expect_equal(object = mdtable[["order"]], expected = seq_len(nrow(mdtable)))
  expect_type(object = mdtable[["keys"]], type = "list")

  expect_snapshot_value(mdtable, "json2")
})

test_that("create_md_table() on a single domain", {
  domain <- test_path("test_study", "advs.yml") |>
    mighty_domain()

  mdtable <- domain |>
    create_md_table() |>
    expect_no_condition()

  expect_equal(object = nrow(mdtable), expected = 1L)
  expect_equal(object = mdtable[["id"]], expected = "ADVS")
  expect_equal(object = mdtable[["order"]], expected = 1L)
  expect_equal(
    object = mdtable[["keys"]][[1]],
    expected = c("USUBJID", "PARAMCD", "AVISITN")
  )
  expect_equal(object = mdtable[["subclass"]], expected = NA_character_)
  expect_equal(object = mdtable[["comment"]], expected = NA_character_)
})
