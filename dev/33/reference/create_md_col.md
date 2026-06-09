# Create Metadata Column Table

Converts a
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
or
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
object into a flat dataframe of column definitions.

## Usage

``` r
create_md_col(x)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

## Value

A tibble with one row per column containing:

- table_id:

  Table identifier

- table_label:

  Table label/description

- order:

  Column order within table

- id:

  Column name

- label:

  Column label

- origin:

  Origin type (e.g., "Predecessor", "Derived")

- key:

  Logical, whether column is a key

- is_core:

  Logical, whether column is a core variable

- core:

  String, whether a column is Req, Cond or Perm

- method:

  Derivation method

- codelist:

  Codelist reference

- format_type:

  Data type ("C" or "N")

- format_length:

  Maximum length

- format_display:

  Display format

- comment:

  Comment

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md),
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
#> → No `documents.yml` file found
mdcol <- create_md_col(study)
```
