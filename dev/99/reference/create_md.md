# Create All Metadata Data Sets

Converts a
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
or
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
object into all four metadata data sets at once, as a convenience
wrapper around
[`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md),
[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md)
and
[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md).

## Usage

``` r
create_md(x)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

## Value

A named list of tibbles:

- mdtable:

  Table definitions, see
  [`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md)

- mdcol:

  Column definitions, see
  [`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)

- mdparam:

  BDS parameter definitions, see
  [`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md)

- mdvalues:

  Value level definitions, see
  [`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md),
[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md),
[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
create_md(study)
#> $mdtable
#> # A tibble: 3 × 8
#>   order id    label                       class subclass structure keys  comment
#>   <int> <chr> <chr>                       <chr> <chr>    <chr>     <lis> <chr>  
#> 1     1 ADAE  Adverse Events Analysis Da… OCCU… ADVERSE… One reco… <chr> NA     
#> 2     2 ADSL  Subject-Level Analysis Dat… SUBJ… NA       One reco… <chr> NA     
#> 3     3 ADVS  Vital Signs Analysis Datas… BASI… NA       One reco… <chr> NA     
#> 
#> $mdcol
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
#> 
#> $mdparam
#> # A tibble: 2 × 5
#>   table_id table_label                  order id     label                   
#>   <chr>    <chr>                        <int> <chr>  <chr>                   
#> 1 ADVS     Vital Signs Analysis Dataset     1 BMI    Body Mass Index (kg/m^2)
#> 2 ADVS     Vital Signs Analysis Dataset     2 BMIGRP Body Mass Index Group   
#> 
#> $mdvalues
#> # A tibble: 3 × 15
#>   table_id table_label param_order param_id param_label order id    label origin
#>   <chr>    <chr>             <int> <chr>    <chr>       <int> <chr> <chr> <chr> 
#> 1 ADVS     Vital Sign…           1 BMI      Body Mass …     1 AVAL  NA    NA    
#> 2 ADVS     Vital Sign…           2 BMIGRP   Body Mass …     1 AVALC NA    NA    
#> 3 ADVS     Vital Sign…           2 BMIGRP   Body Mass …     2 AVAL  NA    NA    
#> # ℹ 6 more variables: method <chr>, codelist <chr>, format_type <chr>,
#> #   format_length <int>, format_display <chr>, comment <chr>
#> 
```
