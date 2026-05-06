# Mighty specifications

`_mighty.yml` defines specifications for the mighty framework. The file
structure is defined by a [JSON-schema](https://json-schema.org)
accessible with:

``` r

system.file("schema", "mighty.json", package = "mighty.metadata")
```

Below you can find a detailed description of the structure.

## Mighty Configuration

Schema for mighty framework configuration in the mightyverse

| Type   | Required      | Additional Properties |
|:-------|:--------------|:----------------------|
| object | external_data | No                    |

### Properties

| Name | Description | Type | Unique Items | Items | Required |
|:---|:---|:---|:---|:---|:---|
| external_data | External data sources referenced by the study | array | Yes | [external_data_source](#external_data_source) | Yes |

## Definitions

### external_data_source

Specification of a single external data source

[TABLE]

#### Properties

| Name | Description                               | Required | Type                |
|:-----|:------------------------------------------|:---------|:--------------------|
| id   | Identifier of the external data source    | Yes      | [cdisc/name](#name) |
| keys | Key columns for joining the external data | Yes      | [keys](#keys)       |

### keys

Keys are always unique and of minimum length 1

| Type                | Items               | Min Items | Unique Items |
|:--------------------|:--------------------|:----------|:-------------|
| array               | [cdisc/name](#name) | 1         | Yes          |
| [cdisc/name](#name) |                     |           |              |

### cdisc

Definitions from CDISC standards

#### name

Uppercase identifier

| Type   | Pattern                  |
|:-------|:-------------------------|
| string | ^\[A-Z\]\[A-Z0-9\_\]\*\$ |
