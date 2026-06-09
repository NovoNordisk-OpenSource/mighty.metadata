# Update documents in your metadata

Functions to list, select, remove, add, and update documents in your
`mighty_documents()` object (or through `mighty_study@documents`).

## Usage

``` r
mighty_documents(file = NULL, x = NULL)

list_documents(x)

select_document(x, id)

remove_documents(x, id)

add_document(
  x,
  id,
  title,
  doctype,
  href,
  .pos = length(list_documents(x)) + 1L
)

update_document(x, id, ...)
```

## Arguments

- file:

  `character(1)` path to `documents.yml`.

- x:

  A `mighty_documents()` or
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  object.

- id:

  [`character()`](https://rdrr.io/r/base/character.html) id of
  document(s) to select, remove, or update.

- title:

  `character(1)` document title.

- doctype:

  `character(1)` document type.

- href:

  `character(1)` document path/URL.

- .pos:

  `integer(1)` insertion position for a new document.

- ...:

  Additional document properties to update.

## Value

- `list_documents()`:
  [`character()`](https://rdrr.io/r/base/character.html) vector with
  document ids.

- `select_document()`: selected document entry as a list.

- `add_document()`, `update_document()`, `remove_documents()`: modified
  object (`invisible(x)`).

## Examples

``` r
# Load study config
s <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
#> → No `documents.yml` file found

# Add a document
s <- s |>
  add_document(
    id = "SAP",
    title = "Statistical Analysis Plan",
    doctype = "suppdoc",
    href = "./docs/sap.pdf"
  )

# List and select documents
list_documents(s)
#> [1] "SAP"
select_document(s, id = "SAP")
#> $id
#> [1] "SAP"
#> 
#> $title
#> [1] "Statistical Analysis Plan"
#> 
#> $doctype
#> [1] "suppdoc"
#> 
#> $href
#> [1] "./docs/sap.pdf"
#> 

# Update existing document
s <- s |>
  update_document(
    id = "SAP",
    title = "Statistical Analysis Plan v2"
  )

# Remove one or more documents
s <- s |>
  remove_documents(id = "SAP")

# Work directly on mighty_documents
docs <- mighty_documents()
docs <- docs |>
  add_document(
    id = "CSR",
    title = "Clinical Study Report",
    doctype = "suppdoc",
    href = "./docs/csr.pdf"
  )

list_documents(docs)
#> [1] "CSR"
```
