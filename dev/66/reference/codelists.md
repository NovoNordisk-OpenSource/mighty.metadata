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

The object is validated on creation and when
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
is called. Validation includes:

- schema compliance with `inst/schema/codelists.json`,

- uniqueness of codelist identifiers (`id`),

- uniqueness of `code` within a codelist across all operation groups,

- `values` being mutually exclusive with `subset` and `restore`,

- consistent use of `decode` within an operation group (all or none).

When part of a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
every codelist must also be referenced by at least one column in the
domain metadata.

## Usage

``` r
mighty_codelists(file, .data)

list_codelists(x)

select_codelist(x, id)

define_codelist(x, id, label, description, datatype, code, decode = NULL)

remove_codelist(x, id)

update_codelist(x, id, ...)

define_codelist_values(x, codelist_id, code, decode = NULL)

extend_codelist_values(x, codelist_id, code, decode = NULL)

restore_codelist_values(x, codelist_id, code)

subset_codelist_values(x, codelist_id, code)

remove_codelist_value(x, codelist_id, code)

move_codelist_value(x, codelist_id, code, .pos)

update_codelist_value(x, codelist_id, code, decode)
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

  `character(1)` one of `"text"`, `"integer"`, `"float"`.

- code:

  [`character()`](https://rdrr.io/r/base/character.html) or
  [`numeric()`](https://rdrr.io/r/base/numeric.html) coded value(s).

- decode:

  [`character()`](https://rdrr.io/r/base/character.html) decode(s), same
  length as `code`. Optional (`NULL`) except in
  `update_codelist_value()`.

- ...:

  Codelist-level fields to update (`label`, `description`, `datatype`).

- codelist_id:

  `character(1)` codelist id.

- .pos:

  `integer(1)` new position of the value within its group.

## Value

- `mighty_codelists()`: an object of class `mighty_codelists`.

- `list_codelists()`:
  [`character()`](https://rdrr.io/r/base/character.html) vector with
  codelist ids.

- `select_codelist()`: selected codelist entry as a list.

- All other functions: the modified object.

## Details

Functions to list, select, define, remove, and update codelists and
their values in your `mighty_codelists()` object or directly on a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
object.

Codelist level:

- `define_codelist()` adds a new sponsor-defined codelist with `values`.

- `remove_codelist()` removes codelist(s) and all their contents.

- `update_codelist()` updates `label`, `description` and `datatype`.

- `select_codelist()` returns a single codelist entry as a list.

Value level:

- `define_codelist_values()` adds `values` to an existing codelist.

- `extend_codelist_values()`, `restore_codelist_values()` and
  `subset_codelist_values()` add `extend`, `restore` and `subset`
  entries, creating the codelist if it does not exist.

- `remove_codelist_value()` removes value(s) from whichever operation
  group they belong to. Empty groups are dropped, and a codelist left
  without any values is removed.

- `move_codelist_value()` moves a value within its operation group.

- `update_codelist_value()` updates the decode of a `values` or `extend`
  entry.

When working on a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
every codelist must be referenced by a column (`codelist` field), so add
the column reference before defining the codelist.

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
  define_codelist(
    id = "REGION",
    label = "Region",
    description = "Geographical regions used in the study",
    datatype = "text",
    code = c("EUROPE", "NORTH AMERICA"),
    decode = c("Europe", "North America")
  ) |>
  subset_codelist_values(codelist_id = "AGEU", code = c("MONTHS", "YEARS")) |>
  restore_codelist_values(codelist_id = "AGEU", code = "DAYS") |>
  extend_codelist_values(
    codelist_id = "LOC",
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
  update_codelist_value(codelist_id = "REGION", code = "EUROPE", decode = "EU") |>
  move_codelist_value(codelist_id = "AGEU", code = "YEARS", .pos = 1) |>
  remove_codelist_value(codelist_id = "AGEU", code = "MONTHS") |>
  remove_codelist(id = "LOC")
```
