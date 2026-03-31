## 1. Add Skill Candidate Detection Step

- [x] 1.1 Read `plugin/skills/retro/SKILL.md` to understand the current step structure and insertion point
- [x] 1.2 Add a new step (after existing friction steps, before "Present findings") that scans user messages for candidate signals: external system + identifier patterns, and multi-step fetch-summarize patterns (3+ tool calls for a single user message)
- [x] 1.3 Add pre-check logic in the step: before flagging a candidate, verify it's not already covered by an available skill from the session or a script in `~/.claude/scripts/`; if covered, route it to Missed Tooling instead

## 2. Update Output and Follow-up Questions

- [x] 2.1 Add a "Skill Candidates" table to the findings presentation section with columns: What You Asked, Implied Workflow, Suggested Skill
- [x] 2.2 Update the existing follow-up questions to include the three skill candidate questions when candidates were found: (1) placement — toolkit vs. project-local, (2) interest in `/opsx:explore` session, (3) calibration — anything missed or flagged too eagerly
- [x] 2.3 Add instruction to save calibration answers as feedback memories to refine future detection

## 3. Verify

- [ ] 3.1 Run a session with at least one natural-language multi-step request (e.g., "familiarize yourself with X"), then invoke `/retro` and confirm the candidate appears in the table
- [ ] 3.2 Confirm that a pattern already covered by an existing skill does NOT appear in the candidates table (appears in Missed Tooling instead)
- [ ] 3.3 Confirm that when no candidates are found, the table and follow-up questions are omitted
