# Changelog

## mighty.metadata (development version)

- Added
  [`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md),
  [`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md),
  and
  [`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)
  to create metadata data sets for tables, BDS parameters, and value
  level metadata, complementing
  [`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)
  ([\#11](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/11)).
  [`create_md()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md.md)
  returns all four as a named list.

- Added
  [`mighty_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  class for the `_mighty.yml` configuration file
  ([\#25](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/25)).
  The `@mighty` property of
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  now holds a
  [`mighty_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  object instead of a plain list, and is `NULL` when no `_mighty.yml`
  exists.

- Added
  [`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)
  class for the `_study.yml` configuration file
  ([\#26](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/26)).
  The `@study` property of
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  now holds a
  [`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)
  object instead of a plain list, and is `NULL` when no `_study.yml`
  exists.

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
