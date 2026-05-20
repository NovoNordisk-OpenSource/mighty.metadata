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

test_that("construct_mighty_domain() - invalid file in specifications dir", {
  expect_error(
    mighty_domain(
      file = "test_study/empty.yml"
    ),
    regexp = "File could not be loaded correctly:.*empty\\.yml.*test_study",
    fixed = FALSE
  )
})
