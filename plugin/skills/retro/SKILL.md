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

### 5. Identify skill candidate patterns

Scan the **user messages** in this session for natural-language requests that imply a multi-step, parameterizable workflow worth codifying as a reusable skill.

Candidate signals to look for:
- An imperative directed at a named external system with a parameterizable identifier (e.g., "familiarize yourself with CLP-5572 in JIRA", "look at PR #123")
- A fetch-then-summarize pattern where a single user sentence resulted in 3 or more sequential tool calls to fulfill it (e.g., "summarize the last 10 commits")

**Pre-check before flagging:** For each candidate, verify it is NOT already covered by an available skill from the session's skill list or a script in `~/.claude/scripts/`. If it is already covered, do not add it to the Skill Candidates table — route it to the Missed Tooling findings instead (it belongs there, not here).

If no user messages match these signals, skip this section entirely.

### 6. Present findings

Summarize in up to three tables:

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

**Skill Candidates** *(omit section if none found):*

| What You Asked | Implied Workflow | Suggested Skill |
|----------------|-----------------|-----------------|
| "familiarize yourself with CLP-5572 in JIRA" | fetch ticket → read description/comments → summarize context | `/jira-context <id>` |
| "summarize the last 10 commits" | git log → format summary | `/commit-digest` |

If no issues are found in a category, say so briefly and move on.

Then ask the user:
- Which missing permissions they'd like added
- Whether any missed-tooling patterns should be saved as feedback memories
- Whether any of the findings warrant updates to this `/retro` skill itself

If skill candidates were found, also ask:
- **Placement**: For each candidate — is it broadly useful across projects (→ claude-toolkit plugin), or tied specifically to this codebase?
- **Interest**: Would you like to start an `/opsx:explore` session to develop any of these into a skill?
- **Calibration**: Did I miss any patterns that could become a skill? Or flag something too eagerly — too rare to be worth it, too project-specific, or already covered by something?

### 7. Apply approved changes

For any permissions the user approves:
- Use the `/update-config` skill to add them to the appropriate settings file (global for cross-project commands, project-local for project-specific ones)

For any behavioral feedback worth remembering:
- Save it as a feedback memory so future sessions benefit

For calibration answers about skill candidate detection:
- Save as a feedback memory (e.g., "don't flag X type of pattern", "always flag Y pattern") so future retro sessions detect more accurately
