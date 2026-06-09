# mighty.metadata 0.1.0

* Initial CRAN submission.
* Core classes: `mighty_domain()` for single ADaM datasets and
  `mighty_study()` for full studies.
* Column, parameter, and row manipulation verbs: `list_*()`, `add_*()`,
  `remove_*()`, `update_*()`, `select_*()`, `move_*()`.
* Study-level operations: `populate_core()`, `populate_sparse()`, and
  `resolve_includes()`.

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

* added validation for column dependencies in `mighty_domain()` - related with issue #12 
* added validation for naming pattern for mighty_study() - related with issue #2 
