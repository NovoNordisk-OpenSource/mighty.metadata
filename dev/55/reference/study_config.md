# Study Config

`study_config()` provides a robust way of working with the `_study.yml`
configuration file in the `{mighty}` framework.

A new object is initialized by supplying either the path to a
`_study.yml` file or an in-memory `list` of the same content. Both are
automatically validated against the `study.json` schema.

`study_config()` inherits from
[`S7schema::S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).
You can validate an object at any time by calling
[`validate()`](https://rconsortium.github.io/S7/reference/validate.html)
and use
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
to save it back as a yaml file.

## Usage

``` r
study_config(file, .data)
```

## Arguments

- file:

  `character(1)` path to a `_study.yml` file. Mutually exclusive with
  `.data`.

- .data:

  `list` holding a `_study.yml` configuration already in memory.
  Mutually exclusive with `file`.

## Value

A `study_config` S7 object extending
[S7schema::S7schema](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).

- `study_id`:

  Unique identifier of the study.

- `study_description`:

  Optional description of the study.

- `standards`:

  Optional list of standards, each with `id` and `version`.

- `terminology`:

  Optional list of controlled terminologies, each with `id` and
  `version`.

## Details

The `_study.yml` file is validated against the `study.json` schema on
load. The file must contain a `study_id` field. Additional study-level
properties are allowed and are kept as-is.

The optional `standards` and `terminology` fields describe the standards
and controlled terminologies applied in the study; see
[`vignette("study-schema")`](https://novonordisk-opensource.github.io/mighty.metadata/articles/study-schema.md).

Study-level properties are used by
[`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md)
to evaluate the `include` conditions of domains, columns, parameters,
and rows.

## Write Config

Use
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)
to serialize a `study_config()` object back to a `_study.yml` file.
Supply `path` to write to a specific file; defaults to the file the
object was loaded from.

## See also

[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
[mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md),
[mighty_domain](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md),
[`write_config()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/write_config.md)

## Examples

``` r
x <- study_config(
  file = system.file("examples", "_study.yml", package = "mighty.metadata")
)

# Custom print method gives a small overview
print(x)
#> <mighty.metadata::study_config>
#> Study ID: example_study
#> Fields: `study_id`, `standards`, and `terminology`

# Underlying object is a `list`
str(x)
#> <mighty.metadata::study_config> List of 3
#>  $ study_id   : chr "example_study"
#>  $ standards  :List of 1
#>   ..$ :List of 2
#>   .. ..$ id     : chr "ADaM-IG"
#>   .. ..$ version: num 1.1
#>  $ terminology:List of 4
#>   ..$ :List of 2
#>   .. ..$ id     : chr "ADAM"
#>   .. ..$ version: chr "2025-08-06"
#>   ..$ :List of 2
#>   .. ..$ id     : chr "SDTM"
#>   .. ..$ version: chr "2025-08-06"
#>   ..$ :List of 2
#>   .. ..$ id     : chr "MedDRA"
#>   .. ..$ version: num 22.1
#>   ..$ :List of 2
#>   .. ..$ id     : chr "WHODrug"
#>   .. ..$ version: chr "2023 JAN"
#>  @ schema   : chr "/home/runner/work/_temp/Library/mighty.metadata/schema/study.json"
#>  @ validator: <S7schema::validator>
#>  .. @ context:Classes 'V8', 'environment' <environment: 0x55873444b908> 
#>  @ file     : chr "/home/runner/work/_temp/Library/mighty.metadata/examples/_study.yml"

# Write back to a file
tmp <- tempfile(fileext = ".yml")
write_config(x, path = tmp)

# Or build one in memory
study_config(
  .data = list(study_id = "example_study", study_description = "A study")
)
#> <mighty.metadata::study_config>
#> Study ID: example_study
#> Fields: `study_id` and `study_description`
```
