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
