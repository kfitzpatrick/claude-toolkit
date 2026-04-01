## Context

`my-prs.sh` evaluates CI status by filtering `statusCheckRollup` check runs. The current failure filter excludes `SUCCESS`, `SKIPPED`, `NEUTRAL`, and `CANCELLED` conclusions. GitHub's `STALE` conclusion (set automatically after 14+ days of inactivity on an in-progress check) is not in the exclusion list, so it would be counted as a failure.

## Goals / Non-Goals

**Goals:**
- Prevent STALE check runs from triggering false ❌ in my-prs.sh

**Non-Goals:**
- Changing deduplication logic
- Handling other edge cases (e.g., null completedAt ordering)
- Modifying any other part of the script

## Decisions

**Add STALE to the exclusion list in the jq filter (line 192)**

The filter already excludes several non-failure conclusions. STALE fits the same pattern: it's a terminal state that doesn't represent an actionable CI failure — it means the check timed out waiting to run, not that code is broken.

No alternative approaches needed — this is a single-term addition to an existing filter.

## Risks / Trade-offs

- **[Risk]** A genuinely stale check (never ran, timed out) would be silently ignored → Mitigation: STALE only occurs after 14 days of inactivity; in practice, PRs with stale checks are either abandoned or the check system is broken — not something my-prs.sh should surface as a code failure.
