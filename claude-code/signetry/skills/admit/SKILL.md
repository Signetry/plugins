---
description: Run the Signetry admission pipeline on the current change and show the earned authority + signed receipt. Use when the user asks to "admit", "govern", "check the change with Signetry", or wants a receipt before opening a PR.
---

# Signetry admission

Run the full Signetry admission pipeline on the current working-tree change and
report the result to the user.

Steps:

1. Confirm `signetry` is available: run `signetry --help`. If it is not installed, tell
   the user to run `pip install "signetry-core @ git+https://github.com/Signetry/core@v0.6.0"` and stop.
2. Run admission over the change already present in the working tree (no agent is
   re-invoked — the change being governed is what's on disk):

   ```
   signetry --json admit . --agent none --mission "$ARGUMENTS" --min-authority 1 --receipt-out /tmp/signetry-receipt.json
   ```

   If `$ARGUMENTS` is empty, use the mission
   "Review the current change for scope, secrets, and injected repository instructions."

3. Summarize the JSON `report` for the user, clearly:
   - **Earned authority**: L0 observe / L1 analyze / L2 branch-PR
   - **Contract**: pass or the specific violations
   - **Trust boundary**: clean, or how many injected lines were quarantined
   - **Independent verifier**: reviewable or blocked (and why)
   - **Checks**: whether required checks ran and passed, and the enforcement tier
   - The one-line `outcome`

4. Point out that the signed receipt was written to `/tmp/signetry-receipt.json` and
   can be verified with `signetry verify /tmp/signetry-receipt.json --public-key <key>`.

5. Never claim the change is safe beyond what the report says. `auto_merge` is
   always false — a human merges. If authority is below L2, explain exactly what
   would need to change to earn branch-PR authority.

Do not attempt to bypass a block or edit `.signetry/admission.yaml` to make a change
pass unless the user explicitly asks to change the policy.
