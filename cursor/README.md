# Signetry for Cursor

Two ways to govern coding-agent changes in Cursor with
[signetry-core](https://github.com/Signetry/core).

## Quickstart (60 seconds)

```bash
# 1. install the kernel (source-available; not on PyPI)
pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"

# 2. scaffold a contract in your repo
cd /path/to/your/repo
signetry init                 # writes a conservative .signetry/admission.yaml
```

### 3. Wire Cursor to Signetry

```bash
mkdir -p .cursor/rules
cp mcp.json .cursor/mcp.json          # or merge into an existing .cursor/mcp.json
cp signetry.mdc .cursor/rules/        # project rule (advisory)
```

Reload Cursor; the agent can then call `signetry_admit`, `signetry_verify` and
`signetry_provenance`.

### Verify it works

```bash
# a path outside the contract's allowed_paths must be denied (exit 1)
signetry guard --repo . --path .github/workflows/release.yml; echo "exit=$?"

# a path inside it must be allowed (exit 0)
signetry guard --repo . --path src/app.py; echo "exit=$?"
```

Cursor has no deterministic pre-write hook, so the enforced gate is CI — see §2 and
the note at the end.

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
