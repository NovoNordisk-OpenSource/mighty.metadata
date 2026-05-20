# Resolve conditional metadata items

Evaluates `include` fields on metadata items (domains, columns, rows,
parameters) and removes items where the condition evaluates to `FALSE`.

## Usage

``` r
resolve_includes(x, info = list())
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

- info:

  [`list()`](https://rdrr.io/r/base/list.html) Named list of values used
  to evaluate `include` expressions. For
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
  merged into `x@study`.

## Value

The input object with conditional items resolved.

## Details

Include conditions are R expressions with `{glue}` syntax for variable
substitution and evaluation. The `info` list provides the values used to
do this.

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)

# Add a conditional column
study$ADVS <- update_column(
  study$ADVS,
  id = "STUDYID",
  include = "{study_id == 'my_study'}"
)

# Condition TRUE: column kept (study_id is "my_study" in @study)
study |>
  resolve_includes() |>
  getElement("ADVS") |>
  list_columns()
#>  [1] "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN"  "AVISIT"  
#>  [7] "PARAMCD"  "PARAM"    "AVAL"     "AVALC"   

# Condition FALSE: column removed
study |>
  resolve_includes(info = list(study_id = "other")) |>
  getElement("ADVS") |>
  list_columns()
#>  [1] "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN"  "AVISIT"  
#>  [7] "PARAMCD"  "PARAM"    "AVAL"     "AVALC"   
```
