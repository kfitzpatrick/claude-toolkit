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

### Bootstrap (installed via `./install.sh`)

| Asset | Description |
|-------|-------------|
| `scripts/gh-api-read.sh` | Read-only `gh api` wrapper (auto-allowed in permissions) |
| `scripts/my-prs.sh` | Morning PR dashboard with review & CI status |
| `scripts/git-read.sh` | Read-only git info for PR workflows |
| `statusline-command.sh` | Custom status line with git branch, model, and context usage |
| `CLAUDE.md` | Personal workflow preferences (merged into `~/.claude/CLAUDE.md`) |

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
