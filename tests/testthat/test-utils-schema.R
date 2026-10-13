test_that("construct_s7schema() returns empty object when neither file nor .data is supplied", {
  x <- construct_s7schema(schema_name = "codelists.json")
  expect_s7_class(x, S7schema::S7schema)
  expect_length(x, 0)
})

test_that("construct_s7schema() returns populated object when .data is supplied", {
  x <- construct_s7schema(
    .data = list(list(id = "AGEU", subset = list(list(code = "YEARS")))),
    schema_name = "codelists.json"
  )
  expect_s7_class(x, S7schema::S7schema)
  expect_length(x, 1)
  expect_identical(x[[1]]$id, "AGEU")
})

test_that("construct_s7schema() returns populated object when file is supplied", {
  x <- construct_s7schema(
    file = test_path("test_study/_codelists.yml"),
    schema_name = "codelists.json"
  )
  expect_s7_class(x, S7schema::S7schema)
  expect_identical(list_ids(S7::S7_data(x)), c("REGION", "AGEU", "LOC"))
})

test_that("construct_s7schema() uses the requested schema from inst/schema", {
  codelists <- construct_s7schema(schema_name = "codelists.json")
  documents <- construct_s7schema(schema_name = "documents.json")
  expect_identical(basename(attr(codelists, "schema")), "codelists.json")
  expect_identical(basename(attr(documents, "schema")), "documents.json")
})

test_that("construct_s7schema() errors when data does not match the schema", {
  expect_error(
    construct_s7schema(
      .data = list(list(id = "A")),
      schema_name = "documents.json"
    ),
    "required property"
  )
})

test_that("construct_s7schema() errors when both file and .data are supplied", {
  expect_error(
    construct_s7schema(
      file = test_path("test_study/_codelists.yml"),
      .data = list(),
      schema_name = "codelists.json"
    ),
    "Exactly one of `file` or `.data`"
  )
})
