test_that("mighty_metadata works", {
  x <- mighty_metadata(
    file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
  ) |>
    expect_no_condition()

  print(x) |>
    expect_snapshot(
      transform = \(x) {
        # Inconsistency between S7 versions
        sub(
          pattern = "<mighty.metadata::mighty_metadata>",
          replacement = "<mighty_metadata>",
          x = x
        )
      }
    )
})
