# Privacy Policy — Umbra plugins

_Last updated: 2026_

**Umbra plugins collect no data.**

The Umbra Claude Code plugin (and the Cursor, Codex, and universal integrations
in this repository) run entirely **locally and offline**:

- The `PreToolUse` guard hook reads the proposed file path or command from the
  editor and checks it against your repository's `.umbra/admission.yaml` using the
  local `umbra` command (from the [umbra-core](https://github.com/bkd-dotcom/umbra-core)
  Python package). No data leaves your machine.
- The plugin makes **no network requests**, sends **no telemetry or analytics**,
  and stores **no personal data**. It has no servers and no backend.
- The bundled MCP server (`python -m umbra_core.mcp_server`) runs locally and is
  scoped to your workspace via `UMBRA_MCP_ROOTS`.

Any network behavior is determined solely by tools **you** invoke (e.g. your own
`git`, `pip`, or agent), not by this plugin.

## Contact

Questions: open an issue at
<https://github.com/bkd-dotcom/umbra-plugins/issues> or email
`binaydalai2024@gmail.com`.
