# Feature Analysis: <!-- feature name -->

**Feature area:** <!-- e.g., group.members, externalWidgetClick -->
**Analyzed by:** Agent Team (Lead, Code Explorer, Browser Explorer, Spec Writer)
**Date:** <!-- date -->
**Dev environment:** <!-- e.g., http://app.mobilize.local, logged in as dev-user@test.com -->

---

## Summary

<!-- 2-3 sentences: what the feature does, how many behaviors were found, overall confidence level -->

**Behaviors found:** <!-- N -->
**Confirmed:** <!-- N --> | **Preserve Quirk:** <!-- N --> | **Correct in Spec:** <!-- N --> | **Out of Scope:** <!-- N --> | **Deferred:** <!-- N -->

**Playwright test suite:** <!-- path to generated test file -->

---

## CONFIRMED Behaviors

<!-- Behaviors where code analysis and browser verification agree. Each has a passing Playwright test. -->

### [C-01] <!-- Behavior name -->

**Observation:** <!-- What the code says and what the browser shows -->
**Evidence:**
- Code: `<!-- file:line — relevant function/method -->`
- Browser: <!-- what was observed in the running app -->

**Playwright test:** <!-- test name or location -->

<!-- Repeat for each confirmed behavior -->

---

## PRESERVE QUIRK

<!-- Behaviors that look wrong but are intentional or historical. Keep them as-is. Tests assert the actual (quirky) behavior. -->

### [Q-01] <!-- Behavior name -->

**Observation:** <!-- What looks weird and why -->
**Evidence:**
- Code: `<!-- file:line -->`
- Browser: <!-- what was observed -->

**Resolution:** <!-- Human's explanation of why this is kept -->
**Migration note:** <!-- Any warning for whoever refactors this — "this looks wrong but is intentional" -->

**Playwright test:** <!-- test name — asserts the quirky behavior -->

<!-- Repeat for each preserved quirk -->

---

## CORRECT IN SPEC

<!-- Behaviors that are wrong. Spec documents the intended behavior. Playwright test may currently fail against the app. -->

### [S-01] <!-- Behavior name -->

**Observation:** <!-- What the code/browser currently does -->
**Intended behavior:** <!-- What it should do -->
**Evidence:**
- Code: `<!-- file:line -->`
- Browser: <!-- what was observed -->

**Resolution:** <!-- Human's determination that this is a bug/wrong behavior -->

**Playwright test:** <!-- test name — asserts the INTENDED behavior, may currently fail -->

<!-- Repeat for each corrected spec -->

---

## OUT OF SCOPE

<!-- Dead code or behaviors not part of this feature. No tests written. -->

| ID | Name | Reason | Location |
|----|------|--------|----------|
| O-01 | <!-- name --> | <!-- dead code / different feature / etc --> | `<!-- file:line -->` |

---

## DEFERRED

<!-- Uncertain items parked for later. No tests written. -->

| ID | Name | Why deferred | Next step |
|----|------|-------------|-----------|
| D-01 | <!-- name --> | <!-- not enough info / needs investigation --> | <!-- what would resolve this --> |

---

## Resolution Log

<!-- Record of human answers during the Q&A resolution loop -->

| Item | Question | Answer | Outcome |
|------|----------|--------|---------|
| <!-- ref --> | <!-- what was asked --> | <!-- human's answer --> | <!-- CONFIRMED / PRESERVE QUIRK / etc --> |

---

## API Contract

<!-- All network requests captured during browser verification -->

```
<!-- HTTP method + path, one per line -->
GET  /api/v1/...
POST /api/v1/...
```

---

## Angular/React Footprint

<!-- Components and controllers found on the page -->

**Angular controllers/directives:**
- `<!-- ng-controller value -->` at `<!-- file:line -->`

**React mount points (react2angular bridges):**
- `<!-- component name -->` → `<!-- React component file -->`

**Pure React pages:**
- `<!-- component name -->` at `<!-- file -->`

---

## Code Explorer Notes

<!-- File graph and key findings from static analysis -->

**Entry points:**
- Route: `<!-- route definition file:line -->`
- Controller: `<!-- file:line -->`

**Key files:**
- `<!-- file -->` — <!-- why it's relevant -->

**Test portability summary:**
- Low portability (Angular-tied): <!-- N files -->
- Medium portability (logic portable, harness not): <!-- N files -->
- High portability (behavior-focused): <!-- N files -->
