# Create Metadata Value Table

Converts a
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
or
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
object into a flat dataframe of value level definitions, i.e. the
columns defined inside each BDS parameter.

Parameters without any `columns` entry contribute no rows. Use
[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md)
for the full list of parameters.

## Usage

``` r
create_md_values(x)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

## Value

A tibble with one row per parameter column containing:

- table_id:

  Table identifier

- table_label:

  Table label/description

- param_order:

  Parameter order within table

- param_id:

  Parameter code (`PARAMCD`)

- param_label:

  Parameter label (`PARAM`)

- order:

  Column order within parameter

- id:

  Column name

- label:

  Column label

- origin:

  Origin type (e.g., "Predecessor", "Derived")

- method:

  Derivation method

- codelist:

  Codelist reference

- format_type:

  Data type

- format_length:

  Maximum length

- format_display:

  Display format

- comment:

  Comment

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[`create_md()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md.md),
[`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md),
[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
create_md_values(study)
#> # A tibble: 3 × 15
#>   table_id table_label param_order param_id param_label order id    label origin
#>   <chr>    <chr>             <int> <chr>    <chr>       <int> <chr> <chr> <chr> 
#> 1 ADVS     Vital Sign…           1 BMI      Body Mass …     1 AVAL  NA    NA    
#> 2 ADVS     Vital Sign…           2 BMIGRP   Body Mass …     1 AVALC NA    NA    
#> 3 ADVS     Vital Sign…           2 BMIGRP   Body Mass …     2 AVAL  NA    NA    
#> # ℹ 6 more variables: method <chr>, codelist <chr>, format_type <chr>,
#> #   format_length <int>, format_display <chr>, comment <chr>
```
