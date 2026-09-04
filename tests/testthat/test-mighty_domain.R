#' Concise valid domain specification for in-memory construction
#' @noRd
minimal_domain_data <- function() {
  list(
    id = "ADVS",
    label = "Vital Signs Analysis Dataset",
    class = "BASIC DATA STRUCTURE",
    structure = "One record per vital sign parameter, per visit, per subject",
    keys = c("USUBJID", "PARAMCD"),
    columns = list(
      list(
        id = "USUBJID",
        label = "Unique Subject Identifier",
        method = "VS.USUBJID"
      ),
      list(id = "PARAMCD", label = "Parameter Code", method = "rows.PARAMCD")
    )
  )
}

test_that("mighty_domain works", {
  x <- mighty_domain(
    file = system.file("examples", "advs.yml", package = "mighty.metadata")
  ) |>
    expect_no_condition()

  print(x) |>
    expect_snapshot(
      transform = \(x) {
        # Inconsistency between S7 versions
        sub(
          pattern = "<mighty.metadata::mighty_domain>",
          replacement = "<mighty_domain>",
          x = x
        )
      }
    )
})

test_that("mighty_domain works with in-memory data", {
  x <- mighty_domain(.data = minimal_domain_data())

  expect_true(S7::S7_inherits(x, mighty_domain))
  expect_equal(x$id, "ADVS")
  expect_equal(length(x$columns), 2L)
  expect_null(x@file)
})

test_that("mighty_domain errors on duplicate column ids", {
  data <- minimal_domain_data()
  data$columns[[2]]$id <- "USUBJID"

  expect_error(mighty_domain(.data = data), regexp = "Duplicate")
})

test_that("mighty_domain errors on column-to-column depends", {
  data <- minimal_domain_data()
  data$columns[[2]]$depends <- "USUBJID"

  expect_error(mighty_domain(.data = data), regexp = "Column dependencies")
})
