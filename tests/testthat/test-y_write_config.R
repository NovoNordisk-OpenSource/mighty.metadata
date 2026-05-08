test_that("multiplication works", {
  study <- test_path("test_study") |>
    mighty_study()

  tmpdir <- withr::local_tempdir()

  write_config(x = study, path = tmpdir) |>
    expect_no_error()

  list.files(tmpdir) |>
    expect_snapshot()
})
