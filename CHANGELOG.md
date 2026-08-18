# Changelog — Signetry plugins

## [Unreleased]

### Fixed — the Claude Code plugin declared the wrong license

- `claude-code/signetry/.claude-plugin/plugin.json` declared `"license": "MIT"`
  while the project is **All Rights Reserved**. Left as-is, the plugin directory
  arguably shipped under MIT terms — i.e. granted rights the rest of the project
  reserves. Now `"Proprietary — All Rights Reserved"`, matching
  `signetry-core`'s `pyproject.toml`.
- There is no `LICENSE` file in this repo and GitHub detects no license, so this
  declaration was the only MIT claim; nothing else needed changing.

### Added — a 60-second quickstart in every integration README

- A consistent `## Quickstart (60 seconds)` block at the top of `codex/`, `cursor/`,
  `claude-code/` and `universal/`: install the kernel → `signetry init` → wire the
  integration → verify with `signetry guard`.
- `claude-code/README.md` and `universal/README.md` **did not exist** — those two
  integrations had no entry point of their own at all.
- Every documented command was executed before being written down; the
  `signetry guard` exit codes in the verify step (`1` = deny, `0` = allow) are
  confirmed against a scaffolded contract rather than assumed.

### Fixed — the documented Claude Code install command was broken

- `README.md` told users to run `/plugin marketplace add bkd-dotcom/signetry-plugins`.
  That repository is a **404** since the move to the `Signetry` org, so the primary
  install path for the Claude Code plugin could not work. Now `Signetry/plugins`.
- The marketplace *name* in `/plugin install signetry@signetry-plugins` is unchanged
  and correct — it comes from `marketplace.json`'s `name` field, not the repo path.

### Fixed — stale version pins

- `signetry-core` pins move `v0.6.0` → `v0.7.0` across the READMEs, hooks, scripts,
  the MCP launcher, `codex/config.toml`, the universal guard and the admit skill.
- The pre-commit `rev:` in `.pre-commit-hooks.yaml` said `v0.2.0` while `v0.2.2` is
  released; it and the new universal README now reference `v0.2.2`.

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
