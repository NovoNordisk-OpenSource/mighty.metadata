# Changelog

## mighty.metadata (development version)

- Added validation for column dependencies in
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  ([\#12](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/12)).
- Added validation for naming pattern in
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  ([\#2](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/2)).
- Added
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  generic to resolve the `rows.row.subset` property.
- [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  now rewrites `component.with.domain` to a
  `.mighty_subset(domain, "subset")` marker call instead of a
  `domain[with(domain, subset), ]` expression, matching the marker
  syntax `mighty.component::mighty_component$render()` (\>= 0.1.0.9003)
  expects.

## mighty.metadata 0.1.0

CRAN release: 2026-05-15

- Initial CRAN submission.
- Core classes:
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  for single ADaM datasets and
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  for full studies.
- Column, parameter, and row manipulation verbs: `list_*()`, `add_*()`,
  `remove_*()`, `update_*()`, `select_*()`, `move_*()`.
- Study-level operations:
  [`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md),
  [`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md),
  and
  [`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md).
