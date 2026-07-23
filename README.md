# umbra-plugins

**Govern coding-agent changes inside your editor — and in CI — with signed receipts.**

Editor and agent integrations for [umbra-core](https://github.com/bkd-dotcom/umbra-core):
Umbra decides how much authority an agent's change has earned and proves it. These
plugins bring that governance *into the tools where agents work* — enforced by
deterministic code, never by the model itself (an agent can't approve its own change).

> Prerequisite for all integrations: `pip install "umbra-core>=0.2.0"` and a
> `.umbra/admission.yaml` in your repo (a conservative default applies without one).

## Claude Code plugin (deepest integration)

A **`PreToolUse` hook** runs before every `Edit`/`Write`/`Bash` and **blocks**
out-of-scope or forbidden actions before they happen — using `umbra guard`
(deterministic, not the model). Bundles the Umbra **MCP server** and an
**`/umbra:admit`** skill for on-demand full admission with a signed receipt.

```
/plugin marketplace add bkd-dotcom/umbra-plugins
/plugin install umbra@umbra-plugins
```

Or test locally: `claude --plugin-dir ./claude-code/umbra`

What it does:
- Agent tries to edit `deploy.yml` / `.env` / a secret, or run `curl … | bash` /
  `git push` → **blocked** with a reason, before it happens.
- Agent edits an in-scope file → allowed silently.
- `/umbra:admit` → full pipeline + earned authority + signed receipt on demand.

## Cursor

MCP server + a project rule. See [`cursor/`](cursor/). Cursor has no deterministic
pre-write hook, so the enforced gate there is the CI check on the PR; the MCP tools
+ rule let the agent self-check in-editor.

## Codex

MCP server (`~/.codex/config.toml`) + a lifecycle-hook guard. See [`codex/`](codex/).

## Universal guard (any editor / CI / pre-commit)

[`universal/umbra-guard.sh`](universal/umbra-guard.sh) — checks a path/command or
all staged files against the contract. Wire it into a git pre-commit hook, a CI
step, or an agent wrapper. Also exposed as a `pre-commit` hook
(`.pre-commit-hooks.yaml`).

## The enforced guarantee is CI

In-editor guards are best-effort defense-in-depth. The *enforced* gate is the
**Umbra Admission GitHub Action** — make it a required status check and nothing
merges without a signed receipt:
<https://github.com/marketplace/actions/umbra-admission>.

`auto_merge` is always false — Umbra governs the agent; a human merges.

## License

[MIT](LICENSE) © 2026 bkd-dotcom.
