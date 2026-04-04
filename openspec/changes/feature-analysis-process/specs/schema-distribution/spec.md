## ADDED Requirements

### Requirement: install.sh copies custom schemas to user-level directory
The `install.sh` script SHALL copy custom OpenSpec schemas from the toolkit's `openspec/schemas/` directory to `~/.local/share/openspec/schemas/`, making them available in any project.

> **Note:** This uses `cp -r` rather than symlinks because OpenSpec's schema scanner uses `dirent.isDirectory()`, which returns `false` for symlinks to directories, causing symlinked schemas to be silently skipped. This is a known upstream bug (Fission-AI/OpenSpec PR #861). When that fix lands, this should be revisited — see the `schema-distribution-symlink` change.

#### Scenario: Fresh install
- **WHEN** a user runs `./install.sh` and `~/.local/share/openspec/schemas/migration-workflow` does not exist
- **THEN** the schema directory is copied to `~/.local/share/openspec/schemas/migration-workflow`

#### Scenario: Schema already installed and up to date
- **WHEN** a user runs `./install.sh` and the schema directory already exists with matching content
- **THEN** no changes are made (idempotent — detected via `diff -rq`)

#### Scenario: Schema installed but outdated
- **WHEN** a user runs `./install.sh` and the schema directory exists but content differs
- **THEN** the existing directory is removed and replaced with a fresh copy

#### Scenario: Verification after install
- **WHEN** the schema copy is in place
- **THEN** `openspec schema which --all` in any project shows `migration-workflow` with `source: "user"`

### Requirement: Uninstall removes schema copy
The `install.sh --uninstall` command SHALL remove the copied schema directory from `~/.local/share/openspec/schemas/`.

#### Scenario: Uninstall
- **WHEN** a user runs `./install.sh --uninstall`
- **THEN** the `~/.local/share/openspec/schemas/migration-workflow` directory is removed
- **AND** `openspec schema which --all` no longer lists `migration-workflow` from the user source
