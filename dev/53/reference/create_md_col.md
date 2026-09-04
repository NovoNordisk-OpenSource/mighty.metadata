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
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md),
[`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md),
[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
create_md_col(study)
#> # A tibble: 32 × 15
#>    table_id table_label      order id    label origin key   is_core core  method
#>    <chr>    <chr>            <int> <chr> <chr> <chr>  <lgl> <lgl>   <chr> <chr> 
#>  1 ADAE     Adverse Events …     1 STUD… Stud… NA     FALSE NA      Req   AE.ST…
#>  2 ADAE     Adverse Events …     2 USUB… Uniq… NA     TRUE  NA      Req   AE.US…
#>  3 ADAE     Adverse Events …     3 AESEQ Sequ… NA     TRUE  NA      Cond  AE.AE…
#>  4 ADAE     Adverse Events …     4 AETE… Repo… NA     FALSE NA      Req   AE.AE…
#>  5 ADAE     Adverse Events …     5 AEDE… Dict… NA     FALSE NA      Cond  AE.AE…
#>  6 ADAE     Adverse Events …     6 AEBO… Body… NA     FALSE NA      Cond  AE.AE…
#>  7 ADAE     Adverse Events …     7 ASTDT Anal… NA     FALSE NA      Cond  Deriv…
#>  8 ADAE     Adverse Events …     8 AENDT Anal… NA     FALSE NA      Cond  Deriv…
#>  9 ADAE     Adverse Events …     9 TRTE… Trea… NA     FALSE NA      Cond  Deriv…
#> 10 ADSL     Subject-Level A…     1 STUD… Stud… NA     FALSE NA      Req   DM.ST…
#> # ℹ 22 more rows
#> # ℹ 5 more variables: codelist <chr>, format_type <chr>, format_length <int>,
#> #   format_display <chr>, comment <chr>
```
