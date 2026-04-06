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
- Eliminating round trips in the Q&A loop — each question requires human input and a subagent restart; this latency is by design, not a bug to fix

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

### 4. Skill uses regular subagents (Agent tool) not Agent Teams

**Decision**: The skill orchestrates work via Claude Code's `Agent` tool (regular subagents) rather than the experimental Agent Teams feature.

**Rationale**: Live testing showed Agent Teams burned through tokens without producing meaningful output. More fundamentally, the work is inherently sequential — Code Explorer must finish before Browser Explorer can run its script, and both must finish before Spec Writer can synthesize. Agent Teams' primary advantage is parallel peer-to-peer collaboration, which doesn't apply here. Regular subagents run to completion, return structured output to the Lead, and the Lead injects that output into the next subagent's prompt — simpler, more reliable, no experimental flag required.

**Alternative considered**: Agent Teams with sequential task dependencies. Rejected because the coordination overhead (independent sessions, token burn, setup friction) outweighed the benefit for a sequential pipeline.

### 5. Flat coordination structure — Lead orchestrates all subagents directly

**Decision**: All subagents are spawned directly by the Lead. There are no subagents-within-subagents.

Subagents (in order):
1. Code Explorer → dependency graph, API list, Angular/React footprint
2. Test Portability Scorer (with Code Explorer file list injected)
3. Script Generator (with Code Explorer findings injected)
4. Browser Explorer (with Script Generator output + Code Explorer findings injected)
5. Spec Writer (with all prior outputs + human resolutions injected)

**Rationale**: The Lead has full context at every handoff point. Nesting subagents inside other subagents adds complexity without benefit — the Lead is better positioned to inject exactly what each subagent needs.

**Alternative considered**: Code Explorer spawns Test Portability Scorer and Script Generator internally. Rejected in favor of flat structure for simplicity and Lead visibility.

### 6. Subagents can pause and ask the Lead a question

**Decision**: Subagents (Code Explorer and Browser Explorer) have two exit modes:

- **Mode A — question**: Write current state to a state file, return a question to the Lead. The Lead asks the human, then restarts the subagent with the state file path + the answer injected.
- **Mode B — done**: Return full findings to the Lead. Optionally clean up state file.

**Rationale**: A bloated upfront interview that tries to anticipate everything is worse than letting subagents surface what they actually need mid-run. The Q&A loop allows the Lead to remain the single point of contact with the human while subagents remain focused on their task.

**Alternative considered**: Fully upfront interview that tries to capture all needed context before spawning. Rejected because real exploration surfaces unknowns that cannot be anticipated.

### 7. Subagents write state files incrementally

**Decision**: Subagents write to their state file after each meaningful discovery, not just when pausing to ask a question. The state file is the subagent's working memory.

**Rationale**: If the user stops a long-running subagent mid-run, the state file preserves all work done so far. The Lead can inspect partial findings and either restart the subagent or present partial results. This solves both the "how do we capture progress" problem and the "how do we resume after a question" problem with the same mechanism.

**State file location**: `<run-log-dir>/<agent-name>-state.md`, derived from the run directory (see Decision 8).

### 8. Run logs capture full prompt/response history

**Decision**: Each run produces a structured log directory:

```
~/.claude/feature-analysis-runs/
  <feature-name>-<date>/
    00-interview.md          ← structured interview answers (Lead constructs before spawning)
    01-code-explorer.md      ← injected prompt + returned findings
    02-portability-scorer.md
    03-script-generator.md
    04-browser-explorer.md
    05-human-resolutions.md  ← each Q&A round with the human
    06-spec-writer.md
    07-feature-analysis.md   ← final artifact (copy)
    <agent-name>-state.md    ← incremental state files (cleaned up on completion)
```

**Rationale**: Reproducibility and iteration. The prompt injected into each subagent is deterministic (Lead constructs it); the response is whatever the subagent returns. Together they form a full replay log. As the process is refined, logs from prior runs make it possible to see exactly what changed and why.

**Default location**: `~/.claude/feature-analysis-runs/`. Could be made configurable via the pre-analysis interview if projects prefer logs stored alongside their OpenSpec changes.

### 9. Model assignments per agent

**Decision**:

| Agent | Model | Rationale |
|---|---|---|
| Lead | Sonnet | Orchestration and interview — many turns, needs judgment |
| Code Explorer | Sonnet | Graph traversal is complex reasoning; tune to Opus if results are poor |
| Test Portability Scorer | Haiku | Pattern classification against known signals — simple task |
| Script Generator | Sonnet | Playwright generation is structured but non-trivial |
| Browser Explorer | Sonnet | Interpreting browser output needs judgment |
| Spec Writer | Opus | Synthesis across all inputs, confidence grading — highest-stakes output |

**Rationale**: Spec Writer gets Opus because it's the only agent whose output goes directly to the human as a deliverable. Portability Scorer gets Haiku because it's purely checking for known string patterns. All others use Sonnet as the default with room to tune.

### 10. install.sh uses cp -r for schema distribution

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
