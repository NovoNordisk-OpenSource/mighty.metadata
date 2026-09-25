# Study specifications

`_study.yml` provides study-level properties for a study directory — the
study identifier, an optional description, and the standards and
terminologies applied in the study. Load it with
[`study_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md),
either directly or as the `@study` property of
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).
The file structure is defined by a
[JSON-schema](https://json-schema.org) accessible with:

``` r

system.file("schema", "study.json", package = "mighty.metadata")
```

Below you can find a detailed description of the structure.

## Study Specification

Schema for study-level properties in the mightyverse

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | study_id | Yes                   |

### Properties

| Name | Description | Type | Items | Required |
|:---|:---|:---|:---|:---|
| study_id | Unique identifier of the study | string | NULL | Yes |
| study_description | Description of the study | string | NULL | No |
| standards | Standards applied in the study | array | [versioned_entry](#versioned_entry) | No |
| terminology | Controlled terminologies applied in the study | array | [versioned_entry](#versioned_entry) | No |

## Definitions

### versioned_entry

Entry identified by an id and a version

[TABLE]

#### Properties

| Name | Description | Type | Required |
|:---|:---|:---|:---|
| id | Identifier of the entry | string | Yes |
| version | Version of the entry. Must be a string; quote values that look like numbers (e.g. ‘27.0’) | string | Yes |

### Standards and terminology

`standards` and `terminology` are optional lists describing the
standards and controlled terminologies applied in the study. Each entry
requires an `id` and a `version`:

``` yaml
study_id: example_study

standards:
  - id: ADaM-IG
    version: '1.1'

terminology:
  - id: MedDRA
    version: '22.1'
  - id: WHODrug
    version: 2023 JAN
```

Omitting a field and supplying an empty list (`standards: []`) are
equivalent and mean that no entries are defined.

`version` must be a string. Since yaml infers types, unquoted values
that look like numbers (e.g. `version: 27.0`) are read as numbers and
fail validation. Quote them to keep the exact literal:
`version: '27.0'`.

Only the structure is validated here — presence, shape, and required
fields. Domain-semantic checks, such as whether a submitted version
actually exists, are the responsibility of the consuming package.
