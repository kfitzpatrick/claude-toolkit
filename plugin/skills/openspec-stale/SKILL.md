---
name: openspec-stale
description: Check for open OpenSpec changes that may have already been implemented and merged into dev.
disable-model-invocation: true
---

Check for open OpenSpec changes that may have already been implemented and merged into dev.

## Steps

1. List open changes: `npx openspec list`
2. For each open change, read its proposal using `npx openspec show <change-name>` to understand what it intends to do.
3. Search for recently merged PRs (last 4 weeks) that match the change's intent. Use `gh pr list --state closed --search "<keywords> closed:>YYYY-MM-DD" --json number,title,mergedAt,author,headRefName --limit 20` with keywords extracted from the change proposal (key terms like class names, feature descriptions, ticket numbers).
4. For any candidate PRs found, check the diff with `gh pr diff <number>` to confirm the change's goal was achieved.
5. Optionally verify the current codebase state using Grep to confirm the implementation is present in dev.

## Output

Present a summary table:

| OpenSpec Change | Status | Evidence |
|-----------------|--------|----------|
| change-name | Likely done | PR #1234 by @author (merged Mar 20) — description of what it did |
| change-name | Still open | No matching PRs found |
| change-name | Partially done | PR #1234 covers X but not Y |

For changes that appear fully implemented, ask the user which ones to delete (with `rm -rf openspec/changes/<name>`).

## Notes

- A change may have been implemented differently than proposed (e.g., different method names, broader scope). Focus on whether the *intent* was achieved, not exact implementation match.
- Check both the change's ticket number (if any, e.g. "clp-XXXX" in the name) and semantic keywords when searching PRs.
- The PR author may be someone other than the change creator.
