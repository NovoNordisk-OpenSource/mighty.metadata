# resolve_subsets(): stop rewriting component.with.domain, pass subset/domain through unchanged

## Background

Summary of the problem:
[`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
(`R/z_resolve_subsets.R`) currently implements row-level `subset` by
rewriting `component.with.domain` from a plain identifier (`"ADLB"`)
into an R expression (`"ADLB[with(ADLB, STUDYID == 'S1'), ]"`), then
deleting the `subset` field. This overloads a parameter every downstream
consumer expects to be a plain identifier:

- `mighty.component`’s `tags_to_depends()` splits `@depends` tags on the
  first whitespace — a substituted expression corrupts the parse.
- `mighty`’s `classify_data_domains()` correctly rejects the corrupted
  result with a loud validation error (this guard should stay; it’s the
  only thing currently catching the corrupted parse).
- Even when a component author works around the parse failure (literal
  domain in `@depends`, `{{{domain}}}` still in the code body), the
  rewritten expression breaks at runtime for `rbind`-shaped row
  components: `<expr> <- rbind(<expr>, new_rows)` is a replacement
  assignment into a fixed number of row slots and cannot grow the frame.
  R silently discards the derived rows with only a warning. This affects
  all 14 `@type row` fixtures in `mighty`’s test suite.

The fix moves subset-handling into `mighty.component::render()` (tracked
in a separate issue in that repo — see
`mighty.component/issue-subset-rendering.md`), which wraps the
*unmodified* component body in a generated prologue/epilogue rather than
substituting an expression into `domain`. For that to work,
`mighty.metadata` must stop consuming/destroying `subset` and `domain`
and instead let both survive on the row action, unchanged, for `mighty`
to pass through to `mighty.component`.

## Scope

This issue covers `mighty.metadata` only. Companion issues: -
`mighty.component`: implement subset-wrapping in `render()`. - `mighty`:
thread `subset`/`domain` through the action pipeline
(`process_adam_domain.R`, `convert_yml_to_data_table.R`,
`extract_actions.R`, `render_code.R`) and pass them to
`get_rendered_component()`.

## Changes

- `resolve_subset_component()` (`z_resolve_subsets.R`) stops rewriting
  `component[["with"]][["domain"]]`. Remove the
  [`glue::glue_data()`](https://glue.tidyverse.org/reference/glue.html)
  call that currently builds `"{domain}[with({domain}, {subset}), ]"`
  and reassigns it onto `domain`.
- `resolve_subset_entry()` stops deleting `x[["subset"]]`. Remove the
  `x[["subset"]] <- NULL` line — `subset` must survive on the row action
  object.
- Keep both existing validation checks — they remain meaningful even
  though the rewrite is gone:
  - Abort if `x[["component"]]` is missing (“Subsetting a row requires
    that a `component` entry is specified”).
  - Abort if `component[["with"]][["domain"]]` is missing (“Subsetting a
    component requires that a `with.domain` entry is specified”).
- Net effect:
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)’s
  role narrows from “resolve/rewrite” to “validate and pass through.”
  Its exported signature
  ([`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  generic; `mighty_study`/`mighty_domain` S7 methods) is unchanged —
  only the internal behavior of
  `resolve_subset_component()`/`resolve_subset_entry()` changes. No
  rename; the public API is already committed in
  `_pkgdown.yml`/`NEWS.md`.

## Tests

- Update `tests/testthat/_snaps/z_resolve_subsets.md` snapshots: after
  resolution, `component.with.domain` should show the original plain
  identifier (e.g. `"ADAE"`), unchanged from input, and `subset` should
  still be present on the resolved row action (not deleted).
- Add/keep a test confirming the two existing validation aborts still
  fire (missing `component`; missing `component.with.domain`) — these
  should not regress even though the rewrite itself is removed.
- Update the function’s own `@examples` block (currently shows `subset`
  being folded into `component.with.domain` — this example’s expected
  output changes since the field is no longer rewritten).

## Documentation

- `vignettes/articles/adr-pooling.Rmd` currently states component
  rendering composes with `subset` “with no changes to component
  internals… needed,” and describes
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)’s
  mechanism as the domain rewrite. Both claims become inaccurate under
  this change — the ADR should be updated to describe
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  as validation-only, with actual subset application happening in
  `mighty.component::render()`.
- Update
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)’s
  roxygen `@description`/`@details` (currently: “Rewrites row actions
  that carry a `subset` field into equivalent `component` actions… The
  row’s `component.with.domain` is rewritten to
  `<domain>[with(<domain>, <subset>), ]`…”) to describe the new
  validate-and-pass-through behavior instead.
- Add a `NEWS.md` entry.

## Out of scope for this issue

- Any change to the `adam.json` schema — `subset`’s placement under
  `row` (not `column`) is already correct and unchanged.
- The `mighty.component` wrapping implementation itself.
- The `mighty` pipeline changes needed to actually pass
  `subset`/`domain` to `mighty.component`.
