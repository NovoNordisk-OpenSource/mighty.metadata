test_that("bind_entries()", {
  study <- test_path("test_study") |>
    mighty_study()

  fun <- \(domain) tibble::tibble(id = domain[["id"]], order = 1L)

  bound <- bind_entries(study, fun)

  expect_s3_class(object = bound, class = "tbl_df")
  expect_equal(object = nrow(bound), expected = length(study))
  expect_equal(
    object = bound[["id"]],
    expected = vapply(study, \(x) x[["id"]], character(1), USE.NAMES = FALSE)
  )

  # order is left untouched unless requested
  expect_equal(object = bound[["order"]], expected = rep(1L, nrow(bound)))

  expect_equal(
    object = bind_entries(study, fun, order = TRUE)[["order"]],
    expected = seq_along(study)
  )
})

test_that("bind_entries() passes arguments on to fun", {
  template <- tibble::tibble(a = character(), order = integer())

  bound <- bind_entries(
    x = list(list(a = "x"), list(a = "y")),
    fun = apply_template,
    template = template,
    order = TRUE
  )

  expect_equal(object = bound[["a"]], expected = c("x", "y"))
  expect_equal(object = bound[["order"]], expected = c(1L, 2L))
})

test_that("bind_entries() drops entries that fun returns NULL for", {
  bound <- bind_entries(
    x = c("x", NA, "y"),
    fun = \(a) if (is.na(a)) NULL else tibble::tibble(a = a),
    order = TRUE
  )

  expect_equal(object = bound[["a"]], expected = c("x", "y"))
  expect_equal(object = bound[["order"]], expected = c(1L, 2L))
})

test_that("copy_columns()", {
  y <- tibble::tibble(id = "ADVS", label = "Vital Signs", keys = list("A"))

  copied <- copy_columns(
    x = tibble::tibble(id = c("AVAL", "AVALC")),
    y = y,
    cols = c("id", "label"),
    prefix = "table_"
  )

  expect_equal(
    object = copied,
    expected = tibble::tibble(
      id = c("AVAL", "AVALC"),
      table_id = c("ADVS", "ADVS"),
      table_label = c("Vital Signs", "Vital Signs")
    )
  )

  # Without a prefix the name is kept, overwriting any column already in x
  expect_equal(
    object = copy_columns(
      x = tibble::tibble(id = "AVAL", label = NA_character_),
      y = y,
      cols = "label",
      prefix = ""
    ),
    expected = tibble::tibble(id = "AVAL", label = "Vital Signs")
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
