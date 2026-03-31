## Why

The `/retro` skill identifies tool friction but misses a higher-value signal: conversational patterns that would benefit from becoming reusable skills. Users often describe multi-step workflows in natural language (e.g., "familiarize yourself with CLP-5572 in JIRA") that could be codified into parameterized commands — but have no mechanism to discover this.

## What Changes

- Add a new detection step to `/retro` that scans user messages for skill candidate patterns
- Pre-check candidates against existing skills/scripts to avoid suggesting duplicates
- Add a "Skill Candidates" table to the retro output
- Extend the post-analysis questions with three skill-focused follow-ups: placement (toolkit vs. project-local), interest in exploring further, and calibration (over/under-flagging)
- Calibration answers are saved as feedback memories to refine future detection

## Capabilities

### New Capabilities

- `retro-skill-detection`: Logic for scanning user messages to identify skill candidate patterns, pre-checking against existing skills/scripts, and presenting findings with follow-up questions

### Modified Capabilities

- `retro`: Extended with the skill candidate detection step and updated follow-up questions

## Impact

- `plugin/skills/retro/SKILL.md` — primary change, new detection step + updated questions
- No new dependencies or breaking changes
- Existing retro behavior (approval friction, missed tooling) is unchanged
