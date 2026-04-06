---
name: feature-analysis-spike
description: Single-session feature analysis spike. Maps a legacy feature's dependency graph, verifies behavior in the browser, grades findings by confidence, and produces a behavioral spec + Playwright migration contract. No subagents — runs entirely in the main session.
---

You are running a feature analysis. Your job is to produce two things:
1. A **confidence-graded behavioral spec** — every behavior this feature exhibits, categorized
2. A **Playwright test suite** — framework-independent tests that assert those behaviors as a migration contract

Work entirely in this session. Do not spawn subagents or agents.

---

## Your Stance

Adopt a **humble, curious stance** throughout:
- Ask, never assert. "Could this be related?" not "This is broken."
- Never assume weird behavior is a bug — it may be intentional.
- Present ambiguous items individually, even if they seem to share a cause.

---

## Phase 1: Interview

Before touching any code, ask the human:

1. **What feature should we analyze?** (name, URL, or entry point)
2. **What's the scope?** Happy path only, or include edge cases, error states, empty states?
3. **Are there multiple user roles** that see different behavior? (e.g. admin vs member)
4. **Any known quirks** — behaviors that look wrong but should be preserved?
5. **Dev environment:** Are you logged in? What user/role? Any feature flags or seed data needed?
6. **Any existing tests** we should reference? (Karma specs, Jest specs, Cypress)

Collect all answers before proceeding. Ask follow-ups if anything is unclear.

---

## Phase 2: Code Exploration

Map the feature's dependency graph. Work systematically:

1. **Find the entry point** — route definition, controller file, or URL given by the human
2. **Trace the call graph** — follow controllers → services → components → API calls
3. **Use LSP tools first** (`workspaceSymbol`, `goToDefinition`, `findReferences`, `outgoingCalls`) where available
4. **Fall back to grep/glob** for patterns LSP can't resolve:
   - Angular directives in templates (`ng-controller`, `ng-include`, directive names)
   - `react2angular` calls (Angular → React bridge points)
   - `ServiceFetcher.get('Name')` calls (React → Angular service bridge)
5. **Note the Angular/React footprint** — which parts of the page are Angular, which are React islands

**For the web-app codebase specifically:**
- Angular 1.x files are plain JavaScript — follow `.directive.js`, `.controller.js`, `.service.js`
- React components live alongside Angular files in `client/src/app/`
- `react2angular` is one-way only (Angular → React, never the reverse)
- Rails controllers are in `app/controllers/`, routes in `config/routes.rb`

**When you need to ask:** If you hit a genuine runtime ambiguity — which role to focus on, whether a feature flag is active, what URL to start from — stop and ask the human before proceeding. Do not guess.

**Produce:**
- A structured file list grouped by layer (Angular / React / Rails)
- All API endpoints the feature uses (inferred from controller actions + routes)
- The Angular/React footprint
- Any existing test files found (Karma/Jest) and their coverage

---

## Phase 3: Browser Verification

Write and run a Playwright verification script against the dev application.

**Write the script first.** Based on your code exploration findings, write a TypeScript Playwright script that:
- Navigates to each relevant page/state
- Asserts that expected Angular controllers are present (`document.querySelectorAll('[ng-controller]')`)
- Asserts React mount points (`document.querySelectorAll('[data-reactroot]')`)
- Exercises core user interactions (clicks, form fills, submissions)
- Captures all network requests (`page.on('response', ...)`)

**Then run it** via Bash against the dev app. Record:
- Which assertions passed / failed
- All network requests captured (method + URL + status)
- Any unexpected behavior (missing elements, console errors, unexpected redirects)

**Classify each finding:**
- **CONFIRMED** — code and browser agree
- **INCONSISTENT** — code says one thing, browser shows another; flag for human resolution
- **CODE-ONLY** — behavior exists in code but couldn't be triggered in browser; flag for human resolution

**When you need to ask:** If the script reveals something unexpected that you cannot interpret alone, ask the human before classifying.

---

## Phase 4: Human Resolution Loop

Present all INCONSISTENT and CODE-ONLY items to the human. Present them one at a time:

```
─────────────────────────────────────────────
#1 [INCONSISTENT] — <behavior name>

Code says: <what the code does>
Browser shows: <what was observed>
Steps taken: <how we got there>

Could this be:
(a) <first possibility>
(b) <second possibility>
(c) Something else?
─────────────────────────────────────────────
```

If items might share a cause, you may ask: "Could #1 and #3 be related?" — but present each individually and accept different answers per item.

Map answers to outcomes:
- "It's admin-only / here are admin creds" → re-run that specific verification → CONFIRMED
- "That's a known quirk, keep it" → PRESERVE QUIRK
- "That's a bug, it should do X" → CORRECT IN SPEC
- "That's dead code" → OUT OF SCOPE
- "Not sure, skip it" → DEFER

Continue until all items are resolved.

---

## Phase 5: Produce the Spec

Write two files:

### 1. `feature-analysis.md`

```markdown
# Feature Analysis: <feature name>
Date: <date>
Scope: <scope from interview>

## CONFIRMED
| Behavior | Evidence | Test |
|----------|----------|------|
| ...      | ...      | ...  |

## PRESERVE QUIRK
| Behavior | Why preserved | Test |
|----------|--------------|------|

## CORRECT IN SPEC
| Behavior | What it does | What it should do |
|----------|-------------|-------------------|

## OUT OF SCOPE
| Item | Location | Note |
|------|----------|------|

## DEFERRED
| Item | What would resolve it |
|------|-----------------------|

## Angular/React Footprint
<description>

## API Contract
<endpoints>

## Existing Test Coverage
<portability assessment — which tests are Angular-tied vs portable>

## Migration Seams
<ranked easiest → hardest based on Angular service dependencies>
```

### 2. `<feature-name>.spec.ts`

A Playwright test file with:
- One test per CONFIRMED behavior (should pass now)
- One test per PRESERVE QUIRK behavior (asserts the quirky behavior explicitly, with a comment explaining why)
- One test per CORRECT IN SPEC behavior (asserts intended behavior — may currently fail)

---

## Phase 6: Deliver

Present to the human:
- Paths to both output files
- Summary: N confirmed, N quirks preserved, N corrections specced, N out of scope, N deferred
- Any next steps (e.g. "3 items deferred — here's what would resolve them")
