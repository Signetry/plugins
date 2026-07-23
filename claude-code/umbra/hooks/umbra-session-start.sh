#!/usr/bin/env bash
#
# Umbra SessionStart hook: make umbra-core available (using a Python >=3.11) so
# the guard works from the first tool call, and print a clear status line so the
# plugin's state is never a mystery. Best-effort and non-blocking.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=umbra-lib.sh
. "$DIR/umbra-lib.sh"

if umbra_find_runner >/dev/null 2>&1; then
  echo "Umbra active: agent edits and commands are checked against .umbra/admission.yaml before they run."
  exit 0
fi

# Not available yet — try to provision a >=3.11 venv once.
if umbra_provision; then
  echo "Umbra active: installed umbra-core into a plugin-local environment; edits and commands are now checked against .umbra/admission.yaml."
  exit 0
fi

# Could not activate. Say so LOUDLY and specifically — do not pretend to protect.
if umbra_py311plus >/dev/null 2>&1; then
  echo "Umbra plugin loaded but INACTIVE: could not install umbra-core (offline?). The guard is NOT enforcing anything. Fix with: pip install 'umbra-core>=0.2.1'"
else
  echo "Umbra plugin loaded but INACTIVE: needs Python >=3.11, which was not found (your default python3 may be older). The guard is NOT enforcing anything. Install Python 3.11+ and: pip install 'umbra-core>=0.2.1'"
fi
exit 0
