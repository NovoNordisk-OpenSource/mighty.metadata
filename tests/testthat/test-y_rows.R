test_that("list_rows()", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  )

  list_rows(x) |>
    expect_type("character") |>
    expect_contains("baseline")
})

test_that("remove_rows()", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  ) |>
    add_row(id = "NEW")

  x |>
    list_rows() |>
    expect_contains("NEW")

  x |>
    remove_rows(id = "NEW") |>
    list_rows() |>
    expect_no_match("NEW")
})

test_that("add_row()", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  )

  x |>
    add_row(
      id = "NEW",
      method = "My new row"
    ) |>
    list_rows() |>
    expect_contains("NEW")

  rows <- x |>
    add_row(
      id = "NEW",
      .pos = 1
    ) |>
    list_rows()

  expect_equal(rows[[1]], "NEW")
})

test_that("move_row()", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  ) |>
    add_row(
      id = "NEW",
      method = "My new row"
    ) |>
    move_row(id = "NEW", .pos = 1)

  list_rows(x)[[1]] |>
    expect_equal("NEW")

  x[["rows"]][[1]][["method"]] |>
    expect_equal("My new row")
})
