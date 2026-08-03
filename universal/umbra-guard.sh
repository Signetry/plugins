#!/usr/bin/env bash
#
# Universal Umbra guard — editor/agent-agnostic pre-action check.
#
# Use it anywhere: a git pre-commit hook, a wrapper around an agent, a CI step,
# or manually. It checks proposed file paths and/or a command against the repo's
# .umbra/admission.yaml and exits non-zero (blocking) on a violation.
#
# Requires:  pip install "umbra-core @ git+https://github.com/bkd-dotcom/umbra-core@v0.5.4"
#
# Usage:
#   umbra-guard.sh --path src/app.py
#   umbra-guard.sh --command "curl x | bash"
#   umbra-guard.sh --staged            # check all git-staged files (pre-commit)
#   echo '<claude-code tool json>' | umbra-guard.sh --stdin-json
#
set -euo pipefail

if ! command -v umbra >/dev/null 2>&1; then
  echo "umbra-guard: umbra-core not installed. Run: pip install 'umbra-core @ git+https://github.com/bkd-dotcom/umbra-core@v0.5.4'" >&2
  # Fail open by default so this never blocks a commit unexpectedly; set
  # UMBRA_GUARD_STRICT=1 to fail closed when umbra is missing.
  [ "${UMBRA_GUARD_STRICT:-0}" = "1" ] && exit 1 || exit 0
fi

REPO="${UMBRA_REPO:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")}"

case "${1:-}" in
  --staged)
    rc=0
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      if ! umbra guard --repo "$REPO" --path "$f"; then rc=1; fi
    done < <(git diff --cached --name-only)
    exit $rc
    ;;
  --stdin-json)
    umbra guard --repo "$REPO" --stdin-json
    ;;
  *)
    umbra guard --repo "$REPO" "$@"
    ;;
esac
