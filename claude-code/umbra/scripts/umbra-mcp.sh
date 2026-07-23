#!/usr/bin/env bash
# Launch the Umbra MCP server using whatever Python has umbra_core, preferring the
# plugin-local venv the hooks provision. Exits cleanly if unavailable.
set -uo pipefail
VENV_PY="${CLAUDE_PLUGIN_DATA:-${CLAUDE_PLUGIN_ROOT:-$HOME/.umbra-plugin}}/venv/bin/python"
export UMBRA_MCP_ROOTS="${CLAUDE_PROJECT_DIR:-$PWD}"
if [ -x "$VENV_PY" ] && "$VENV_PY" -c "import umbra_core.mcp_server" >/dev/null 2>&1; then
  exec "$VENV_PY" -m umbra_core.mcp_server
fi
for PY in python3 python; do
  if command -v "$PY" >/dev/null 2>&1 && "$PY" -c "import umbra_core.mcp_server" >/dev/null 2>&1; then
    exec "$PY" -m umbra_core.mcp_server
  fi
done
echo "umbra-core[mcp] not installed; run: pip install 'umbra-core[mcp]>=0.2.0'" >&2
exit 1
