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
    expect_error(
      regexp = "Id `d` does not exist"
    )
})

test_that("list_ids", {
  x <- list(
    list(id = "a", value = 1),
    list(id = "b", value = 2),
    list(id = "c", value = 3)
  )

  list_ids(x) |>
    expect_equal(c("a", "b", "c"))

  list_ids(list()) |>
    expect_equal(character(0))
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

  which_ids(list(), "a") |>
    expect_equal(integer(0))
})

test_that("remove_ids()", {
  x <- list(list(id = "a"), list(id = "b"))

  remove_ids(x, character()) |>
    expect_equal(x)

  remove_ids(x, "a") |>
    expect_length(1L)

  remove_ids(x, c("a", "b")) |>
    expect_null()
})

test_that("update_ids()", {
  x <- list(list(id = "a", value = 1), list(id = "b", value = 2))

  update_ids(x, "a", value = 10) |>
    getElement(1) |>
    expect_equal(list(id = "a", value = 10))

  update_ids(x, character(), value = 10) |>
    expect_equal(x)
})

test_that("list_includes()", {
  x <- list(
    list(id = "a", include = "other"),
    list(id = "b", value = 1)
  )

  list_includes(x) |>
    expect_equal("a")

  list_includes(list()) |>
    expect_equal(character(0))
})

test_that("check_unique_ids()", {
  list() |>
    check_unique_ids() |>
    expect_length(0L)

  list(
    list(id = "a", x = 1),
    list(id = "b", x = 1)
  ) |>
    check_unique_ids() |>
    expect_no_condition()

  x <- list(
    id = "a",
    new_list = list(
      list(id = "a", a = 1),
      list(id = "b", b = 1),
      list(id = "a", a = 2)
    ),
    other_list = list(
      sub_list = list(
        list(id = "a"),
        list(id = "b")
      )
    )
  )

  check_unique_ids(x) |>
    expect_error("Duplicate `id` entries found")
})


test_that("check_column_dependencies()", {
  list() |>
    check_column_dependencies() |>
    expect_length(0L)

  list(
    list(id = "a", columns = "STUDYID"),
    list(id = "b", x = "USUBJID")
  ) |>
    check_column_dependencies() |>
    expect_no_condition()

  list(
    id = "XYZ",
    columns = list(
      list(id = "a", depends = "parameters.xyz"),
      list(id = "b", depends = "rows.xyz"),
      list(id = "c")
    )
  ) |> expect_no_condition()


  list(
    id = "XYZ",
    columns = list(
      list(id = "a", depends = c("parameters.xyz", "rows.xyz")),
      list(id = "b"),
      list(id = "c")
    )
  ) |>
    check_column_dependencies() |>
    expect_error(paste0("Detected multiple column dependencies for column: a in the XYZ dataset. ",
                        "Please fix them or remove them."))

  list(
    id = "XYZ",
    columns = list(
      list(id = "a", depends = "parameters.xyz"),
      list(id = "b", depends = ".abc"),
      list(id = "c", depends = "XYZ.abc")
    )
  ) |>
    check_column_dependencies() |>
    expect_error()

})
