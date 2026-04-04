## Why

Working with legacy codebases requires understanding feature behavior before refactoring, but existing test suites are often framework-tied (e.g., Angular unit tests using `$scope` and `$digest`) and can't serve as a migration safety net. There's no repeatable process for analyzing a feature, specifying its behavior, evaluating test portability, and producing framework-independent tests that survive a rewrite.

## What Changes

- Add a custom OpenSpec schema (`migration-workflow`) that introduces a `feature-analysis` artifact step before design and specs, defining what a feature analysis must produce
- Add a schema template that guides the feature-analysis artifact's structure — confidence-graded behavioral spec with CONFIRMED, PRESERVE QUIRK, CORRECT IN SPEC, OUT OF SCOPE, and DEFER categories
- Add a Claude Code skill (`/claude-toolkit:feature-analysis`) that serves as the operational playbook — how to spawn an Agent Team, what each teammate does, the workflow rules, and the human interaction model
- Add `install.sh` support for distributing the custom schema to `~/.local/share/openspec/schemas/` so it's available in any project

## Capabilities

### New Capabilities

- `migration-workflow-schema`: Custom OpenSpec schema that adds a `feature-analysis` artifact to the standard spec-driven workflow, with dependency ordering (feature-analysis before design/specs)
- `feature-analysis-skill`: Claude Code skill that defines the Agent Team playbook — team roles (Lead, Code Explorer, Browser Explorer, Spec Writer), subagent roles (Script Generator, Test Portability Scorer, Gap Analyzer), browser automation strategy, confidence grading, and human-in-the-loop resolution workflow
- `schema-distribution`: Install.sh support for symlinking custom OpenSpec schemas to the user-level schema directory

### Modified Capabilities

_(none)_

## Impact

- **claude-toolkit repo**: New directories under `openspec/schemas/`, `plugin/skills/`, and changes to `install.sh`
- **Dependencies**: Requires Claude Code v2.1.32+ with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` enabled; requires OpenSpec with schema support (experimental)
- **Target projects**: Any project using OpenSpec can opt into the `migration-workflow` schema per-change via `--schema migration-workflow`
