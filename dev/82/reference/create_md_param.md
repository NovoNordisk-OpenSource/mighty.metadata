# Create Metadata Parameter Table

Converts a
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
or
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
object into a flat dataframe of BDS parameter definitions.

Only the parameters themselves are returned. Use
[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)
to get the column definitions nested inside each parameter.

## Usage

``` r
create_md_param(x)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

## Value

A tibble with one row per parameter containing:

- table_id:

  Table identifier

- table_label:

  Table label/description

- order:

  Parameter order within table

- id:

  Parameter code (`PARAMCD`)

- label:

  Parameter label (`PARAM`)

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[`create_md()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md.md),
[`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md),
[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
create_md_param(study)
#> # A tibble: 2 × 5
#>   table_id table_label                  order id     label                   
#>   <chr>    <chr>                        <int> <chr>  <chr>                   
#> 1 ADVS     Vital Signs Analysis Dataset     1 BMI    Body Mass Index (kg/m^2)
#> 2 ADVS     Vital Signs Analysis Dataset     2 BMIGRP Body Mass Index Group   
```
