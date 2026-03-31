## Context

The `/retro` skill (`plugin/skills/retro/SKILL.md`) is a plain-text prompt that directs Claude to analyze the current session's tool calls. It has six sequential steps, each producing output before asking the user follow-up questions. The skill uses `disable-model-invocation: true`, meaning it can only be triggered by the user — not auto-invoked by Claude.

The new capability adds a step that scans **user messages** (not tool calls) for natural-language patterns that imply a multi-step workflow worth codifying as a skill.

## Goals / Non-Goals

**Goals:**
- Identify user messages that describe parameterizable, multi-step workflows
- Cross-reference candidates against already-available skills and scripts before surfacing
- Present candidates in a concise table with suggested skill names
- Ask three targeted follow-up questions: placement, interest in exploring, and calibration
- Save calibration feedback as memory to improve future detection

**Non-Goals:**
- Auto-generating or scaffolding skill files (identification only)
- Analyzing tool call patterns for skill candidates (focus is user messages)
- Detecting candidates across multiple sessions (current session only)

## Decisions

### Detection is interpretive, not pattern-matched

Skill candidate detection requires reading user messages for implied workflow structure — it can't be reduced to regex or keyword matching. The step description in the skill must be prescriptive enough to guide consistent behavior without over-specifying.

*Alternative considered*: Keyword matching on external system nouns (JIRA, GitHub, etc.). Rejected — too narrow, misses "summarize the last 10 commits" style candidates that don't name an external system.

### Pre-check against existing skills and scripts

Before flagging a candidate, Claude checks whether available skills (from the session's skill list) or scripts in `~/.claude/scripts/` already cover the pattern. This reduces false positives structurally rather than relying solely on user calibration.

*Alternative considered*: Skip pre-check and let calibration questions handle duplicates. Rejected — duplicate suggestions erode trust in the detection step.

### Three follow-up questions, not one

Separate questions for placement, interest, and calibration serve distinct purposes and should not be collapsed. Placement determines where a skill would live. Interest gates whether to act now. Calibration feeds the feedback loop.

### Calibration feedback saved as memory

Answers to the calibration question ("too eager?", "missed anything?") are saved as feedback memories. This is the primary mechanism for tuning detection quality over time — each session's retro makes the next one more accurate.

## Risks / Trade-offs

- **Over-flagging risk** → Mitigated by pre-check against existing skills/scripts and the explicit calibration question
- **Under-flagging risk** → Mitigated by open-ended calibration question that invites the user to name missed patterns
- **Detection quality variance** → The step is interpretive; results may vary by session context. Feedback memories reduce variance over time.
- **Placement question may be redundant** → If a candidate is clearly project-specific, the question is obvious. Acceptable friction given it only fires when candidates exist.

## Open Questions

- Should the calibration question explicitly mention the feedback memory mechanism, so users understand their answer shapes future behavior?
