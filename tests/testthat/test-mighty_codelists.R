test_that("mighty_codelists() reads _codelists.yml", {
  cl <- mighty_codelists(file = test_path("test_codelists/_codelists.yml"))
  expect_s7_class(cl, mighty_codelists)
  expect_identical(
    list_codelists(cl),
    c("REGION", "AGEU", "LOC")
  )
})

test_that("mighty_codelists() without input is empty", {
  expect_length(mighty_codelists(), 0)
})

test_that("schema requires id", {
  expect_error(
    new_cl(list(label = "x", subset = list(list(code = "A")))),
    "required property 'id'"
  )
})

test_that("schema accepts any string id", {
  expect_no_error(new_cl(list(id = "CL.AGEU", subset = list(list(code = "X")))))
})

test_that("schema requires at least one operation group", {
  # anyOf reports only its first branch, hence the `values` message
  expect_error(new_cl(list(id = "A")), "missingProperty: values")
})

test_that("schema accepts each operation group on its own", {
  expect_no_error(new_cl(list(
    id = "A",
    label = "a",
    description = "a",
    datatype = "text",
    values = list(list(code = "X"))
  )))
  expect_no_error(new_cl(list(id = "A", subset = list(list(code = "X")))))
  expect_no_error(new_cl(list(id = "A", restore = list(list(code = "X")))))
  expect_no_error(new_cl(list(id = "A", extend = list(list(code = "X")))))
})

test_that("schema rejects an empty operation group", {
  expect_error(
    new_cl(list(id = "A", subset = list())),
    "must NOT have fewer than 1 items"
  )
})

test_that("schema requires label, description and datatype for values", {
  base <- list(
    id = "A",
    label = "a",
    description = "a",
    datatype = "text",
    values = list(list(code = "X"))
  )
  for (field in c("label", "description", "datatype")) {
    cl <- base
    cl[[field]] <- NULL
    expect_error(new_cl(cl), paste0("required property '", field, "'"))
  }
})

test_that("schema restricts datatype to text, integer, float", {
  expect_error(
    new_cl(list(
      id = "A",
      label = "a",
      description = "a",
      datatype = "date",
      values = list(list(code = "X"))
    )),
    "must be equal to one of the allowed values"
  )
})

test_that("schema requires code in operation group entries", {
  expect_error(
    new_cl(list(id = "A", extend = list(list(decode = "x")))),
    "required property 'code'"
  )
})

test_that("schema rejects decode in subset/restore", {
  expect_error(
    new_cl(list(id = "A", subset = list(list(code = "X", decode = "x")))),
    "additionalProperty: decode"
  )
  expect_error(
    new_cl(list(id = "A", restore = list(list(code = "X", decode = "x")))),
    "additionalProperty: decode"
  )
})

test_that("schema rejects unknown codelist fields", {
  expect_error(
    new_cl(list(id = "A", other = 1, subset = list(list(code = "X")))),
    "additionalProperty: other"
  )
})

test_that("subset can be combined with restore", {
  expect_no_error(new_cl(list(
    id = "A",
    subset = list(list(code = "X")),
    restore = list(list(code = "Y"))
  )))
})

test_that("values can be combined with extend", {
  expect_no_error(new_cl(list(
    id = "B",
    label = "b",
    description = "b",
    datatype = "float",
    values = list(list(code = 1.5)),
    extend = list(list(code = 2.5))
  )))
})

test_that("validate_mighty_codelists() detects duplicate ids", {
  expect_snapshot(
    new_cl(
      list(id = "A", subset = list(list(code = "X"))),
      list(id = "A", restore = list(list(code = "Y")))
    ),
    error = TRUE
  )
})

test_that("validate_mighty_codelists() detects duplicate codes across groups", {
  expect_snapshot(
    new_cl(list(
      id = "A",
      subset = list(list(code = "X")),
      restore = list(list(code = "X"))
    )),
    error = TRUE
  )
})

test_that("validate_mighty_codelists() detects duplicate codes within a group", {
  expect_error(
    new_cl(list(id = "A", subset = list(list(code = "X"), list(code = "X")))),
    "Duplicate code values in codelist"
  )
})

test_that("validate_mighty_codelists() rejects values combined with subset", {
  expect_snapshot(
    new_cl(list(
      id = "A",
      label = "a",
      description = "a",
      datatype = "text",
      values = list(list(code = "X")),
      subset = list(list(code = "Y"))
    )),
    error = TRUE
  )
})

test_that("validate_mighty_codelists() rejects values combined with restore", {
  expect_snapshot(
    new_cl(list(
      id = "A",
      label = "a",
      description = "a",
      datatype = "text",
      values = list(list(code = "X")),
      restore = list(list(code = "Y"))
    )),
    error = TRUE
  )
})

test_that("validate_mighty_codelists() rejects mixed decodes in extend", {
  expect_snapshot(
    new_cl(list(
      id = "A",
      extend = list(list(code = "X", decode = "x"), list(code = "Y"))
    )),
    error = TRUE
  )
})

test_that("validate_mighty_codelists() rejects mixed decodes in values", {
  expect_snapshot(
    new_cl(list(
      id = "A",
      label = "a",
      description = "a",
      datatype = "text",
      values = list(list(code = "X"), list(code = "Y", decode = "y"))
    )),
    error = TRUE
  )
})

test_that("mighty_codelists print() summarizes codelists", {
  cl <- mighty_codelists(file = test_path("test_codelists/_codelists.yml"))
  print(cl) |>
    expect_snapshot(
      transform = \(x) {
        sub("<mighty.metadata::mighty_codelists>", "<mighty_codelists>", x)
      }
    )
})
