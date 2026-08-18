#!/usr/bin/env bash
#
# Universal Signetry guard — editor/agent-agnostic pre-action check.
#
# Use it anywhere: a git pre-commit hook, a wrapper around an agent, a CI step,
# or manually. It checks proposed file paths and/or a command against the repo's
# .signetry/admission.yaml and exits non-zero (blocking) on a violation.
#
# Requires:  pip install "signetry-core @ git+https://github.com/Signetry/core@v0.7.0"
#
# Usage:
#   signetry-guard.sh --path src/app.py
#   signetry-guard.sh --command "curl x | bash"
#   signetry-guard.sh --staged            # check all git-staged files (pre-commit)
#   echo '<claude-code tool json>' | signetry-guard.sh --stdin-json
#
set -euo pipefail

if ! command -v signetry >/dev/null 2>&1; then
  echo "signetry-guard: signetry-core not installed. Run: pip install 'signetry-core @ git+https://github.com/Signetry/core@v0.7.0'" >&2
  # Fail open by default so this never blocks a commit unexpectedly; set
  # SIGNETRY_GUARD_STRICT=1 to fail closed when signetry is missing.
  [ "${SIGNETRY_GUARD_STRICT:-0}" = "1" ] && exit 1 || exit 0
fi

REPO="${SIGNETRY_REPO:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")}"

case "${1:-}" in
  --staged)
    rc=0
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      if ! signetry guard --repo "$REPO" --path "$f"; then rc=1; fi
    done < <(git diff --cached --name-only)
    exit $rc
    ;;
  --stdin-json)
    signetry guard --repo "$REPO" --stdin-json
    ;;
  *)
    signetry guard --repo "$REPO" "$@"
    ;;
esac
