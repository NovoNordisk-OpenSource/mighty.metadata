# mighty.metadata (development version)

* Added validation for column dependencies in `mighty_domain()` (#12).
* Added validation for naming pattern in `mighty_study()` (#2).
* Added `resolve_subsets()` generic to resolve the `rows.row.subset`
  property.

# mighty.metadata 0.1.0

* Initial CRAN submission.
* Core classes: `mighty_domain()` for single ADaM datasets and
  `mighty_study()` for full studies.
* Column, parameter, and row manipulation verbs: `list_*()`, `add_*()`,
  `remove_*()`, `update_*()`, `select_*()`, `move_*()`.
* Study-level operations: `populate_core()`, `populate_sparse()`, and
  `resolve_includes()`.
