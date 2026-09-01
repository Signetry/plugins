# signetry-plugins

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![PRs welcome (CLA)](https://img.shields.io/badge/PRs-welcome%20(CLA)-brightgreen.svg)](CONTRIBUTING.md)

**Govern coding-agent changes inside your editor — and in CI — with signed receipts.**

Editor and agent integrations for [signetry-core](https://github.com/Signetry/core):
Signetry decides how much authority an agent's change has earned and proves it. These
plugins bring that governance *into the tools where agents work* — enforced by
deterministic code, never by the model itself (an agent can't approve its own change).

> Prerequisite for all integrations: `pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"` and a
> `.signetry/admission.yaml` in your repo (a conservative default applies without one).

## Claude Code plugin (deepest integration)

A **`PreToolUse` hook** runs before every `Edit`/`Write`/`Bash` and **blocks**
out-of-scope or forbidden actions before they happen — using `signetry guard`
(deterministic, not the model). Bundles the Signetry **MCP server** and an
**`/signetry:admit`** skill for on-demand full admission with a signed receipt.

```
/plugin marketplace add Signetry/plugins
/plugin install signetry@signetry-plugins
```

Or test locally: `claude --plugin-dir ./claude-code/signetry`

What it does:
- Agent tries to edit `deploy.yml` / `.env` / a secret, or run `curl … | bash` /
  `git push` → **blocked** with a reason, before it happens.
- Agent edits an in-scope file → allowed silently.
- `/signetry:admit` → full pipeline + earned authority + signed receipt on demand.

### How the guard works

```
Claude Code is about to Edit/Write/run Bash
        │
        ▼
  PreToolUse hook  ──►  hooks/signetry-guard.sh
        │                     │  (passes the tool JSON on stdin)
        │                     ▼
        │              signetry guard  ── loads .signetry/admission.yaml,
        │              (signetry-core)    checks the path/command deterministically
        │                     │
        ▼                     ▼
   deny? ◄──── permissionDecision: "deny" + reason   (forbidden / out-of-scope / dangerous)
   allow? ◄─── {}  (silent → normal permission flow continues)
```

- The decision is made by **`signetry guard` (signetry-core), not the model** — so the
  agent can't approve its own out-of-scope change. This is the whole point: an
  agent cannot govern itself.
- On the **first** tool call, a `SessionStart` hook provisions `signetry-core` into a
  plugin-local venv using a Python ≥3.11 (it skips an older default `python3`). It
  prints **`Signetry active: …`** when ready, or a loud **`INACTIVE — NOT enforcing`**
  line if it can't (e.g. no Python 3.11+ / offline) — so "installed" is never
  mistaken for "protected".
- It **fails open** (never blocks) if signetry-core genuinely can't run, so it can't
  break a session; the `INACTIVE` notice tells you when that happens.

### See it without an interactive session

Reviewers (and you) can verify enforcement in one command — it drives the real
hook with the exact tool JSON Claude Code sends, against a throwaway repo:

```bash
bash demos/try-guard.sh
```

Expected output: `deploy.yml`, `curl | bash`, `cat .env`, and a `.pem` write are
**BLOCKED** with reasons; an in-scope `src/app.js` edit is **ALLOWED**. Requires
`bash`, `git`, and Python ≥3.11 (the hook self-provisions signetry-core).

## Cursor

MCP server + a project rule. See [`cursor/`](cursor/). Cursor has no deterministic
pre-write hook, so the enforced gate there is the CI check on the PR; the MCP tools
+ rule let the agent self-check in-editor.

## Codex

MCP server (`~/.codex/config.toml`) + a lifecycle-hook guard. See [`codex/`](codex/).

## Universal guard (any editor / CI / pre-commit)

[`universal/signetry-guard.sh`](universal/signetry-guard.sh) — checks a path/command or
all staged files against the contract. Wire it into a git pre-commit hook, a CI
step, or an agent wrapper. Also exposed as a `pre-commit` hook
(`.pre-commit-hooks.yaml`).

## The enforced guarantee is CI

In-editor guards are best-effort defense-in-depth. The *enforced* gate is the
**Signetry Admission GitHub Action** — make it a required status check and nothing
merges without a signed receipt:
<https://github.com/marketplace/actions/signetry-admission>.

`auto_merge` is always false — Signetry governs the agent; a human merges.

## License

[Apache-2.0](LICENSE). Use it, fork it, ship it commercially — no strings.

This repository is part of Signetry's [open-core model](https://github.com/Signetry/signetry/blob/main/LICENSING.md):
the **integration surface is Apache-2.0** so anyone can add an agent, an editor, or a
CI adapter, while the engine ([`Signetry/core`](https://github.com/Signetry/core)) is
source-available under BUSL-1.1 and converts to Apache-2.0 on 2030-08-31.

Contributions are accepted under the [CLA](CLA.md) — it lets us move a well-built
adapter into the engine later without asking every contributor for permission again.
