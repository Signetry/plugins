# Umbra for Cursor

Two ways to govern coding-agent changes in Cursor with
[umbra-core](https://github.com/bkd-dotcom/umbra-core).

## Prerequisite

```bash
pip install "umbra-core @ git+https://github.com/bkd-dotcom/umbra-core@v0.5.4"
```

Add a `.umbra/admission.yaml` to your repo declaring allowed/forbidden paths,
diff budget, and required checks (a conservative default applies without one).

## 1. MCP server (recommended)

Cursor speaks MCP. Add Umbra's server so the agent can run admission / verify /
provenance itself. Copy `mcp.json` to `.cursor/mcp.json` in your project (or merge
into your existing one):

```json
{
  "mcpServers": {
    "umbra": {
      "command": "python",
      "args": ["-m", "umbra_core.mcp_server"],
      "env": { "UMBRA_MCP_ROOTS": "${workspaceFolder}" }
    }
  }
}
```

Then the agent can call `umbra_admit`, `umbra_verify`, and `umbra_provenance`.
`UMBRA_MCP_ROOTS` scopes the server to your workspace so it can't be pointed at
arbitrary host paths.

## 2. Project rule (defense in depth)

Drop `umbra.mdc` into `.cursor/rules/` so the agent is told to stay within the
contract and to run `umbra guard` before writing forbidden paths. This is advisory
(the model may still err) — the durable guard is running Umbra in CI on the PR via
the [Umbra Admission GitHub Action](https://github.com/marketplace/actions/umbra-admission).

> Note: Cursor has no deterministic pre-write hook like Claude Code, so in Cursor
> the strong enforcement is the CI check on the PR; the MCP tools + rule give the
> agent an in-editor way to self-check first.
