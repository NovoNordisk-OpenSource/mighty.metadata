test_that("list_parameters()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  list_parameters(x) |>
    expect_type("character") |>
    expect_contains("BMI")
})

test_that("remove_parameters()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  x |>
    remove_parameters(id = "BMI") |>
    list_parameters() |>
    expect_no_match("^BMI$")

  x |>
    remove_parameters(id = c("BMI", "BMIGRP")) |>
    list_parameters() |>
    expect_length(0)
})

test_that("add_parameter()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  x |>
    add_parameter(
      id = "NEW",
      label = "My new parameter",
      columns = list(
        list(
          id = "AVAL"
        )
      )
    ) |>
    list_parameters() |>
    expect_contains("NEW")

  parameters <- x |>
    add_parameter(
      id = "NEW",
      label = "My new parameter",
      columns = list(
        list(
          id = "AVAL"
        )
      ),
      .pos = 2
    ) |>
    list_parameters()

  expect_equal(parameters[[2]], "NEW")
})

test_that("move_parameter()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  ) |>
    add_parameter(
      id = "NEW",
      label = "My new parameter",
      columns = list(
        list(
          id = "AVAL"
        )
      )
    ) |>
    move_parameter(id = "NEW", .pos = 1)

  list_parameters(x)[[1]] |>
    expect_equal("NEW")

  select_parameter(x, "NEW")[["label"]] |>
    expect_equal("My new parameter")
})

test_that("update_parameter() updates existing properties", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  y <- x |>
    update_parameter(id = "BMI", label = "Updated BMI Label")

  select_parameter(y, "BMI")[["label"]] |>
    expect_equal("Updated BMI Label")
})

test_that("update_parameter() updates columns property", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  new_columns <- list(list(id = "AVAL", label = "New AVAL"))

  y <- x |>
    update_parameter(id = "BMI", columns = new_columns)

  select_parameter(y, "BMI")[["columns"]] |>
    expect_equal(new_columns)
})

test_that("select_parameter()", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  )

  parameter <- select_parameter(x, id = "BMI")
  expect_type(parameter, "list")
  expect_equal(parameter[["id"]], "BMI")
})
