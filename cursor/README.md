# Signetry for Cursor

Two ways to govern coding-agent changes in Cursor with
[signetry-core](https://github.com/Signetry/core).

## Prerequisite

```bash
pip install "signetry-core @ git+https://github.com/Signetry/core@v0.6.0"
```

Add a `.signetry/admission.yaml` to your repo declaring allowed/forbidden paths,
diff budget, and required checks (a conservative default applies without one).

## 1. MCP server (recommended)

Cursor speaks MCP. Add Signetry's server so the agent can run admission / verify /
provenance itself. Copy `mcp.json` to `.cursor/mcp.json` in your project (or merge
into your existing one):

```json
{
  "mcpServers": {
    "signetry": {
      "command": "python",
      "args": ["-m", "signetry_core.mcp_server"],
      "env": { "SIGNETRY_MCP_ROOTS": "${workspaceFolder}" }
    }
  }
}
```

Then the agent can call `signetry_admit`, `signetry_verify`, and `signetry_provenance`.
`SIGNETRY_MCP_ROOTS` scopes the server to your workspace so it can't be pointed at
arbitrary host paths.

## 2. Project rule (defense in depth)

Drop `signetry.mdc` into `.cursor/rules/` so the agent is told to stay within the
contract and to run `signetry guard` before writing forbidden paths. This is advisory
(the model may still err) — the durable guard is running Signetry in CI on the PR via
the [Signetry Admission GitHub Action](https://github.com/marketplace/actions/signetry-admission).

> Note: Cursor has no deterministic pre-write hook like Claude Code, so in Cursor
> the strong enforcement is the CI check on the PR; the MCP tools + rule give the
> agent an in-editor way to self-check first.
