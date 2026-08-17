# Write a mighty object to YAML

Methods for the
[`S7schema::write_config()`](https://novonordisk-opensource.github.io/S7schema/reference/write_config.html)
generic that serialize
[mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
and
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
objects back to YAML files.

## Usage

``` r
write_config(x, path = NULL)

## S7 method for class <mighty.metadata::mighty_config>
write_config(x, path = NULL)

## S7 method for class <mighty.metadata::mighty_study>
write_config(x, path = NULL)
```

## Arguments

- x:

  A
  [mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md)
  or
  [mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  object.

- path:

  Directory to write to. If `NULL`, defaults to the source directory the
  object was loaded from.

## Value

Invisibly returns `x`.

## See also

[mighty_config](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_config.md),
[mighty_study](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
