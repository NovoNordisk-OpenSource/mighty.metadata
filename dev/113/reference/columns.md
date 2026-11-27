# Update columns in your metadata

Functions to list, select, remove, add, update, and move columns in your
[`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
objects.

## Usage

``` r
list_columns(x)

remove_columns(x, id)

add_column(x, id, ..., .pos = length(x[["columns"]]) + 1L)

move_column(x, id, .pos = length(x[["columns"]]))

select_column(x, id)

update_column(x, id, ...)
```

## Arguments

- x:

  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  Object to manipulate.

- id:

  [`character()`](https://rdrr.io/r/base/character.html) Id of the
  column(s) to remove, add, or move.

- ...:

  Additional properties to add/update for the column, e.g. a
  `label = "my label"`.

- .pos:

  `integer(1)` Position to put or move the column to. Default places the
  column as the last.

## Value

`invisible(x)`

## Examples

``` r
# Load example configuration
x <- mighty_domain(
  file = system.file("examples", "advs.yml", package = "mighty.metadata")
)

# List all columns defined
list_columns(x)
#>  [1] "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN" 
#>  [7] "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"   

# Remove the STUDYID and USUBJID columns
x |>
  remove_columns(c("STUDYID", "USUBJID")) |>
  list_columns()
#> [1] "SAFFL"    "TRTP"     "VISITNUM" "AVISITN"  "AVISIT"   "PARAMCD"  "PARAM"   
#> [8] "AVAL"     "AVALC"   

# Add a new column
x |>
  add_column(id = "NEW") |>
  list_columns()
#>  [1] "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM" "AVISITN" 
#>  [7] "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"    "NEW"     

# Add new column with label and as the first column
y <- x |>
  add_column(id = "NEW", label = "My label", .pos = 1)

list_columns(y)
#>  [1] "NEW"      "STUDYID"  "USUBJID"  "SAFFL"    "TRTP"     "VISITNUM"
#>  [7] "AVISITN"  "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"   

y[["columns"]][[1]] |>
  str()
#> List of 2
#>  $ id   : chr "NEW"
#>  $ label: chr "My label"

# Move the STUDYID column to the 3rd position
x |>
  move_column(id = "STUDYID", .pos = 3) |>
  list_columns()
#>  [1] "USUBJID"  "SAFFL"    "STUDYID"  "TRTP"     "VISITNUM" "AVISITN" 
#>  [7] "AVISIT"   "PARAMCD"  "PARAM"    "AVAL"     "AVALC"   

# Update an existing column
x |>
  update_column(id = "STUDYID", label = "Updated Label") |>
  select_column(id = "STUDYID") |>
  str()
#> List of 4
#>  $ id    : chr "STUDYID"
#>  $ label : chr "Updated Label"
#>  $ method: chr "VS.STUDYID"
#>  $ core  : chr "Req"

# Select a specific column
select_column(x, id = "STUDYID") |>
  str()
#> List of 4
#>  $ id    : chr "STUDYID"
#>  $ label : chr "Study Identifier"
#>  $ method: chr "VS.STUDYID"
#>  $ core  : chr "Req"
```
