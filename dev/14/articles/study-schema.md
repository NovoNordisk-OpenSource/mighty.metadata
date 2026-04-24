# Study specifications

`_study.yml` provides study-level properties for a study directory — the
study identifier and an optional description. The file structure is
defined by a [JSON-schema](https://json-schema.org) accessible with:

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

| Name              | Description                    | Type   | Required |
|:------------------|:-------------------------------|:-------|:---------|
| study_id          | Unique identifier of the study | string | Yes      |
| study_description | Description of the study       | string | No       |
