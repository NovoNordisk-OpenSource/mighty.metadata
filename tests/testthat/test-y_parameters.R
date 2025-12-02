test_that("list_parameters()", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  )

  list_parameters(x) |>
    expect_type("character") |>
    expect_contains("BMI")
})

test_that("remove_parameters()", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
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
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
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
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
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

  x[["parameters"]][[1]][["label"]] |>
    expect_equal("My new parameter")
})
