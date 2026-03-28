#!/bin/bash
# Read-only git info wrapper used by /sync-pr and similar workflows.
# Runs a fixed set of safe, non-destructive git commands.
# Auto-allowed in permissions so Claude doesn't need per-call approval.

git log --oneline dev..HEAD
echo "---"
git status
echo "---"
git branch --show-current
echo "---"
git rev-parse --abbrev-ref @{u} 2>/dev/null
