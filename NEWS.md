# mighty.metadata (development version)

* added `mighty_documents()` class with schema validation and document manipulation helpers:
  `list_documents()`, `select_document()`, `add_document()`, `update_document()`, `remove_documents()`
* added study-level documents support via `documents.yml` and new `study@documents` property
* added document references in ADaM metadata at domain, column, and parameter-column levels
* added study validation for document references:
  unknown document ids (error), invalid METHOD usage outside `origin: Derived` (error), missing COMMENT text (warning)
* added read/write support for `documents.yml` in `mighty_study()` and `write_config()`
* improved `print.mighty_study()` output with documents summary
* added tests and fixtures for documents schema, reference validation, and write/read roundtrip
(all above related with issue #27)
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
