# Changelog — Signetry plugins

## [Unreleased]

### Changed — rebranded Signetry → Signetry

- Platform kernel dependency `signetry-core` (installed from the git tag
  `git+https://github.com/Signetry/core@v0.6.0`), including the `[mcp]` extra used
  by the MCP launcher.
- CLI command `signetry` across all shell hooks, scripts, docs, and editor configs
  (e.g. `signetry admit`, `signetry guard`, `signetry --json admit`).
- Environment variables use the `SIGNETRY_*` prefix (e.g. `SIGNETRY_MCP_ROOTS`,
  `SIGNETRY_REPO`, `SIGNETRY_GUARD_STRICT`).
- Config directory `.signetry/` with `.signetry/admission.yaml`.
- Python import path `signetry_core`.
- Sibling package reference `signetry-reviewer`.
- Plugin/marketplace names, hook/script filenames, and brand prose use Signetry.

## [0.2.2] — 2026-07-23

### Fixed — "installed but silently inactive" on Python < 3.11 defaults

- The self-provisioning venv is now built with a **Python ≥3.11** interpreter
  (probes `python3.13/3.12/3.11` before falling back), because signetry-core requires
  ≥3.11. Previously, on a machine whose default `python3` is 3.9 (stock macOS),
  the venv was built with 3.9, the signetry-core install failed, and the guard
  silently failed open — the plugin appeared installed but enforced nothing.
- **SessionStart now prints a loud `INACTIVE` status** when the guard can't be
  activated (no ≥3.11 Python, or install failed), instead of pretending to
  protect. "Installed" no longer masquerades as "protected".
- Interpreter-resolution logic is centralized in `hooks/signetry-lib.sh` and shared
  by the guard hook, the SessionStart hook, and the MCP launcher.

## [0.2.1] — 2026-07-23

- Self-provisioning (SessionStart installs signetry-core into a plugin-local venv),
  robust MCP launcher, pinned `signetry-core>=0.2.1`.

## [0.2.0] — 2026-07-22

- Initial editor/agent plugins: Claude Code (PreToolUse guard hook + MCP +
  /signetry:admit skill), Cursor, Codex, and a universal guard.
