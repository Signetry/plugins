# Privacy Policy — Signetry plugins

_Last updated: 2026_

**Signetry plugins collect no data.**

The Signetry Claude Code plugin (and the Cursor, Codex, and universal integrations
in this repository) run entirely **locally and offline**:

- The `PreToolUse` guard hook reads the proposed file path or command from the
  editor and checks it against your repository's `.signetry/admission.yaml` using the
  local `signetry` command (from the [signetry-core](https://github.com/Signetry/core)
  Python package). No data leaves your machine.
- The plugin makes **no network requests**, sends **no telemetry or analytics**,
  and stores **no personal data**. It has no servers and no backend.
- The bundled MCP server (`python -m signetry_core.mcp_server`) runs locally and is
  scoped to your workspace via `SIGNETRY_MCP_ROOTS`.

Any network behavior is determined solely by tools **you** invoke (e.g. your own
`git`, `pip`, or agent), not by this plugin.

## Contact

Questions: open an issue at
<https://github.com/Signetry/plugins/issues> or email
`binaydalai2024@gmail.com`.
