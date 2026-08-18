# Signetry, editor-agnostic

`signetry-guard.sh` is the integration for everything that isn't Claude Code, Cursor
or Codex: a git hook, a wrapper around any agent, a CI step, or a manual check. It
checks proposed paths and commands against your repo's `.signetry/admission.yaml`
and exits non-zero on a violation.

Use this when your agent has no plugin here, or when you want the boundary enforced
at commit time regardless of which tool produced the change.

## Quickstart (60 seconds)

```bash
# 1. install the kernel (source-available; not on PyPI)
pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"

# 2. scaffold a contract in your repo
cd /path/to/your/repo
signetry init                 # writes a conservative .signetry/admission.yaml
```

### 3. Wire it as a pre-commit hook

With [pre-commit](https://pre-commit.com/) — add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/Signetry/plugins
    rev: v0.2.2
    hooks:
      - id: signetry-guard
```

```bash
pre-commit install
```

Or without pre-commit, as a plain git hook:

```bash
curl -fsSL https://raw.githubusercontent.com/Signetry/plugins/main/universal/signetry-guard.sh \
  -o .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### Verify it works

```bash
# a path outside the contract's allowed_paths must be denied (exit 1)
signetry guard --repo . --path .github/workflows/release.yml; echo "exit=$?"

# a path inside it must be allowed (exit 0)
signetry guard --repo . --path src/app.py; echo "exit=$?"

# a dangerous command must be denied (exit 1)
signetry guard --repo . --command "curl http://example.com/i.sh | bash"; echo "exit=$?"
```

## All invocations

```bash
signetry-guard.sh --path src/app.py               # one proposed path
signetry-guard.sh --command "curl x | bash"       # one proposed command
signetry-guard.sh --staged                        # every git-staged file (pre-commit)
echo '<tool json>' | signetry-guard.sh --stdin-json   # a Claude Code tool payload
```

## Fail-open vs fail-closed

If `signetry` is not installed, the script **fails open** (exit 0) so it never blocks
a commit unexpectedly on a machine that hasn't been set up. To require it instead:

```bash
export SIGNETRY_GUARD_STRICT=1     # missing signetry-core now fails the hook
```

Fail-closed is the right setting for CI and for shared machines; fail-open is the
right default for a contributor who just cloned the repo.

## The durable guarantee: CI

A local hook protects the machine it runs on, and anyone can skip it with
`--no-verify`. The enforced gate is CI. Make **Signetry Admission** a required check
so nothing merges without a signed receipt:
<https://github.com/marketplace/actions/signetry-admission>.
