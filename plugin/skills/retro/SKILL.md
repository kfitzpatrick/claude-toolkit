---
name: retro
description: Retrospective on tool usage in the current session — identify unnecessary approval prompts, missed tooling, and suggest improvements.
disable-model-invocation: true
---

Pause and review the tool calls made so far in this conversation. The goal is to identify friction — places where I used a tool in a way that caused unnecessary approval prompts, or missed purpose-built tooling that was available.

## Analysis Steps

### 1. Identify every Bash tool call that required (or would have required) user approval

Review the conversation history for Bash calls. For each one, check whether it matches an entry in the user's allow list. To do this:

- Read the project-level settings: `.claude/settings.local.json` (in the current working directory)
- Read the global settings: `~/.claude/settings.json`

Extract the `permissions.allow` arrays from both files. A Bash call is auto-allowed if it matches any `Bash(...)` pattern in either file. The pattern format is prefix-based: `Bash(git log:*)` allows any command starting with `git log`.

### 2. Classify each unapproved call

For each Bash call that was NOT covered by an allow pattern, classify it:

- **Avoidable**: A dedicated tool (Read, Glob, Grep, etc.) could have done the same thing without needing Bash at all. Note which tool should have been used.
- **Missing permission**: The Bash call was the right approach, but the permission pattern is missing or too narrow. Suggest the specific `Bash(...)` pattern to add and whether it belongs in global or project-local settings.
- **One-off**: A niche command that doesn't warrant a permanent permission. No action needed.

### 3. Check for missed purpose-built tooling

Review the conversation for cases where I did something manually that existing tooling could have handled better:

- **User scripts**: Check `~/.claude/scripts/` for scripts that could have replaced raw commands (e.g., `my-prs.sh` instead of crafting GitHub API queries manually).
- **Project CLIs**: Check the Bash allow list for project-specific CLIs (e.g., `npx openspec`, `bin/rails`) that were available but unused. If I manually read files or hit APIs that a CLI abstracts, flag it.
- **Available skills**: Check whether any of the session's available skills could have handled part of the task but weren't invoked.
- **MCP tools**: Check whether MCP tools (GitHub, Atlassian, etc.) could have replaced manual API calls.

### 4. Check for other tool friction

Look for non-Bash tools that required approval too (e.g., Read paths outside the project, MCP tools, WebFetch domains). Suggest additions if they'd be frequently useful.

### 5. Present findings

Summarize in two tables:

**Approval Friction:**

| Tool Call | Category | Suggestion |
|-----------|----------|------------|
| `head -5 file.md` | Avoidable | Use Read tool instead |
| `git remote -v` | Missing permission | Add `Bash(git remote -v*)` to global settings |

**Missed Tooling:**

| What I Did | What Was Available | Impact |
|------------|--------------------|--------|
| Raw GitHub API search | `~/.claude/scripts/my-prs.sh` or `/my-prs` skill | Reinvented existing functionality |
| Manually read openspec/ files | `npx openspec list --json` | More approvals, messier output |

If no issues are found in a category, say so briefly and move on.

Then ask the user:
- Which missing permissions they'd like added
- Whether any missed-tooling patterns should be saved as feedback memories
- Whether any of the findings warrant updates to this `/retro` skill itself

### 6. Apply approved changes

For any permissions the user approves:
- Use the `/update-config` skill to add them to the appropriate settings file (global for cross-project commands, project-local for project-specific ones)

For any behavioral feedback worth remembering:
- Save it as a feedback memory so future sessions benefit
