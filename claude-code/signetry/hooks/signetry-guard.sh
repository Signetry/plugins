#!/usr/bin/env bash
#
# Signetry PreToolUse guard for Claude Code.
#
# Reads the tool-call JSON from stdin and asks `signetry guard` whether the proposed
# file write or shell command is allowed by the repo's .signetry/admission.yaml.
# Emits Claude Code's PreToolUse decision JSON: a "deny" BLOCKS the tool call
# with a reason; anything else stays silent (normal permission flow continues).
#
# Governance runs in this deterministic external check — NOT the model — so the
# agent cannot approve its own out-of-scope change.
#
# Resolution (a Python >=3.11 is required by signetry-core; a stock macOS python3 is
# often 3.9 and is skipped): signetry on PATH -> a >=3.11 python that imports
# signetry_core -> plugin-local venv -> provision the venv once. If none works it
# FAILS OPEN (never blocks) so it can't break a session; SessionStart prints a
# loud INACTIVE notice in that case so "installed" is never mistaken for "protected".
set -euo pipefail

INPUT="$(cat)"
REPO="${CLAUDE_PROJECT_DIR:-$PWD}"

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=signetry-lib.sh
. "$DIR/signetry-lib.sh"

RUNNER="$(signetry_find_runner 2>/dev/null || true)"
if [ -z "$RUNNER" ]; then
  # Try to provision a >=3.11 venv once, then re-resolve.
  signetry_provision || exit 0
  RUNNER="$(signetry_find_runner 2>/dev/null || true)"
  [ -z "$RUNNER" ] && exit 0
fi

# shellcheck disable=SC2086 - RUNNER is a trusted command prefix we constructed.
printf '%s' "$INPUT" | $RUNNER guard --repo "$REPO" --stdin-json --hook-output 2>/dev/null || exit 0
