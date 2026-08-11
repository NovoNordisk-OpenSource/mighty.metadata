# NA

## Bug Report

### Description

`resolve_subset_component()` rewrites `component.with.domain` from a
plain identifier into an expression, e.g. `domain = "ADAE"`,
`subset = "STUDYID == 'S1'"` becomes
`"ADAE[with(ADAE, STUDYID == 'S1'), ]"`. That string is substituted into
the component template wherever `{{{domain}}}` appears, including inside
`@depends`/`@outputs` — not just `@code`.

### Problem 1: drops rows on append-shaped row components

`mighty`’s `@type row` fixtures append rows,
e.g. `tests/testthat/fixtures/components/new_visitnum_01.R`:

``` r

#' @type row
#' @code
new_visitnum <- ADLB |> dplyr::filter(...) |> dplyr::mutate(...)
ADLB <- rbind(ADLB, new_visitnum)
```

With the rewrite this becomes
`ADLB[with(ADLB, subset), ] <- rbind(ADLB[with(ADLB, subset), ], new_visitnum)`,
which is a fixed-size replacement that can’t grow, so R silently drops
the appended rows.

This means the current approach requires component authors to write row
components in a specific way so as to be compatible with the
`substitute` behavior

### Problem 2: corrupts `@depends`/`@outputs`

Real components write `{{{domain}}}` inside their `@depends`/`@outputs`
header lines, e.g. `mighty.component`’s
`inst/examples/ady.mustache:10-12`:

``` r

#' @depends {{{domain}}} {{{date}}}
#' @outputs {{{variable}}}
```

`mighty.component`’s parser, `tags_to_depends()`
(`R/mighty_component.R:236-259`), splits each tag on the *first*
whitespace run into `domain`/`column`. A substituted expression splits
mid-expression (after `ADAE[with(ADAE,`), corrupting both fields.

(`mighty::classify_data_domains()` does reject the corrupted domain
string with a validation error today — that’s the only thing currently
catching problem 2, and it doesn’t address problem 1.)
