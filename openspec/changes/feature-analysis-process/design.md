## Context

The claude-toolkit distributes Claude Code configuration — skills, scripts, statusline, and CLAUDE.md preferences — via `install.sh` (symlinks + section markers) and the plugin marketplace. This change adds three new types of artifact: a custom OpenSpec schema, a schema template, and a skill that orchestrates a Claude Agent Team. All three must be portable across projects.

The target use case is analyzing features in legacy codebases before refactoring. The first consumer is `~/werk/web-app` (Rails + React + AngularJS), but the process should work for any project using OpenSpec.

Agent Teams is an experimental Claude Code feature (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, v2.1.32+). OpenSpec custom schemas are also experimental. Both are stable enough for use but may evolve.

## Goals / Non-Goals

**Goals:**
- Create a custom OpenSpec schema that adds a `feature-analysis` step to the workflow
- Create a skill that serves as the playbook for running the Agent Team
- Distribute the schema via `install.sh` to `~/.local/share/openspec/schemas/`
- Keep the skill and schema independent — the skill can be used without the schema, and the schema can be used with manual analysis instead of the Agent Team

**Non-Goals:**
- Building a programmatic orchestrator (Python/TS script that calls the Claude API) — this uses Claude Code's native Agent Teams, not the SDK
- Automating the human-in-the-loop resolution — the human is always in the loop for non-CONFIRMED findings
- Defining the Playwright test infrastructure for target projects — the skill tells the team to write Playwright tests, but setting up Playwright in the target project is out of scope
- Making this work without the Agent Teams experimental flag — if the flag is off, the skill won't work

## Decisions

### 1. Skill and schema are independent layers

**Decision**: The skill (`/claude-toolkit:feature-analysis`) and the schema (`migration-workflow`) are separate artifacts that can be used independently.

**Rationale**: A user might want to run the feature analysis process without using the custom schema (e.g., producing the analysis as a standalone document). Or they might want the schema's `feature-analysis` artifact step but fill it manually without the Agent Team. Coupling them would reduce flexibility.

**Alternative considered**: A single skill that both defines the workflow and orchestrates the team. Rejected because it conflates the "what" (schema) with the "how" (skill).

### 2. Schema extends spec-driven rather than replacing it

**Decision**: Fork the built-in `spec-driven` schema via `openspec schema fork spec-driven migration-workflow`, then add the `feature-analysis` artifact. Keep all other artifacts (proposal, specs, design, tasks) identical.

**Rationale**: Users are already familiar with the spec-driven workflow. The migration-workflow should feel like spec-driven with one extra step, not a completely different workflow. Forking ensures we inherit any future improvements to the built-in schema's instructions and templates.

**Alternative considered**: Building a schema from scratch. Rejected because it would duplicate all the standard artifact definitions and diverge from updates.

### 3. Schema template encodes the five-outcome model

**Decision**: The `feature-analysis.md` template defines sections for each confidence category (CONFIRMED, PRESERVE QUIRK, CORRECT IN SPEC, OUT OF SCOPE, DEFER) with structured fields per item (observation, evidence, hypothesis, resolution).

**Rationale**: A structured template ensures consistency across runs and makes the resolution loop tractable. Without it, each analysis would produce differently-shaped output.

**Alternative considered**: Freeform template that just says "list findings." Rejected because the confidence-grading model is the core value proposition.

### 4. Skill prompt defines spawn prompts for each teammate

**Decision**: The skill's `prompt.md` includes the full spawn prompt for each teammate (Code Explorer, Browser Explorer, Spec Writer). The Lead reads these from the skill and uses them when creating the team.

**Rationale**: Spawn prompts need to include the teammate's role, tools, interaction rules, and the brownfield stance. Keeping them in the skill means they're version-controlled and portable.

**Alternative considered**: Having the Lead agent write spawn prompts dynamically based on high-level role descriptions. Rejected because prompt quality directly affects teammate behavior — tested prompts are better than improvised ones.

### 5. install.sh uses ensure_symlink for schema distribution

**Decision**: Reuse the existing `ensure_symlink` function in `install.sh` to create `~/.local/share/openspec/schemas/migration-workflow → <toolkit>/openspec/schemas/migration-workflow`. Create the parent directory if it doesn't exist.

**Rationale**: Consistent with how `install.sh` already handles scripts and statusline. Idempotent, supports `--uninstall`.

**Alternative considered**: Copying the schema directory instead of symlinking. Rejected because symlinks mean edits to the toolkit propagate immediately, matching the behavior of other toolkit artifacts.

## Risks / Trade-offs

**[Agent Teams is experimental]** → The feature may change. Mitigation: the skill is a prompt file — if the Agent Teams API changes, only the skill prompt needs updating. The schema is independent of Agent Teams entirely.

**[Skill prompt may be large and complex]** → Encoding spawn prompts for 4 teammates plus workflow rules in a single prompt.md could hit context limits or reduce quality. Mitigation: test the prompt size against Claude's context window; if too large, split into a main prompt.md that references separate spawn prompt files.

**[Browser automation depends on dev environment]** → The Browser Explorer needs a running dev app with seeded data and valid credentials. If the dev environment is flaky, the whole process stalls. Mitigation: the skill instructs the Lead to verify dev environment readiness during the pre-analysis interview.

**[User-level schema path may change]** → `~/.local/share/openspec/schemas/` is the current user-level path but OpenSpec schemas are experimental. Mitigation: the symlink is easy to update if the path changes.

**[Flight-plan pattern assumes Code Explorer accuracy]** → If the code analysis is wrong, the verification script tests the wrong things. Mismatches become INCONSISTENT findings, which is actually valuable — but a wildly wrong code analysis could waste the Browser Explorer's time. Mitigation: the Browser Explorer always captures full DOM state and network requests regardless of the script, so unexpected findings surface naturally.

## Open Questions

- **How large can the skill prompt be?** Need to test whether encoding all spawn prompts in a single file works within Claude Code's skill loading limits, or whether we need to split into multiple files.
- **Should the schema template include a section for the resolution log?** The human's answers during the resolution loop are valuable context — should they be captured in the artifact, or just in conversation history?
- **What's the right Playwright output format?** Should the team produce a standalone test file, or a test file plus a fixture/helper structure? This may depend on the target project's existing test setup.
