# Codelists specifications

`_codelists.yml` defines the codelists used in a study. It is an
optional file in the study directory. Load it with
[`mighty_codelists()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/codelists.md),
either directly or as the `@codelists` property of
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).
Columns refer to a codelist by its `id` in their `codelist` field. The
file structure is defined by a [JSON-schema](https://json-schema.org)
accessible with:

``` r

system.file("schema", "codelists.json", package = "mighty.metadata")
```

## Structure

The file is a list of codelists. Each codelist has the following fields:

| Field | Type | Description |
|----|----|----|
| `id` | string | Unique id used to reference the codelist from column metadata (required) |
| `label` | string | Codelist label |
| `description` | string | Codelist description |
| `datatype` | string | Data type of the coded values: `text`, `integer` or `float` |
| `values` | list | Values of a sponsor-defined codelist |
| `subset` | list | Values to keep from an external codelist |
| `restore` | list | SDTM CT values to include even when not used in the SDTM define.xml |
| `extend` | list | Values extending an extensible external codelist |

Entries in `values` and `extend` have a `code` and an optional `decode`
(intended for `TranslatedText` in define.xml); entries in `subset` and
`restore` have only a `code`. Each group must have at least one entry,
and within a group either all or none of the entries have a `decode`.

## Operation groups

Each codelist has an `id` and at least one of four operation groups. The
groups fall into two kinds: a sponsor-defined codelist, or changes to a
codelist from an external source of controlled terminology (e.g. CDISC
CT).

| Group | Kind | Entries | Purpose |
|----|----|----|----|
| `values` | Sponsor-defined | `code`, optional `decode` | Defines all values of a codelist that does not exist externally |
| `subset` | External | `code` | Keeps only these values from the external codelist |
| `restore` | External | `code` | Includes SDTM controlled terminology values in the ADaM codelist even when they are not used in the SDTM define.xml |
| `extend` | External | `code`, optional `decode` | Adds sponsor-defined values to an extensible external codelist |

A codelist with `values` must also have `label`, `description` and
`datatype`. For the other groups these fields are optional, as they come
from the external codelist.

`values` cannot be combined with `subset` or `restore` on the same
codelist. Codelist `id`s must be unique, and `code` must be unique
across all groups within a codelist (compared as text, so `1` and `"1"`
are duplicates).

## Example

``` yaml
# A sponsor-defined codelist
- id: REGION
  label: Codelist for region
  description: Region codelist
  datatype: text
  values:
    - code: EUROPE
      decode: Europe
    - code: NORTH AMERICA
      decode: North America

# Keep two values of an external codelist and restore one more
- id: AGEU
  subset:
    - code: YEARS
    - code: MONTHS
  restore:
    - code: DAYS

# Add a sponsor-defined value to an extensible external codelist
- id: LOC
  extend:
    - code: MY CUSTOM LOCATION
      decode: My Custom Location
```

A column refers to a codelist by its `id`:

``` yaml
columns:
  - id: REGION
    label: Region
    codelist: REGION
```

Codelists do not have to be referenced by a column, e.g. when they are
added before the columns that use them. Use
[`check_codelist_references()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/codelists.md)
to check that every codelist in a study is referenced by at least one
column (including columns within parameters). It does not check the
opposite direction: a column referring to a codelist that is not defined
in `_codelists.yml` is not reported.

`code` can be a string or a number. Since yaml infers types, unquoted
values that look like numbers (e.g. `code: 1`) are read as numbers.
