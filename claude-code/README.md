# Signetry for Claude Code

Govern coding-agent changes in [Claude Code](https://claude.com/claude-code) with
[signetry-core](https://github.com/Signetry/core).

This is the strongest in-editor integration of the four, because Claude Code exposes
a **deterministic `PreToolUse` hook**: an out-of-scope write or a forbidden command is
blocked by code before it happens, not merely discouraged in a prompt.

## Quickstart (60 seconds)

```bash
# 1. install the kernel (source-available; not on PyPI)
pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"

# 2. scaffold a contract in your repo
cd /path/to/your/repo
signetry init                 # writes a conservative .signetry/admission.yaml
```

### 3. Install the plugin

In Claude Code:

```
/plugin marketplace add Signetry/plugins
/plugin install signetry@signetry-plugins
```

Or run against a local checkout without installing:

```bash
claude --plugin-dir ./claude-code/signetry
```

### Verify it works

```bash
# a path outside the contract's allowed_paths must be denied (exit 1)
signetry guard --repo . --path .github/workflows/release.yml; echo "exit=$?"

# a path inside it must be allowed (exit 0)
signetry guard --repo . --path src/app.py; echo "exit=$?"
```

`exit=1` means the guard would block that action; `exit=0` means it is within your
contract. In the editor, ask Claude to edit a path your contract forbids — the write
is refused with the contract's reason rather than being applied.

## What the plugin adds

| piece | trigger | effect |
|---|---|---|
| `hooks/signetry-guard.sh` | `PreToolUse` on `Edit`/`Write`/`MultiEdit`/`NotebookEdit` | blocks a write outside `allowed_paths` or inside `forbidden_paths` |
| `hooks/signetry-guard.sh` | `PreToolUse` on `Bash` | blocks a command the contract forbids |
| `hooks/signetry-session-start.sh` | `SessionStart` | prepares the guard and reports whether the contract was found |
| `skills/admit/SKILL.md` | `/signetry:admit` | runs the full admission pipeline and seals a receipt |
| `.mcp.json` | — | the Signetry MCP server (`signetry_admit`, `signetry_verify`, `signetry_provenance`) |

The guard is deterministic: the decision comes from `.signetry/admission.yaml`, so the
agent cannot talk its way past it.

## The durable guarantee: CI

An in-editor hook is defence in depth — it protects the machine it runs on. The
enforced gate is CI. Make **Signetry Admission** a required check so nothing merges
without a signed receipt, whichever agent (or human) opened the PR:
<https://github.com/marketplace/actions/signetry-admission>.
