# Update parameters in your metadata

Functions to list, select, remove, add, update, and move parameters in
your
[`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
objects.

## Usage

``` r
list_parameters(x)

remove_parameters(x, id)

add_parameter(
  x,
  id,
  label,
  columns,
  ...,
  .pos = length(x[["parameters"]]) + 1L
)

move_parameter(x, id, .pos = length(x[["parameters"]]))

update_parameter(x, id, ...)

select_parameter(x, id)
```

## Arguments

- x:

  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  Object to manipulate.

- id:

  [`character()`](https://rdrr.io/r/base/character.html) Id of the
  parameter(s) to remove, add, or move.

- label:

  `character(1)` Parameter label.

- columns:

  [`list()`](https://rdrr.io/r/base/list.html) Columns to set for the
  parameter.

- ...:

  Additional properties to add for the parameter, e.g. a component
  reference.

- .pos:

  `integer(1)` Position to put or move the parameter to. Default places
  the parameter as the last.

## Value

`invisible(x)`

## Examples

``` r
# Load example configuration
x <- mighty_domain(
  file = system.file("examples", "advs.yml", package = "mighty.metadata")
)

# List all parameters defined
list_parameters(x)
#> [1] "BMI"    "BMIGRP"

# Remove the BMIGRP parameter
x |>
  remove_parameters("BMIGRP") |>
  list_parameters()
#> [1] "BMI"

# Add a new parameter
x |>
  add_parameter(
    id = "NEW",
    label = "My new parameter",
    columns = list(list(id = "AVAL"))
  ) |>
  list_parameters()
#> [1] "BMI"    "BMIGRP" "NEW"   

# Move the BMIGRP parameter to the 1st position
x |>
  move_parameter(id = "BMIGRP", .pos = 1) |>
  list_parameters()
#> [1] "BMIGRP" "BMI"   

# Update an existing parameter
x |>
  update_parameter(id = "BMI", label = "Updated BMI Label") |>
  select_parameter(id = "BMI") |>
  str()
#> List of 3
#>  $ id     : chr "BMI"
#>  $ label  : chr "Updated BMI Label"
#>  $ columns:List of 1
#>   ..$ :List of 2
#>   .. ..$ id    : chr "AVAL"
#>   .. ..$ method: chr "Derived from height and weight"

# Select a specific parameter
select_parameter(x, id = "BMI") |>
  str()
#> List of 3
#>  $ id     : chr "BMI"
#>  $ label  : chr "Body Mass Index (kg/m^2)"
#>  $ columns:List of 1
#>   ..$ :List of 2
#>   .. ..$ id    : chr "AVAL"
#>   .. ..$ method: chr "Derived from height and weight"
```
