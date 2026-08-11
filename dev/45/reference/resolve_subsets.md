# Resolve row subsets

Rewrites row actions that carry a `subset` field into equivalent
`component` actions that operate on a filtered subset of the source
domain. The `subset` field is removed after resolution.

## Usage

``` r
resolve_subsets(x)
```

## Arguments

- x:

  A
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  or
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.

## Value

The input object with row subsets resolved.

## Details

The row's `component.with.domain` is rewritten to
`.mighty_subset(<domain>, "<subset>")`, a marker call that
`mighty.component::mighty_component$render()` recognizes and expands
into code that applies the action only to rows matching the R expression
given in `subset`. A `component` with a `with.domain` entry is required.

## Examples

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)

# Add a row action restricted to a subset of source rows
study$ADAE <- add_row(
  study$ADAE,
  id = "TRTEMFL_STUDY1",
  component = list(
    id = "STUDY1_COMPONENT",
    with = list(domain = "ADAE")
  ),
  subset = "STUDYID == 'STUDY1'"
)

# `subset` is folded into `component.with.domain` as a `.mighty_subset()` marker call
study |>
  resolve_subsets() |>
  getElement("ADAE") |>
  select_row("TRTEMFL_STUDY1") |>
  str()
#> ! Resolving row subsets requires mighty.component (>= 0.1.0.9003)
#> List of 2
#>  $ id       : chr "TRTEMFL_STUDY1"
#>  $ component:List of 2
#>   ..$ id  : chr "STUDY1_COMPONENT"
#>   ..$ with:List of 1
#>   .. ..$ domain: chr ".mighty_subset(ADAE, \"STUDYID == 'STUDY1'\")"
```
