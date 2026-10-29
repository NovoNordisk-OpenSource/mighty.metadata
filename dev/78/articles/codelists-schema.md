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

Below you can find a detailed description of the structure.

## Mighty Metadata Codelists Specification

Schema for study-level codelist definitions and value-level overrides
referenced from ADaM domain metadata

| Type  | Items                 | Unique Items |
|:------|:----------------------|:-------------|
| array | [codelist](#codelist) | Yes          |

## Definitions

### code

Coded value

#### anyOf

### decoded_value

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | code     | No                    |

#### Properties

| Name   | Description                           | Type          | Required |
|:-------|:--------------------------------------|:--------------|:---------|
| code   |                                       | [code](#code) | Yes      |
| decode | Decode text rendered as in define.xml | string        | No       |

### coded_value

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | code     | No                    |

#### Properties

| Name | Required | Type          |
|:-----|:---------|:--------------|
| code | Yes      | [code](#code) |

### codelist

[TABLE]

#### Properties

| Name | Description | Type | Enum | Min Items | Items | Required |
|:---|:---|:---|:---|---:|:---|:---|
| id | Unique id used to reference the codelist from column metadata | string | NULL |  | NULL | Yes |
| label | Codelist label | string | NULL |  | NULL | No |
| description | Codelist description | string | NULL |  | NULL | No |
| datatype | Data type of the coded values | string | text , integer, float |  | NULL | No |
| values | Values of a sponsor-defined (non-standard) codelist | array | NULL | 1 | [decoded_value](#decoded_value) | No |
| subset | Values to keep from a standard controlled terminology codelist | array | NULL | 1 | [coded_value](#coded_value) | No |
| restore | SDTM controlled terminology values to include in the ADaM codelist even when not used in the SDTM define.xml | array | NULL | 1 | [coded_value](#coded_value) | No |
| extend | Values extending an extensible codelist | array | NULL | 1 | [decoded_value](#decoded_value) | No |

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
codelist. `code` must be unique across all groups within a codelist.

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
to check that every codelist in a study is referenced.

`code` can be a string or a number. Since yaml infers types, unquoted
values that look like numbers (e.g. `code: 1`) are read as numbers.
