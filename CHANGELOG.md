# Changelog — Umbra plugins

## [0.2.2] — 2026-07-23

### Fixed — "installed but silently inactive" on Python < 3.11 defaults

- The self-provisioning venv is now built with a **Python ≥3.11** interpreter
  (probes `python3.13/3.12/3.11` before falling back), because umbra-core requires
  ≥3.11. Previously, on a machine whose default `python3` is 3.9 (stock macOS),
  the venv was built with 3.9, the umbra-core install failed, and the guard
  silently failed open — the plugin appeared installed but enforced nothing.
- **SessionStart now prints a loud `INACTIVE` status** when the guard can't be
  activated (no ≥3.11 Python, or install failed), instead of pretending to
  protect. "Installed" no longer masquerades as "protected".
- Interpreter-resolution logic is centralized in `hooks/umbra-lib.sh` and shared
  by the guard hook, the SessionStart hook, and the MCP launcher.

## [0.2.1] — 2026-07-23

- Self-provisioning (SessionStart installs umbra-core into a plugin-local venv),
  robust MCP launcher, pinned `umbra-core>=0.2.1`.

## [0.2.0] — 2026-07-22

- Initial editor/agent plugins: Claude Code (PreToolUse guard hook + MCP +
  /umbra:admit skill), Cursor, Codex, and a universal guard.
