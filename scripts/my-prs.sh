#!/bin/bash
# Morning dashboard: show my open PRs with review & check status.
# Outputs a formatted table with clickable OSC 8 hyperlinks (works in iTerm2, Ghostty, etc.)
# Usage: my-prs.sh [--org ORG] [weeks=4]

set -euo pipefail

# Parse arguments
ORG="mobilizeio"
WEEKS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --org) ORG="$2"; shift 2 ;;
    *) WEEKS="$1"; shift ;;
  esac
done
WEEKS="${WEEKS:-4}"

SINCE=$(date -v-"${WEEKS}"w +%Y-%m-%d 2>/dev/null || date -d "${WEEKS} weeks ago" +%Y-%m-%d)

# OSC 8 hyperlink helper
link() { printf '\e]8;;%s\e\\%s\e]8;;\e\\' "$1" "$2"; }

# Print string padded to a visible width, accounting for invisible escape sequences.
# Usage: pcol <visible_width> <visible_text> [formatted_text]
# If formatted_text is omitted, visible_text is printed as-is.
pcol() {
  local width="$1" visible="$2" formatted="${3:-$2}"
  local vlen=${#visible}
  local padding=$((width - vlen))
  printf '%s' "$formatted"
  if [ "$padding" -gt 0 ]; then
    printf '%*s' "$padding" ""
  fi
}

# Print an emoji padded to a visible width. Emojis are 2 display columns wide.
pcol_emoji() {
  local width="$1" emoji="$2"
  local padding=$((width - 2))
  printf '%s' "$emoji"
  if [ "$padding" -gt 0 ]; then
    printf '%*s' "$padding" ""
  fi
}

# Truncate string to N visible chars + ellipsis
truncate() {
  local str="$1" max="$2"
  if [ ${#str} -gt "$max" ]; then
    printf '%s' "${str:0:$((max - 1))}…"
  else
    printf '%s' "$str"
  fi
}

# Step 1: Find repos with my open PRs
REPOS=$(gh api --method GET \
  "search/issues?q=is:pr+is:open+author:@me+org:${ORG}+created:>=${SINCE}&sort=created&order=desc&per_page=50" \
  --jq '[.items[].repository_url | split("/") | last] | unique | .[]')

if [ -z "$REPOS" ]; then
  echo "No open PRs in ${ORG} from the last ${WEEKS} weeks."
  exit 0
fi

# Step 2: Fetch detailed PR data per repo (parallel)
TMPDIR_DATA=$(mktemp -d)
for repo in $REPOS; do
  (
    gh pr list --repo "${ORG}/${repo}" --author @me --state open \
      --json number,title,isDraft,reviewDecision,statusCheckRollup,createdAt,url \
      > "${TMPDIR_DATA}/${repo}.json"
  ) &
done
wait

# Step 3: Count totals (first pass)
total=0
count_draft=0
count_approved=0
count_changes=0
count_awaiting=0

for repo in $REPOS; do
  file="${TMPDIR_DATA}/${repo}.json"
  [ -f "$file" ] || continue
  prs=$(jq --arg since "$SINCE" '[.[] | select(.createdAt >= $since)]' "$file")
  count=$(echo "$prs" | jq 'length')
  for i in $(seq 0 $((count - 1))); do
    is_draft=$(echo "$prs" | jq -r ".[$i].isDraft")
    review_decision=$(echo "$prs" | jq -r ".[$i].reviewDecision")
    total=$((total + 1))
    if [ "$is_draft" = "true" ]; then
      count_draft=$((count_draft + 1))
    elif [ "$review_decision" = "APPROVED" ]; then
      count_approved=$((count_approved + 1))
    elif [ "$review_decision" = "CHANGES_REQUESTED" ]; then
      count_changes=$((count_changes + 1))
    else
      count_awaiting=$((count_awaiting + 1))
    fi
  done
done

# Summary
summary_parts=()
[ "$count_approved" -gt 0 ] && summary_parts+=("${count_approved} approved")
[ "$count_awaiting" -gt 0 ] && summary_parts+=("${count_awaiting} awaiting review")
[ "$count_changes" -gt 0 ] && summary_parts+=("${count_changes} changes requested")
[ "$count_draft" -gt 0 ] && summary_parts+=("${count_draft} draft")

repo_count=$(echo "$REPOS" | wc -w | tr -d ' ')
summary="${total} open PRs across ${repo_count} repos"
if [ ${#summary_parts[@]} -gt 0 ]; then
  summary="${summary}: $(IFS=', '; echo "${summary_parts[*]}")"
fi

# Column widths
W_PR=16
W_TITLE=28
W_REV=4
W_CI=4

echo ""
printf '\e[1m%s\e[0m\n' "My Open PRs"
printf '\e[2m%s\e[0m\n' "$summary"
echo ""

# Header
printf "  "
pcol $W_PR "PR" "$(printf '\e[1m%s\e[0m' PR)"
printf "  "
pcol $W_TITLE "Title" "$(printf '\e[1m%s\e[0m' Title)"
printf "  "
pcol $W_REV "Rev" "$(printf '\e[1m%s\e[0m' Rev)"
printf "  "
pcol $W_CI "CI" "$(printf '\e[1m%s\e[0m' CI)"
printf "  "
printf '\e[1m%s\e[0m\n' "Failed"

# Separator
printf "  "
printf '%.0s─' $(seq 1 $W_PR)
printf "  "
printf '%.0s─' $(seq 1 $W_TITLE)
printf "  "
printf '%.0s─' $(seq 1 $W_REV)
printf "  "
printf '%.0s─' $(seq 1 $W_CI)
printf "  "
printf '%.0s─' $(seq 1 30)
printf '\n'

# Step 4: Print rows (second pass — no intermediate array)
for repo in $REPOS; do
  file="${TMPDIR_DATA}/${repo}.json"
  [ -f "$file" ] || continue

  prs=$(jq --arg since "$SINCE" '[.[] | select(.createdAt >= $since)]' "$file")
  count=$(echo "$prs" | jq 'length')
  [ "$count" -eq 0 ] && continue

  for i in $(seq 0 $((count - 1))); do
    number=$(echo "$prs" | jq -r ".[$i].number")
    title=$(echo "$prs" | jq -r ".[$i].title")
    url=$(echo "$prs" | jq -r ".[$i].url")
    is_draft=$(echo "$prs" | jq -r ".[$i].isDraft")
    review_decision=$(echo "$prs" | jq -r ".[$i].reviewDecision")

    # Review state
    if [ "$is_draft" = "true" ]; then
      rev_emoji='📝'
    elif [ "$review_decision" = "APPROVED" ]; then
      rev_emoji='✅'
    elif [ "$review_decision" = "CHANGES_REQUESTED" ]; then
      rev_emoji='🔄'
    else
      rev_emoji='⏳'
    fi

    # Check status
    checks=$(echo "$prs" | jq -r ".[$i].statusCheckRollup")
    check_count=$(echo "$checks" | jq 'length')

    ci_emoji='—'
    fail_cell=""

    if [ "$check_count" -gt 0 ]; then
      deduped=$(echo "$checks" | jq -c '[sort_by(.completedAt) | reverse | unique_by(.name) | .[]]')
      has_pending=$(echo "$deduped" | jq '[.[] | select(.status != "COMPLETED")] | length')
      failed_json=$(echo "$deduped" | jq -c '[.[] | select(.status == "COMPLETED" and .conclusion != "SUCCESS" and .conclusion != "SKIPPED" and .conclusion != "NEUTRAL" and .conclusion != "CANCELLED")]')
      failed_count=$(echo "$failed_json" | jq 'length')

      if [ "$has_pending" -gt 0 ]; then
        ci_emoji='⏳'
      elif [ "$failed_count" -gt 0 ]; then
        ci_emoji='❌'
        # Build clickable failed check links
        fail_parts=()
        for j in $(seq 0 $((failed_count - 1))); do
          fname=$(echo "$failed_json" | jq -r ".[$j].name")
          furl=$(echo "$failed_json" | jq -r ".[$j].detailsUrl")
          fail_parts+=("$(link "$furl" "$fname")")
        done
        IFS=', '
        fail_cell="${fail_parts[*]}"
        unset IFS
      else
        ci_emoji='✅'
      fi
    fi

    # Print the row
    pr_label="${repo}#${number}"
    title_trunc=$(truncate "$title" $W_TITLE)

    printf "  "
    pcol $W_PR "$pr_label" "$(link "$url" "$pr_label")"
    printf "  "
    pcol $W_TITLE "$title_trunc"
    printf "  "
    pcol_emoji $W_REV "$rev_emoji"
    printf "  "
    pcol_emoji $W_CI "$ci_emoji"
    printf "  %s\n" "$fail_cell"
  done
done

echo ""
printf '\e[2m%s\e[0m\n' "Legend: ✅ Approved/Passing  ⏳ Awaiting/Pending  📝 Draft  🔄 Changes Requested  ❌ Failing"
echo ""

# Cleanup
rm -rf "$TMPDIR_DATA"
