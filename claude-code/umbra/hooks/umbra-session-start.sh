#!/usr/bin/env bash
#
# Umbra SessionStart hook: ensure umbra-core is available so the guard works from
# the first tool call, and print a one-line status so the plugin's presence is
# visible. Best-effort and non-blocking — never fails the session.
set -uo pipefail

VENV="${CLAUDE_PLUGIN_DATA:-${CLAUDE_PLUGIN_ROOT:-$HOME/.umbra-plugin}}/venv"
VENV_PY="$VENV/bin/python"

have() {
  command -v umbra >/dev/null 2>&1 && return 0
  for PY in python3 python; do
    command -v "$PY" >/dev/null 2>&1 && "$PY" -c "import umbra_core" >/dev/null 2>&1 && return 0
  done
  [ -x "$VENV_PY" ] && "$VENV_PY" -c "import umbra_core" >/dev/null 2>&1 && return 0
  return 1
}

if ! have; then
  # Provision a plugin-local venv once (best-effort, quiet, offline-safe).
  if command -v python3 >/dev/null 2>&1; then
    { python3 -m venv "$VENV" && "$VENV_PY" -m pip install --quiet --disable-pip-version-check "umbra-core>=0.2.1"; } >/dev/null 2>&1 || true
  fi
fi

if have; then
  echo "Umbra active: agent edits and commands are checked against .umbra/admission.yaml before they run."
else
  echo "Umbra plugin loaded, but umbra-core isn't installed and couldn't be auto-installed (offline?). Install with: pip install 'umbra-core>=0.2.1'. The guard is inactive until then."
fi
exit 0
