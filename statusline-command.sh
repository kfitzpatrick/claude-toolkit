#!/usr/bin/env bash
# Claude Code status line — based on awesomepanda zsh theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")
session_name=$(echo "$input" | jq -r '.session_name // empty')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Git branch (skip lock files to avoid conflicts)
git_branch=""
if git_dir=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --git-dir 2>/dev/null); then
  git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
    || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Colors (ANSI — will render dimmed in the status bar)
CYAN='\033[0;36m'
RED='\033[0;31m'
BLUE='\033[0;34m'
STEEL_BLUE='\033[38;5;75m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Build prompt
output=""

# Directory (cyan, like %c in the theme)
output+="$(printf "${CYAN}%s${RESET}" "$dir")"

# Session name (shown only when set via /rename)
if [ -n "$session_name" ]; then
  output+=" $(printf "${YELLOW}[%s]${RESET}" "$session_name")"
fi

# Git branch (red inside parens, blue parens — like the theme)
if [ -n "$git_branch" ]; then
  output+=" $(printf "${STEEL_BLUE}git:(${RED}%s${STEEL_BLUE})${RESET}" "$git_branch")"
fi

# Model
if [ -n "$model" ]; then
  output+=" $(printf "${STEEL_BLUE}[%s]${RESET}" "$model")"
fi

# Context usage
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 80 ]; then
    ctx_color="$RED"
  elif [ "$used_int" -ge 50 ]; then
    ctx_color="$YELLOW"
  else
    ctx_color="$STEEL_BLUE"
  fi
  output+=" $(printf "${ctx_color}ctx:%s%%${RESET}" "$used_int")"

  # Token counts (format as K for readability)
  if [ -n "$total_tokens" ] && [ -n "$used_pct" ] && [ -n "$remaining_pct" ]; then
    used_k=$(awk "BEGIN {printf \"%.0f\", ($total_tokens * $used_pct / 100) / 1000}")
    total_k=$(awk "BEGIN {printf \"%.0f\", $total_tokens / 1000}")
    remaining_k=$(awk "BEGIN {printf \"%.0f\", ($total_tokens * $remaining_pct / 100) / 1000}")
    output+=" $(printf "${ctx_color}[%sk/%sk rem:%sk]${RESET}" "$used_k" "$total_k" "$remaining_k")"
  fi
fi

printf "%b\n" "$output"
