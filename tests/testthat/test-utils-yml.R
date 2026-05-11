test_that("find_yml() returns validated file path", {
  schema <- system.file("schema", "study.json", package = "mighty.metadata")

  result <- find_yml(
    path = test_path("test_study"),
    name = "_study",
    schema = schema
  )

  expect_type(result, "character")
  expect_length(result, 1)
  expect_true(file.exists(result))
})

test_that("find_yml() returns NULL when no file found", {
  schema <- system.file("schema", "study.json", package = "mighty.metadata")
  tmp <- withr::local_tempdir()

  find_yml(path = tmp, name = "_study", schema = schema) |>
    expect_null()
})

test_that("find_yml() errors on multiple files", {
  schema <- system.file("schema", "study.json", package = "mighty.metadata")
  tmp <- withr::local_tempdir()
  writeLines("study_id: a", file.path(tmp, "_study.yml"))
  writeLines("study_id: b", file.path(tmp, "_study.yaml"))

  expect_error(
    find_yml(path = tmp, name = "_study", schema = schema),
    "Only one `_study` file allowed"
  )
})

test_that("find_yml() errors on invalid YAML", {
  schema <- system.file("schema", "study.json", package = "mighty.metadata")
  tmp <- withr::local_tempdir()
  writeLines("not_study_id: invalid", file.path(tmp, "_study.yml"))

  expect_error(
    find_yml(path = tmp, name = "_study", schema = schema),
    "study_id"
  )
})

test_that("read_yml() returns empty list for NULL", {
  expect_equal(read_yml(file = NULL), list())
})

test_that("read_yml() returns parsed YAML for valid path", {
  file <- test_path("test_study", "_study.yml")

  result <- read_yml(file = file)

  expect_type(result, "list")
  expect_equal(result$study_id, "test_study")
})

test_that("match_yml() returns default .yml path when no file exists", {
  tmp <- withr::local_tempdir()

  match_yml(path = tmp, name = "_study") |>
    expect_equal(file.path(tmp, "_study.yml"))
})

test_that("match_yml() returns matched file when one .yml exists", {
  tmp <- withr::local_tempdir()
  writeLines("study_id: a", file.path(tmp, "_study.yml"))

  match_yml(path = tmp, name = "_study") |>
    expect_equal(file.path(tmp, "_study.yml"))
})

test_that("match_yml() returns matched file when one .yaml exists", {
  tmp <- withr::local_tempdir()
  writeLines("study_id: a", file.path(tmp, "_study.yaml"))

  match_yml(path = tmp, name = "_study") |>
    expect_equal(file.path(tmp, "_study.yaml"))
})

test_that("match_yml() errors on multiple files", {
  tmp <- withr::local_tempdir()
  writeLines("study_id: a", file.path(tmp, "_study.yml"))
  writeLines("study_id: b", file.path(tmp, "_study.yaml"))

  expect_error(
    match_yml(path = tmp, name = "_study"),
    "Only one `_study` file allowed"
  )
})

test_that("write_yml() writes YAML content to new file in empty dir", {
  tmp <- withr::local_tempdir()

  write_yml(x = list(study_id = "test"), path = tmp, name = "_study")

  expect_true(file.exists(file.path(tmp, "_study.yml")))
})

test_that("write_yml() overwrites existing .yaml file", {
  tmp <- withr::local_tempdir()
  writeLines("study_id: old", file.path(tmp, "_study.yaml"))

  write_yml(x = list(study_id = "new"), path = tmp, name = "_study")

  result <- yaml::read_yaml(file.path(tmp, "_study.yaml"))
  expect_equal(result$study_id, "new")
})

test_that("write_yml() returns invisible(x)", {
  tmp <- withr::local_tempdir()
  x <- list(study_id = "test")

  result <- write_yml(x = x, path = tmp, name = "_study")

  expect_equal(result, x)
})
