# Mighty Documents

`mighty_documents()` creates an S7 object for storing document metadata.
The class inherits from
[`S7::class_list`](https://rconsortium.github.io/S7/reference/base_classes.html)
and represents the contents of `documents.yml` as a list of document
entries.

The object is validated on creation and when
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
is called. Validation includes:

- schema compliance with `inst/schema/documents.json`,

- uniqueness of document identifiers (`id`).

Writing to YAML is done via
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
on a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
object, where documents are saved to `documents.yml`.

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

An object of class `mighty_documents`.

- `list_documents()`:
  [`character()`](https://rdrr.io/r/base/character.html) vector with
  document ids.

- `select_document()`: selected document entry as a list.

- `add_document()`, `update_document()`, `remove_documents()`: modified
  object (`invisible(x)`).

## Examples

``` r
docs <- mighty_documents(
  x = list(
    list(
      id = "DOC001",
      title = "Statistical Analysis Plan",
      doctype = "suppdoc",
      href = "./docs/sap.pdf"
    )
  )
)

# Custom print method gives a small overview
print(docs)
#> <mighty.metadata::mighty_documents>
#> Documents: 1 entry
#> IDs: `DOC001`

# Write documents.yml through mighty_study
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
#> → No `_documents.yml` file found
study@documents <- docs

# Load study config
s <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
#> → No `_documents.yml` file found

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
