## ADDED Requirements

### Requirement: STALE check runs excluded from CI failure display
`my-prs.sh` SHALL treat check runs with conclusion `STALE` as non-failures, equivalent to `CANCELLED`, `SKIPPED`, and `NEUTRAL`.

#### Scenario: PR with a STALE check and all others passing
- **WHEN** a PR's `statusCheckRollup` contains a check with `status=COMPLETED` and `conclusion=STALE`, and all other checks have passing conclusions
- **THEN** the CI column displays ✅, not ❌

#### Scenario: PR with a STALE check and a genuine FAILURE
- **WHEN** a PR's `statusCheckRollup` contains both a STALE check and a check with `conclusion=FAILURE`
- **THEN** the CI column displays ❌ (the real failure is still surfaced)
