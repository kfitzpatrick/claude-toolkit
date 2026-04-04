## Why

GitHub check runs can have a `STALE` conclusion, set automatically when a check remains in-progress for 14+ days. `my-prs.sh` does not exclude `STALE` from its failure set, so a stale check run would be counted as a failure and display ❌ incorrectly.

## What Changes

- Add `STALE` to the list of conclusions excluded from CI failure detection in `my-prs.sh`

## Capabilities

### New Capabilities

- `ci-stale-exclusion`: Exclude STALE check run conclusions from CI failure display in my-prs.sh

### Modified Capabilities

<!-- none -->

## Impact

- `scripts/my-prs.sh`: one-line change to the `failed_json` jq filter (line 192)
