test_that("insert_in_vector()", {
  insert_in_vector(x = 1:3, y = 4) |>
    expect_equal(1:4)

  insert_in_vector(x = 1:3, y = 4, pos = 2) |>
    expect_equal(c(1, 4, 2, 3))

  insert_in_vector(x = 1:3, y = 4, pos = 6) |>
    expect_equal(c(1:3, NA, NA, 4))

  insert_in_vector(x = 1:3, y = 4, pos = 0) |>
    expect_error()

  insert_in_vector(x = 1:3, y = 4:5, pos = 0) |>
    expect_error()
})

test_that("get_id()", {
  x <- list(
    list(id = "a", value = 1),
    list(id = "b", value = 2),
    list(id = "c", value = 3)
  )

  get_id(x, "b") |>
    expect_equal(list(id = "b", value = 2))

  get_id(x, "d") |>
    expect_error()
})

test_that("list_ids", {
  x <- list(
    list(id = "a", value = 1),
    list(id = "b", value = 2),
    list(id = "c", value = 3)
  )

  list_ids(x) |>
    expect_equal(c("a", "b", "c"))
})

test_that("which_ids", {
  x <- list(
    list(id = "a", value = 1),
    list(id = "b", value = 2),
    list(id = "c", value = 3)
  )

  which_ids(x, "a") |>
    expect_equal(1L)

  which_ids(x, c("b", "c")) |>
    expect_equal(2:3)
})
