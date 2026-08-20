test_that("list_documents() returns document ids", {
  docs <- mighty_documents()
  expect_identical(list_documents(docs), character())

  docs <- mighty_documents(
    file = test_path("test_study/_documents.yml")
  )
  expect_identical(list_documents(docs), c("SUPPDOC001", "COMMENT001", "METHOD001"))
})

test_that("document can be added via add_document()", {
  docs <- mighty_documents()

  docs <- add_document(
    docs,
    id = "DOC001",
    title = "A title",
    doctype = "suppdoc",
    href = "./doc.pdf"
  ) |> add_document(
    id = "DOC002",
    title = "Another title",
    doctype = "comment",
    href = "./comment.txt"
  )

  expect_equal(sort(list_documents(docs)), c("DOC001", "DOC002"))
})

test_that("document can be selected via select_document()", {
  docs <- mighty_documents(
    file = test_path("test_study/_documents.yml")
  )

  expect_equal(select_document(docs, "SUPPDOC001")$title, "Analysis Reviewer Guide Protocol")
})

test_that("document title can be correctly updated via update_document() method", {
  docs <- mighty_documents(
    file = test_path("test_study/_documents.yml")
  )

  docs <- update_document(docs, id = "SUPPDOC001", title = "Updated")
  expect_equal(select_document(docs, "SUPPDOC001")$title, "Updated")
})

test_that("document can be removed via remove_documents()", {
  docs <- mighty_documents(
    file = test_path("test_study/_documents.yml")
  )

  docs <- remove_documents(docs, id = "COMMENT001")

  expect_length(list_documents(docs), 2)
  expect_equal(list_documents(docs),  c("SUPPDOC001", "METHOD001"))
})

test_that("mighty_study() reads _documents.yml", {
  study <- mighty_study(test_path("test_study"))

  expect_s7_class(study@documents, mighty_documents)
  expect_setequal(
    list_documents(study),
    c("COMMENT001", "METHOD001", "SUPPDOC001")
  )
})

test_that("check_document_references() returns study unchanged when no doc refs in domains and no docs in _documents.yml", { # nolint: line_length_linter
  tmpdir <- withr::local_tempdir()
  file.copy(test_path("test_study/adsl.yml"), tmpdir) # adsl.yml has no document references
  study <- mighty_study(tmpdir)

  expect_no_error(out <- check_document_references(study))
  expect_equal(out, study)
})

test_that("check_document_references() returns study unchanged when no doc refs in domains but docs exist in _documents.yml", { # nolint: line_length_linter
  tmpdir <- withr::local_tempdir()
  file.copy(test_path("test_study/adsl.yml"), tmpdir) # adsl.yml has no document references
  file.copy(test_path("test_study/_documents.yml"), tmpdir)
  study <- mighty_study(tmpdir)

  expect_no_error(out <- check_document_references(study))
  expect_equal(out, study)
})

test_that("check_document_references() errors when domains reference document ids but no docs in _documents.yml", {
  study <- mighty_study(test_path("test_study"))

  expect_snapshot(study@documents <- mighty_documents(), error = TRUE)
})

test_that("check_document_references() errors when domains reference document ids not defined in _documents.yml", {
  study <- mighty_study(test_path("test_study"))
  study$ADVS$documents <- list(list(id = "UNKNOWN"), list(id = "NEXT"))

  expect_snapshot(validate(study), error = TRUE)
})

test_that("check_document_references() errors for METHOD on non-Derived", {
  study <- mighty_study(test_path("test_study"))
  study$ADVS$columns[[1]]$documents <- list(list(id = "METHOD001"))

  expect_snapshot(validate(study), error = TRUE)
})

test_that("check_document_references() warns for COMMENT with missing text", {
  study <- mighty_study(test_path("test_study"))
  study$ADAE$columns[[9]]$comment <- ""

  expect_snapshot(validate(study))
})

test_that("as_list_or_empty() returns empty list for empty inputs", {
  expect_equal(as_list_or_empty(NULL), list())
  expect_equal(as_list_or_empty(list()), list())

  x <- list(list(id = "A"))
  expect_identical(as_list_or_empty(x), x)
})

test_that("build_document_refs() builds normalized references", {
  docs <- list(list(id = "DOC1"), list(id = "DOC2"))

  refs <- build_document_refs(
    documents = docs,
    level = "domain ADSL",
    comment = "A comment",
    origin = "Derived"
  )

  expect_length(refs, 2)
  expect_identical(
    refs[[1]],
    list(
      id = "DOC1",
      level = "domain ADSL",
      comment = "A comment",
      origin = "Derived"
    )
  )
  expect_identical(refs[[2]]$id, "DOC2")

  expect_equal(build_document_refs(list(), "x"), list())
})

test_that("collect_*_document_refs() collects references from each metadata level", {
  domain <- list(
    id = "ADSL",
    comment = "Domain comment",
    documents = list(list(id = "COMMENT001")),
    columns = list(
      list(
        id = "AGE",
        comment = "Column comment",
        origin = "Derived",
        documents = list(list(id = "METHOD001"))
      )
    ),
    parameters = list(
      list(
        id = "P01",
        columns = list(
          list(
            id = "AVAL",
            comment = "Param column comment",
            origin = "Derived",
            documents = list(list(id = "SUPPDOC001"))
          )
        )
      )
    )
  )

  domain_refs <- collect_domain_document_refs(domain)
  expect_length(domain_refs, 1)
  expect_identical(domain_refs[[1]]$level, "domain ADSL")

  col_refs <- collect_column_document_refs(domain[["columns"]], domain$id)
  expect_length(col_refs, 1)
  expect_identical(col_refs[[1]]$level, "domain ADSL column AGE")

  param_refs <- collect_parameter_document_refs(
    domain[["parameters"]],
    domain$id
  )
  expect_length(param_refs, 1)
  expect_identical(
    param_refs[[1]]$level,
    "domain ADSL parameter P01 column AVAL"
  )

  all_refs <- collect_document_refs(domain)
  expect_length(all_refs, 3)
  expect_equal(
    vapply(all_refs, function(x) x[["id"]], character(1)),
    c(
      "COMMENT001",
      "METHOD001",
      "SUPPDOC001"
    )
  )
})

test_that("find_invalid_method_refs() flags METHOD refs with non-Derived origin", {
  refs <- list(
    list(id = "METHOD001", level = "x", origin = "Assigned"),
    list(id = "METHOD001", level = "y", origin = "Derived"),
    list(id = "SUPPDOC001", level = "z", origin = "Assigned")
  )
  ref_types <- c("method", "method", "suppdoc")

  invalid <- find_invalid_method_refs(refs, ref_types)

  expect_length(invalid, 1)
  expect_identical(invalid[[1]]$level, "x")
})
