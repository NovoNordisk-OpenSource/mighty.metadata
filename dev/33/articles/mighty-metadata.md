# Getting Started

This vignette walks you through the key workflows for defining and
working with ADaM specifications: loading and editing a single domain,
assembling a multi-domain study, propagating metadata across domains,
applying conditional includes, and producing flat output for downstream
tooling.

## The YAML Specification Format

Each ADaM domain is defined in a YAML file. The simplest case is a
subject-level dataset like ADSL, which only has columns:

``` yaml
id: ADSL
label: Subject-Level Analysis Dataset
class: SUBJECT LEVEL ANALYSIS DATASET
structure: One record per subject
keys: USUBJID

population:
  base:
    - domain: DM
      depends: [USUBJID]
      filter: USUBJID != ""

columns:
  - id: STUDYID
    label: Study Identifier
    method: DM.STUDYID
    core: Req
  - id: USUBJID
    label: Unique Subject Identifier
    method: DM.USUBJID
    core: Req
  # ... more columns ...
```

Top-level keys define the domain identity (`id`, `label`, `class`,
`structure`, `keys`). The `population` block declares which source
domains supply raw data and what row-level filters apply. The mighty
code generator reads this to build the initial population step;
mighty.metadata stores it but does not execute it.

Each column has an `id`, `label`, and `core` conformance level: `Req`
(Required), `Cond` (Conditionally Required), or `Perm` (Permissible).
The `method` field describes how the column is derived. A
`DOMAIN.COLUMN` pattern (e.g., `DM.STUDYID`) means the column is a
predecessor — its metadata can be inherited from the referenced source
via
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md).

BDS (Basic Data Structure) domains like ADVS add `parameters` and
`rows`:

``` yaml
id: ADVS
label: Vital Signs Analysis Dataset
keys: [USUBJID, PARAMCD, AVISITN]

parameters:
  - id: BMI
    label: Body Mass Index (kg/m^2)
    columns:
      - id: AVAL
        method: Derived from height and weight

rows:
  - id: BASELINE
    method: Add baseline visit as a new row
```

See
[`vignette("adam-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/adam-schema.md)
for the full schema reference.

## Working with a Single Domain

The package provides a consistent set of verbs for columns, parameters,
and rows:

| Action | Columns | Parameters | Rows |
|----|----|----|----|
| List | [`list_columns()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md) | [`list_parameters()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md) | [`list_rows()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md) |
| Select | [`select_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md) | [`select_parameter()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md) | [`select_row()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md) |
| Add | [`add_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md) | [`add_parameter()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md) | [`add_row()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md) |
| Update | [`update_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md) | [`update_parameter()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md) | [`update_row()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md) |
| Move | [`move_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md) | [`move_parameter()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md) | [`move_row()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md) |
| Remove | [`remove_columns()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md) | [`remove_parameters()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md) | [`remove_rows()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md) |

The `remove_*` functions accept a character vector to remove multiple
items at once.

### Loading and Inspecting

Load a domain specification from a YAML file with
[`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md).
The file is validated against the ADaM JSON schema on load.

``` r

path <- system.file("examples", "advs.yml", package = "mighty.metadata")
advs <- mighty_domain(path)
advs
#> <mighty.metadata::mighty_domain>
#> ADVS: Vital Signs Analysis Dataset
#> Class: BASIC DATA STRUCTURE
#> Keys: USUBJID, PARAMCD, and AVISITN
```

Use `list_*()` functions to see what the specification contains:

``` r

list_columns(advs)
#>  [1] "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN" 
#>  [7] "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"
list_parameters(advs)
#> [1] "BMI"    "BMIGRP"
list_rows(advs)
#> [1] "BASELINE"
```

Drill into a specific column with
[`select_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md):

``` r

select_column(advs, id = "AVAL") |>
  str()
#> List of 4
#>  $ id    : chr "AVAL"
#>  $ label : chr "Analysis Value"
#>  $ method: chr "VS.VSSTRESN"
#>  $ core  : chr "Req"
```

### Modifying Columns

Every modification automatically re-validates the domain against the
schema. All column functions return the modified domain, so they compose
naturally into a pipe chain. Here we add an actual treatment column
sourced from ADSL, update a label, and drop an unused column:

``` r

advs <- mighty_domain(path) |>
  add_column(
    id = "TRTA",
    label = "Actual Treatment",
    method = "ADSL.TRT01A",
    .pos = 5
  ) |>
  update_column(id = "AVAL", label = "Analysis Value (Numeric)") |>
  remove_columns(id = "AVALC")

list_columns(advs)
#>  [1] "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "TRTA"     "VISITNUM"
#>  [7] "AVISITN"  "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"
```

#### Schema Validation

Validation runs on every modification and on initial load. You can also
call
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
explicitly at any time:

``` r

validate(advs)
```

If a modification violates the schema, you get an immediate error. For
example, adding a column with a duplicate ID fails:

``` r

advs |> add_column(id = "AVAL", label = "Duplicate")
#> Error in `check_unique_ids()`:
#> ! Duplicate `id` entries found:
#> ✖ columns.id: AVAL
```

### Modifying Parameters

Parameters use the same verbs. The key difference is the `columns`
argument in
[`add_parameter()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md),
which accepts a nested list of column overrides specific to that
parameter:

``` r

select_parameter(advs, id = "BMI") |>
  str()
#> List of 3
#>  $ id     : chr "BMI"
#>  $ label  : chr "Body Mass Index (kg/m^2)"
#>  $ columns:List of 1
#>   ..$ :List of 2
#>   .. ..$ id    : chr "AVAL"
#>   .. ..$ method: chr "Derived from height and weight"
```

``` r

advs <- advs |>
  add_parameter(
    id = "WSTCIR",
    label = "Waist Circumference (cm)",
    columns = list(
      list(id = "AVAL", method = "VS.VSSTRESN")
    )
  )

list_parameters(advs)
#> [1] "BMI"    "BMIGRP" "WSTCIR"
```

Update and remove work as expected:

``` r

advs <- advs |>
  update_parameter(id = "WSTCIR", label = "Waist Circumference") |>
  remove_parameters(id = "BMIGRP")

list_parameters(advs)
#> [1] "BMI"    "WSTCIR"
```

### Rows

Rows follow the same pattern. Inspect a row with
[`select_row()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md):

``` r

select_row(advs, id = "BASELINE") |>
  str()
#> List of 2
#>  $ id    : chr "BASELINE"
#>  $ method: chr "Add baseline visit as a new row"
```

### Saving Changes

Write the modified domain back to YAML with
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html):

``` r

out <- tempfile(fileext = ".yml")
write_config(advs, path = out)
```

The written file can be loaded back with
[`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md).

## Working with a Study

### Loading a Study

Load all domain specifications from a directory with
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).
The directory can contain `_study.yml` (study-level properties) and
`_mighty.yml` (mighty framework configuration).

``` r

study_path <- system.file("examples", package = "mighty.metadata")
study <- mighty_study(study_path)
#> → No `documents.yml` file found
study
#> <mighty.metadata::mighty_study/list/S7_object>
#> @ mighty: <mighty.metadata::mighty_config>
#> @ study: `study_id`
#> $ ADAE: <mighty.metadata::mighty_domain>
#> $ ADSL: <mighty.metadata::mighty_domain>
#> $ ADVS: <mighty.metadata::mighty_domain>
```

Access individual domains with `$`. Study-level properties from
`_study.yml` are stored in `@study` and mighty framework configuration
from `_mighty.yml` is stored in `@mighty`. The `@` operator accesses
properties of S7 objects:

``` r

names(study)
#> [1] "ADAE" "ADSL" "ADVS"
str(study@study)
#> List of 1
#>  $ study_id: chr "example_study"
str(study@mighty)
#> <mighty.metadata::mighty_config> List of 2
#>  $ external_data:List of 3
#>   ..$ :List of 2
#>   .. ..$ id  : chr "DM"
#>   .. ..$ keys: chr [1:2] "STUDYID" "USUBJID"
#>   ..$ :List of 2
#>   .. ..$ id  : chr "VS"
#>   .. ..$ keys: chr [1:2] "STUDYID" "USUBJID"
#>   ..$ :List of 2
#>   .. ..$ id  : chr "AE"
#>   .. ..$ keys: chr [1:2] "STUDYID" "USUBJID"
#>  $ repos        : chr [1:2] "NovoNordisk-OpenSource/mighty.standards/components@main" "."
#>  @ schema   : chr "/home/runner/work/_temp/Library/mighty.metadata/schema/mighty.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x555a38dc9a00> 
#>  @ file     : chr "/home/runner/work/_temp/Library/mighty.metadata/examples/_mighty.yml"
```

The `_study.yml` file provides the `study_id`. The `_mighty.yml` file
provides `external_data` definitions (source domains and their keys).

### Populating Core Variables

A “core variable” is an ADSL column that should appear in every consumer
domain (ADVS, ADAE, etc.) as a predecessor column — for example, SEX and
RACE for subgroup analyses.

Note: `core` (string: Req/Cond/Perm) records the ADaM conformance level
and is unrelated to “core variable” propagation. The two fields that
control propagation are:

- `is_core` (Boolean, column-level in ADSL) — marks a column for
  propagation to consumer domains.
- `usecore` (Boolean, domain-level) — signals that a domain should
  receive the propagated columns. This is a top-level YAML property on
  the consumer domain, so it is set via list assignment rather than
  [`update_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md).

[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
reads these flags and adds the marked ADSL columns to each consumer
domain as predecessor columns.

The bundled examples do not include these fields, so we add them here to
demonstrate the workflow:

``` r

study$ADSL <- study$ADSL |>
  update_column(id = "SEX", is_core = TRUE) |>
  update_column(id = "RACE", is_core = TRUE)

study$ADAE[["usecore"]] <- TRUE

study <- study |>
  populate_core()

list_columns(study$ADAE)
#>  [1] "STUDYID"  "USUBJID"  "AESEQ"    "AETERM"   "AEDECOD"  "AEBODSYS"
#>  [7] "ASTDT"    "AENDT"    "TRTEMFL"  "SEX"      "RACE"
```

SEX and RACE now appear in ADAE as predecessor columns sourced from
ADSL.

### Populating Predecessor Metadata

Columns that reference another domain (e.g., `method: ADSL.SAFFL`) can
inherit metadata from the referenced column.
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
performs this lookup across the study, filling in only missing
properties.

``` r

# Before: SAFFL in ADVS references ADSL.SAFFL
select_column(study$ADVS, id = "SAFFL") |>
  str()
#> List of 4
#>  $ id    : chr "SAFFL"
#>  $ label : chr "Safety Population Flag"
#>  $ method: chr "ADSL.SAFFL"
#>  $ core  : chr "Req"
```

``` r

study <- study |> populate_sparse()

# After: origin inherited from ADSL
select_column(study$ADVS, id = "SAFFL") |>
  str()
#> List of 5
#>  $ id    : chr "SAFFL"
#>  $ label : chr "Safety Population Flag"
#>  $ method: chr "ADSL.SAFFL"
#>  $ core  : chr "Req"
#>  $ origin: chr "Predecessor"
```

### The Complete Study Pipeline

Here is the full pipeline in one block:

``` r

study <- mighty_study(study_path)
#> → No `documents.yml` file found

# Mark ADSL core variables
study$ADSL <- study$ADSL |>
  update_column(id = "SEX", is_core = TRUE) |>
  update_column(id = "RACE", is_core = TRUE)

# Mark consumer domains
study$ADAE[["usecore"]] <- TRUE

# Run the pipeline
study <- study |>
  populate_core() |>
  populate_sparse()
```

If your YAML files already include the `is_core` and `usecore` flags,
the entire pipeline collapses to a single call. Passing
`populate = TRUE` is equivalent to calling
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
then
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
after loading:

``` r

study <- mighty_study(study_path, populate = TRUE)
#> → No `documents.yml` file found
```

### Saving a Study

Write all domain files, `_study.yml`, and `_mighty.yml` back to disk
with
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html):

``` r

out <- withr::local_tempdir()
write_config(study, path = out)
list.files(out)
#> [1] "_mighty.yml" "_study.yml"  "adae.yml"    "adsl.yml"    "advs.yml"
```

Omit `path` to write back to the original directory (`study@path`).

## Conditional Metadata

Pooled specifications can serve multiple studies by using conditional
`include` fields. Conditions are wrapped in `{braces}` and evaluated as
R expressions (via
[`glue::glue_data()`](https://glue.tidyverse.org/reference/glue.html))
against the study’s `@study` values.

``` r

study <- mighty_study(study_path)
#> → No `documents.yml` file found

study$ADVS <- study$ADVS |>
  update_column(
    id = "STUDYID",
    include = "{study_id == 'example_study'}"
  )
```

When `study_id` in `@study` matches, the condition is `TRUE` and the
column is kept:

``` r

resolved <- resolve_includes(study)
list_columns(resolved$ADVS)
#>  [1] "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN" 
#>  [7] "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"
```

Override with a different value and the column is removed:

``` r

resolved <- resolve_includes(study, info = list(study_id = "other"))
list_columns(resolved$ADVS)
#>  [1] "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN"  "AVISIT"  
#>  [7] "PARAMCD"  "PARAM"    "AVAL"     "AVALC"
```

`include` works on parameters and rows too, not just columns.

## Creating a Flat Column Table

[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)
flattens the study’s column specifications into a single tibble. This is
the format consumed by downstream mighty tools.

``` r

create_md_col(study)
#> # A tibble: 32 × 15
#>    table_id table_label      order id    label origin key   is_core core  method
#>    <chr>    <chr>            <int> <chr> <chr> <chr>  <lgl> <lgl>   <chr> <chr> 
#>  1 ADAE     Adverse Events …     1 STUD… Stud… NA     FALSE NA      Req   AE.ST…
#>  2 ADAE     Adverse Events …     2 USUB… Uniq… NA     TRUE  NA      Req   AE.US…
#>  3 ADAE     Adverse Events …     3 AESEQ Sequ… NA     TRUE  NA      Cond  AE.AE…
#>  4 ADAE     Adverse Events …     4 AETE… Repo… NA     FALSE NA      Req   AE.AE…
#>  5 ADAE     Adverse Events …     5 AEDE… Dict… NA     FALSE NA      Cond  AE.AE…
#>  6 ADAE     Adverse Events …     6 AEBO… Body… NA     FALSE NA      Cond  AE.AE…
#>  7 ADAE     Adverse Events …     7 ASTDT Anal… NA     FALSE NA      Cond  Deriv…
#>  8 ADAE     Adverse Events …     8 AENDT Anal… NA     FALSE NA      Cond  Deriv…
#>  9 ADAE     Adverse Events …     9 TRTE… Trea… NA     FALSE NA      Cond  Deriv…
#> 10 ADSL     Subject-Level A…     1 STUD… Stud… NA     FALSE NA      Req   DM.ST…
#> # ℹ 22 more rows
#> # ℹ 5 more variables: codelist <chr>, format_type <chr>, format_length <int>,
#> #   format_display <chr>, comment <chr>
```

## Next Steps

This vignette covered the core workflows:
[`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
for single datasets,
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
for collections,
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
and
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
for metadata propagation,
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
for saving changes,
[`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md)
for conditional specifications, and
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)
for flat output.

To learn more:

- [`vignette("adam-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/adam-schema.md)
  documents the domain YAML schema reference
- [`vignette("study-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/study-schema.md)
  documents the study YAML schema reference
- [`vignette("mighty-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/mighty-schema.md)
  documents the mighty YAML schema reference
- The [package
  reference](https://novonordisk-opensource.github.io/mighty.metadata/reference/index.html)
  lists all available functions
