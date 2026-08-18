#!/usr/bin/env bash
#
# Signetry SessionStart hook: make signetry-core available (using a Python >=3.11) so
# the guard works from the first tool call, and print a clear status line so the
# plugin's state is never a mystery. Best-effort and non-blocking.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=signetry-lib.sh
. "$DIR/signetry-lib.sh"

if signetry_find_runner >/dev/null 2>&1; then
  echo "Signetry active: agent edits and commands are checked against .signetry/admission.yaml before they run."
  exit 0
fi

# Not available yet — try to provision a >=3.11 venv once.
if signetry_provision; then
  echo "Signetry active: installed signetry-core into a plugin-local environment; edits and commands are now checked against .signetry/admission.yaml."
  exit 0
fi

# Could not activate. Say so LOUDLY and specifically — do not pretend to protect.
if signetry_py311plus >/dev/null 2>&1; then
  echo "Signetry plugin loaded but INACTIVE: could not install signetry-core (offline?). The guard is NOT enforcing anything. Fix with: pip install 'signetry-core @ git+https://github.com/Signetry/core@v0.7.0'"
else
  echo "Signetry plugin loaded but INACTIVE: needs Python >=3.11, which was not found (your default python3 may be older). The guard is NOT enforcing anything. Install Python 3.11+ and: pip install 'signetry-core @ git+https://github.com/Signetry/core@v0.7.0'"
fi
exit 0
