#!/usr/bin/env bash
#
# Umbra PreToolUse guard for Claude Code.
#
# Reads the tool-call JSON from stdin and asks `umbra guard` whether the proposed
# file write or shell command is allowed by the repo's .umbra/admission.yaml.
# Emits Claude Code's PreToolUse decision JSON: a "deny" BLOCKS the tool call
# with a reason; anything else stays silent (normal permission flow continues).
#
# Governance runs in this deterministic external check — NOT the model — so the
# agent cannot approve its own out-of-scope change.
#
# Fails OPEN (never blocks) if umbra-core isn't installed or errors, so the plugin
# never breaks a session; install with:  pip install "umbra-core>=0.2.0"
set -euo pipefail

INPUT="$(cat)"

# Locate the umbra CLI; if absent, do nothing (exit 0, no decision).
if ! command -v umbra >/dev/null 2>&1; then
  # Try a bundled venv if the user set one up, else fail open.
  if [ -n "${UMBRA_PYTHON:-}" ] && "$UMBRA_PYTHON" -c "import umbra_core" >/dev/null 2>&1; then
    UMBRA_CMD=("$UMBRA_PYTHON" -m umbra_core.cli)
  else
    exit 0
  fi
else
  UMBRA_CMD=(umbra)
fi

# Repo root: Claude Code sets CLAUDE_PROJECT_DIR; fall back to cwd.
REPO="${CLAUDE_PROJECT_DIR:-$PWD}"

# Hand the tool JSON to `umbra guard`, which extracts tool_input.file_path /
# tool_input.command and emits the PreToolUse decision JSON.
printf '%s' "$INPUT" | "${UMBRA_CMD[@]}" guard --repo "$REPO" --stdin-json --hook-output 2>/dev/null || exit 0
