# NA

## Feature Request

### Description

[`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
(`R/z_resolve_subsets.R`) implements the pooling ADR’s `subset` field by
rewriting a row action’s `component$with$domain` to a filtering
expression:

``` r

# resolve_subset_component(), R/z_resolve_subsets.R:112-129
component[["with"]][["domain"]] <- glue::glue_data(
  .x = list(domain = component[["with"]][["domain"]], subset = subset),
  "{domain}[with({domain}, {subset}), ]"
) |>
  as.character()
```

So `domain = "ADAE"`, `subset = "STUDYID == 'S1'"` becomes
`domain = "ADAE[with(ADAE, STUDYID == 'S1'), ]"`. That string is passed
as a render parameter to `mighty.component::mighty_component$render()`,
which substitutes it into the component template wherever `{{{domain}}}`
appears — including inside `@depends`/`@outputs`, not just the `@code`
body. This breaks in two ways: `@depends` corrupts (its parser expects
`domain` to be a bare identifier and splits on whitespace, so the
substituted expression is sliced apart incorrectly), and row-type
components that append rows (`domain <- rbind(domain, new_rows)`, the
shape used throughout `mighty`’s own row-component test fixtures)
silently drop the appended rows at runtime, because the rewritten
assignment target `domain[with(domain, subset), ] <-` is a fixed-size
row replacement that cannot grow to hold more rows than it selected.

**`mighty.component` (\>= 0.1.0.9003) already resolves both of these.**
Its `render()` now recognizes a `.mighty_subset(domain, "subset")`
marker call passed as a render parameter, renders `@depends`/`@outputs`
against the bare domain name, and wraps the generated code in a
hold-back/recombine prologue and epilogue so appended rows survive.
Nothing in this package (`mighty.metadata`) uses that marker yet:
`resolve_subset_component()` still glues the
`domain[with(domain, subset), ]` form, which `mighty.component` does not
treat specially. The fix this package needs is one output-format change
to match what `mighty.component` now expects.

### Proposed Solution

Change `resolve_subset_component()`’s `glue_data()` template string from

``` r

"{domain}[with({domain}, {subset}), ]"
```

to the marker shape `mighty.component::render()` recognizes:

``` r

'.mighty_subset({domain}, "{subset}")'
```

So `domain = "ADAE"`, `subset = "STUDYID == 'S1'"` produces
`.mighty_subset(ADAE, "STUDYID == 'S1'")` instead of
`ADAE[with(ADAE, STUDYID == 'S1'), ]`. No other function in this package
changes — `resolve_subsets_domain()`, `resolve_subsets_list()`, and
`resolve_subset_entry()` (`R/z_resolve_subsets.R:65-109`) are
unaffected. The rewrite still happens in the same place, at the same
point in the pipeline, carrying the same two logical values (domain,
subset); only the string’s syntax changes to one
`mighty.component::render()` can parse unambiguously via
[`str2lang()`](https://rdrr.io/r/base/parse.html) instead of a bracket
expression that gets mis-split by whitespace.

This also raises the minimum version constraint on `mighty.component` to
`>= 0.1.0.9003` in `DESCRIPTION`, since earlier versions don’t recognize
the marker and would render it as literal (broken) R code.

### Use Case

The pooling ADR (`vignettes/articles/adr-pooling.Rmd`, Use case 3) needs
`subset` combined with standard/example components, unmodified, so a
pooled build can run a study-specific derivation against only that
study’s rows within a single script — one of the ADR’s explicit success
criteria (“Standard components can be reused unmodified in pooled
specifications”). That’s blocked today because this package still emits
the syntax `mighty.component` no longer needs to support that way, and
gets neither the corrected `@depends` parsing nor the row-preserving
wrap in exchange.

### Additional Context

- Verified independently of any component-specific detail: rendering the
  stock example component `ady.mustache` with today’s output,
  `domain = "ADAE[with(ADAE, STUDYID == 'S1'), ]"`, corrupts its
  `@depends` fields. This affects every component following
  `mighty.component`’s own documented convention of writing
  `{{{domain}}}` in `@depends`, not anything specific to one template.
- Considered and rejected: relaxing `mighty`’s domain-name validator
  (`classify_data_domains()`) to accept the current bracket-expression
  string as a “domain name” instead of adopting the marker. Rejected
  because even if that guard were relaxed, the corrupted column field
  would remain, and `mighty::make_edges()` matches dependency edges on
  exact `(domain, column)` pairs — the edge would silently fail to match
  and the node would receive a synthetic edge to `init_domain` instead
  of its real parent. A silently wrong dependency graph is worse than
  today’s loud validation error, so this is not a substitute for
  adopting the marker.
- This package’s change is deliberately the smallest possible: one
  template string plus a version-floor bump. The parsing and
  code-wrapping logic belongs to, and is now owned by,
  `mighty.component`; this package doesn’t need to know how
  `.mighty_subset(...)` is expanded, only that it needs to emit it.
- Not yet exercised through a full
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  →
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  → `mighty::generate_adam_code()` pipeline with the marker in place —
  the `@depends`-corruption and row-loss findings above predate the
  `mighty.component` fix and were reproduced by calling
  `mighty.component::mighty_component$render()` directly against
  hand-built templates, not through this package’s own functions.

### Impact

Without this, `subset` cannot be safely combined with standard/example
row-type components — the primary use case it was designed to support
per the pooling ADR — even though the packages downstream
(`mighty.component`) are already able to support it. This is a small,
contained change: one `glue_data()` template string and a version floor
bump, with no change to
[`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)’s
exported behavior or signature.

### Related Issues

None open in this repo. `mighty.component`’s side of this (the
`.mighty_subset()` marker recognized by `render()`) is already
implemented on its `main` branch as of `mighty.component` `0.1.0.9003` —
this issue is the remaining adoption step in `mighty.metadata`, not a
paired proposal.
