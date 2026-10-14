# Mighty Codelists

`mighty_codelists()` creates an S7 object for storing codelist metadata.
The class represents the contents of `_codelists.yml` as a list of
codelist entries. Each codelist is referenced from column metadata via
its `id` (the `codelist` field of a column).

A codelist can contain the following operation groups:

- `values`: values of a sponsor-defined (non-standard) codelist,

- `subset`: values kept from a standard controlled terminology codelist,

- `restore`: SDTM controlled terminology values included in the ADaM
  codelist even when they are not used in the SDTM define.xml,

- `extend`: values added to an extensible codelist.

`values` is meant for codelists that are not part of standard controlled
terminology, while `subset`, `restore` and `extend` modify a standard
codelist retrieved from an external source.

The object is validated on creation and after every modification.
Validation includes:

- schema compliance with `inst/schema/codelists.json`,

- uniqueness of codelist identifiers (`id`),

- uniqueness of `code` within a codelist across all operation groups,

- `values` being mutually exclusive with `subset` and `restore`,

- consistent use of `decode` within an operation group (all or none).

Codelists do not have to be referenced by a column. Use
`check_codelist_references()` to check that every codelist in a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
is used.

## Usage

``` r
mighty_codelists(file, .data)

list_codelists(x)

select_codelist(x, id)

add_codelist(x, id, label, description, datatype = NULL, code, decode = NULL)

remove_codelist(x, id)

update_codelist(x, id, ...)

add_codelist_values(x, id, code, decode = NULL)

extend_codelist_values(x, id, code, decode = NULL)

restore_codelist_values(x, id, code)

subset_codelist_values(x, id, code)

remove_codelist_value(x, id, code)

move_codelist_value(x, id, code, .pos)

update_codelist_value(x, id, code, decode)

check_codelist_references(study)
```

## Arguments

- file:

  `character(1)` path to `_codelists.yml`. Optional; mutually exclusive
  with `.data`.

- .data:

  [`list()`](https://rdrr.io/r/base/list.html) of codelist entries.
  Optional; mutually exclusive with `file`. Supplying neither returns an
  empty `mighty_codelists`.

- x:

  A `mighty_codelists()` or
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  object.

- id:

  `character(1)` codelist id. `remove_codelist()` accepts
  [`character()`](https://rdrr.io/r/base/character.html) to remove
  several codelists.

- label:

  `character(1)` codelist label.

- description:

  `character(1)` codelist description.

- datatype:

  `character(1)` one of `"text"`, `"integer"`, `"float"`. Optional
  (`NULL`).

- code:

  [`character()`](https://rdrr.io/r/base/character.html) or
  [`numeric()`](https://rdrr.io/r/base/numeric.html) coded value(s).

- decode:

  [`character()`](https://rdrr.io/r/base/character.html) decode(s), same
  length as `code`. Optional (`NULL`) except in
  `update_codelist_value()`.

- ...:

  Codelist-level fields to update (`label`, `description`, `datatype`).

- .pos:

  `integer(1)` new position of the value within its group.

- study:

  A
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  object.

## Value

- `mighty_codelists()`: an object of class `mighty_codelists`.

- `list_codelists()`:
  [`character()`](https://rdrr.io/r/base/character.html) vector with
  codelist ids.

- `select_codelist()`: selected codelist entry as a list.

- All other functions: the modified object.

## Details

Functions to list, select, add, remove, and update codelists and their
values in your `mighty_codelists()` object or directly on a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
object.

Codelist level:

- `add_codelist()` adds a new sponsor-defined codelist with `values`.

- `remove_codelist()` removes codelist(s) and all their contents.

- `update_codelist()` updates `label`, `description` and `datatype`.

- `select_codelist()` returns a single codelist entry as a list.

Value level:

- `add_codelist_values()` adds `values` to an existing codelist.

- `remove_codelist_value()` removes value(s) from whichever operation
  group they belong to. Empty groups are dropped, and a codelist left
  without any values is removed.

- `move_codelist_value()` moves a value within its operation group.

- `update_codelist_value()` updates the decode of a `values` or `extend`
  entry.

Reuse of external codelists:

Most codelists come from an external source of controlled terminology
(e.g. CDISC CT), retrieved by downstream tooling such as
`mighty.toolbox`. Instead of redefining these codelists, the functions
below record how the study changes them. Support for reusing external
codelists is still maturing. Each function creates the codelist entry if
it does not exist.

- `subset_codelist_values()` keeps only the given codes from the
  external codelist (`subset`).

- `restore_codelist_values()` includes SDTM controlled terminology codes
  that would otherwise be excluded from the ADaM define.xml (`restore`).

- `extend_codelist_values()` adds sponsor-defined codes to an extensible
  external codelist (`extend`).

`subset` and `restore` cannot be combined with `values` on the same
codelist, as `values` defines a sponsor-defined codelist.

Study level:

- `check_codelist_references()` checks that every codelist in a
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  is referenced by at least one column (`codelist` field), including
  columns in parameters. It returns `study` invisibly or errors. The
  check is not run automatically, so codelists can be added before they
  are used by any column.

## Examples

``` r
cl <- mighty_codelists(
  .data = list(
    list(
      id = "REGION",
      label = "Region",
      description = "Geographical regions",
      datatype = "text",
      values = list(list(code = "EUROPE", decode = "Europe"))
    ),
    list(
      id = "AGEU",
      subset = list(list(code = "YEARS")),
      restore = list(list(code = "MONTHS"))
    )
  )
)

print(cl)
#> <mighty.metadata::mighty_codelists>
#> Codelists: 2 entries
#> IDs: `REGION` and `AGEU`

cl <- mighty_codelists() |>
  add_codelist(
    id = "REGION",
    label = "Region",
    description = "Geographical regions used in the study",
    datatype = "text",
    code = c("EUROPE", "NORTH AMERICA"),
    decode = c("Europe", "North America")
  ) |>
  subset_codelist_values(id = "AGEU", code = c("MONTHS", "YEARS")) |>
  restore_codelist_values(id = "AGEU", code = "DAYS") |>
  extend_codelist_values(
    id = "LOC",
    code = "MY CUSTOM LOCATION",
    decode = "My Custom Location"
  )

list_codelists(cl)
#> [1] "REGION" "AGEU"   "LOC"   
select_codelist(cl, id = "AGEU")
#> $id
#> [1] "AGEU"
#> 
#> $subset
#> $subset[[1]]
#> $subset[[1]]$code
#> [1] "MONTHS"
#> 
#> 
#> $subset[[2]]
#> $subset[[2]]$code
#> [1] "YEARS"
#> 
#> 
#> 
#> $restore
#> $restore[[1]]
#> $restore[[1]]$code
#> [1] "DAYS"
#> 
#> 
#> 

cl <- cl |>
  update_codelist(id = "REGION", description = "Regions used in the trial") |>
  update_codelist_value(id = "REGION", code = "EUROPE", decode = "EU") |>
  move_codelist_value(id = "AGEU", code = "YEARS", .pos = 1) |>
  remove_codelist_value(id = "AGEU", code = "MONTHS") |>
  remove_codelist(id = "LOC")


# Check that all codelists in a study are referenced by a column
study <- mighty_study(
  path = system.file("examples", package = "mighty.metadata")
) |>
  extend_codelist_values("UNUSED", code = "A")
#> → No `_documents.yml` file found
#> → No `_codelists.yml` file found

try(check_codelist_references(study))
#> Error in check_codelist_references(study) : 
#>   Codelist "UNUSED" is not referenced by any column.
#> ℹ Reference the codelist in a column codelist field or remove it from
#>   _codelists.yml.
```
