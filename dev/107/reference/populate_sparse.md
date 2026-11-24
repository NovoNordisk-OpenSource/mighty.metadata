# Populate Predecessor Metadata

Populates column metadata from predecessor references. Columns with a
`method` in the format `domain.column` (e.g., `ADSL.USUBJID`) inherit
metadata from the referenced predecessor.

## Usage

``` r
populate_sparse(x, ...)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

- ...:

  Additional arguments passed to methods.

## Value

A modified
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
or
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
with predecessor column metadata populated.

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
study <- populate_sparse(study)
```
