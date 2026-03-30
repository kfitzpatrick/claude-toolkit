# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A portable Claude Code configuration toolkit distributed as both a plugin marketplace (skills) and a bootstrap installer (scripts, statusline, CLAUDE.md preferences). Two install paths:

- **`./install.sh`** — symlinks scripts and statusline into `~/.claude/`, merges this file's content into `~/.claude/CLAUDE.md` between `<!-- claude-toolkit:start/end -->` markers
- **`/plugin marketplace add kfitzpatrick/claude-toolkit`** — installs skills from `plugin/skills/`

## Architecture

- `.claude-plugin/marketplace.json` — plugin marketplace manifest (must stay at this path for the plugin system to find it)
- `plugin/skills/` — each subdirectory is a skill exposed as `/claude-toolkit:<name>`
- `scripts/` — shell scripts symlinked into `~/.claude/scripts/`; `gh-api-read.sh` is auto-allowed in permissions for read-only GitHub API access
- `statusline-command.sh` — custom status line (git branch, model, context usage with color thresholds)
- `install.sh` — idempotent bootstrap; uses `ensure_symlink` for scripts/statusline, section markers for CLAUDE.md merge; supports `--uninstall`

## Workflow Preferences (merged into ~/.claude/CLAUDE.md)

The content below this section is what gets injected into the user's global CLAUDE.md by `install.sh`. Changes here propagate on next `./install.sh` run.

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