---
name: openspec-status
description: Check the status of all open OpenSpec changes — identify stale ones already merged into dev, and surface open PRs that address them.
disable-model-invocation: true
---

Check the status of all open OpenSpec changes: identify stale ones already merged into dev, and surface open PRs that address them.

## Steps

1. List open changes: `npx openspec list`
2. For each open change, read its proposal using `npx openspec show <change-name>` to understand what it intends to do.
3. Search for open PRs whose branch name or title relates to the change. Use `gh pr list --state open --json number,title,headRefName,author,url --limit 30` once upfront, then match against each change by branch name (often matches the change name) and by keywords from the proposal.
4. Search for recently merged PRs (last 4 weeks) that match the change's intent. Use `gh pr list --state closed --search "<keywords> merged:>YYYY-MM-DD" --json number,title,mergedAt,author,headRefName --limit 20` with keywords extracted from the change proposal (key terms like class names, feature descriptions, ticket numbers).
5. For any candidate merged PRs found, check the diff with `gh pr diff <number>` to confirm the change's goal was achieved.
6. Optionally verify the current codebase state using LSP or Grep to confirm the implementation is present in dev.

## Output

Present a summary table:

| OpenSpec Change | Status | Evidence |
|-----------------|--------|----------|
| change-name | Done | PR #1234 by @author (merged Mar 20) — description of what it did |
| change-name | PR open | PR #1234 by @author — title (draft/ready, review status) |
| change-name | Not started | No matching PRs found |
| change-name | Partially done | PR #1234 covers X but not Y |

### Status definitions

- **Done** — A merged PR fully achieves the change's intent. Offer to archive with `rm -rf openspec/changes/<name>`.
- **PR open** — An open PR addresses this change. Note whether it's a draft, has review approvals, or is failing checks. Include the PR URL.
- **Not started** — No matching open or merged PRs found.
- **Partially done** — A merged PR covers some but not all of the change's scope, OR an open PR exists but only addresses part of it.

## Notes

- A change may have been implemented differently than proposed (e.g., different method names, broader scope). Focus on whether the *intent* was achieved, not exact implementation match.
- Check both the change's ticket number (if any, e.g. "clp-XXXX" in the name) and semantic keywords when searching PRs.
- The PR author may be someone other than the change creator.
- When matching open PRs, the branch name is often the strongest signal — branches frequently use the change name or a variation of it.
