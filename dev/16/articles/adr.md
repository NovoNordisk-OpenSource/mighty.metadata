# ADR: Package design and scope

## Status

|             |                                                               |
|-------------|---------------------------------------------------------------|
| Package     | mighty.metadata                                               |
| Status      | Approved                                                      |
| Version     | 0.1.0                                                         |
| Description | ADR for base structure and initial release of mighty.metadata |

## Success criteria

With the initial v0.1.0 release of mighty.metadata users will be able to
specify ADaM data sets using our new YAML based format. Functions and
classes in mighty.metadata will facilitate easy manipulation,
validation, and downstream usage.

## Context

mighty.metadata is a new R package defining a new way of working with
metadata and specifications for programming CDISC ADaM data sets. It
replaces legacy Excel metadata that are stored in tabular form generally
known as CST files.

The specification of ADaM datasets in mighty.metadata has a dual purpose
of equal importance:

1.  Full specification in a machine readable format that can be utilized
    for automation and limit existing manual coding workflows.
2.  Automatic generation of ADaM scripts using the complete mighty
    framework.

In order to achieve this we need agreement on the aspects below.

*User interface:*

- How will a Clinical Data Scientist specify their ADaM dataset?
- What will be the main functionalities exported by the package?

*Scope of the package:*

- What is the technological scope of the solutions?
- To what degree will additional business logic be implemented?

*Integration:*

- What is our main tech stack?
- How do we ensure compatibility with mighty and mighty.toolbox?
- Should mighty.metadata be developed for Open-Source?

## Decisions

### 1. Use YAML

> YAML is used to specify ADaM data sets since it is machine readable,
> can be version controlled, and are easy to edit for a CDS. One YAML
> per ADaM domain. Structure of YAML will be defined with a JSON schema.
> YAML is used since it integrates well with Git while still being easy
> to update for a human.

### 2. Scope of solutions (YAML, R)

> The package will only read YAML specification files, and only write
> modified YAML specification files. All other functionalities will
> ingest and return R objects.

### 3. S7 based tech stack for robust validation and modern OOP

> Main classes and functionalities are based on S7, and S7 generics and
> dispatch are used. YAML functionalities are based on S7schema and use
> the validator from there.

### 4. Main classes

> The package will define two main classes:
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
> and
> [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)[¹](#fn1).
> [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
> is a list of metadata regarding a single ADaM domain. A new instance
> will be created based on the YAML specification.
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
> is a named list of
> [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
> objects. New instance to be created based on a path to a folder of
> YAML specifications.

### 5. Business logic handling

> The package will provide utility functions to reduce redundancies in
> ADaM specifications. Initially this will include inheritance of core
> variables, conditional filtering of specifications (e.g. subsetting a
> pooled specification to only include columns relevant for a single
> trial), and fully populate specifications (e.g. reusing label and
> format information from a predecessor). These utilities will ingest
> and return
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
> and/or
> [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
> objects as applicable. Often a method for
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
> will call the generic on each
> [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
> entry.

### 6. Process integration

> In general all downstream usage, e.g. code generation in mighty,
> should be based on
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).
> For easier reuse of metadata specifications in scripts the package
> will also include utility functions to create metadata in tabular
> format. Metadata will concern domains, columns, and parameters
> specified in
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
> and will be returned as
> [`data.frame()`](https://rdrr.io/r/base/data.frame.html)/`tibble`.
> Similarly, the package will also contain utility functions to do the
> reverse; creating a
> [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
> and
> [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
> objects from the same tabular format.

### 7. Open-Source

> mighty.metadata will be developed sufficiently generic to be suitable
> as a publicly available R package. To be hosted on
> NovoNordisk-OpenSource GitHub organization, and will be submitted to
> CRAN. 8. CDISC Standards support

The aim is for mighty.metadata and its schema to be compatible:

| Standard   | Version |
|------------|---------|
| ADaM.      | 2.1     |
| ADaM IG    | 1.2.    |
| OCCDS      | 1.1.    |
| Define-XML | 2.1     |

## Consequences

### Changes to current content

1.  Add
    [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
    class.
2.  Remove html viewer and formatting function.
3.  Move `build_adam_metadata()`, `write_adam_yaml()`, and
    `write_adam_domain_yaml()` to {plz} (utility package for NN specific
    workflows).
4.  Update `make_mdcol_from_yaml()` to ingest
    [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).

## Alternatives Considered

### 1. Work only directly with YAML files

- **Pros**: Simplifies technical implementation if we just read/write
  YAML files directly instead of defining new
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  and
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  classes.
- **Cons**: Lose the ability to work with the specifications in memory
  (suited for e.g. a later Shiny editor app).
- **R-specific considerations**: Validation without using parent
  S7schema class (or similar) would require significant development,
  that is out of scope for this package.
- **Why not chosen**: Validation needed; both when reading and writing
  specifications. In memory manipulation of specs needed for any further
  app development, but also makes it easier to manually work with the
  metadata from R.

### 2. Use S3 base R classes and methods

- **Pros**: Keep it simple, without using new “cutting-edge” libraries
  such as S7.
- **Cons**: Makes adopting S7schema validation harder.
- **R-specific considerations**: Lose the new more robust dispatch
  features of S7.
- **Why not chosen**: We need S7schema for validation, and S7schema need
  to be S7 due to how the javascript validator is implemented.

### 3. Use R6

- **Pros**: Use a more widely adopted OOP library.
- **Cons**: Lose the more pipeable user interface from S7.
- **R-specific considerations**: We do not need to modify objects in
  place, which is the standard in R6.
- **Why not chosen**: Implementing the pipeable user interface is
  simpler with S7.

### 4. Use jsonvalidate instead of S7schema

- **Pros**: Would have saved development time, since jsonvalidate was
  initially developed for use in mighty.metadata.
- **Cons**: jsonvalidate is less robust, and the reporting of validation
  errors are lacking. Also does not include functions to document a
  schema (planned in S7schema).
- **R-specific considerations**: jsonvalidate is based on R6, and we
  would therefore lose the
  [`S7::validate()`](https://rconsortium.github.io/S7/reference/validate.html)
  integration. The serializer in jsonvalidator looked really promising,
  but when tested it was not very robust.
- **Why not chosen**: Reporting of validation errors are not good enough
  for us to be able to represent them to a user in a meaningful way.

## Implementation Details

### Key Functions

- [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md):
  Metadata object for a single ADaM domain. Inherits from
  [`S7schema::S7schema()`](https://novonordisk-opensource.github.io/S7schema/reference/S7schema.html).
- [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md):
  Metadata object for a study. Named list of
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  objects.
- Utility functions to manipulate columns, rows, and parameters in a
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  object.
- Utility functions to create tabular representations of
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  metadata.
- Function to add core variables (e.g. from ADSL) as predecessors in
  another
  [`mighty_domain()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_domain.md)
  domain.
- Function to conditionally filter specifications suitable for
  subsetting a pooled study specification.
- Function to fully specify a domain when sparse information was
  provided. E.g. defining the format of a predecessor column based on
  the format of the origin column.
- Utility function to create YAML files based on tabular representations
  of
  [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
  metadata. Consider if we want to add wrapper covering Pinnacle 21E
  Excel metadata format. \### Example workflow

Below is an example workflow. Note that function names are stand-ins
unless they are explicitly specified above:

``` r
mighty_study("path/to/specs") |> # --> List `mighty_domain()` specs
  filter_with_metadata() |> # --> Remove e.g. columns from a pooled spec that are not relevant for study A
  populate_core() |> # --> adds core variables as predecessors 
  populate_sparse() |> # --> all info filled out and still returning a `mighty_study()` object
  create_md_col() # --> data.frame with all column specs
```

### Documentation Strategy

- roxygen2 documentation for all exported functions. Group in meaningful
  sections.
- README showing simple use case relevant for a new user
- Vignette documenting the schema
- Getting Started vignette showing general workflow (see example above)
- Article containing this ADR until we have a better place to put it.
- Include in overview of the mightyverse in the mighty package.
- Include as part of holistic ADaM programming section in r-docs2.

## Testing Strategy

- All scripts (`/R/{scriptname}.R`) should have a corresponding test
  file (`/tests/testthat/test-{scriptname}.R`).
- Focus on unit testing individual functions, including helper
  functions.
- Always aim for 100% test coverage.
- Also treat testing of larger exported functions as integration tests,
  making sure realistic use is tested, but rely on helper function to
  throw errors on invalid input in order to keep tests modular.
- Use standard GitHub Actions workflows from r.workflows.
- Avoid repo-level lint configurations as much as possible to ensure
  adherence QA standards established by r.workflows

## Risks

- S7 package disclaimer \> [We hope to avoid any major breaking changes,
  but reserve the right if we discover major
  problems.](https://rconsortium.github.io/S7/index.html)

## Compliance Considerations

- All development on GitHub using Pull Requests for merges to main
  branch, and standard ATMOS branch protection rules.
- R CMD Check is required to pass on all relevant platforms before a PR
  is approved.

## References

- [jsonvalidate](https://docs.ropensci.org/jsonvalidate/index.html)
- [mighty](https://github.com/NovoNordisk-OpenSource/mighty)
- [mighty.metadata](https://github.com/NovoNordisk-OpenSource/mighty.metadata)
- mighty.toolbox (internal package)
- plz (internal package)
- [r.workflows](https://github.com/NovoNordisk-OpenSource/r.workflows)
- [roxygen2](https://roxygen2.r-lib.org)
- [S7](https://rconsortium.github.io/S7/index.html)
- [S7schema](https://github.com/NovoNordisk-OpenSource/S7schema)

------------------------------------------------------------------------

1.  Originally named `mighty_metadata()`.
