# ADR: mighty_complete_study() class

## Status

|             |                                                    |
|-------------|----------------------------------------------------|
| Package     | mighty.metadata                                    |
| Version     | 0.1.0                                              |
| Description | New complete metadata class to ease downstream use |

## Success criteria

1.  Users can specify predecessors with shorthand: columns
    (`ADXX.MYVAR`, already supported), SUPP– qualifiers, BDS parameters
    and SDTM findings.
2.  Metadata is used consistently for code generation and documentation,
    in {mighty} and {mighty.toolbox} respectively, without any further
    processing inside the two packages.
3.  Information from components is re-used as much as possible, so users
    do not have to create redundant specifications.

## Context

Currently, the main export of {mighty.metadata} is the
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
class that defines all ADaM metadata for a study. It is sparsely defined
so that users do not have to specify redundant information, which makes
the current class suitable for CRUD updates, but not suitable for
downstream use.

It has the helpers
[`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md),
[`resolve_subsets()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_subsets.md),
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
and
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md),
which every integration must call correctly.

To make this easier, this ADR proposes a new class that handles this
consistently, and also adds functionality to inherit metadata from the
referenced components.

## Decisions

`mighty_complete_study()` is a new S7 class (parent `S7_object`) that
stores the resolved
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
as a read-only property. It does not inherit from
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md),
because read-only cannot be enforced on the `<list>` parent of
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md).
It populates and resolves all information, so all metadata and
components are directly available for downstream use.

The new flow in the packages becomes:

    mighty_study()
    └─> mighty_complete_study()
        ├─> mighty::generate_adam_code()
        └─> mighty.toolbox::generate_define_xml()

Add new downstream methods for both generics, and keep existing
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
methods as wrappers:

    generate_adam_code(<mighty_study>)
    └─> mighty_complete_study()
        └─> generate_adam_code(<mighty_complete_study>)

    generate_define_xml(<mighty_study>)
    └─> mighty_complete_study()
        └─> generate_define_xml(<mighty_complete_study>)

The new `resolve_components()` helper is exported alongside the existing
helpers. All helper functions consistently return a
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
object.

The `populate` argument of
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
is soft-deprecated in favor of `mighty_complete_study()`. It only runs
[`populate_core()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_core.md)
and
[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md),
and skips includes and subsets.

## Consequences

Downstream use in {mighty} and {mighty.toolbox} has to be updated after
this feature is released.

Any new special `mighty_*` components have to be added to
{mighty.standards}.

All components must have correct `@method` and `@origin` tags; existing
components do not.

{mighty.metadata} adds {mighty.component} to `Imports`. There is no
circular dependency, since {mighty.component} does not depend on
{mighty.metadata}. {mighty.standards} is not a package dependency but a
GitHub repository of components, found through the `repos` field in
`_mighty.yml`.

## Alternatives Considered

### 1. Only add a new helper function to resolve components and inherit component metadata

Not chosen, because a separate class guarantees that downstream code
receives a fully resolved object, and lets {mighty} and {mighty.toolbox}
dispatch on it. With only a helper, every integration must call it, and
nothing ensures that it was called.

### 2. Handle supplementary data as part of the base domain specification

Proposed as Option A in
[mighty#95](https://github.com/NovoNordisk-OpenSource/mighty/issues/95).
The base domain gets a flag, and columns refer to `SUPP` only. The SUPP–
data set is derived from the base domain (e.g. `AE` –\> `SUPPAE`):

``` yaml
population:
  base:
    - domain: AE
      include_supp: TRUE

columns:
  - id: AETECH1
    method: SUPP.AETECH1
```

This keeps the two-part `DOMAIN.COLUMN` notation, and with multiple base
domains (e.g. LB and XL) one column entry can get values from both
SUPPLB and SUPPXL.

Not chosen, because it requires changes to `population`, makes `SUPP` a
reserved domain name, and only supports SUPP– data sets of the base
domain. Instead, we use the explicit `SUPPDM.EFFICACY.QVAL` notation,
which maps directly to a predecessor with a where clause and needs no
flag on the base domain.

## Implementation Details

In general, this change should be implemented in many smaller increments
to ensure we continuously remain compatible with {mighty} and
{mighty.toolbox}.

Proposed implementation order:

1.  Update
    [`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
    to support component predecessor mapping. Extend the predecessor
    regex in
    [`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
    and `is_predecessor()` to accept the three-part shorthand and the
    expanded `where` form.
2.  First version of `resolve_components()`.
3.  Add any new special `mighty_*` components to {mighty.standards}.
4.  First version of `mighty_complete_study()`, only implementing
    component metadata re-use. Note that this means {mighty} will
    temporarily fetch the components a second time.
5.  Implement the new method dispatch in {mighty} and {mighty.toolbox}
    to ensure compatibility. Steps 1–5 give the first complete
    implementation; steps 6 and 7 are optimization.
6.  Remove now-redundant logic around predecessors in {mighty}.
7.  In several steps refactor {mighty} to use the new `@nodes` property
    effectively.

### Component metadata retrieval

The component metadata is added in the following steps:

1.  A new `resolve_components()` function populates component tags back
    to the `column` entries in the
    [`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
    object:
    1.  `@origin` –\> `column.origin`
    2.  `@method` –\> `column.method`
2.  The rendered component objects are stored in `@nodes` of
    `mighty_complete_study()` (see below).

`resolve_components()` uses the `repos` field of `_mighty.yml`
(`@mighty`) to find standard and local components. If `@mighty` is
`NULL`, it returns the study unchanged. This supports documentation-only
use.

[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
keeps a user-set `component` but still runs metadata inheritance for it,
so the parser accepts both the shorthand and the expanded form.

`origin` and `component` are only filled when missing. Precedence per
field:

1.  `origin`: user, else the origin set by the predecessor mapping
    (`"Predecessor"` or `"Derived"`), else component `@origin`.
2.  `method`: the expanded form if the user’s `method` is a predecessor
    reference, else the user’s `method`, else the base-domain reference
    for case 1, else component `@method`.
3.  `component`: user, else the shorthand mapping.

Every helper, and the full pipeline, must give the same result when run
again on its own output. This is needed because the
`generate_*(<mighty_study>)` wrappers always call
`mighty_complete_study()`, and a resolved
[`mighty_study()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/mighty_study.md)
cannot be distinguished from a raw one.

### `mighty_complete_study()`

Proposed structure, all properties read-only:

    <mighty_complete_study>
    @ properties :
      $ spec       : <mighty_study>  # The resolved and populated study specification
      $ components : <list>          # Named list with all components used in the study
      $ nodes      : <list>          # Nested list of nodes, see below

Read-only is enforced with set-once setters. Each setter only allows the
assignment at construction, and errors afterwards:

``` r

spec = S7::new_property(
  class = S7::new_union(NULL, mighty_study),
  default = NULL,
  setter = function(self, value) {
    if (!is.null(self@spec)) {
      cli::cli_abort("{.field @spec} is read-only")
    }
    self@spec <- value
    self
  }
)
```

Rendered components are R6 objects and are not protected from in-place
modification. The guarantee is that `@spec`, `@components` and `@nodes`
are consistent with each other at construction.

`mighty_complete_study(x, ...)` passes `...` on to the helpers
(e.g. `info` to
[`resolve_includes()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/resolve_includes.md)).
`@spec` is built with:

``` r

x |>
  resolve_includes(...) |>
  resolve_subsets() |>
  populate_core() |>
  populate_sparse() |>
  resolve_components()
```

`@nodes` has a package-neutral structure owned by {mighty.metadata};
downstream packages adapt to it. Each node has `type` (column, row, or
parameter, matching the `columns`, `rows` and `parameters` entries of
the domain), `id`, and `component` (the rendered component object):

    @nodes$ADSL$AGE
      $ type      : "column"
      $ id        : "AGE"
      $ component : <mighty_component_rendered>

### Predecessor mapping and components

Shorthand predecessor mapping, with current domain `ADSL` and base
domain `DM`:

| \# | Case | Input `method` | `method` after [`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md) | Component | Origin | Inherits from |
|----|----|----|----|----|----|----|
| 1 | Keep column from the base domain | none (`id: MYVAR`) | `DM.MYVAR` | `mighty_init_domain` | Predecessor | Source column, if in study |
| 2 | Rename column from the base domain | `DM.DMSEQ` | unchanged | `mighty_col_rename` | Predecessor | Source column, if in study |
| 3 | Copy existing column into new column | `ADSL.MYVAR` | unchanged | `mighty_col_mutate` | Predecessor | Source column, if in study |
| 4 | Join predecessor from other domain | `ADXX.VAR2` | unchanged | `mighty_col_echo` | Predecessor | Source column, if in study |
| 5 | Join predecessor from supplementary SDTM data | `SUPPDM.EFFICACY.QVAL` | `SUPPDM.QVAL where QNAM="EFFICACY"` | `mighty_merge_supp` | Predecessor | None |
| 6 | Join predecessor from ADaM BDS data set | `ADVS.BMIGRP.AVALC` | `ADVS.AVALC where PARAMCD="BMIGRP"` | `mighty_merge_param` | Derived | `AVALC` of parameter `BMIGRP` |
| 7 | Join predecessor from SDTM findings data | `VS.SYSBP.VSSTRESN` | `VS.VSSTRESN where VSTESTCD="SYSBP"` | `mighty_merge_param` | Derived | None |

In case 1, a column with no `method` and no `component` is taken from
the base domain(s). Several base domains are row-bound, and all must
have the column. With several base domains (e.g. LB and XL), `method` is
`LB.MYVAR, XL.MYVAR` and `origin` is `Derived`.

Filtered references other than SUPP– (cases 6 and 7) get
`origin: Derived`, since they are not valid define.xml predecessors.

Cases 1–4 inherit label and type from the source column only if the
source domain is in the study; case 6 inherits from the parameter
column. Cases 5 and 7 inherit nothing, since SUPP– and SDTM sources are
not in the study. Where no metadata is inherited, users must specify
label and type.

[`populate_sparse()`](https://novonordisk-opensource.github.io/mighty.metadata/reference/populate_sparse.md)
sets or rewrites `method` to the expanded form used in define.xml, and
writes `component.id` and, if needed, `component.with` (`domain`,
`column`, optional `filter`) for code generation. Example for a column
in `ADAE` (case 4):

``` yaml
# input
- id: AGE
  method: ADSL.AGE

# after populate_sparse()
- id: AGE
  method: ADSL.AGE
  origin: Predecessor
  component:
    id: mighty_col_echo
    with:
      domain: ADSL
      column: AGE
```

The three-part notation `DOMAIN.VALUE.COLUMN` filters the predecessor
domain on `VALUE`. The filter key is derived from the domain prefix:

1.  `SUPP--`: `QNAM`
2.  Domain in the study (ADaM BDS): `PARAMCD`
3.  Any other domain (SDTM findings): `<DOMAIN>TESTCD`

The filter is stored in `component.with`, e.g. for SUPP–:

``` yaml
method: 'SUPPDM.QVAL where QNAM="EFFICACY"'
origin: Predecessor
component:
  id: mighty_merge_supp
  with:
    domain: SUPPDM
    column: QVAL
    filter:
      QNAM: EFFICACY
```

{mighty.metadata} only passes domain, column and filter in
`component.with`. Components choose their own join keys (e.g. `USUBJID`,
or `IDVAR`/`IDVARVAL` for SUPP–).

The first four components are already implemented in {mighty}, and the
standard components exist in {mighty.standards}. `mighty_merge_supp` and
`mighty_merge_param` are new and have to be written; whether they become
one component is decided during implementation.

## Testing Strategy

1.  Keep all tests for exported functions in downstream packages the
    same, ensuring a consistent user experience.
2.  Only remove internal tests when the functionality is made redundant
    by this new class.
3.  Integration tests: {mighty} in the {mighty.metadata} CI;
    {mighty.toolbox} in its own CI, since it is an internal repository.
4.  Add unit tests in {mighty.metadata} for:
    1.  Parsing of the two- and three-part predecessor notation,
        including the filter key rules.
    2.  The expanded form parses to the same `component.with` as the
        shorthand.
    3.  Field precedence for `origin`, `method` and `component`.
    4.  Each helper and `mighty_complete_study()` give the same result
        when run again on their own output.
    5.  Read-only properties of `mighty_complete_study()`.
    6.  `resolve_components()` returns the study unchanged when
        `@mighty` is `NULL`.

## Risks

Internally, {mighty} handles a lot of the logic that is now pushed
forward into the component helpers. Depending on how large the required
changes are, we may have to plan them separately from this document.

Open question: whether the case 1 mapping stays inside {mighty} for
performance. If so, this is an exception to success criterion 2.

## Compliance Considerations

None.

## References

- [ADR: Package design and
  scope](https://novonordisk-opensource.github.io/mighty.metadata/articles/adr.md)
- [ADR: mighty.toolbox
  integration](https://novonordisk-opensource.github.io/mighty.metadata/articles/adr-mighty_toolbox_integration.md)
- [ADR: Specifying pooled
  specifications](https://novonordisk-opensource.github.io/mighty.metadata/articles/adr-pooling.md)
- [mighty.metadata milestone: 0.3.0 integration with
  mighty.component](https://github.com/NovoNordisk-OpenSource/mighty.metadata/milestone/4)
- [mighty.metadata#23: Integrate component
  metadata](https://github.com/NovoNordisk-OpenSource/mighty.metadata/issues/23)
- [mighty.component milestone: 0.1.1 integration with
  mighty.metadata](https://github.com/NovoNordisk-OpenSource/mighty.component/milestone/8)
- [mighty.standards milestone: initial release with internal
  components](https://github.com/NovoNordisk-OpenSource/mighty.standards/milestone/5)
- [mighty.standards#72: supp: add supplemental
  qualifiers](https://github.com/NovoNordisk-OpenSource/mighty.standards/issues/72)
- [mighty#95: Reference SUPP– qualifiers directly from the domain
  specification](https://github.com/NovoNordisk-OpenSource/mighty/issues/95)
