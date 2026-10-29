# mighty.metadata 0.2.0

* Added `mighty_codelists()` class for study-level codelist metadata in
  `_codelists.yml`, available as `mighty_study()@codelists` (#49).
* Added `mighty_documents()` class for study-level document metadata in
  `_documents.yml`, available as `mighty_study()@documents`. Call
  `check_document_references()` to verify references (#27, #72).
* Added `mighty_config()` class for `_mighty.yml`. `mighty_study()@mighty` is
  now a `mighty_config()` object, or `NULL` if the file is missing (#25).
* `_mighty.yml` requires a non-empty `repos` field (#24, #65).
* Added `study_config()` class for `_study.yml`. `mighty_study()@study` is now
  a `study_config()` object, or `NULL` if the file is missing (#26).
* Added optional `standards` and `terminology` fields to `_study.yml`. Each
  entry needs an `id` and a string `version` (#48, #62).
* `mighty_domain()`, `mighty_config()` and `study_config()` gain a `.data`
  argument to build objects from an in-memory list (#51).
* Added `create_md_table()`, `create_md_param()` and `create_md_values()`.
  `create_md()` returns all metadata data sets as a named list (#11).
* Added `rows.row.subset` property and `resolve_subsets()` (#36, #44).
* Added `filter_domains()` to filter a `mighty_study` by domain prefix (#46).
* `mighty_study()` errors on wrongly named files in the specifications
  directory, and accepts both `AD*` and `MD*` files (#2, #46).
* Column `depends` may only reference `rows.*` or `parameters.*` (#12).
* `populate_core()` and `populate_sparse()` are faster (#10).
* `resolve_includes()` now resolves `include` on columns within parameters
  (#52).
* Requires S7schema >= 0.2.1. `yaml` moved to Suggests (#57, #70).
* Compatibility with the upcoming S7 release (#73).

# mighty.metadata 0.1.0

* Initial CRAN submission.
* Core classes: `mighty_domain()` for single ADaM datasets and
  `mighty_study()` for full studies.
* Column, parameter, and row manipulation verbs: `list_*()`, `add_*()`,
  `remove_*()`, `update_*()`, `select_*()`, `move_*()`.
* Study-level operations: `populate_core()`, `populate_sparse()`, and
  `resolve_includes()`.
