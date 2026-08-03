# umbra-plugins

> **Copyright (c) 2026 Binay Dalai. All rights reserved.**
> This repository is strictly for viewing and contributing to the original project. You may not use, copy, modify, distribute, or commercialize this code for your own personal or commercial projects without explicit written permission. Only the original author retains the right to use and monetize this project.


**Govern coding-agent changes inside your editor — and in CI — with signed receipts.**

Editor and agent integrations for [umbra-core](https://github.com/bkd-dotcom/umbra-core):
Umbra decides how much authority an agent's change has earned and proves it. These
plugins bring that governance *into the tools where agents work* — enforced by
deterministic code, never by the model itself (an agent can't approve its own change).

> Prerequisite for all integrations: `pip install "umbra-core @ git+https://github.com/bkd-dotcom/umbra-core@v0.5.4"` and a
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

### How the guard works

```
Claude Code is about to Edit/Write/run Bash
        │
        ▼
  PreToolUse hook  ──►  hooks/umbra-guard.sh
        │                     │  (passes the tool JSON on stdin)
        │                     ▼
        │              umbra guard  ── loads .umbra/admission.yaml,
        │              (umbra-core)    checks the path/command deterministically
        │                     │
        ▼                     ▼
   deny? ◄──── permissionDecision: "deny" + reason   (forbidden / out-of-scope / dangerous)
   allow? ◄─── {}  (silent → normal permission flow continues)
```

- The decision is made by **`umbra guard` (umbra-core), not the model** — so the
  agent can't approve its own out-of-scope change. This is the whole point: an
  agent cannot govern itself.
- On the **first** tool call, a `SessionStart` hook provisions `umbra-core` into a
  plugin-local venv using a Python ≥3.11 (it skips an older default `python3`). It
  prints **`Umbra active: …`** when ready, or a loud **`INACTIVE — NOT enforcing`**
  line if it can't (e.g. no Python 3.11+ / offline) — so "installed" is never
  mistaken for "protected".
- It **fails open** (never blocks) if umbra-core genuinely can't run, so it can't
  break a session; the `INACTIVE` notice tells you when that happens.

### See it without an interactive session

Reviewers (and you) can verify enforcement in one command — it drives the real
hook with the exact tool JSON Claude Code sends, against a throwaway repo:

```bash
bash demos/try-guard.sh
```

Expected output: `deploy.yml`, `curl | bash`, `cat .env`, and a `.pem` write are
**BLOCKED** with reasons; an in-scope `src/app.js` edit is **ALLOWED**. Requires
`bash`, `git`, and Python ≥3.11 (the hook self-provisions umbra-core).

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

**Copyright (c) 2026 Binay Dalai. All rights reserved.** This code is not open source. You may not use, copy, modify, distribute, or commercialize it for your own personal or commercial purposes without explicit written permission from the author, who alone retains the right to use and monetize this project. See [CONTRIBUTING.md](CONTRIBUTING.md).
