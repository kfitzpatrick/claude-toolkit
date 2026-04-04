## ADDED Requirements

### Requirement: Skill defines a two-tier agent team
The skill SHALL instruct the Lead agent to spawn a team with four members (Lead, Code Explorer, Browser Explorer, Spec Writer) and define three subagent roles (Script Generator, Test Portability Scorer, Gap Analyzer) that teammates spawn internally.

#### Scenario: Team creation
- **WHEN** the user invokes `/claude-toolkit:feature-analysis`
- **THEN** the skill prompt instructs the Lead to create an Agent Team with the defined members
- **AND** each teammate's spawn prompt includes their role, responsibilities, and interaction rules

#### Scenario: Subagent usage
- **WHEN** the Code Explorer needs to generate a Playwright verification script
- **THEN** it spawns a Script Generator subagent within its own session
- **AND** the subagent returns the script and its context is reclaimed

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
