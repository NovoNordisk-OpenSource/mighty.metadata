
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mighty.metadata <a href="https://novonordisk-opensource.github.io/mighty.metadata/"><img src="man/figures/logo.png" align="right" height="139" alt="mighty.metadata website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/NovoNordisk-OpenSource/mighty.metadata/actions/workflows/check_and_co.yaml/badge.svg)](https://github.com/NovoNordisk-OpenSource/mighty.metadata/actions/workflows/check_and_co.yaml)
<!-- badges: end -->

## Overview

Clinical data scientists programming CDISC Analysis Data Model (ADaM)
datasets need specifications that are both human-readable and
machine-readable. These specifications typically live in Excel
spreadsheets that are hard to version-control, difficult to validate,
and cannot be consumed by automation tooling. mighty.metadata replaces
that workflow with YAML files.

The package loads YAML specifications, validates them against a JSON
schema, and provides a pipe-friendly R interface for inspecting and
modifying column, parameter, and row definitions. It works at two
levels: a single ADaM domain (`mighty_domain()`) or an entire study
(`mighty_study()`).

mighty.metadata is part of the mighty framework for automated ADaM
programming. It is built on [S7](https://rconsortium.github.io/S7/) and
[S7schema](https://novonordisk-opensource.github.io/S7schema/) for
robust validation and modern OOP.

## Installation

``` r
# Install from CRAN:
install.packages("mighty.metadata")

# Install the development version from GitHub:
pak::pak("NovoNordisk-OpenSource/mighty.metadata")
```

## Usage

### Load and inspect a single domain

`mighty_domain()` loads a YAML metadata file for a single ADaM dataset
and validates it against the schema on load.

``` r
library(mighty.metadata)

advs <- mighty_domain(
  file = system.file("examples", "advs.yml", package = "mighty.metadata")
)

advs
#> <mighty.metadata::mighty_domain>
#> ADVS: Vital Signs Analysis Dataset
#> Class: BASIC DATA STRUCTURE
#> Keys: USUBJID, PARAMCD, and AVISITN
```

Use `list_columns()`, `list_parameters()`, and `list_rows()` to see what
the specification contains.

``` r
list_columns(advs)
#>  [1] "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN" 
#>  [7] "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"
```

``` r
list_parameters(advs)
#> [1] "BMI"    "BMIGRP"
```

``` r
list_rows(advs)
#> [1] "BASELINE"
```

### Modify a domain

Each dimension (columns, parameters, rows) has a consistent set of
verbs: `list_*`, `add_*`, `remove_*`, `update_*`, `select_*`, and
`move_*`. These return a modified `mighty_domain` object and work
naturally with the pipe.

``` r
# Add a new column
advs |>
  add_column(id = "TRTA", label = "Actual Treatment", .pos = 3) |>
  list_columns()
#>  [1] "STUDYID"  "USUBJID"  "TRTA"     "SAFFL"    "TRTP"     "VISITNUM"
#>  [7] "AVISITN"  "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"
```

``` r
# Remove columns
advs |>
  remove_columns(c("VISITNUM", "AVALC")) |>
  list_columns()
#> [1] "STUDYID" "USUBJID" "SAFFL"   "TRTP"    "AVISITN" "AVISIT"  "PARAMCD"
#> [8] "PARAM"   "AVAL"
```

### Work with a full study

`mighty_study()` loads every YAML file from a directory. Each file
becomes a named `mighty_domain`. The optional `_study.yml` provides
study-level properties and `_mighty.yml` provides mighty framework
configuration.

``` r
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
)

study
#> <mighty.metadata::mighty_study/list/S7_object>
#> @ mighty: `external_data`
#> @ study: `study_id`
#> $ ADAE: <mighty.metadata::mighty_domain>
#> $ ADSL: <mighty.metadata::mighty_domain>
#> $ ADVS: <mighty.metadata::mighty_domain>
```

``` r
names(study)
#> [1] "ADAE" "ADSL" "ADVS"
```

``` r
str(study@study)
#> List of 1
#>  $ study_id: chr "example_study"
str(study@mighty)
#> List of 1
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
```

## Useful links

- `vignette("mighty-metadata")` – Getting started guide
- `vignette("adam-schema")` – Domain YAML schema reference
- `vignette("study-schema")` – Study YAML schema reference
- `vignette("mighty-schema")` – Mighty YAML schema reference
- [S7schema](https://novonordisk-opensource.github.io/S7schema/) –
  Schema validation engine used by mighty.metadata
- [Novo Nordisk Open Source R
  packages](https://novonordisk-opensource.github.io/R-packages/) –
  Overview of R packages published by Novo Nordisk.
