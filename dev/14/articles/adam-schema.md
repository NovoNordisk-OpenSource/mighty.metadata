# ADaM specifications

`mighty.metadata` uses YAML files to specify Analysis Data Model (ADaM)
datasets. Each YAML file follows a fixed structure with defines
properties and entries.

This structure is defined in a [JSON-schema](https://json-schema.org)
that you can access with:

``` r

system.file("schema", "adam.json", package = "mighty.metadata")
```

Below you can find a detailed description of the structure.

## Mighty Metadata ADaM Domain Specification

Common schema for ADaM dataset specification in the mightyverse

[TABLE]

### Properties

| Name | Description | Type | Required |
|:---|:---|:---|:---|
| id | Name of the ADaM dataset | [cdisc/name](#name) | Yes |
| label | Label of the ADaM dataset | string | Yes |
| include | Conditional expression to include the domain | [mighty/include](#include) | No |
| class | CDISC class of the dataset | [cdisc/class](#class) | Yes |
| subclass | CDISC subclass of the dataset | [cdisc/subclass](#subclass) | No |
| structure | Text description of the structure of the dataset | string | Yes |
| keys | Key variables for the dataset | [keys](#keys) | Yes |
| comment | Comment to the dataset | string | No |
| usecore | Flag to populate with core variables from ADSL | boolean | No |
| population | Population and base domain used to create the dataset | [mighty/population](#population) | No |
| columns | Columns in the dataset | [columns](#columns) | Yes |
| rows | Row derivations for mighty | [rows](#rows) | No |
| parameters | Parameters in a BDS dataset | [parameters](#parameters) | No |

## Definitions

### keys

Keys are always unique and of minimum length 1

| Type                | Items               | Min Items | Unique Items |
|:--------------------|:--------------------|:----------|:-------------|
| array               | [cdisc/name](#name) | 1         | Yes          |
| [cdisc/name](#name) |                     |           |              |

### columns

List of column specifications

| Type  | Items             | Min Items | Unique Items |
|:------|:------------------|:----------|:-------------|
| array | [column](#column) | 1         | Yes          |

### column

Specification of a single column

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | id       | No                    |

#### Properties

| Name | Description | Type | Required |
|:---|:---|:---|:---|
| id | Name of the column | [cdisc/name](#name) | Yes |
| include | Conditional expression to include the column | [mighty/include](#include) | No |
| label | Label of the column | string | No |
| method | How to derive the column (free text) | string | No |
| origin | Origin type of the column | [cdisc/origin](#origin) | No |
| codelist | Codelist of possible values of the column | string | No |
| is_core | Flag for designating a core variables in subject level datasets | boolean | No |
| format | Data format of the column | [standard/dataformat](#dataformat) | No |
| component | Mighty component to create the column | [mighty/component](#component) | No |
| depends | dependencies required to create the column | [mighty/depends](#depends) | No |
| core | Describes whether a variable is required (Req), conditionally required (Cond) or permissible (Perm) | [cdisc/core](#core) | No |
| comment | Comment to the column (free text) | string | No |

### rows

List of row action specifications. Typically used when adding additional
rows to the data.

| Type  | Items       | Min Items | Unique Items |
|:------|:------------|:----------|:-------------|
| array | [row](#row) | 1         | Yes          |

### row

Specification of a single row action

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | id       | No                    |

#### Properties

| Name | Description | Type | Required |
|:---|:---|:---|:---|
| id | Unique identifier of the action. Used to reference in other places, e.g. as a dependency. | [cdisc/name](#name) | Yes |
| include | Conditional expression to include the row | [mighty/include](#include) | No |
| method | How to derive the row action (free text) | string | No |
| component | Mighty component to do the row action | [mighty/component](#component) | No |
| depends | Dependencies needed before the action can be carried out | [mighty/depends](#depends) | No |

### parameters

Specification of parameters in a BDS dataset

| Type  | Items                   | Min Items | Unique Items |
|:------|:------------------------|:----------|:-------------|
| array | [parameter](#parameter) | 1         | Yes          |

### parameter

Specification of a single BDS parameter

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | id       | No                    |

#### Properties

| Name | Description | Type | Required |
|:---|:---|:---|:---|
| id | Parameter id (PARAMCD) | [cdisc/name](#name) | Yes |
| include | Conditional expression to include the parameter | [mighty/include](#include) | No |
| label | Parameter label (PARAM) | string | No |
| columns | Additional columns to derive for the parameter, e.g. AVAL and AVALC | [columns](#columns) | No |
| component | Mighty component used to derive the parameter and all relevant columns | [mighty/component](#component) | No |
| depends | Dependencies required to create the parameter | [mighty/depends](#depends) | No |

### standard

Additional definitions used for e.g. define.xml

#### dataformat

Format used to display the data

[TABLE]

##### Properties

| Name | Description | Type | Enum | Minimum | Pattern | Required |
|:---|:---|:---|:---|---:|:---|:---|
| type | Data type | string | text , integer , float , datetime , date , time , partialDate , partialTime , partialDatetime , incompleteDatetime, durationDatetime , intervalDatetime |  |  | Yes |
| length | Maximum length of content | integer | NULL | 1 |  | Yes |
| display | SAS display format | string | NULL |  | . | No |

### cdisc

Definitions from CDISC standards

#### name

Uppercase identifier

| Type   | Pattern                  |
|:-------|:-------------------------|
| string | ^\[A-Z\]\[A-Z0-9\_\]\*\$ |

#### class

Subset of CDISC controlled terminology C103329

[TABLE]

#### subclass

Union of CDISC controlled terminology C165635 and C176227

[TABLE]

#### origin

Controlled terminology C170449

[TABLE]

#### core

Indicator of whether a variable is required (Req), conditionally
required (Cond), or permissible (Perm) in the dataset

[TABLE]

### mighty

Definitions only relevant when using mighty to generate code

#### population

mighty - specification of the base domain(s) and any global filters to
apply

| Type   | Required |
|:-------|:---------|
| object | base     |

##### Properties

| Name | Description | Required | Type |
|:---|:---|:---|:---|
| base | mighty - domains to filter and combine to create initial dataset | Yes | [mighty/base_input_list](#base_input_list) |
| global | mighty - global filters to apply after combining base datasets | No | [mighty/global_input_list](#global_input_list) |

#### base_input_list

mighty - list of base input datasets

| Type  | Items                            | Min Items | Unique Items |
|:------|:---------------------------------|:----------|:-------------|
| array | [mighty/base_input](#base_input) | 1         | Yes          |

#### base_input

mighty - single base input dataset with filters

[TABLE]

##### Properties

| Name | Description | Required | Type |
|:---|:---|:---|:---|
| domain | Name of the dataset to use | Yes | [cdisc/name](#name) |
| depends | Which columns in the dataset the filter depends on | Yes | [mighty/depends](#depends) |
| filter |  | Yes | [mighty/filter](#filter) |

#### global_input_list

mighty - list of global filters

| Type  | Items                                | Min Items | Unique Items |
|:------|:-------------------------------------|:----------|:-------------|
| array | [mighty/global_input](#global_input) | 1         | Yes          |

#### global_input

mighty - single global filter

[TABLE]

##### Properties

| Name | Description | Required | Type |
|:---|:---|:---|:---|
| filter |  | Yes | [mighty/filter](#filter) |
| depends | Which columns the filter depends on | Yes | [mighty/depends](#depends) |

#### depends_string

A single dependency: COLUMN, DOMAIN.COLUMN, rows.ID, or parameters.ID

| Type | Pattern |
|:---|:---|
| string | ^((\[A-Z\]\[A-Z0-9\_\]*(.\[A-Z\]\[A-Z0-9\_\]*)?)\$\|)(rows\|parameters).\[A-Z\]\[A-Z0-9\_\]\*\$ |

#### depends

List of dependencies needed before the component code can be evaluated

| Type | Items | Min Items | Unique Items |
|:---|:---|:---|:---|
| array | [mighty/depends_string](#depends_string) | 1 | Yes |
| [mighty/depends_string](#depends_string) |  |  |  |

#### include

Glue expression that evaluates to TRUE or FALSE

| Type    | Pattern  |
|:--------|:---------|
| string  | ^{.\*}\$ |
| boolean |          |

#### filter

Filter specification. Must be an R expression that can be evaluated.

| Type   |
|:-------|
| string |

#### component

mighty component used to carry out the desired derivation

| Type   | Required | Additional Properties |
|:-------|:---------|:----------------------|
| object | id       | No                    |

##### Properties

| Name | Description | Type | Required |
|:---|:---|:---|:---|
| id | ID of the component. Either name of standard or file path to local component. | string | Yes |
| with | named list of input arguments needed to render component | object | No |
