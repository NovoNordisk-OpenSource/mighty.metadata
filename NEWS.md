# mighty.metadata (development version)

* Added `study_config()` class for the `_study.yml` configuration file (#26).
  The `@study` property of `mighty_study()` now holds a `study_config()`
  object instead of a plain list, and is `NULL` when no `_study.yml` exists.
* Added validation for column dependencies in `mighty_domain()` (#12).
* Added validation for naming pattern in `mighty_study()` (#2).
* Added `resolve_subsets()` generic to resolve the `rows.row.subset`
  property, rewriting `component.with.domain` to a
  `.mighty_subset(domain, "subset")` marker call matching the marker syntax
  `mighty.component::mighty_component$render()` (>= 0.1.0.9003) expects.

# mighty.metadata 0.1.0

* Initial CRAN submission.
* Core classes: `mighty_domain()` for single ADaM datasets and
  `mighty_study()` for full studies.
* Column, parameter, and row manipulation verbs: `list_*()`, `add_*()`,
  `remove_*()`, `update_*()`, `select_*()`, `move_*()`.
* Study-level operations: `populate_core()`, `populate_sparse()`, and
  `resolve_includes()`.
