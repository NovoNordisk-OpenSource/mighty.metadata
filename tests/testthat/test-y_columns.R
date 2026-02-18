test_that("list_columns()", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  list_columns(x) |>
    expect_type("character") |>
    expect_contains("USUBJID")
})

test_that("remove_columns()", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  x |>
    remove_columns(id = "USUBJID") |>
    list_columns() |>
    expect_no_match("USUBJID")

  x |>
    remove_columns(id = c("STUDYID", "USUBJID")) |>
    list_columns() |>
    expect_no_match("STUDYID|USUBJID")
})

test_that("add_column()", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  x |>
    add_column(id = "NEW") |>
    list_columns() |>
    expect_contains("NEW")

  columns <- x |>
    add_column(id = "NEW", .pos = 3) |>
    list_columns()

  expect_equal(columns[[3]], "NEW")

  y <- x |>
    add_column(id = "NEW", label = "My new column") |>
    expect_no_condition()

  y[["columns"]][[length(y[["columns"]])]] |>
    expect_equal(
      list(id = "NEW", label = "My new column")
    )
})

test_that("move_column()", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  ) |>
    add_column(id = "NEW", label = "test") |>
    move_column(id = "NEW", .pos = 7)

  list_columns(x)[[7]] |>
    expect_equal("NEW")

  x[["columns"]][[7]][["label"]] |>
    expect_equal("test")
})
