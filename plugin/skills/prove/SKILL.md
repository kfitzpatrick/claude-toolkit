---
name: prove
description: Challenge recent assertions — find evidence or explain reasoning for claims made in the conversation.
disable-model-invocation: true
---

Pause and review your recent statements in this conversation. The goal is to identify assertions you made and back them up with evidence or reasoning.

## Steps

### 1. Identify assertions

Scan your recent messages (focus on the last few exchanges) for factual claims, especially:

- Statements of fact about how something works ("X does Y", "X is a limitation of Y")
- Claims about best practices or conventions ("the recommended approach is X")
- Descriptions of behavior ("this will cause X", "X happens when Y")
- Historical or contextual claims ("X was introduced because Y", "X is deprecated")

List each assertion clearly, quoting the relevant text.

### 2. Prove each assertion

For each assertion, attempt to verify it in this order of preference:

1. **Source code / local files**: If the claim is about the codebase, find the specific code or config that proves it. Show the file path, line number, and relevant snippet.

2. **Official documentation**: Use WebSearch and WebFetch to find authoritative documentation (official docs, RFCs, specs, release notes) that confirms the claim. Link to the source.

3. **Reasoning from first principles**: If external evidence is unavailable or the claim is about general software concepts, explain the logical reasoning step by step. Be explicit about what you know vs. what you're inferring.

### 3. Present findings

For each assertion, present:

| # | Assertion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | "X is a known limitation of Y" | **Confirmed** | [link or file:line] |
| 2 | "The recommended approach is X" | **Partially confirmed** | Docs say X but with caveats... |
| 3 | "This causes X" | **Reasoning only** | No external source found. Reasoning: ... |
| 4 | "X was deprecated in v2" | **Could not confirm** | No evidence found — retracting this claim |

### 4. Retract or qualify

For any assertion you cannot prove:
- Explicitly retract it or qualify it with appropriate uncertainty
- If the retraction changes the advice you gave, provide corrected guidance
