# Getting Started

This vignette walks you through the key workflows for defining and
working with ADaM specifications: loading and editing a single domain,
assembling a multi-domain study, propagating metadata across domains,
applying conditional includes and row subsets, managing documents and
codelists, and producing flat output for downstream tooling.

mighty.metadata manages *specifications* (metadata) only; it does not
read or create ADaM datasets.

All examples use the specifications bundled with the package in
`system.file("examples", package = "mighty.metadata")`, so every code
chunk can be run as-is. One chunk also uses the withr package, which can
be installed with `install.packages("withr")`.

To start your own study, copy the bundled examples to a new directory
and edit the YAML files there:

``` r

dir.create("specs")
file.copy(
  list.files(
    system.file("examples", package = "mighty.metadata"),
    full.names = TRUE
  ),
  "specs"
)
study <- mighty_study("specs")
```

## The YAML Specification Format

Each ADaM domain is defined in a YAML file. The simplest case is a
subject-level dataset like ADSL, which has no parameters or rows:

``` yaml
id: ADSL
label: Subject-Level Analysis Dataset
class: SUBJECT LEVEL ANALYSIS DATASET
structure: One record per subject
keys: USUBJID

population:
  base:
    - domain: DM
      depends: USUBJID
      filter: USUBJID != ""
  global:
    - filter: RANDFL == "Y"
      depends: RANDFL

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

Every domain needs `id`, `label`, `class`, `structure`, `keys` and
`columns`; for columns only `id` is required. The optional `population`
block declares the source domains and filters used by the mighty code
generator.

BDS domains like ADVS can also have `parameters`, which override column
metadata for their records, and `rows`, which describe actions that add
or modify records (e.g. baseline):

``` yaml
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
for all fields and allowed values.

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

A domain can also be created from a list in memory with `.data`,
e.g. when specifications are generated programmatically:

``` r

mighty_domain(
  .data = list(
    id = "ADXX",
    label = "Example Dataset",
    class = "ADAM OTHER",
    structure = "One record per subject",
    keys = "USUBJID",
    columns = list(list(id = "USUBJID", label = "Unique Subject Identifier"))
  )
)
#> <mighty.metadata::mighty_domain>
#> ADXX: Example Dataset
#> Class: ADAM OTHER
#> Keys: USUBJID
```

A `mighty_domain` is a list, so any field can be read with `$` or `[[`:

``` r

advs$keys
#> [1] "USUBJID" "PARAMCD" "AVISITN"
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
  move_column(id = "PARAM", .pos = 3) |>
  remove_columns(id = "AVALC")

list_columns(advs)
#>  [1] "STUDYID"  "USUBJID"  "PARAM"    "SAFFL"    "TRTP"     "TRTA"    
#>  [7] "VISITNUM" "AVISITN"  "AVISIT"   "PARAMCD"  "AVAL"
```

Any column field (see
[`vignette("adam-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/adam-schema.md))
can be passed to
[`add_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md)
and
[`update_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md)
as a named argument. `.pos` sets the position; by default new items are
appended at the end.
[`update_column()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md)
only changes the given fields and keeps the column’s position.

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

Values outside the controlled terminology are rejected as well:

``` r

advs |> update_column(id = "AVAL", origin = "Calculated")
#> Error in `validate_S7schema()`:
#> ! /columns/11/origin must be equal to one of the allowed values
#> ✖ allowedValues: list("Assigned", "Collected", "Derived", "Not Available",
#>   "Other", "Predecessor", "Protocol")
#> ℹ current value: "Calculated"
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

Add a row action that uses a mighty component, update it and change its
position:

``` r

advs <- advs |>
  add_row(
    id = "LOCF",
    method = "Last observation carried forward",
    component = list(id = "locf", with = list(domain = "ADVS")),
    depends = "rows.BASELINE"
  ) |>
  update_row(id = "LOCF", method = "LOCF imputation for missing visits") |>
  move_row(id = "LOCF", .pos = 1)

list_rows(advs)
#> [1] "LOCF"     "BASELINE"
```

### Saving Changes

Write the modified domain back to YAML with
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md):

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
Besides the domain files, the directory can contain four optional
study-level files:

| File | Property | Content |
|----|----|----|
| `_study.yml` | `@study` | Study-level properties ([`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md)) |
| `_mighty.yml` | `@mighty` | mighty framework configuration ([`mighty_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)) |
| `_documents.yml` | `@documents` | Study documents ([`mighty_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)) |
| `_codelists.yml` | `@codelists` | Study codelists ([`mighty_codelists()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/codelists.md)) |

All other YAML files are loaded as domains and their file names must
start with `ad` or `md` (case-insensitive); any other name is an error.

``` r

study_path <- system.file("examples", package = "mighty.metadata")
study <- mighty_study(study_path)
study
#> <mighty.metadata::mighty_study/list/S7_object>
#> @ mighty: <mighty.metadata::mighty_config>
#> @ study: <mighty.metadata::study_config>
#> @ documents: 2 entries
#> @ codelists: 2 entries
#> $ ADAE: <mighty.metadata::mighty_domain>
#> $ ADSL: <mighty.metadata::mighty_domain>
#> $ ADVS: <mighty.metadata::mighty_domain>
```

The bundled examples include all four study-level files. When a file is
absent,
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
prints a message; `@documents` and `@codelists` are then empty, while
`@study` and `@mighty` are `NULL`.

Access individual domains with `$` and study-level properties with `@`:

``` r

names(study)
#> [1] "ADAE" "ADSL" "ADVS"
study@study$study_id
#> [1] "example_study"
study@mighty$repos
#> [1] "NovoNordisk-OpenSource/mighty.standards/components@main"
#> [2] "."
```

`_study.yml` holds the `study_id` and optionally the `standards` and
`terminology` used in the study. `_mighty.yml` lists the source domains
(`external_data`) and the repositories (`repos`) where mighty components
are found. See
[`vignette("study-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/study-schema.md)
and
[`vignette("mighty-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/mighty-schema.md)
for their structure.

Loading messages, such as the ones printed for missing study-level
files, can be silenced with the `mighty.metadata.verbosity_level` option
(see
[`?"mighty.metadata-options"`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty.metadata-options.md)):

``` r

withr::with_options(
  list(mighty.metadata.verbosity_level = "quiet"),
  mighty_study(study_path)
)
#> <mighty.metadata::mighty_study/list/S7_object>
#> @ mighty: <mighty.metadata::mighty_config>
#> @ study: <mighty.metadata::study_config>
#> @ documents: 2 entries
#> @ codelists: 2 entries
#> $ ADAE: <mighty.metadata::mighty_domain>
#> $ ADSL: <mighty.metadata::mighty_domain>
#> $ ADVS: <mighty.metadata::mighty_domain>
```

[`filter_domains()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/filter_domains.md)
keeps only domains whose names start with given prefixes, e.g. to drop
`MD*` domains:

``` r

study |>
  filter_domains(prefix = "AD") |>
  names()
#> [1] "ADAE" "ADSL" "ADVS"
```

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
reads these flags and appends the marked ADSL columns to the end of each
consumer domain as predecessor columns (`method: ADSL.<COLUMN>`,
`origin: Predecessor`). It errors if a consumer domain already has a
column with the same name, and only ADSL may mark columns with
`is_core`.

In YAML this looks like:

``` yaml
# adsl.yml
columns:
  - id: SEX
    label: Sex
    is_core: true

# adae.yml
id: ADAE
usecore: true
```

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
performs this lookup across the study for every predecessor column
(`method: DOMAIN.COLUMN` or `origin: Predecessor`):

- `origin` is set to `Predecessor`.
- Properties missing in the column (e.g. `label`, `format`, `codelist`)
  are copied from the referenced column; existing properties are not
  overwritten. `id`, `method`, `origin`, `is_core`, `component` and
  `depends` are never copied.
- If the referenced domain is not in the study (e.g. SDTM `DM`), only
  `origin` is set. If the domain exists but the column does not, it is
  an error.

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

# After: origin set to Predecessor
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
```

### Saving a Study

Write all domain files back to disk with
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md).
`_study.yml` and `_mighty.yml` are written when `@study` and `@mighty`
are set, and `_documents.yml` and `_codelists.yml` when `@documents` and
`@codelists` are not empty:

``` r

out <- tempfile()
dir.create(out)
write_config(study, path = out)
list.files(out)
#> [1] "_codelists.yml" "_documents.yml" "_mighty.yml"    "_study.yml"    
#> [5] "adae.yml"       "adsl.yml"       "advs.yml"
```

Omit `path` to write back to the original directory (`study@path`).

## Conditional Metadata

Pooled specifications can serve multiple studies by using conditional
`include` fields. Conditions are wrapped in `{braces}` and evaluated as
R expressions (via
[`glue::glue_data()`](https://glue.tidyverse.org/reference/glue.html))
against the study’s `@study` values. `include` can also be a plain
`true` or `false`:

``` yaml
columns:
  - id: STUDYID
    label: Study Identifier
    include: "{study_id == 'example_study'}"
  - id: SITEID
    label: Study Site Identifier
    include: false
```

The same condition set in R:

``` r

study <- mighty_study(study_path)

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

`include` can be applied to whole domains, columns, rows, parameters,
and individual columns within a parameter. A domain whose condition is
`FALSE` is removed from the study. `info` can hold any values used in
the conditions, not only `study_id`.

### Row Subsets

A row action can be restricted to a subset of the source rows with the
`subset` field (e.g. `subset: STUDYID == 'STUDY1'`).
[`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
folds the subset into the row’s mighty component so that the generated
code only uses those rows. See
[`?resolve_subsets`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
for details and requirements.

## Documents

Study-level documents (e.g. the SAP) are stored in `_documents.yml` and
available as `@documents`. Each document has an `id`, `title`, `href`
and a `doctype` of `"suppdoc"`, `"comment"` or `"method"`. The bundled
`_documents.yml` contains:

``` yaml
- id: SAP
  title: Statistical Analysis Plan
  doctype: suppdoc
  href: ./docs/sap.pdf

- id: DERIV_METHODS
  title: Derivation Methods
  doctype: method
  href: ./docs/methods.pdf
```

``` r

list_documents(study)
#> [1] "SAP"           "DERIV_METHODS"
```

Domains and columns (including columns within parameters) reference
documents by `id` in their `documents` field, optionally with a `page`:

``` yaml
columns:
  - id: SAFFL
    label: Safety Population Flag
    origin: Derived
    documents:
      - id: DERIV_METHODS
        page: 12
```

The
[`list_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
[`select_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
[`add_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md),
[`update_document()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
and
[`remove_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
verbs work on both a study and a
[`mighty_documents()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
object:

``` r

study <- study |>
  add_document(
    id = "PROTOCOL",
    title = "Study Protocol",
    doctype = "suppdoc",
    href = "./docs/protocol.pdf"
  )

list_documents(study)
#> [1] "SAP"           "DERIV_METHODS" "PROTOCOL"
```

References can also be added in R:

``` r

study$ADSL <- study$ADSL |>
  update_column(id = "SAFFL", documents = list(list(id = "SAP", page = 12)))
```

[`check_document_references()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/documents.md)
verifies that every referenced document exists, that `"method"`
documents are only used where `origin` is `"Derived"`, and warns when a
`"comment"` document is referenced without a `comment`:

``` r

check_document_references(study)
```

## Codelists

Codelists are stored in `_codelists.yml` and available as `@codelists`.
A codelist is either sponsor-defined (`values`) or records changes to an
external codelist, such as CDISC CT, through `subset`, `restore` and
`extend`. The bundled `_codelists.yml` contains one sponsor-defined
codelist (`SEX`) and one that modifies an external codelist (`AGEU`, via
`subset` and `restore`):

``` yaml
# Sponsor-defined codelist
- id: SEX
  label: Sex
  description: Sex of the subject
  datatype: text
  values:
    - code: F
      decode: Female
    - code: M
      decode: Male

# Keep only some values of an external codelist and restore one more
- id: AGEU
  subset:
    - code: YEARS
  restore:
    - code: MONTHS
```

``` r

list_codelists(study)
#> [1] "SEX"  "AGEU"
select_codelist(study, id = "SEX") |>
  str()
#> List of 5
#>  $ id         : chr "SEX"
#>  $ label      : chr "Sex"
#>  $ description: chr "Sex of the subject"
#>  $ datatype   : chr "text"
#>  $ values     :List of 2
#>   ..$ :List of 2
#>   .. ..$ code  : chr "F"
#>   .. ..$ decode: chr "Female"
#>   ..$ :List of 2
#>   .. ..$ code  : chr "M"
#>   .. ..$ decode: chr "Male"
```

Columns refer to a codelist by its `id` in their `codelist` field, as
`SEX` and `AGEU` do in the bundled `adsl.yml`:

``` yaml
columns:
  - id: SEX
    label: Sex
    codelist: SEX
```

Codelists can also be added in R. Here we add a sponsor-defined value to
the extensible external `LOC` codelist:

``` r

study <- study |>
  extend_codelist_values(
    id = "LOC",
    code = "MY CUSTOM LOCATION",
    decode = "My Custom Location"
  )

list_codelists(study)
#> [1] "SEX"  "AGEU" "LOC"
```

Codelists can be added before any column uses them. Use
[`check_codelist_references()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/codelists.md)
to check that every codelist is referenced:

``` r

check_codelist_references(study)
#> Error in `check_codelist_references()`:
#> ! Codelist "LOC" is not referenced by any column.
#> ℹ Reference the codelist in a column codelist field or remove it from
#>   _codelists.yml.
```

``` r

study$ADVS <- study$ADVS |>
  add_column(
    id = "VSLOC",
    label = "Location of Vital Signs Measurement",
    codelist = "LOC"
  )

check_codelist_references(study)
```

See
[`vignette("codelists-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/codelists-schema.md)
for all operation groups and validation rules, and
[`?list_codelists`](https://novonordisk-opensource.github.io/mighty.metadata/reference/codelists.md)
for all codelist verbs.

## Creating Flat Metadata Tables

A set of `create_md_*()` functions flattens the study specifications
into tibbles. This is the format consumed by downstream mighty tools.

[`create_md_table()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_table.md)
gives one row per dataset:

``` r

create_md_table(study)
#> # A tibble: 3 × 8
#>   order id    label                       class subclass structure keys  comment
#>   <int> <chr> <chr>                       <chr> <chr>    <chr>     <lis> <chr>  
#> 1     1 ADAE  Adverse Events Analysis Da… OCCU… ADVERSE… One reco… <chr> NA     
#> 2     2 ADSL  Subject-Level Analysis Dat… SUBJ… NA       One reco… <chr> NA     
#> 3     3 ADVS  Vital Signs Analysis Datas… BASI… NA       One reco… <chr> NA
```

[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)
gives one row per column:

``` r

create_md_col(study)
#> # A tibble: 33 × 15
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
#> # ℹ 23 more rows
#> # ℹ 5 more variables: codelist <chr>, format_type <chr>, format_length <int>,
#> #   format_display <chr>, comment <chr>
```

[`create_md_param()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_param.md)
gives one row per BDS parameter:

``` r

create_md_param(study)
#> # A tibble: 2 × 5
#>   table_id table_label                  order id     label                   
#>   <chr>    <chr>                        <int> <chr>  <chr>                   
#> 1 ADVS     Vital Signs Analysis Dataset     1 BMI    Body Mass Index (kg/m^2)
#> 2 ADVS     Vital Signs Analysis Dataset     2 BMIGRP Body Mass Index Group
```

[`create_md_values()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_values.md)
gives one row per column defined inside a parameter, i.e. the value
level metadata:

``` r

create_md_values(study)
#> # A tibble: 3 × 15
#>   table_id table_label param_order param_id param_label order id    label origin
#>   <chr>    <chr>             <int> <chr>    <chr>       <int> <chr> <chr> <chr> 
#> 1 ADVS     Vital Sign…           1 BMI      Body Mass …     1 AVAL  NA    NA    
#> 2 ADVS     Vital Sign…           2 BMIGRP   Body Mass …     1 AVALC NA    NA    
#> 3 ADVS     Vital Sign…           2 BMIGRP   Body Mass …     2 AVAL  NA    NA    
#> # ℹ 6 more variables: method <chr>, codelist <chr>, format_type <chr>,
#> #   format_length <int>, format_display <chr>, comment <chr>
```

The tables reflect the study as it is, so populate and resolve it first.
A typical end-to-end workflow:

``` r

md_col <- mighty_study(study_path, populate = TRUE) |>
  resolve_includes() |>
  resolve_subsets() |>
  create_md_col()

md_col
#> # A tibble: 32 × 15
#>    table_id table_label      order id    label origin key   is_core core  method
#>    <chr>    <chr>            <int> <chr> <chr> <chr>  <lgl> <lgl>   <chr> <chr> 
#>  1 ADAE     Adverse Events …     1 STUD… Stud… Prede… FALSE NA      Req   AE.ST…
#>  2 ADAE     Adverse Events …     2 USUB… Uniq… Prede… TRUE  NA      Req   AE.US…
#>  3 ADAE     Adverse Events …     3 AESEQ Sequ… Prede… TRUE  NA      Cond  AE.AE…
#>  4 ADAE     Adverse Events …     4 AETE… Repo… Prede… FALSE NA      Req   AE.AE…
#>  5 ADAE     Adverse Events …     5 AEDE… Dict… Prede… FALSE NA      Cond  AE.AE…
#>  6 ADAE     Adverse Events …     6 AEBO… Body… Prede… FALSE NA      Cond  AE.AE…
#>  7 ADAE     Adverse Events …     7 ASTDT Anal… NA     FALSE NA      Cond  Deriv…
#>  8 ADAE     Adverse Events …     8 AENDT Anal… NA     FALSE NA      Cond  Deriv…
#>  9 ADAE     Adverse Events …     9 TRTE… Trea… NA     FALSE NA      Cond  Deriv…
#> 10 ADSL     Subject-Level A…     1 STUD… Stud… Prede… FALSE NA      Req   DM.ST…
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
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
for saving changes,
[`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md)
and
[`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md)
for conditional specifications, documents and codelists, and the
`create_md_*()` functions for flat output.

To learn more:

- [`vignette("adam-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/adam-schema.md)
  documents the domain YAML schema reference
- [`vignette("study-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/study-schema.md)
  documents the study YAML schema reference
- [`vignette("mighty-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/mighty-schema.md)
  documents the mighty YAML schema reference
- [`vignette("codelists-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/codelists-schema.md)
  documents the codelists YAML schema reference
- The [package
  reference](https://novonordisk-opensource.github.io/mighty.metadata/reference/index.html)
  lists all available functions
