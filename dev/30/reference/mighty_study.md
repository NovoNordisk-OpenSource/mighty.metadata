# Mighty Study

Creates a `mighty_study` object by loading all YAML metadata files from
a directory. Each YAML file (except `_mighty.yml` and `_study.yml`) is
parsed as a
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
object. The optional `_study.yml` file provides study-level properties
and the optional `_mighty.yml` file provides mighty framework
configuration.

## Usage

``` r
mighty_study(path, populate = FALSE)
```

## Arguments

- path:

  `character(1)` path to a directory containing YAML metadata files.

- populate:

  `logical(1)` if `TRUE`, calls
  [`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
  then
  [`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
  before returning. Default is `FALSE`.

## Value

A `mighty_study` S7 object extending `list`:

- List elements:

  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  objects, named by their `id` field. Access via e.g. `study$adsl`.

- `@study`:

  Study-level properties from `_study.yml`, or empty list if no
  properties file exists.

- `@mighty`:

  A `mighty_config` object loaded from `_mighty.yml`, or `NULL` if no
  configuration file exists.

- `@path`:

  The source directory path as `character(1)`.

## Details

The function scans the directory for files matching `*.yaml` or `*.yml`:

- Files named `_study.yml` or `_study.yaml` are treated as study
  properties

- Files named `_mighty.yml` or `_mighty.yaml` are treated as mighty
  framework config

- All other YAML files must follow ADaM naming conventions (starting
  with `ad`) and are loaded as
  [mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  objects

- Only one `_mighty.yml` and one `_study.yml` file is allowed per
  directory

## Write Study Metadata

Use
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
to serialize a `mighty_study()` object back to YAML files. Each domain
is written as a separate file, plus `_mighty.yml` and `_study.yml` when
non-empty.

If `path` is `NULL` (default), files are written to `x@path`.

## See also

[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md),
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html),
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md),
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md),
[`create_md_col()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/create_md_col.md)

## Examples

``` r
# Load example study
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)

# List tables with metadata
names(study)
#> [1] "ADAE" "ADSL" "ADVS"

# Access ADVS
study$ADVS
#> <mighty.metadata::mighty_domain>
#> ADVS: Vital Signs Analysis Dataset
#> Class: BASIC DATA STRUCTURE
#> Keys: USUBJID, PARAMCD, and AVISITN

# Access study-level properties
study@study
#> $study_id
#> [1] "example_study"
#> 

# Access mighty framework configuration
study@mighty
#> <mighty.metadata::mighty_config>
#> External data: 3 sources (`DM`, `VS`, and `AE`)

# Load and populate in one step
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata"),
  populate = TRUE
)

# Write study back to YAML
tmp <- tempdir()
write_config(study, path = tmp)
```
