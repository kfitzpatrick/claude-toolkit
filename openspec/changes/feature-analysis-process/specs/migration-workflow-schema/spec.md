## ADDED Requirements

### Requirement: Custom schema adds feature-analysis artifact
The `migration-workflow` schema SHALL define a `feature-analysis` artifact that produces a confidence-graded behavioral spec for the feature under analysis. The artifact SHALL be required before `design` and `specs` artifacts can be created.

#### Scenario: Creating a change with the migration-workflow schema
- **WHEN** a user runs `openspec new change <name> --schema migration-workflow`
- **THEN** the change directory is created with `.openspec.yaml` containing `schema: migration-workflow`
- **AND** `openspec status` shows `feature-analysis` as the first ready artifact

#### Scenario: Artifact dependency ordering
- **WHEN** the `feature-analysis` artifact has not been created
- **THEN** `design` and `specs` artifacts SHALL have status `blocked` with `feature-analysis` in their missing dependencies

#### Scenario: Feature-analysis artifact is complete
- **WHEN** the `feature-analysis` artifact has been written
- **THEN** `design` and `specs` artifacts SHALL become `ready`

### Requirement: Schema includes proposal artifact
The schema SHALL include a standard `proposal` artifact as the first step, identical in structure to the built-in `spec-driven` schema's proposal. The `feature-analysis` artifact SHALL require `proposal`.

#### Scenario: Proposal before feature-analysis
- **WHEN** a new change is created with the migration-workflow schema
- **THEN** `proposal` is the only `ready` artifact
- **AND** `feature-analysis` is `blocked` until `proposal` is complete

### Requirement: Schema template guides confidence-graded output
The `feature-analysis` artifact's template SHALL instruct the creator to produce output with five confidence categories: CONFIRMED, PRESERVE QUIRK, CORRECT IN SPEC, OUT OF SCOPE, and DEFER.

#### Scenario: Feature-analysis artifact structure
- **WHEN** a user or agent creates the feature-analysis artifact
- **THEN** the output document SHALL contain sections for each confidence category
- **AND** each discovered behavior SHALL be placed in exactly one category

### Requirement: Schema is valid OpenSpec schema
The `migration-workflow` schema SHALL pass `openspec schema validate` without errors.

#### Scenario: Schema validation
- **WHEN** `openspec schema validate migration-workflow` is run
- **THEN** the command exits with status 0 and reports no errors
