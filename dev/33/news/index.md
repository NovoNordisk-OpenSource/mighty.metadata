# Changelog

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

## mighty.metadata (development version)

- added
  [`mighty_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
  class with schema validation and document manipulation helpers:
  [`list_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`select_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`add_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`update_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
  [`remove_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)

- added study-level documents support via `documents.yml` and new
  `study@documents` property

- added document references in ADaM metadata at domain, column, and
  parameter-column levels

- added study validation for document references: unknown document ids
  (error), invalid METHOD usage outside `origin: Derived` (error),
  missing COMMENT text (warning)

- added read/write support for `documents.yml` in
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  and
  [`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)

- improved `print.mighty_study()` output with documents summary

- added tests and fixtures for documents schema, reference validation,
  and write/read roundtrip (all above related with issue
  [\#27](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/27))

- added validation for column dependencies in
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md) -
  related with issue
  [\#12](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/12)

- added validation for naming pattern for mighty_study() - related with
  issue
  [\#2](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/2)
