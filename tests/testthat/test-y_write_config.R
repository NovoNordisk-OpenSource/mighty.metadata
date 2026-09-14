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

  expected <- c(
    "_mighty.yml",
    "_study.yml",
    "_documents.yml",
    "adae.yml",
    "adsl.yml",
    "advs.yml"
  )
  expect_true(all(file.exists(file.path(tmpdir, expected))))
})

test_that("write_config() roundtrip is consistent", {
  study <- test_path("test_study") |> mighty_study()
  tmpdir <- withr::local_tempdir()

  write_config(x = study, path = tmpdir)
  roundtrip <- mighty_study(path = tmpdir)

  expect_equal(S7::S7_data(roundtrip@study), S7::S7_data(study@study))
  expect_equal(roundtrip@mighty$external_data, study@mighty$external_data)
  expect_equal(names(roundtrip), names(study))
})

test_that("write_mighty_study() preserves standards and terminology", {
  source <- withr::local_tempdir()
  file.copy(list.files(test_path("test_study"), full.names = TRUE), source)

  writeLines(
    c(
      "study_id: test_study",
      "standards:",
      "  - id: ADaM-IG",
      "    version: 1.1",
      "terminology:",
      "  - id: MedDRA",
      "    version: 22.1",
      "  - id: WHODrug",
      "    version: 2023 JAN"
    ),
    file.path(source, "_study.yml")
  )

  study <- mighty_study(path = source)
  target <- withr::local_tempdir()
  write_mighty_study(study, path = target)

  roundtrip <- mighty_study(path = target)

  expect_equal(roundtrip@study$standards, study@study$standards)
  expect_equal(roundtrip@study$terminology, study@study$terminology)
})

test_that("write_mighty_study() preserves empty standards and terminology", {
  source <- withr::local_tempdir()
  file.copy(list.files(test_path("test_study"), full.names = TRUE), source)

  writeLines(
    c("study_id: test_study", "standards: []", "terminology: []"),
    file.path(source, "_study.yml")
  )

  study <- mighty_study(path = source) |> expect_no_error()
  target <- withr::local_tempdir()
  write_mighty_study(study, path = target)

  roundtrip <- mighty_study(path = target)

  expect_length(roundtrip@study$standards, 0)
  expect_length(roundtrip@study$terminology, 0)
})

test_that("write_config() skips missing _mighty and _study files", {
  study <- test_path("test_study") |> mighty_study()
  tmpdir <- withr::local_tempdir()

  study@mighty <- NULL
  study@study <- NULL

  write_config(x = study, path = tmpdir)

  files <- list.files(tmpdir)
  expect_false("_mighty.yml" %in% files)
  expect_false("_study.yml" %in% files)
})
