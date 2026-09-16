# Filter domains in a study

Returns a `mighty_study` object containing only domains whose names
start with the given prefix(es).

## Usage

``` r
filter_domains(x, prefix = "AD")
```

## Arguments

- x:

  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  Object to filter.

- prefix:

  [`character()`](https://rdrr.io/r/base/character.html) one or more
  prefixes to keep (case-insensitive). Defaults to `"AD"` to keep only
  ADaM domains.

## Value

A `mighty_study` object.

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)
#> → No `_documents.yml` file found

# Keep only ADaM domains (default)
study |>
  filter_domains()
#> <mighty.metadata::mighty_study/list/S7_object>
#> @ mighty: <mighty.metadata::mighty_config>
#> @ study: <mighty.metadata::study_config>
#> $ ADAE: <mighty.metadata::mighty_domain>
#> $ ADSL: <mighty.metadata::mighty_domain>
#> $ ADVS: <mighty.metadata::mighty_domain>
```
