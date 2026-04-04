## 1. Implementation

- [x] 1.1 Add `and .conclusion != "STALE"` to the `failed_json` jq filter in `scripts/my-prs.sh` (line 192)

## 2. Verification

- [x] 2.1 Run `my-prs.sh` and confirm mobot#182 still shows ✅ and web-app#15283 still shows ❌
- [x] 2.2 Manually verify the jq filter excludes STALE: `echo '[{"status":"COMPLETED","conclusion":"STALE"}]' | jq '[.[] | select(.status == "COMPLETED" and .conclusion != "SUCCESS" and .conclusion != "SKIPPED" and .conclusion != "NEUTRAL" and .conclusion != "CANCELLED" and .conclusion != "STALE")]'` → should return `[]`
