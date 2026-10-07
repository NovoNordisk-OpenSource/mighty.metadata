new_cl <- function(...) mighty_codelists(.data = list(...))

region <- function(...) {
  list(
    id = "REGION",
    label = "Region",
    description = "Region",
    datatype = "text",
    values = list(...)
  )
}

local_codelist_study <- function(env = parent.frame()) {
  tmpdir <- withr::local_tempdir(.local_envir = env)
  file.copy(test_path("test_study/adae.yml"), tmpdir)
  file.copy(test_path("test_study/_documents.yml"), tmpdir)
  # adae.yml references FANCY_CDISC_CODELIST
  yaml::write_yaml(
    list(list(id = "FANCY_CDISC_CODELIST", subset = list(list(code = "A")))),
    file.path(tmpdir, "_codelists.yml")
  )
  tmpdir
}

codes <- function(cl, group) group_codes(cl[[group]])

test_that("select_codelist() returns entry and errors on unknown id", {
  cl <- new_cl(region(list(code = "EU")))
  expect_equal(select_codelist(cl, "REGION")$label, "Region")
  expect_error(select_codelist(cl, "NOPE"), "does not exist")
})

test_that("define_codelist() adds a codelist with values", {
  cl <- mighty_codelists() |>
    define_codelist(
      id = "NEW",
      label = "New",
      description = "New codelist",
      datatype = "text",
      code = c("A", "B"),
      decode = c("a", "b")
    )
  new <- select_codelist(cl, "NEW")
  expect_equal(codes(new, "values"), c("A", "B"))
  expect_equal(new$values[[2]]$decode, "b")
})

test_that("define_codelist() works without decodes and errors on duplicates", {
  cl <- mighty_codelists() |>
    define_codelist("NUM", "n", "n", "integer", code = c(1, 2))
  expect_null(select_codelist(cl, "NUM")$values[[1]]$decode)
  expect_snapshot(
    define_codelist(cl, "NUM", "n", "n", "integer", code = 3),
    error = TRUE
  )
  expect_snapshot(
    define_codelist(
      cl,
      "X",
      "n",
      "n",
      "text",
      code = c("A", "B"),
      decode = "a"
    ),
    error = TRUE
  )
})

test_that("define_codelist() requires at least one value", {
  expect_error(
    define_codelist(
      mighty_codelists(),
      "A",
      "a",
      "a",
      "text",
      code = character(0)
    ),
    "At least one `code` must be supplied"
  )
})

test_that("remove_codelist() removes a codelist", {
  cl <- new_cl(list(id = "A", subset = list(list(code = "X")))) |>
    remove_codelist("A")
  expect_length(cl, 0)
  expect_snapshot(remove_codelist(cl, "NOPE"), error = TRUE)
})

test_that("update_codelist() updates only codelist-level fields", {
  cl <- new_cl(region(list(code = "1"))) |>
    update_codelist("REGION", description = "New", datatype = "integer")
  expect_equal(select_codelist(cl, "REGION")$description, "New")
  expect_equal(select_codelist(cl, "REGION")$datatype, "integer")
  expect_snapshot(update_codelist(cl, "REGION", values = list()), error = TRUE)
})

test_that("update_codelist() validates datatype", {
  expect_error(
    update_codelist(
      new_cl(region(list(code = "EU"))),
      "REGION",
      datatype = "date"
    ),
    "must be equal to one of the allowed values"
  )
})

test_that("update_codelist() errors on unknown id", {
  expect_error(
    update_codelist(mighty_codelists(), "NOPE", label = "x"),
    "Codelist \"NOPE\" does not exist"
  )
})

test_that("define_codelist_values() appends to existing codelist", {
  cl <- new_cl(region(list(code = "EU", decode = "Europe"))) |>
    define_codelist_values("REGION", code = "AF", decode = "Africa")
  expect_equal(codes(select_codelist(cl, "REGION"), "values"), c("EU", "AF"))
  expect_snapshot(define_codelist_values(cl, "NOPE", code = "X"), error = TRUE)
})

test_that("define_codelist_values() errors on a subset codelist", {
  cl <- new_cl(list(id = "AGEU", subset = list(list(code = "YEARS"))))
  expect_error(
    define_codelist_values(cl, "AGEU", code = "DAYS"),
    "cannot combine"
  )
})

test_that("subset/restore/extend create codelists if needed", {
  cl <- mighty_codelists() |>
    subset_codelist_values("AGEU", code = "YEARS") |>
    restore_codelist_values("AGEU", code = "MONTHS") |>
    extend_codelist_values("LOC", code = "X", decode = "x")
  ageu <- select_codelist(cl, "AGEU")
  expect_equal(names(ageu), c("id", "subset", "restore"))
  expect_equal(codes(ageu, "restore"), "MONTHS")
  expect_equal(select_codelist(cl, "LOC")$extend[[1]]$decode, "x")
})

test_that("remove_codelist_value() removes from the right group", {
  cl <- new_cl(list(
    id = "AGEU",
    subset = list(list(code = "YEARS")),
    restore = list(list(code = "MONTHS"))
  )) |>
    remove_codelist_value("AGEU", code = "MONTHS")
  ageu <- select_codelist(cl, "AGEU")
  expect_null(ageu$restore)
  expect_equal(codes(ageu, "subset"), "YEARS")
  expect_snapshot(
    remove_codelist_value(cl, "AGEU", code = "NOPE"),
    error = TRUE
  )
})

test_that("remove_codelist_value() drops codelist without values", {
  cl <- new_cl(list(id = "LOC", extend = list(list(code = "X"))))
  expect_message(cl <- remove_codelist_value(cl, "LOC", code = "X"), "removed")
  expect_length(cl, 0)
})

test_that("move_codelist_value() moves within group", {
  cl <- new_cl(list(
    id = "AGEU",
    subset = list(list(code = "YEARS"), list(code = "DAYS"))
  )) |>
    move_codelist_value("AGEU", code = "DAYS", .pos = 1)
  expect_equal(codes(select_codelist(cl, "AGEU"), "subset"), c("DAYS", "YEARS"))
  expect_snapshot(
    move_codelist_value(cl, "AGEU", code = "DAYS", .pos = 5),
    error = TRUE
  )
})

test_that("move_codelist_value() rejects invalid .pos and code", {
  cl <- new_cl(list(
    id = "AGEU",
    subset = list(list(code = "A"), list(code = "B"), list(code = "C"))
  ))
  for (pos in list(1.5, c(1, 2), NA, "1", Inf, 0)) {
    expect_error(
      move_codelist_value(cl, "AGEU", code = "A", .pos = pos),
      "must be a single integer"
    )
  }
  expect_error(
    move_codelist_value(cl, "AGEU", code = c("A", "B"), .pos = 1),
    "must be a single value"
  )
  # Integer-valued doubles remain accepted
  moved <- move_codelist_value(cl, "AGEU", code = "C", .pos = 1)
  expect_equal(
    codes(select_codelist(moved, "AGEU"), "subset"),
    c("C", "A", "B")
  )
})

test_that("update_codelist_value() works for values and extend only", {
  cl <- new_cl(
    region(list(code = "EU", decode = "Europe")),
    list(id = "LOC", extend = list(list(code = "X", decode = "x"))),
    list(id = "AGEU", subset = list(list(code = "YEARS")))
  ) |>
    update_codelist_value("REGION", code = "EU", decode = "EU new") |>
    update_codelist_value("LOC", code = "X", decode = "x new")
  expect_equal(select_codelist(cl, "REGION")$values[[1]]$decode, "EU new")
  expect_equal(select_codelist(cl, "LOC")$extend[[1]]$decode, "x new")
  expect_snapshot(
    update_codelist_value(cl, "AGEU", code = "YEARS", decode = "Y"),
    error = TRUE
  )
})

test_that("mighty_study() has NULL codelists without _codelists.yml", {
  study <- mighty_study(test_path("test_study"))
  expect_null(study@codelists)
  expect_identical(list_codelists(study), character(0))
})

test_that("mighty_study() reads _codelists.yml", {
  study <- mighty_study(local_codelist_study())
  expect_s7_class(study@codelists, mighty_codelists)
  expect_identical(list_codelists(study), "FANCY_CDISC_CODELIST")
})

test_that("mighty_study print() shows codelists", {
  study <- mighty_study(local_codelist_study())
  expect_match(
    cli::cli_fmt(print(study)),
    "@ codelists: 1 entries",
    all = FALSE
  )
})

test_that("mighty_study() errors on unreferenced codelists", {
  study <- mighty_study(local_codelist_study())
  expect_snapshot(
    subset_codelist_values(study, "UNUSED", code = "A"),
    error = TRUE
  )
})

test_that("collect_codelist_refs() includes columns in parameters", {
  domains <- list(list(
    id = "ADVS",
    columns = list(list(id = "PARAMCD", codelist = "UNIT"), list(id = "AVAL")),
    parameters = list(list(
      id = "WEIGHT",
      columns = list(list(id = "AVALC", codelist = "RESULT"))
    ))
  ))
  expect_setequal(collect_codelist_refs(domains), c("UNIT", "RESULT"))
})

test_that("CRUD on mighty_study works and drops empty codelists", {
  study <- mighty_study(test_path("test_study")) |>
    extend_codelist_values("FANCY_CDISC_CODELIST", code = "X")
  expect_identical(list_codelists(study), "FANCY_CDISC_CODELIST")

  study <- suppressMessages(
    remove_codelist_value(study, "FANCY_CDISC_CODELIST", code = "X")
  )
  expect_null(study@codelists)
})

# mighty_study methods: FANCY_CDISC_CODELIST is the only id referenced in
# test_study, so it is used for every operation that must pass validation.

test_that("define_codelist() and define_codelist_values() work on mighty_study", {
  study <- mighty_study(test_path("test_study")) |>
    define_codelist(
      id = "FANCY_CDISC_CODELIST",
      label = "Fancy",
      description = "Fancy codelist",
      datatype = "text",
      code = "A",
      decode = "a"
    ) |>
    define_codelist_values("FANCY_CDISC_CODELIST", code = "B", decode = "b")
  expect_s7_class(study, mighty_study)
  expect_equal(
    codes(select_codelist(study, "FANCY_CDISC_CODELIST"), "values"),
    c("A", "B")
  )
})

test_that("subset/restore/extend_codelist_values() work on mighty_study", {
  study <- mighty_study(test_path("test_study")) |>
    subset_codelist_values("FANCY_CDISC_CODELIST", code = "S") |>
    restore_codelist_values("FANCY_CDISC_CODELIST", code = "R") |>
    extend_codelist_values("FANCY_CDISC_CODELIST", code = "E", decode = "e")
  cl <- select_codelist(study, "FANCY_CDISC_CODELIST")
  expect_equal(codes(cl, "subset"), "S")
  expect_equal(codes(cl, "restore"), "R")
  expect_equal(codes(cl, "extend"), "E")
})

test_that("update_codelist() and update_codelist_value() work on mighty_study", {
  study <- mighty_study(test_path("test_study")) |>
    define_codelist(
      id = "FANCY_CDISC_CODELIST",
      label = "Fancy",
      description = "Fancy codelist",
      datatype = "text",
      code = "A",
      decode = "a"
    ) |>
    update_codelist("FANCY_CDISC_CODELIST", label = "New label") |>
    update_codelist_value("FANCY_CDISC_CODELIST", code = "A", decode = "new a")
  cl <- select_codelist(study, "FANCY_CDISC_CODELIST")
  expect_equal(cl$label, "New label")
  expect_equal(cl$values[[1]]$decode, "new a")
})

test_that("move_codelist_value() works on mighty_study", {
  study <- mighty_study(test_path("test_study")) |>
    subset_codelist_values("FANCY_CDISC_CODELIST", code = c("A", "B")) |>
    move_codelist_value("FANCY_CDISC_CODELIST", code = "B", .pos = 1)
  expect_equal(
    codes(select_codelist(study, "FANCY_CDISC_CODELIST"), "subset"),
    c("B", "A")
  )
})

test_that("remove_codelist() on mighty_study sets codelists to NULL when empty", {
  study <- mighty_study(local_codelist_study()) |>
    remove_codelist("FANCY_CDISC_CODELIST")
  expect_null(study@codelists)
  expect_identical(list_codelists(study), character(0))
})

test_that("select_codelist() on mighty_study errors on unknown id", {
  study <- mighty_study(local_codelist_study())
  expect_equal(
    select_codelist(study, "FANCY_CDISC_CODELIST")$subset[[1]]$code,
    "A"
  )
  expect_error(select_codelist(study, "NOPE"), "does not exist")
})

test_that("mighty_study methods error when codelist is not referenced", {
  study <- mighty_study(test_path("test_study"))
  expect_error(
    define_codelist(
      study,
      id = "UNREFERENCED",
      label = "x",
      description = "x",
      datatype = "text",
      code = "A"
    ),
    "not referenced by any column"
  )
  expect_error(
    extend_codelist_values(study, "UNREFERENCED", code = "A"),
    "not referenced by any column"
  )
  expect_error(
    restore_codelist_values(study, "UNREFERENCED", code = "A"),
    "not referenced by any column"
  )
  # The study is unchanged after a failed operation
  expect_null(study@codelists)
})

test_that("write_config() round-trips _codelists.yml", {
  study <- mighty_study(local_codelist_study())
  out <- withr::local_tempdir()
  write_config(study, path = out)

  reread <- mighty_study(out)
  expect_equal(
    select_codelist(reread, "FANCY_CDISC_CODELIST"),
    select_codelist(study, "FANCY_CDISC_CODELIST")
  )
})

test_that("write_config() writes no _codelists.yml when codelists is NULL", {
  out <- withr::local_tempdir()
  write_config(mighty_study(test_path("test_study")), path = out)
  expect_false(file.exists(file.path(out, "_codelists.yml")))
})
