#!/usr/bin/env bash
#
# Shared Umbra resolver — sourced by the plugin hooks.
#
# Provides:
#   umbra_venv_path       -> echoes the plugin-local venv path
#   umbra_find_runner     -> echoes a working "umbra runner" (the command prefix
#                            that runs `umbra_core.cli`), or nothing if none.
#   umbra_py311plus       -> echoes a Python >=3.11 interpreter, or nothing.
#   umbra_provision       -> best-effort: build the venv with a >=3.11 interpreter
#                            and install umbra-core into it. Returns 0 on success.
#
# Every function is quiet and never exits the caller; callers decide what to do.

umbra_venv_path() {
  echo "${CLAUDE_PLUGIN_DATA:-${CLAUDE_PLUGIN_ROOT:-$HOME/.umbra-plugin}}/venv"
}

# Is $1 a Python interpreter reporting version >= 3.11?
_umbra_is_py311plus() {
  command -v "$1" >/dev/null 2>&1 || return 1
  "$1" -c 'import sys; sys.exit(0 if sys.version_info[:2] >= (3, 11) else 1)' >/dev/null 2>&1
}

# Echo the first available Python >= 3.11. umbra-core requires >=3.11, so a
# stock macOS python3 (3.9) must NOT be used to build the venv.
umbra_py311plus() {
  for PY in python3.13 python3.12 python3.11 python3 python; do
    if _umbra_is_py311plus "$PY"; then
      command -v "$PY"
      return 0
    fi
  done
  return 1
}

# Echo a working runner: a command prefix that can run `guard`, or nothing.
# Order: umbra on PATH -> a >=3.11 python that already imports umbra_core ->
# the plugin-local venv.
umbra_find_runner() {
  if command -v umbra >/dev/null 2>&1; then
    echo "umbra"
    return 0
  fi
  for PY in python3.13 python3.12 python3.11 python3 python; do
    if _umbra_is_py311plus "$PY" && "$PY" -c "import umbra_core" >/dev/null 2>&1; then
      echo "$PY -m umbra_core.cli"
      return 0
    fi
  done
  local venv_py
  venv_py="$(umbra_venv_path)/bin/python"
  if [ -x "$venv_py" ] && "$venv_py" -c "import umbra_core" >/dev/null 2>&1; then
    echo "$venv_py -m umbra_core.cli"
    return 0
  fi
  return 1
}

# Build the plugin-local venv with a >=3.11 interpreter and install umbra-core.
# Best-effort; returns 0 only if umbra_core is importable afterwards.
umbra_provision() {
  local py venv venv_py
  py="$(umbra_py311plus)" || return 1     # no suitable interpreter -> cannot provision
  venv="$(umbra_venv_path)"
  venv_py="$venv/bin/python"
  {
    "$py" -m venv "$venv" \
      && "$venv_py" -m pip install --quiet --disable-pip-version-check "umbra-core>=0.2.1"
  } >/dev/null 2>&1 || true
  [ -x "$venv_py" ] && "$venv_py" -c "import umbra_core" >/dev/null 2>&1
}
