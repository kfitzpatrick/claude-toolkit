# claude-toolkit

Personal Claude Code configuration — skills, scripts, statusline, and preferences. Portable across machines and teams.

## Quick Start

```bash
# Clone
git clone git@github.com:kfitzpatrick/claude-toolkit.git ~/werk/claude-toolkit

# Bootstrap — symlinks scripts, statusline, and merges preferences into ~/.claude/CLAUDE.md
cd ~/werk/claude-toolkit
./install.sh

# Install the plugin (from within a Claude Code session)
/plugin marketplace add kfitzpatrick/claude-toolkit
```

## What's Included

### Plugin (installed via `/plugin`)

Skills available as `/claude-toolkit:<name>`:

| Skill | Description |
|-------|-------------|
| `prove` | Challenge recent assertions with evidence |
| `retro` | Retrospective on tool usage and approval friction |
| `grill-me` | Stress-test a plan or design with relentless questions |
| `find-skills` | Discover and install community skills |
| `openspec-stale` | Find OpenSpec changes already merged into dev |
| `openspec-status` | Dashboard of all open OpenSpec changes |
| `feature-analysis` | Agent Team process for analyzing legacy features before migration (see below) |

### feature-analysis

A skill for safely migrating legacy features. Spawns a Claude Agent Team (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` required) that:

1. **Interviews you** about the feature scope, permissions, known quirks, and dev environment
2. **Maps the code** — Code Explorer traces the dependency graph via LSP (routes → controllers → components → services → models), spawning subagents for Test Portability Scoring and Playwright script generation
3. **Verifies in the browser** — Browser Explorer runs a scripted Playwright batch against your dev app, then does targeted exploration for edge cases
4. **Produces a confidence-graded spec** — every discovered behavior is classified as CONFIRMED, PRESERVE QUIRK, CORRECT IN SPEC, OUT OF SCOPE, or DEFER
5. **Resolves ambiguities with you** — inconsistencies are presented as batched Q&A, not silent assumptions
6. **Outputs** a `feature-analysis.md` artifact + a Playwright test suite (the migration contract)

The skill pairs with the `migration-workflow` OpenSpec schema (installed via `./install.sh`), which adds a `feature-analysis` artifact step before design and specs in any change:

```bash
openspec new change my-feature-migration --schema migration-workflow
```

**Requires:** Claude Code v2.1.32+, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, Playwright in the target project

### Bootstrap (installed via `./install.sh`)

| Asset | Description |
|-------|-------------|
| `scripts/gh-api-read.sh` | Read-only `gh api` wrapper (auto-allowed in permissions) |
| `scripts/my-prs.sh` | Morning PR dashboard with review & CI status |
| `scripts/git-read.sh` | Read-only git info for PR workflows |
| `statusline-command.sh` | Custom status line with git branch, model, and context usage |
| `CLAUDE.md` | Personal workflow preferences (merged into `~/.claude/CLAUDE.md`) |
| `openspec/schemas/migration-workflow` | Custom OpenSpec schema (copied to `~/.local/share/openspec/schemas/`) |

## Usage

### my-prs.sh

```bash
my-prs.sh                    # mobilizeio org, last 4 weeks
my-prs.sh 2                  # mobilizeio org, last 2 weeks
my-prs.sh --org acme-corp    # different org, last 4 weeks
my-prs.sh --org acme-corp 2  # different org, last 2 weeks
```

## Updating

```bash
cd ~/werk/claude-toolkit
git pull
./install.sh   # re-runs idempotently, updates CLAUDE.md managed section
```

## Uninstalling

```bash
./install.sh --uninstall   # removes symlinks and managed CLAUDE.md section
```

To also remove the plugin, from within a Claude Code session:
```
/plugin uninstall claude-toolkit
```
