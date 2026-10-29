# Changelog

## mighty.metadata 0.2.0

- Added
  [`mighty_codelists()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/codelists.md)
  class for study-level codelist metadata in `_codelists.yml`, available
  as `mighty_study()@codelists`
  ([\#49](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/49)).
- Added
  [`mighty_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
  class for study-level document metadata in `_documents.yml`, available
  as `mighty_study()@documents`. Call
  [`check_document_references()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
  to verify references
  ([\#27](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/27),
  [\#72](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/72)).
- Added
  [`mighty_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  class for `_mighty.yml`. `mighty_study()@mighty` is now a
  [`mighty_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  object, or `NULL` if the file is missing
  ([\#25](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/25)).
- `_mighty.yml` requires a non-empty `repos` field
  ([\#24](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/24),
  [\#65](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/65)).
- Added
  [`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)
  class for `_study.yml`. `mighty_study()@study` is now a
  [`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)
  object, or `NULL` if the file is missing
  ([\#26](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/26)).
- Added optional `standards` and `terminology` fields to `_study.yml`.
  Each entry needs an `id` and a string `version`
  ([\#48](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/48),
  [\#62](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/62)).
- [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md),
  [`mighty_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  and
  [`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)
  gain a `.data` argument to build objects from an in-memory list
  ([\#51](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/51)).
- Added
  [`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
  [`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md)
  and
  [`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md).
  [`create_md()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md.md)
  returns all metadata data sets as a named list
  ([\#11](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/11)).
- Added `rows.row.subset` property and
  [`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
  ([\#36](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/36),
  [\#44](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/44)).
- Added
  [`filter_domains()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/filter_domains.md)
  to filter a `mighty_study` by domain prefix
  ([\#46](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/46)).
- [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  errors on wrongly named files in the specifications directory, and
  accepts both `AD*` and `MD*` files
  ([\#2](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/2),
  [\#46](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/46)).
- Column `depends` may only reference `rows.*` or `parameters.*`
  ([\#12](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/12)).
- [`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
  and
  [`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
  are faster
  ([\#10](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/10)).
- [`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md)
  now resolves `include` on columns within parameters
  ([\#52](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/52)).
- Requires S7schema \>= 0.2.1. `yaml` moved to Suggests
  ([\#57](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/57),
  [\#70](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/70)).
- Compatibility with the upcoming S7 release
  ([\#73](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/73)).

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
