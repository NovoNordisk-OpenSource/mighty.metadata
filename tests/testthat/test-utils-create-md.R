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

  # A data frame without rows returns the template itself
  expect_equal(
    object = apply_template(tibble::tibble(), template),
    expected = template
  )

  expect_equal(
    object = apply_template(tibble::tibble(a = character()), template),
    expected = template
  )

  # A metadata entry is turned into a single row
  expect_equal(
    object = apply_template(list(a = "x", d = "drop me"), template),
    expected = tibble::tibble(a = "x", b = NA_integer_)
  )
})

test_that("new_md_row()", {
  template <- tibble::tibble(
    id = character(),
    keys = list(),
    format_type = character(),
    format_length = integer()
  )

  # Nested entries are flattened, list columns wrapped, the rest dropped
  entry <- list(
    id = "ADVS",
    keys = list("USUBJID", "PARAMCD"),
    format = list(type = "C", length = 8L),
    columns = list(list(id = "AVAL"))
  )

  row <- new_md_row(entry, template)

  expect_equal(object = nrow(row), expected = 1L)

  # Column order is left to apply_template()
  expect_setequal(object = names(row), expected = names(template))
  expect_equal(object = row[["keys"]][[1]], expected = c("USUBJID", "PARAMCD"))
  expect_equal(object = row[["format_type"]], expected = "C")
  expect_equal(object = row[["format_length"]], expected = 8L)
})

test_that("wrap_list_entries()", {
  expect_equal(
    object = wrap_list_entries(list(keys = list("A", "B"), other = "C")),
    expected = list(keys = list(c("A", "B")), other = list("C"))
  )

  expect_equal(object = wrap_list_entries(list()), expected = list())
})
