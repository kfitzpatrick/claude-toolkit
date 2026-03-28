#!/bin/bash
# Bootstrap installer for claude-toolkit.
# Symlinks scripts and statusline into ~/.claude/ and merges
# managed content into ~/.claude/CLAUDE.md using section markers.
#
# Usage:
#   ./install.sh              Install/update
#   ./install.sh --uninstall  Remove symlinks and managed CLAUDE.md section

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
MARKER_START="<!-- claude-toolkit:start -->"
MARKER_END="<!-- claude-toolkit:end -->"

# ── Helpers ──────────────────────────────────────────────────

log()  { printf '  %s\n' "$1"; }
ok()   { printf '  ✓ %s\n' "$1"; }
skip() { printf '  · %s (already up to date)\n' "$1"; }
warn() { printf '  ⚠ %s\n' "$1"; }

# Create a symlink, backing up any existing non-symlink file.
ensure_symlink() {
  local src="$1" dest="$2" name
  name="$(basename "$dest")"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      skip "$name"
      return
    fi
    # Symlink points elsewhere — replace it
    rm "$dest"
  elif [ -e "$dest" ]; then
    # Existing non-symlink file — back up
    mv "$dest" "${dest}.bak"
    warn "$name: backed up existing file to ${name}.bak"
  fi

  ln -s "$src" "$dest"
  ok "$name → $src"
}

# Remove a symlink only if it points to this repo.
remove_symlink() {
  local src="$1" dest="$2" name
  name="$(basename "$dest")"

  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      rm "$dest"
      ok "removed $name"
    else
      skip "$name (symlink points elsewhere, leaving it)"
    fi
  elif [ -e "$dest" ]; then
    skip "$name (not a symlink, leaving it)"
  else
    skip "$name (not present)"
  fi
}

# ── CLAUDE.md merge ──────────────────────────────────────────

managed_block() {
  printf '%s\n' "$MARKER_START"
  printf '# Claude Toolkit — Managed Section\n'
  printf '# (do not edit between these markers — managed by install.sh)\n\n'
  cat "$TOOLKIT_DIR/CLAUDE.md"
  printf '\n%s\n' "$MARKER_END"
}

install_claude_md() {
  local target="$CLAUDE_DIR/CLAUDE.md"
  local managed
  managed="$(managed_block)"

  if [ ! -f "$target" ]; then
    # No existing file — create with just the managed section
    printf '%s\n' "$managed" > "$target"
    ok "CLAUDE.md (created)"
    return
  fi

  if grep -qF "$MARKER_START" "$target"; then
    # Markers exist — replace content between them
    local before after
    before="$(sed -n "1,/$(printf '%s' "$MARKER_START" | sed 's/[[\.*^$()+?{|]/\\&/g')/{ /$(printf '%s' "$MARKER_START" | sed 's/[[\.*^$()+?{|]/\\&/g')/d; p; }" "$target")"
    after="$(sed -n "/$(printf '%s' "$MARKER_END" | sed 's/[[\.*^$()+?{|]/\\&/g')/,\${ /$(printf '%s' "$MARKER_END" | sed 's/[[\.*^$()+?{|]/\\&/g')/d; p; }" "$target")"

    { printf '%s\n' "$before"; printf '%s\n' "$managed"; printf '%s\n' "$after"; } > "${target}.tmp"
    mv "${target}.tmp" "$target"
    ok "CLAUDE.md (updated managed section)"
  else
    # No markers — append
    printf '\n%s\n' "$managed" >> "$target"
    ok "CLAUDE.md (appended managed section)"
  fi
}

uninstall_claude_md() {
  local target="$CLAUDE_DIR/CLAUDE.md"

  if [ ! -f "$target" ]; then
    skip "CLAUDE.md (not present)"
    return
  fi

  if ! grep -qF "$MARKER_START" "$target"; then
    skip "CLAUDE.md (no managed section found)"
    return
  fi

  # Remove markers and everything between them
  local before after
  before="$(sed -n "1,/$(printf '%s' "$MARKER_START" | sed 's/[[\.*^$()+?{|]/\\&/g')/{ /$(printf '%s' "$MARKER_START" | sed 's/[[\.*^$()+?{|]/\\&/g')/d; p; }" "$target")"
  after="$(sed -n "/$(printf '%s' "$MARKER_END" | sed 's/[[\.*^$()+?{|]/\\&/g')/,\${ /$(printf '%s' "$MARKER_END" | sed 's/[[\.*^$()+?{|]/\\&/g')/d; p; }" "$target")"

  # Remove trailing blank line from before (left by the append)
  before="$(printf '%s' "$before" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}')"

  if [ -z "$before" ] && [ -z "$after" ]; then
    rm "$target"
    ok "CLAUDE.md (removed — was only managed content)"
  else
    { printf '%s\n' "$before"; printf '%s\n' "$after"; } > "${target}.tmp"
    mv "${target}.tmp" "$target"
    ok "CLAUDE.md (removed managed section)"
  fi
}

# ── Install ──────────────────────────────────────────────────

do_install() {
  printf '\nInstalling claude-toolkit from %s\n\n' "$TOOLKIT_DIR"

  # Ensure directories exist
  mkdir -p "$CLAUDE_DIR/scripts"

  printf 'Scripts:\n'
  for script in "$TOOLKIT_DIR"/scripts/*.sh; do
    [ -f "$script" ] || continue
    ensure_symlink "$script" "$CLAUDE_DIR/scripts/$(basename "$script")"
  done

  printf '\nStatusline:\n'
  ensure_symlink "$TOOLKIT_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"

  printf '\nCLAUDE.md:\n'
  install_claude_md

  printf '\nDone! Plugin can be installed separately:\n'
  printf '  /plugin marketplace add kfitzpatrick/claude-toolkit\n\n'
}

# ── Uninstall ────────────────────────────────────────────────

do_uninstall() {
  printf '\nUninstalling claude-toolkit\n\n'

  printf 'Scripts:\n'
  for script in "$TOOLKIT_DIR"/scripts/*.sh; do
    [ -f "$script" ] || continue
    remove_symlink "$script" "$CLAUDE_DIR/scripts/$(basename "$script")"
  done

  printf '\nStatusline:\n'
  remove_symlink "$TOOLKIT_DIR/statusline-command.sh" "$CLAUDE_DIR/statusline-command.sh"

  printf '\nCLAUDE.md:\n'
  uninstall_claude_md

  printf '\nDone! To also remove the plugin:\n'
  printf '  /plugin uninstall claude-toolkit\n\n'
}

# ── Main ─────────────────────────────────────────────────────

case "${1:-}" in
  --uninstall) do_uninstall ;;
  *)           do_install ;;
esac
