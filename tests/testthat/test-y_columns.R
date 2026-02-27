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

  select_column(y, "NEW") |>
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

  select_column(x, "NEW")[["label"]] |>
    expect_equal("test")
})

test_that("update_column() updates existing properties", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  original_label <- x[["columns"]][[1]][["label"]]

  y <- x |>
    update_column(id = "STUDYID", label = "Updated Label")

  select_column(y, "STUDYID")[["label"]] |>
    expect_equal("Updated Label")

  list_columns(y)[[1]] |>
    expect_equal("STUDYID")
})

test_that("update_column() adds new properties", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  y <- x |>
    update_column(id = "STUDYID", method = "New method value")

  select_column(y, "STUDYID")[["method"]] |>
    expect_equal("New method value")
})

test_that("update_column() preserves position", {
  x <- mighty_metadata(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  original_columns <- list_columns(x)

  y <- x |>
    update_column(id = "USUBJID", label = "Updated USUBJID")

  list_columns(y) |>
    expect_equal(original_columns)
})
