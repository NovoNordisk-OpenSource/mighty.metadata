# Update rows in your metadata

Functions to list, select, remove, add, update, and move row operations
in your
[`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
objects.

## Usage

``` r
list_rows(x)

remove_rows(x, id)

add_row(x, id, ..., .pos = length(x[["rows"]]) + 1L)

move_row(x, id, .pos = length(x[["rows"]]))

update_row(x, id, ...)

select_row(x, id)
```

## Arguments

- x:

  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  Object to manipulate.

- id:

  [`character()`](https://rdrr.io/r/base/character.html) Id of the
  row(s) to remove, add, or move.

- ...:

  Additional properties to add for the row, e.g. a `label = "my row"`.

- .pos:

  `integer(1)` Position to put or move the row to. Default places the
  row as the last.

## Value

`invisible(x)`

## Examples

``` r
# Load example configuration
x <- mighty_domain(
  file = system.file("examples", "advs.yml", package = "mighty.metadata")
)

# List all rows defined
list_rows(x)
#> [1] "BASELINE"

# Add a new row
y <- x |>
  add_row(id = "NEW")

list_rows(y)
#> [1] "BASELINE" "NEW"     

# Remove the new row again
y |>
  remove_rows("NEW") |>
  list_rows()
#> [1] "BASELINE"

# Update an existing row
x |>
  update_row(id = "BASELINE", method = "Updated method") |>
  select_row(id = "BASELINE") |>
  str()
#> List of 2
#>  $ id    : chr "BASELINE"
#>  $ method: chr "Updated method"

# Select a specific row
select_row(x, id = "BASELINE") |>
  str()
#> List of 2
#>  $ id    : chr "BASELINE"
#>  $ method: chr "Add baseline visit as a new row"
```
