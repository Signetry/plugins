# Contributing to signetry-plugins

This repository is **Apache-2.0** (see [LICENSE](LICENSE)) — the integration surface of
Signetry's [open-core model](https://github.com/Signetry/signetry/blob/main/LICENSING.md).
You may use, modify, fork, redistribute, and ship it commercially, with no permission
needed from anyone. New agent, editor, and CI adapters are exactly what this repo is
for, so contributions are very welcome.

The engine these plugins call, [`signetry-core`](https://github.com/Signetry/core), is
source-available under BUSL-1.1 and converts to Apache-2.0 on 2030-08-31. Everything in
*this* repo is Apache-2.0 today.

## Getting started

Every integration here is a thin, deterministic wrapper around the `signetry` CLI, so
you need the kernel installed first (it is not on PyPI — install from the git tag):

```bash
pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"
```

Then clone this repo and scaffold a contract in a scratch repo to test against:

```bash
signetry init                 # writes a conservative .signetry/admission.yaml
```

### Run the Claude Code plugin from your checkout

```bash
claude --plugin-dir ./claude-code/signetry
```

### Verify enforcement without an interactive session

This is the closest thing the repo has to a test suite, and it is the check to run
before opening a PR. It drives the real `PreToolUse` hook with the exact tool-call JSON
Claude Code sends, against a throwaway repo:

```bash
bash demos/try-guard.sh
```

Expected output: `deploy.yml`, `curl … | bash`, `cat .env`, and a `.pem` write are
**BLOCKED** with reasons; an in-scope `src/app.js` edit is **ALLOWED**. Requires `bash`,
`git`, and Python ≥3.11 (the hook self-provisions signetry-core into a plugin-local
venv on first run).

### Check the universal guard directly

```bash
universal/signetry-guard.sh --path src/app.py               # one proposed path
universal/signetry-guard.sh --command "curl x | bash"       # one proposed command
universal/signetry-guard.sh --staged                        # every git-staged file
echo '<tool json>' | universal/signetry-guard.sh --stdin-json   # a Claude Code payload
```

Exit `1` means the guard would block the action and prints the contract's reason; exit
`0` means it is allowed.

### What CI runs on your PR

- **CLA** — the signature gate described below; it must pass before merge.
- **Reviewer** — an advisory architecture/security review that posts one comment. It
  never fails the PR and never merges anything.

## House rules for changes

- The guard decision must stay **deterministic** — it comes from
  `.signetry/admission.yaml` via `signetry guard`, never from a model. An agent must not
  be able to talk its way past it.
- In-editor guards **fail open** so they cannot break a session, and say so loudly when
  they are inactive. "Installed" must never masquerade as "protected".
- Don't document a command you haven't run. Version pins, exit codes, and expected
  output in these READMEs are meant to be verified, not assumed.

## Signing the CLA (required before merge)

Signetry keeps a Contributor License Agreement even though the code is open source.
The reason is the open-core line: a well-built adapter here may later be promoted into
the BUSL-1.1 engine, or engine code may be released outward into this repo. The CLA
gives the maintainer the rights to move code across that line without having to track
down every past contributor for permission.

It does **not** take anything away from you: the project — including your contribution —
is published under Apache-2.0, and you keep every right that licence grants, the same as
any other user. You may use, fork, and commercialize the code, including your own work.

This is enforced by a bot. When you open a pull request, the **CLA Assistant** check
will ask you to sign the [Contributor License Agreement](CLA.md). Reply on the PR
with exactly:

```
I have read the CLA Document and I hereby sign the CLA
```

Your acceptance is recorded in `signatures/cla.json`. A PR **cannot be merged** until
the CLA is signed.

## Credit

Contributors are **acknowledged** in [CONTRIBUTORS.md](CONTRIBUTORS.md), the Git
history, and release notes. This is attribution, and it is separate from licensing:
your rights to use the code come from Apache-2.0, not from being listed. Being listed
does not make you a maintainer or let you speak for the project or use its name to
endorse your own products. See the "Recognition of Contributors" clause in [CLA.md](CLA.md).

## Reporting a security issue

Please don't open a public issue. See [SECURITY.md](SECURITY.md) — this is a security
tool, and reports are handled privately via GitHub Security Advisories.
