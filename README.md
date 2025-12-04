# mighty.metadata

A package for managing CDISC ADaM metadata in YAML format.

## Introduction

The `mighty.metadata` package provides tools for working with CDISC ADaM
metadata in YAML format. It facilitates the extraction, transformation, and
management of metadata for clinical trial analysis datasets, making it easier
to maintain, version, and document ADaM specifications.

Key features:

- Transform raw metadata into structured ADaM format
- Generate YAML files with proper formatting
- Create column metadata datasets from YAML files
- Track domain references across datasets
- View metadata in interactive HTML format
- Support for predecessor, derived, and assigned variables

## Installation

```r
# Install from GitHub (development version)
# devtools::install_github("your-org/mighty.metadata")
library(mighty.metadata)
```

## Quick Start

```r
# Build ADaM metadata from source components
adam_metadata <- build_adam_metadata(metadata)

# Write to YAML files
yaml_files <- write_adam_yaml(adam_metadata, output_dir = "yaml_output")

# Create column metadata dataset from YAML files
col_metadata <- make_mdcol_from_yaml("yaml_output")

# View in HTML format
view_define_html("yaml_output/adsl.yaml")
```

## Main Functions

### Metadata Processing

- `build_adam_metadata()` - Transform raw metadata into structured ADaM format
- `make_mdcol_from_yaml()` - Create column metadata from YAML files

### YAML Operations

- `write_adam_domain_yaml()` - Write single domain to YAML file
- `write_adam_yaml()` - Write all domains to YAML files

### HTML Visualization

- `view_define_html()` - View metadata in interactive HTML format
- `format_table_metadata_html()` - Format table metadata as HTML
- `format_column_metadata_html()` - Format column metadata as HTML

## Variable Types

The package handles three types of ADaM variables according to CDISC standards:

### 1. Predecessor Variables

Inherit metadata from source datasets:

```yaml
USUBJID:
  column: DM.USUBJID  # Simple reference
```

### 2. Derived Variables

Include derivation methods:

```yaml
AAGE:
  column: AAGE
  label: Analysis Age
  type: integer
  origin: |
    Derived from DM.AGE using the following algorithm:
    - Convert age to integer
    - Apply study-specific rules
```

### 3. Assigned Variables

Include assignment information:

```yaml
PARAMCD:
  column: PARAMCD
  label: Parameter Code
  origin: "Assigned: Fixed value based on parameter"
```

## YAML Structure

Generated YAML files follow this structure:

```yaml
table_metadata:
  table: ADSL
  label: Subject Level Analysis Dataset
  class: SUBJECT LEVEL ANALYSIS DATASET
  structure: One record per subject
  keys: [STUDYID, USUBJID]

column_metadata:
  USUBJID:
    column: DM.USUBJID
  AAGE:
    column: AAGE
    label: Analysis Age
    type: integer
    origin: |
      Derivation algorithm here

value_metadata:
  PARAMCD:
    "WEIGHT":
      column: PARAMCD
      whereclause: PARAMCD = "WEIGHT"
      origin: "Assigned: Weight parameter"
```

## HTML Features

Interactive HTML visualization includes:

- Sortable and filterable tables
- Expandable value-level metadata (VLM)
- Dark/light theme toggle
- Professional documentation styling
- Cross-references between domains

## Dependencies

- `dplyr` - Data manipulation
- `yaml` - YAML file operations
- `stringr` - String processing
- `tidyr` - Data tidying
- `purrr` - Functional programming
- `rstudioapi` - RStudio integration

## Documentation

For more detailed information, see the package vignettes:

- `vignette("mightymetadata")` - Main usage documentation
- `vignette("yaml-format")` - YAML format structure details
- `vignette("adam-metadata")` - ADaM metadata concepts

## Contributing

We welcome contributions through:

1. Reporting issues
2. Suggesting enhancements  
3. Creating pull requests

Please contact the BOS team for guidance on contributing.

## License

MIT License, Copyright (c) Novo Nordisk A/S
