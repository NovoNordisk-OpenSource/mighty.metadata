minimal_md_domain <- function() {
  mighty_domain(
    .data = list(
      id = "MDCOL",
      label = "Metadata Columns",
      class = "ADAM OTHER",
      structure = "One record per column",
      keys = "ID",
      columns = list(list(id = "ID"))
    )
  )
}

test_that("filter_domains() returns a mighty_study object", {
  study <- test_path("test_study") |> mighty_study()
  study[["MDCOL"]] <- minimal_md_domain()

  filter_domains(study) |>
    expect_s7_class(mighty_study)
})

test_that("filter_domains() retains only ADaM datasets by default", {
  study <- test_path("test_study") |> mighty_study()
  study[["MDCOL"]] <- minimal_md_domain()

  result <- filter_domains(study)

  expect_equal(names(result), c("ADAE", "ADSL", "ADVS"))
})

test_that("filter_domains() filters by non-default prefix", {
  study <- test_path("test_study") |> mighty_study()
  study[["MDCOL"]] <- minimal_md_domain()

  result <- filter_domains(study, prefix = "MD")

  expect_equal(names(result), "MDCOL")
})

test_that("filter_domains() is case-insensitive", {
  study <- test_path("test_study") |> mighty_study()
  study[["MDCOL"]] <- minimal_md_domain()

  expect_equal(
    names(filter_domains(study, prefix = "ad")),
    names(filter_domains(study, prefix = "AD"))
  )
})
