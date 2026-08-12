#!/usr/bin/env bash
#
# Shared Signetry resolver — sourced by the plugin hooks.
#
# Provides:
#   signetry_venv_path    -> echoes the plugin-local venv path
#   signetry_find_runner  -> echoes a working "signetry runner" (the command prefix
#                            that runs `signetry_core.cli`), or nothing if none.
#   signetry_py311plus    -> echoes a Python >=3.11 interpreter, or nothing.
#   signetry_provision    -> best-effort: build the venv with a >=3.11 interpreter
#                            and install signetry-core into it. Returns 0 on success.
#
# Every function is quiet and never exits the caller; callers decide what to do.

signetry_venv_path() {
  echo "${CLAUDE_PLUGIN_DATA:-${CLAUDE_PLUGIN_ROOT:-$HOME/.signetry-plugin}}/venv"
}

# Is $1 a Python interpreter reporting version >= 3.11?
_signetry_is_py311plus() {
  command -v "$1" >/dev/null 2>&1 || return 1
  "$1" -c 'import sys; sys.exit(0 if sys.version_info[:2] >= (3, 11) else 1)' >/dev/null 2>&1
}

# Echo the first available Python >= 3.11. signetry-core requires >=3.11, so a
# stock macOS python3 (3.9) must NOT be used to build the venv.
signetry_py311plus() {
  for PY in python3.13 python3.12 python3.11 python3 python; do
    if _signetry_is_py311plus "$PY"; then
      command -v "$PY"
      return 0
    fi
  done
  return 1
}

# Echo a working runner: a command prefix that can run `guard`, or nothing.
# Order: signetry on PATH -> a >=3.11 python that already imports signetry_core ->
# the plugin-local venv.
signetry_find_runner() {
  if command -v signetry >/dev/null 2>&1; then
    echo "signetry"
    return 0
  fi
  for PY in python3.13 python3.12 python3.11 python3 python; do
    if _signetry_is_py311plus "$PY" && "$PY" -c "import signetry_core" >/dev/null 2>&1; then
      echo "$PY -m signetry_core.cli"
      return 0
    fi
  done
  local venv_py
  venv_py="$(signetry_venv_path)/bin/python"
  if [ -x "$venv_py" ] && "$venv_py" -c "import signetry_core" >/dev/null 2>&1; then
    echo "$venv_py -m signetry_core.cli"
    return 0
  fi
  return 1
}

# Build the plugin-local venv with a >=3.11 interpreter and install signetry-core.
# Best-effort; returns 0 only if signetry_core is importable afterwards.
signetry_provision() {
  local py venv venv_py
  py="$(signetry_py311plus)" || return 1     # no suitable interpreter -> cannot provision
  venv="$(signetry_venv_path)"
  venv_py="$venv/bin/python"
  {
    "$py" -m venv "$venv" \
      && "$venv_py" -m pip install --quiet --disable-pip-version-check "signetry-core @ git+https://github.com/Signetry/core@v0.6.0"
  } >/dev/null 2>&1 || true
  [ -x "$venv_py" ] && "$venv_py" -c "import signetry_core" >/dev/null 2>&1
}
