# Capability: retro-skill-detection

## Purpose

Logic for scanning user messages to identify skill candidate patterns, pre-checking candidates against existing skills and scripts, and presenting findings with follow-up questions.

## Requirements

### Requirement: Identify skill candidate patterns in user messages
Claude SHALL scan the current session's user messages for natural-language requests that imply a multi-step, parameterizable workflow worth codifying as a reusable skill.

Candidate signals include:
- Imperative requests involving an external system with an identifier (e.g., "familiarize yourself with CLP-5572 in JIRA")
- Multi-step fetch-then-summarize patterns (e.g., "summarize the last 10 commits")
- Any request where Claude performed 3+ tool calls to fulfill a single user sentence

#### Scenario: External system with identifier
- **WHEN** a user message contains an imperative directed at a named external system with a parameterizable identifier
- **THEN** the pattern is flagged as a skill candidate with a suggested skill name and parameter

#### Scenario: Multi-step fetch-summarize
- **WHEN** a user message resulted in 3 or more sequential tool calls to fulfill a single request
- **THEN** the pattern is flagged as a skill candidate

#### Scenario: No candidates found
- **WHEN** no user messages match candidate signals
- **THEN** the skill candidate section is omitted from the retro output

### Requirement: Pre-check candidates against existing skills and scripts
Before flagging a skill candidate, Claude SHALL verify the pattern is not already covered by an available skill from the session or a script in `~/.claude/scripts/`.

#### Scenario: Existing skill covers the pattern
- **WHEN** a candidate pattern is already handled by an installed skill
- **THEN** the candidate is NOT added to the skill candidates table; instead it is noted as a missed-tooling finding

#### Scenario: No existing coverage
- **WHEN** no installed skill or script covers the candidate pattern
- **THEN** the candidate is added to the skill candidates table

### Requirement: Present skill candidates in a table
Identified candidates SHALL be presented in a table with columns: What You Asked, Implied Workflow, Suggested Skill.

#### Scenario: One or more candidates
- **WHEN** candidates are found after pre-checking
- **THEN** a "Skill Candidates" table is shown with one row per candidate

### Requirement: Ask three follow-up questions about skill candidates
After presenting the table, Claude SHALL ask the user:
1. **Placement**: Is each candidate broadly useful (→ claude-toolkit) or tied to this project/codebase?
2. **Interest**: Would you like to start an `/opsx:explore` session to develop any of these?
3. **Calibration**: Did I miss any patterns, or flag something too eagerly (too rare, too specific, already covered)?

#### Scenario: User answers calibration question
- **WHEN** the user indicates a candidate was flagged incorrectly or a pattern was missed
- **THEN** Claude saves the feedback as a memory to refine future detection

#### Scenario: No candidates, no questions
- **WHEN** no candidates were found
- **THEN** the three follow-up questions are not asked
