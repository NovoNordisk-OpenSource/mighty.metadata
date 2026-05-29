# Mighty Domain

`mighty_domain()` provides a robust way of working with ADaM metadata in
the `{mighty}` framework.

A new object is initialized by supplying an existing yaml metadata file.
This package provides helpers to update column, parameter, and row
entries. See the references below for help:

- [`help("columns")`](https://novonordisk-opensource.github.io/mighty.metadata/reference/columns.md)

- [`help("parameters")`](https://novonordisk-opensource.github.io/mighty.metadata/reference/parameters.md)

- [`help("rows")`](https://novonordisk-opensource.github.io/mighty.metadata/reference/rows.md)

`mighty_domain()` inherits from
[`S7schema::S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html)
and the yaml file is automatically validated when loaded. The helper
functions above also always validates the new configuration before
returning.

You can at anytime validate an object by calling
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
and use
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
to save it as a yaml file again.

## Usage

``` r
mighty_domain(file)
```

## Arguments

- file:

  `character(1)` path to a yaml file defining an ADaM dataset.

## Value

A `mighty_domain` S7 object extending
[S7schema::S7schema](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).
The underlying list contains the parsed and validated YAML metadata
including `id`, `label`, `class`, `keys`, `columns`, `parameters`, and
`rows`.

## Examples

``` r
x <- mighty_domain(
  file = system.file("examples", "advs.yml", package = "mighty.metadata")
)

# Custom print method gives a small overview
print(x)
#> <mighty.metadata::mighty_domain>
#> ADVS: Vital Signs Analysis Dataset
#> Class: BASIC DATA STRUCTURE
#> Keys: USUBJID, PARAMCD, and AVISITN

# Underlying object is a `list`
str(x)
#> <mighty.metadata::mighty_domain> List of 9
#>  $ id        : chr "ADVS"
#>  $ label     : chr "Vital Signs Analysis Dataset"
#>  $ class     : chr "BASIC DATA STRUCTURE"
#>  $ structure : chr "One record per vital sign parameter, per visit, per subject"
#>  $ keys      : chr [1:3] "USUBJID" "PARAMCD" "AVISITN"
#>  $ population:List of 2
#>   ..$ base  :List of 1
#>   .. ..$ :List of 3
#>   .. .. ..$ domain : chr "VS"
#>   .. .. ..$ depends: chr "VSTESTCD"
#>   .. .. ..$ filter : chr "VSTESTCD != \"\""
#>   ..$ global:List of 1
#>   .. ..$ :List of 2
#>   .. .. ..$ filter : chr "SAFFL == \"Y\""
#>   .. .. ..$ depends: chr "SAFFL"
#>  $ columns   :List of 11
#>   ..$ :List of 4
#>   .. ..$ id    : chr "STUDYID"
#>   .. ..$ label : chr "Study Identifier"
#>   .. ..$ method: chr "VS.STUDYID"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "USUBJID"
#>   .. ..$ label : chr "Unique Subject Identifier"
#>   .. ..$ method: chr "VS.USUBJID"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "SAFFL"
#>   .. ..$ label : chr "Safety Population Flag"
#>   .. ..$ method: chr "ADSL.SAFFL"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "TRTP"
#>   .. ..$ label : chr "Planned Treatment"
#>   .. ..$ method: chr "ADSL.TRT01P"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "VISITNUM"
#>   .. ..$ label : chr "Visit Number"
#>   .. ..$ method: chr "VS.VISITNUM"
#>   .. ..$ core  : chr "Perm"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "AVISITN"
#>   .. ..$ label : chr "Analysis Visit (N)"
#>   .. ..$ method: chr "Derived from VISITNUM"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "AVISIT"
#>   .. ..$ label : chr "Analysis Visit"
#>   .. ..$ method: chr "Derived from VISIT converted to title case"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "PARAMCD"
#>   .. ..$ label : chr "Parameter Code"
#>   .. ..$ method: chr "VS.VSTESTCD"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "PARAM"
#>   .. ..$ label : chr "Parameter"
#>   .. ..$ method: chr "VS.VSTEST"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 4
#>   .. ..$ id    : chr "AVAL"
#>   .. ..$ label : chr "Analysis Value"
#>   .. ..$ method: chr "VS.VSSTRESN"
#>   .. ..$ core  : chr "Req"
#>   ..$ :List of 3
#>   .. ..$ id   : chr "AVALC"
#>   .. ..$ label: chr "Analysis Value (C)"
#>   .. ..$ core : chr "Perm"
#>  $ rows      :List of 1
#>   ..$ :List of 2
#>   .. ..$ id    : chr "BASELINE"
#>   .. ..$ method: chr "Add baseline visit as a new row"
#>  $ parameters:List of 2
#>   ..$ :List of 3
#>   .. ..$ id     : chr "BMI"
#>   .. ..$ label  : chr "Body Mass Index (kg/m^2)"
#>   .. ..$ columns:List of 1
#>   .. .. ..$ :List of 2
#>   .. .. .. ..$ id    : chr "AVAL"
#>   .. .. .. ..$ method: chr "Derived from height and weight"
#>   ..$ :List of 3
#>   .. ..$ id     : chr "BMIGRP"
#>   .. ..$ label  : chr "Body Mass Index Group"
#>   .. ..$ columns:List of 2
#>   .. .. ..$ :List of 2
#>   .. .. .. ..$ id    : chr "AVALC"
#>   .. .. .. ..$ method: chr "BMI grouped in <20, 20-<25, 25-<30, 30+"
#>   .. .. ..$ :List of 2
#>   .. .. .. ..$ id    : chr "AVAL"
#>   .. .. .. ..$ method: chr "Numeric representation of AVALC"
#>  @ schema   : chr "/home/runner/work/_temp/Library/mighty.metadata/schema/adam.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x557ef9083e08> 
#>  @ file     : chr "/home/runner/work/_temp/Library/mighty.metadata/examples/advs.yml"
```
