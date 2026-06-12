test_that("mighty_documents() validates schema", {
  docs <- mighty_documents(
    x = list(
      list(
        id = "DOC001",
        title = "A title",
        doctype = "suppdoc",
        href = "./doc.pdf"
      )
    )
  )

  expect_s7_class(docs, mighty_documents)
  expect_equal(list_documents(docs), "DOC001")
})
