# Global Instructions

## How I Work
- Do NOT commit without explicit user approval
- Never commit directly to the main branch (dev, main, etc.)
- ~5-6 files per commit, grouped by concern/layer, specs alongside code
- Prefer dedicated tools (Read/Glob) over Bash for file exploration
- Extract public collaborator objects instead of .send on private methods

## GitHub API Access

Prefer `gh` subcommands (`gh pr list`, `gh issue view`, etc.) over raw API calls —
they infer the repo from git remotes and handle pagination automatically.

When you need the REST API directly (no `gh` subcommand covers the query),
use `~/.claude/scripts/gh-api-read.sh` instead of `gh api` for read-only calls.
This wrapper is auto-allowed in permissions and enforces GET-only requests.

For write operations (POST, PATCH, PUT, DELETE), use `gh api` directly —
this requires per-session user approval.
