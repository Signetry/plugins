#!/usr/bin/env bash
# Launch the Umbra MCP server using a Python >=3.11 that has umbra_core,
# preferring the plugin-local venv the hooks provision. Exits cleanly if none.
set -uo pipefail
export UMBRA_MCP_ROOTS="${CLAUDE_PROJECT_DIR:-$PWD}"

VENV_PY="${CLAUDE_PLUGIN_DATA:-${CLAUDE_PLUGIN_ROOT:-$HOME/.umbra-plugin}}/venv/bin/python"
if [ -x "$VENV_PY" ] && "$VENV_PY" -c "import umbra_core.mcp_server" >/dev/null 2>&1; then
  exec "$VENV_PY" -m umbra_core.mcp_server
fi
for PY in python3.13 python3.12 python3.11 python3 python; do
  if command -v "$PY" >/dev/null 2>&1 \
     && "$PY" -c 'import sys; sys.exit(0 if sys.version_info[:2] >= (3,11) else 1)' >/dev/null 2>&1 \
     && "$PY" -c "import umbra_core.mcp_server" >/dev/null 2>&1; then
    exec "$PY" -m umbra_core.mcp_server
  fi
done
echo "umbra-core[mcp] not available on a Python >=3.11; run: pip install 'umbra-core[mcp] @ git+https://github.com/bkd-dotcom/umbra-core@v0.5.3'" >&2
exit 1
