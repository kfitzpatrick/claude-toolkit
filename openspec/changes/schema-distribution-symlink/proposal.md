## Why

OpenSpec's schema scanner uses `dirent.isDirectory()` which returns `false` for symlinks to directories, causing symlinked schemas in `~/.local/share/openspec/schemas/` to be silently skipped. As a workaround, `install.sh` copies schemas instead of symlinking them (see `feature-analysis-process` change). Fission-AI/OpenSpec PR #861 fixes this by replacing `dirent.isDirectory()` with `statSync()`-based checks across 13 source files. Once that fix ships, the copy workaround can be replaced with symlinks — consistent with how scripts and statusline are installed.

## What Changes

- Replace the `cp -r` block in `do_install()` with `ensure_symlink` calls (one per schema directory)
- Replace the directory-removal block in `do_uninstall()` with `remove_symlink` calls
- Update `specs/schema-distribution/spec.md` back to symlink language, removing the upstream-bug note

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `schema-distribution`: Requirement language updated from copy to symlink semantics

## Impact

- `install.sh` only — two small blocks replaced
- Users re-running `./install.sh` after this change: existing copied directory will be replaced with a symlink
- Requires OpenSpec version that includes Fission-AI/OpenSpec PR #861 (check release notes before implementing)
