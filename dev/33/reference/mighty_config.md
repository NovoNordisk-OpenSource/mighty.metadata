# Mighty Config

`mighty_config()` provides a robust way of working with the
`_mighty.yml` configuration file in the `{mighty}` framework.

A new object is initialized by supplying a directory path containing a
`_mighty.yml` file. The file is automatically validated against the
`mighty.json` schema when loaded.

`mighty_config()` inherits from
[`S7schema::S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).
You can validate an object at any time by calling
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
and use
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
to save it back as a yaml file.

## Usage

``` r
mighty_config(path)
```

## Arguments

- path:

  `character(1)` path to a directory containing a `_mighty.yml` file.

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
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
to serialize a `mighty_config()` object back to a `_mighty.yml` file.

Supply `path` to write to a specific directory; defaults to the
directory the object was loaded from.

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md),
[`write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)

## Examples

``` r
x <- mighty_config(
  path = system.file("examples", package = "mighty.metadata")
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
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x55f005d8d940> 
#>  @ file     : chr "/home/runner/work/_temp/Library/mighty.metadata/examples/_mighty.yml"

# Write back to a directory
tmp <- tempdir()
write_config(x, path = tmp)
```
