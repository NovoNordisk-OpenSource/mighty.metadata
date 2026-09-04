# Mighty Config

`mighty_config()` provides a robust way of working with the
`_mighty.yml` configuration file in the `{mighty}` framework.

A new object is initialized by supplying either the path to a
`_mighty.yml` file or an in-memory `list` of the same content. Both are
automatically validated against the `mighty.json` schema.

`mighty_config()` inherits from
[`S7schema::S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).
You can validate an object at any time by calling
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
and use
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
to save it back as a yaml file.

## Usage

``` r
mighty_config(file, .data)
```

## Arguments

- file:

  `character(1)` path to a `_mighty.yml` file. Mutually exclusive with
  `.data`.

- .data:

  `list` holding a `_mighty.yml` configuration already in memory.
  Mutually exclusive with `file`. The resulting object has `@file` set
  to `NULL`, so
  [`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
  requires an explicit `path`.

## Value

A `mighty_config` S7 object extending
[S7schema::S7schema](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).

- `external_data`:

  A list of external data source specifications, each with an `id` and
  `keys` field.

- `repos`:

  Optional character vector of component repository locations, or `NULL`
  if not specified.

## Details

The `_mighty.yml` file is validated against the `mighty.json` schema on
load. The file must contain an `external_data` array declaring the
primary keys of any datasets external to the ADaM study (e.g. SDTM or
reference datasets) that ADaM domain specifications may depend on.

The optional `repos` field specifies where `mighty.component` should
look for shared components. Each entry is either a local path (e.g.
`"."`) or a GitHub reference in `owner/repo/subdir@ref` format (e.g.
`"NovoNordisk-OpenSource/mighty.standards/components@main"`).

## Write Config

Use
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
to serialize a `mighty_config()` object back to a `_mighty.yml` file.
Supply `path` to write to a specific file; defaults to the file the
object was loaded from.

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[study_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/study_config.md),
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md),
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)

## Examples

``` r
x <- mighty_config(
  file = system.file("examples", "_mighty.yml", package = "mighty.metadata")
)

# Custom print method gives a small overview
print(x)
#> <mighty.metadata::mighty_config>
#> External data: 3 sources (`DM`, `VS`, and `AE`)
#> Repos: 2 (`NovoNordisk-OpenSource/mighty.standards/components@main` and `.`)

# Underlying object is a `list`
str(x)
#> <mighty.metadata::mighty_config> List of 2
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
#>  $ repos        : chr [1:2] "NovoNordisk-OpenSource/mighty.standards/components@main" "."
#>  @ schema   : chr "/home/runner/work/_temp/Library/mighty.metadata/schema/mighty.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x555faa37dcc0> 
#>  @ file     : chr "/home/runner/work/_temp/Library/mighty.metadata/examples/_mighty.yml"

# Write back to a file
tmp <- tempfile(fileext = ".yml")
write_config(x, path = tmp)

# Or build one in memory
y <- mighty_config(
  .data = list(
    external_data = list(list(id = "DM", keys = "USUBJID")),
    repos = "."
  )
)

# In-memory objects have no file, so `write_config()` needs a `path`
y@file
#> NULL
```
