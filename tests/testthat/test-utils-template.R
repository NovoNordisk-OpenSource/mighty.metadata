test_that("apply_template()", {
  template <- tibble::tibble(a = character(), b = integer())

  # Missing columns are added with the type from the template
  expect_equal(
    object = apply_template(tibble::tibble(a = "x"), template),
    expected = tibble::tibble(a = "x", b = NA_integer_)
  )

  # Extra columns are dropped and the template order is enforced
  expect_equal(
    object = apply_template(
      tibble::tibble(c = TRUE, b = 1L, a = "x"),
      template
    ),
    expected = tibble::tibble(a = "x", b = 1L)
  )

  # An empty data frame returns the template itself
  expect_equal(
    object = apply_template(tibble::tibble(), template),
    expected = template
  )
})
