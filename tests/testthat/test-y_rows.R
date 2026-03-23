test_that("list_rows()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  list_rows(x) |>
    expect_type("character") |>
    expect_contains("BASELINE")
})

test_that("remove_rows()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
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
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
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
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  ) |>
    add_row(
      id = "NEW",
      method = "My new row"
    ) |>
    move_row(id = "NEW", .pos = 1)

  list_rows(x)[[1]] |>
    expect_equal("NEW")

  select_row(x, "NEW")[["method"]] |>
    expect_equal("My new row")
})

test_that("update_row() updates existing properties", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  y <- x |>
    update_row(id = "BASELINE", method = "Updated method")

  select_row(y, "BASELINE")[["method"]] |>
    expect_equal("Updated method")
})

test_that("update_row() adds new properties", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  y <- x |>
    update_row(id = "BASELINE", depends = "USUBJID")

  select_row(y, "BASELINE")[["depends"]] |>
    expect_equal("USUBJID")
})

test_that("select_row()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  row <- select_row(x, id = "BASELINE")
  expect_type(row, "list")
  expect_equal(row[["id"]], "BASELINE")
})
