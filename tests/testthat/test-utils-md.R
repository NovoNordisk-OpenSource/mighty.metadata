test_that("bind_domains()", {
  study <- test_path("test_study") |>
    mighty_study()

  fun <- \(domain) tibble::tibble(id = domain[["id"]], order = 1L)

  bound <- bind_domains(study, fun)

  expect_s3_class(object = bound, class = "tbl_df")
  expect_equal(object = nrow(bound), expected = length(study))
  expect_equal(
    object = bound[["id"]],
    expected = vapply(study, \(x) x[["id"]], character(1), USE.NAMES = FALSE)
  )

  # order is left untouched unless requested
  expect_equal(object = bound[["order"]], expected = rep(1L, nrow(bound)))

  expect_equal(
    object = bind_domains(study, fun, order = TRUE)[["order"]],
    expected = seq_along(study)
  )
})

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
