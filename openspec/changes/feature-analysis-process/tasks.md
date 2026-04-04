## 1. Custom OpenSpec Schema

- [x] 1.1 Fork the built-in `spec-driven` schema: `openspec schema fork spec-driven migration-workflow` (produces `openspec/schemas/migration-workflow/`)
- [x] 1.2 Add `feature-analysis` artifact to `schema.yaml` — id, generates (`feature-analysis.md`), description, template reference, instruction, `requires: [proposal]`
- [x] 1.3 Update `design` and `specs` artifacts to add `feature-analysis` to their `requires` arrays
- [x] 1.4 Create `templates/feature-analysis.md` with sections for the five confidence categories (CONFIRMED, PRESERVE QUIRK, CORRECT IN SPEC, OUT OF SCOPE, DEFER) and structured fields per item (observation, evidence, hypothesis, resolution)
- [x] 1.5 Validate the schema: `openspec schema validate migration-workflow`

## 2. Feature Analysis Skill

- [x] 2.1 Create `plugin/skills/feature-analysis/` directory
- [x] 2.2 Write `SKILL.md` — Lead agent instructions: how to create the team, pre-analysis interview questions, resolution loop rules, brownfield stance
- [x] 2.3 Write Code Explorer spawn prompt section — LSP-first navigation strategy, fallback to grep/glob, subagent definitions (Script Generator, Test Portability Scorer)
- [x] 2.4 Write Browser Explorer spawn prompt section — two-mode operation (scripted verification + guided exploration), Playwright patterns, DOM inspection for Angular/React footprint, network request capture
- [x] 2.5 Write Spec Writer spawn prompt section — confidence grading rules, artifact output format, subagent definition (Gap Analyzer), test suite generation from verification scripts
- [x] 2.6 Add skill frontmatter to SKILL.md (marketplace.json is plugin-level, not per-skill)

## 3. Schema Distribution (install.sh)

- [x] 3.1 Add copy-based install for `openspec/schemas/migration-workflow` → `~/.local/share/openspec/schemas/migration-workflow` (note: copy not symlink — OpenSpec uses dirent.isDirectory() which doesn't follow symlinks)
- [x] 3.2 Add corresponding removal in `--uninstall` path
- [x] 3.3 Test: fresh install copies schema, `openspec schema which --all` shows `migration-workflow` with `source: "user"` ✓
- [x] 3.4 Test: re-run is idempotent (skips when content matches), uninstall removes schema directory ✓

## 4. Validation

- [x] 4.1 Create a test change in web-app using `--schema migration-workflow`, verify artifact ordering and status ✓
- [ ] 4.2 Invoke the skill in a Claude Code session, verify team creation instructions are clear and complete
- [ ] 4.3 Run the full process against a small feature in web-app as an integration test
