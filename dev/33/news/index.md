# Changelog

## mighty.metadata (development version)

- added
  [`mighty_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
  class with schema validation and document manipulation helpers:
  [`list_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`select_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`add_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`update_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`remove_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
  ([\#27](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/27))
- added study-level documents support via `_documents.yml` and new
  `study@documents` property
  ([\#27](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/27))
- Added validation for column dependencies in
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  ([\#12](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/12)).
- Added validation for naming pattern in
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  ([\#2](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/2)).
- Added
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  generic to resolve the `rows.row.subset` property, rewriting
  `component.with.domain` to a `.mighty_subset(domain, "subset")` marker
  call matching the marker syntax
  `mighty.component::mighty_component$render()` (\>= 0.1.0.9003)
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
