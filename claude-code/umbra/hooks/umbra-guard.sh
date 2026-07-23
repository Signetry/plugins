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
# Self-provisioning: if the `umbra` CLI (umbra-core) isn't found, this resolves it
# via `python -m umbra_core.cli`, and if still unavailable, installs umbra-core
# into a plugin-local venv under $CLAUDE_PLUGIN_DATA (once). If provisioning fails
# (e.g. offline), it FAILS OPEN so it never breaks a session.
set -euo pipefail

INPUT="$(cat)"
REPO="${CLAUDE_PROJECT_DIR:-$PWD}"

run_guard() {
  printf '%s' "$INPUT" | "$@" guard --repo "$REPO" --stdin-json --hook-output 2>/dev/null
}

# 1. umbra on PATH.
if command -v umbra >/dev/null 2>&1; then
  run_guard umbra || exit 0
  exit 0
fi

# 2. umbra_core importable by the default python.
for PY in python3 python; do
  if command -v "$PY" >/dev/null 2>&1 && "$PY" -c "import umbra_core" >/dev/null 2>&1; then
    run_guard "$PY" -m umbra_core.cli || exit 0
    exit 0
  fi
done

# 3. Plugin-local venv (persists across updates via CLAUDE_PLUGIN_DATA).
VENV="${CLAUDE_PLUGIN_DATA:-${CLAUDE_PLUGIN_ROOT:-$HOME/.umbra-plugin}}/venv"
VENV_PY="$VENV/bin/python"
if [ -x "$VENV_PY" ] && "$VENV_PY" -c "import umbra_core" >/dev/null 2>&1; then
  run_guard "$VENV_PY" -m umbra_core.cli || exit 0
  exit 0
fi

# 4. Try to provision the venv once (best-effort; fail open on any error).
if command -v python3 >/dev/null 2>&1; then
  {
    python3 -m venv "$VENV" \
      && "$VENV_PY" -m pip install --quiet --disable-pip-version-check "umbra-core>=0.2.1"
  } >/dev/null 2>&1 || true
  if [ -x "$VENV_PY" ] && "$VENV_PY" -c "import umbra_core" >/dev/null 2>&1; then
    run_guard "$VENV_PY" -m umbra_core.cli || exit 0
    exit 0
  fi
fi

# 5. Could not provision (offline / no python) — fail open, never block.
exit 0
