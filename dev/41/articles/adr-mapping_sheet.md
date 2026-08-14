# ADR: Mapping Sheet Structure

|  |  |
|----|----|
| Package | `mighty.metadata` |
| Status | Approved |
| Version | 0.2.0 |
| Description | ADR for defining the structure of mapping metadata in compliance with `mighty.toolbox` needs |

## Success Criteria

- `mighty.metadata` declares schema support for study-level `standards`
  and `terminology` fields in `inst/schema/study.json`.
- `_study.yml` supports structured `standards` and `terminology`
  sections.
- Each `standards` / `terminology` entry requires `id` and `version`.
- `mighty.toolbox` can consume `standards` and `terminology` from
  `_study.yml` without manual transformation when generating
  `define.xml`.
- The structure can be correctly referenced in all supported levels for
  `define.xml` generation.

------------------------------------------------------------------------

## Context

Standards and terminology are study-level metadata and should be stored
directly in `_study.yml`. The required structure is list-based and
explicit:

- `standards`: list of objects with `id` and `version`
- `terminology`: list of objects with `id` and `version`

This structure is intended to be the source consumed by `mighty.toolbox`
for `define.xml` generation.

------------------------------------------------------------------------

## Decisions

- Standards/terminology are implemented inside `_study.yml` as
  study-level metadata.
- Validation is implemented in `inst/schema/study.json`.
- Two new optional top-level fields are added to study metadata:
  - `standards`
  - `terminology`
- Entries in both lists must contain:
  - `id` (required)
  - `version` (required)

------------------------------------------------------------------------

## Example Representation

``` yaml
study_id: XYZGTV35

standards:
  - id: ADaM-IG
    version: 1.1

terminology:
  - id: ADAM
    version: 2025-08-06
  - id: SDTM
    version: 2025-08-06
  - id: MedDRA
    version: 22.1
  - id: WHODrug
    version: 2023 JAN
```

------------------------------------------------------------------------

## Validation and Checks

Validation is performed as part of study-level schema validation for
`_study.yml`.

Rules:

- `standards` and `terminology` are optional top-level fields.
- If present, each must be an array of objects.
- Each object must include required fields `id` and `version`.
- Additional fields may be allowed for forward compatibility unless
  explicitly restricted in schema.

Validation must also accept the “empty mapping information” case:

- missing `standards` and/or `terminology`
- existing `standards: []` and/or `terminology: []`

Both variants are interpreted as no standards/terminology entries.

Responsibility split:

- `mighty.metadata` performs structural/schema validation only
  (presence, shape, required fields).
- `mighty.metadata` does not perform domain-semantic validation (e.g.,
  version-existence checks in GCMD).
- `mighty.toolbox` performs domain-semantic validation required for
  downstream `define.xml` generation, including checks whether submitted
  versions exist in GCMD.

------------------------------------------------------------------------

## Classes

The implementation follows the existing `mighty_study` structure by
extending the study payload (loaded from `_study.yml`) rather than
introducing a new top-level component. This keeps standards/terminology
in the same study-level object and aligns with the decision that they
are part of core study metadata.

------------------------------------------------------------------------

## Consequences

### Changes to Current Content

- `_study.yml` gains new `standards` and `terminology` sections.

------------------------------------------------------------------------

## Implementation Details

- Update `inst/schema/study.json`:
  - add `standards` as an array of objects,
  - add `terminology` as an array of objects,
  - require `id` and `version` for each item.
- Keep validation in the existing study loading path (`_study.yml`
  schema validation).
- Ensure `write_mighty_study()` preserves/writes `standards` and
  `terminology` in `_study.yml`.

Add tests:

- valid `_study.yml` with both sections,
- missing `id`/`version` -\> validation message,
- roundtrip read/write retains structure,
- empty-list cases (`standards: []`, `terminology: []`) are valid, but
  validation messages may be issued.

------------------------------------------------------------------------

## Testing Strategy

- Test in `mighty.toolbox` using `mighty.metadata` metadata.
- Unit and/or acceptance tests in `mighty.metadata`.
- Add tests for empty standards/terminology scenarios:
  - no `standards` field,
  - no `terminology` field,
  - `standards: []`,
  - `terminology: []`,
  - expected result: valid study metadata with no standards/terminology
    entries.

------------------------------------------------------------------------

## Risks

- Schema changes in `study.json` may affect existing study validation
  behavior.

------------------------------------------------------------------------

## Compliance Considerations

- All development on GitHub using Pull Requests for merges to `main`,
  following standard ATMOS branch protection rules.
- `R CMD Check` must pass on all relevant platforms before a PR is
  approved.

------------------------------------------------------------------------

## References

- [mighty.metadata](https://github.com/NovoNordisk-OpenSource/mighty.metadata)
- mighty.toolbox (internal package)
- [r.workflows](https://github.com/NovoNordisk-OpenSource/r.workflows)
