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

## 4. Skill Rewrite (subagent model)

- [ ] 4.1 Rewrite SKILL.md — replace Agent Teams coordination with flat subagent orchestration (Lead spawns all agents via Agent tool in sequence)
- [ ] 4.2 Add state file protocol to Code Explorer and Browser Explorer prompts — two exit modes (question / done), incremental writes after each discovery
- [ ] 4.3 Add run log instructions to Lead — create run directory at interview completion, write phase files after each subagent returns
- [ ] 4.4 Add model assignments to each subagent spawn instruction (Haiku for Portability Scorer, Opus for Spec Writer, Sonnet for others)
- [ ] 4.5 Promote Test Portability Scorer and Script Generator to flat subagents (remove from inside Code Explorer prompt)

## 5. Spike — Q&A Loop

- [ ] 5.1 Run Code Explorer against a small web-app feature with the new SKILL.md
- [ ] 5.2 Verify: does Code Explorer detect when it needs to ask a question vs. proceed?
- [ ] 5.3 Verify: does restarting with state file + answer work in practice?
- [ ] 5.4 Measure: how many round trips does a real exploration need?
- [ ] 5.5 Document findings — update design.md if the pattern needs adjustment

## 6. Validation

- [ ] 6.1 Invoke `/feature-analysis` against a small web-app feature, verify full pipeline runs
- [ ] 6.2 Verify run log is created and contains all phase files
- [ ] 6.3 Run the full process against a real feature in web-app as integration test
