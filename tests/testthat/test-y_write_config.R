test_that("write_config() writes study to directory", {
  study <- test_path("test_study") |>
    mighty_study()

  tmpdir <- withr::local_tempdir()

  write_config(x = study, path = tmpdir) |>
    expect_no_error()

  list.files(tmpdir) |>
    expect_snapshot()
})

test_that("write_config() uses study@path when path is NULL", {
  tmpdir <- withr::local_tempdir()

  file.copy(list.files(test_path("test_study"), full.names = TRUE), tmpdir)

  study <- mighty_study(path = tmpdir)

  write_config(x = study) |>
    expect_no_error()

  expected <- c("_mighty.yml", "_study.yml", "adae.yml", "adsl.yml", "advs.yml")
  expect_true(all(file.exists(file.path(tmpdir, expected))))
})

test_that("write_config() roundtrips study correctly", {
  study <- test_path("test_study") |> mighty_study()
  tmpdir <- withr::local_tempdir()

  write_config(x = study, path = tmpdir)
  roundtrip <- mighty_study(path = tmpdir)

  expect_equal(roundtrip@study, study@study)
  expect_equal(roundtrip@mighty, study@mighty)
  expect_equal(names(roundtrip), names(study))
})

test_that("write_config() skips empty _mighty and _study files", {
  study <- test_path("test_study") |> mighty_study()
  tmpdir <- withr::local_tempdir()

  study@mighty <- list()
  study@study <- list()

  write_config(x = study, path = tmpdir)

  files <- list.files(tmpdir)
  expect_false("_mighty.yml" %in% files)
  expect_false("_study.yml" %in% files)
})
