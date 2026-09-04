# Create Metadata Dataset Table

Converts a
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
or
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
object into a flat dataframe of table (dataset) definitions.

## Usage

``` r
create_md_table(x)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

## Value

A tibble with one row per table containing:

- order:

  Table order within the study, `NA` for a single domain

- id:

  Table identifier

- label:

  Table label/description

- class:

  CDISC class of the dataset

- subclass:

  CDISC subclass of the dataset

- structure:

  Description of the structure of the dataset

- keys:

  List column of key variables

- comment:

  Comment

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md),
[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md),
[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
create_md_table(study)
#> # A tibble: 3 × 8
#>   order id    label                       class subclass structure keys  comment
#>   <int> <chr> <chr>                       <chr> <chr>    <chr>     <lis> <chr>  
#> 1     1 ADAE  Adverse Events Analysis Da… OCCU… ADVERSE… One reco… <chr> NA     
#> 2     2 ADSL  Subject-Level Analysis Dat… SUBJ… NA       One reco… <chr> NA     
#> 3     3 ADVS  Vital Signs Analysis Datas… BASI… NA       One reco… <chr> NA     
```
