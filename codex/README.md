# Signetry for Codex

Govern coding-agent changes in [OpenAI Codex](https://developers.openai.com/codex)
with [signetry-core](https://github.com/Signetry/core).

## Quickstart (60 seconds)

```bash
# 1. install the kernel (source-available; not on PyPI)
pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"

# 2. scaffold a contract in your repo
cd /path/to/your/repo
signetry init                 # writes a conservative .signetry/admission.yaml
```

### 3. Wire Codex to Signetry

Add the MCP server to `~/.codex/config.toml` (details in §1 below):

```toml
[mcp_servers.signetry]
command = "python"
args = ["-m", "signetry_core.mcp_server"]

[mcp_servers.signetry.env]
SIGNETRY_MCP_ROOTS = "/absolute/path/to/your/repo"
```

Restart Codex; the agent now has `signetry_admit`, `signetry_verify` and
`signetry_provenance`.

### Verify it works

```bash
# a path outside the contract's allowed_paths must be denied (exit 1)
signetry guard --repo . --path .github/workflows/release.yml; echo "exit=$?"

# a path inside it must be allowed (exit 0)
signetry guard --repo . --path src/app.py; echo "exit=$?"
```

Then read on for the lifecycle-hook guard and the CI gate.

## 1. MCP server (recommended)

Codex reads MCP servers from `~/.codex/config.toml`. Add Signetry's server so the
agent can run admission / verify / provenance itself:

```toml
[mcp_servers.signetry]
command = "python"
args = ["-m", "signetry_core.mcp_server"]

[mcp_servers.signetry.env]
SIGNETRY_MCP_ROOTS = "/absolute/path/to/your/repo"
```

`SIGNETRY_MCP_ROOTS` scopes the server to your workspace(s) so it can't be pointed
at arbitrary host paths. The agent then has `signetry_admit`, `signetry_verify`, and
`signetry_provenance` tools.

## 2. Lifecycle hook guard (deterministic pre-action check)

Codex supports lifecycle hooks. Configure a hook that runs `signetry guard` before a
file write / command, so an out-of-scope or forbidden action is blocked by
deterministic code (not the model). See the Codex config docs for the exact hook
schema for your version; the guard command to wire in is:

```bash
signetry guard --repo "$REPO" --path "$PROPOSED_PATH"      # exit 1 = deny
signetry guard --repo "$REPO" --command "$PROPOSED_COMMAND" # exit 1 = deny
```

`signetry guard` exits non-zero and prints a reason when the action violates the
contract; exit 0 means allowed.

## 3. The durable guarantee: CI

Whichever agent opens the PR, make **Signetry Admission** a required check so nothing
merges without a signed receipt:
<https://github.com/marketplace/actions/signetry-admission>. In-editor guards are
best-effort defense-in-depth; the CI check is the enforced gate.
