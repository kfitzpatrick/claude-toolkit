## ADDED Requirements

### Requirement: Skill uses a flat subagent orchestration model
The skill SHALL instruct the Lead to orchestrate five subagents directly via the Agent tool in sequence: Code Explorer, Test Portability Scorer, Script Generator, Browser Explorer, Spec Writer. The Lead spawns each subagent, receives its output, and injects that output into the next subagent's prompt.

#### Scenario: Sequential subagent execution
- **WHEN** the user invokes `/feature-analysis`
- **THEN** the Lead runs the pre-analysis interview, then spawns subagents in order
- **AND** each subagent receives the prior subagents' outputs injected into its prompt
- **AND** the Spec Writer receives all outputs plus human resolutions

#### Scenario: Model selection per subagent
- **WHEN** the Lead spawns each subagent
- **THEN** it uses the designated model: Haiku for Portability Scorer, Opus for Spec Writer, Sonnet for all others

### Requirement: Subagents can pause and ask the Lead a question
Code Explorer and Browser Explorer SHALL support two exit modes: question mode (write state, return question) and done mode (return findings). The Lead SHALL restart a subagent that exits in question mode by injecting its state file path and the human's answer into the new prompt.

#### Scenario: Subagent needs clarification
- **WHEN** Code Explorer or Browser Explorer encounters an ambiguity it cannot resolve from code alone
- **THEN** it writes its current state to its state file
- **AND** returns a structured question to the Lead
- **AND** the Lead presents the question to the human and restarts the subagent with the answer

#### Scenario: Subagent resumes from state
- **WHEN** the Lead restarts a subagent after answering its question
- **THEN** the subagent's prompt includes the state file path and the answer
- **AND** the subagent reads its state file to reorient before continuing

### Requirement: Subagents write state files incrementally
Code Explorer and Browser Explorer SHALL write to their state file after each meaningful discovery, not only when pausing to ask a question.

#### Scenario: Incremental state capture
- **WHEN** Code Explorer discovers a new file, API endpoint, or component boundary
- **THEN** it appends the finding to its state file before continuing
- **AND** if the run is interrupted, the state file contains all work completed so far

### Requirement: Each run produces a structured log directory
The Lead SHALL create a run log directory at the start of each run and write the injected prompt and returned output for each subagent phase.

#### Scenario: Run log creation
- **WHEN** the pre-analysis interview completes
- **THEN** the Lead creates `~/.claude/feature-analysis-runs/<feature-name>-<date>/`
- **AND** writes `00-interview.md` with structured interview answers before spawning any subagent

#### Scenario: Phase logging
- **WHEN** a subagent returns its output
- **THEN** the Lead writes `<NN>-<agent-name>.md` with the injected prompt and the returned output

### Requirement: Code Explorer uses LSP-first navigation
The skill SHALL instruct the Code Explorer to trace feature dependency graphs using LSP operations (`workspaceSymbol`, `goToDefinition`, `outgoingCalls`, `findReferences`, `incomingCalls`) as the primary navigation method, falling back to grep/glob for patterns LSP cannot resolve.

#### Scenario: Feature tracing from entry point
- **WHEN** the Code Explorer receives a feature area to analyze
- **THEN** it starts from route definitions or entry points and follows the call graph via LSP
- **AND** it only reads files that are part of the feature's dependency graph

#### Scenario: LSP fallback
- **WHEN** LSP cannot resolve a reference (e.g., Angular directive in a template string)
- **THEN** the Code Explorer falls back to grep/glob pattern matching

### Requirement: Browser automation uses flight-plan pattern
The skill SHALL instruct the Browser Explorer to operate in two modes. Mode 1 (default): execute a Playwright verification script generated from the Code Explorer's analysis as a fast batch. Mode 2 (targeted): interactive exploration for specific edge cases flagged by the human or Code Explorer.

#### Scenario: Mode 1 — scripted verification
- **WHEN** the Code Explorer has produced a structured analysis and the Script Generator has produced a Playwright script
- **THEN** the Browser Explorer runs the script as a batch against the dev application
- **AND** returns results (DOM state, API calls captured, Angular/React footprint) without interactive think-click-think cycles

#### Scenario: Mode 2 — guided exploration
- **WHEN** the human or Code Explorer flags a specific edge case to investigate
- **THEN** the Browser Explorer interactively navigates the dev application with a narrowly scoped goal

### Requirement: Lead interviews the human before and during analysis
The skill SHALL instruct the Lead to interview the human about the feature's scope, known edge cases, permission levels, and any historical context before dispatching work. During analysis, the Lead SHALL present unresolved items for human resolution.

#### Scenario: Pre-analysis interview
- **WHEN** the feature analysis begins
- **THEN** the Lead asks the human about scope, known quirks, relevant permission levels, and test environment requirements (credentials, feature flags, seed data)

#### Scenario: Resolution loop
- **WHEN** the team produces findings with non-CONFIRMED items
- **THEN** the Lead presents them as a batch with observations, hypotheses, and steps to reproduce
- **AND** waits for the human to resolve each item before finalizing the spec

### Requirement: Findings are confidence-graded with five outcomes
The skill SHALL instruct the Spec Writer to assign every discovered behavior exactly one of five confidence grades: CONFIRMED (code and browser agree), PRESERVE QUIRK (weird but intentional — keep it), CORRECT IN SPEC (wrong behavior — spec the intent), OUT OF SCOPE (dead code or not this feature), DEFER (uncertain — park it).

#### Scenario: Confirmed behavior
- **WHEN** code analysis and browser verification agree on a behavior
- **THEN** it is marked CONFIRMED and a passing Playwright test is written for it

#### Scenario: Inconsistent finding
- **WHEN** code says one thing and the browser shows another
- **THEN** the Lead presents the inconsistency to the human with a hypothesis and steps to reproduce
- **AND** the human's answer determines whether it becomes PRESERVE QUIRK, CORRECT IN SPEC, OUT OF SCOPE, or DEFER

### Requirement: Humble curious stance in all human interaction
The skill SHALL instruct all agents to adopt a humble, curious stance when presenting findings. Agents SHALL NOT assert explanations for inconsistencies but instead ask. Agents SHALL present items individually even when suggesting possible clusters.

#### Scenario: Pattern suggestion
- **WHEN** multiple unresolved items appear to share a common cause
- **THEN** the Lead suggests the possible connection ("Could these be related?") rather than asserting it ("These are all permission-gated")
- **AND** each item is presented individually so the human can give different answers

#### Scenario: Brownfield behavior
- **WHEN** a behavior appears incorrect
- **THEN** the agent asks whether to preserve or correct it, never asserting that it is broken

### Requirement: Output is an OpenSpec feature-analysis artifact plus Playwright tests
The skill SHALL instruct the Spec Writer to produce the feature-analysis artifact in the format defined by the migration-workflow schema template. The verification scripts generated during the process SHALL be evolved into a Playwright test suite that serves as the migration contract.

#### Scenario: Artifact output
- **WHEN** the feature analysis process completes
- **THEN** a `feature-analysis.md` artifact exists in the change directory with all behaviors categorized
- **AND** a Playwright test file exists with passing tests for all CONFIRMED and PRESERVE QUIRK behaviors
