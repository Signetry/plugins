# Security policy

This integration is a thin surface over [signetry-core](https://github.com/Signetry/core),
which owns all governance logic. Please report vulnerabilities in the governance
pipeline (contract evaluation, guard, verifier, receipts) against **signetry-core**.

## Reporting

Open a private security advisory on the affected repository, or use the umbrella's
security contact: <https://github.com/Signetry/signetry>. Do not open a
public issue for an unpatched vulnerability.

## Scope and guarantees

- The soft, in-editor guard is **defense-in-depth**. It may fail open only with a
  loud `INACTIVE` signal; it is not the hard security boundary.
- The hard guarantee is the required check on the pull request
  ([signetry-action](https://github.com/Signetry/action)) plus the signed
  receipt — verifiable offline against Signetry's pinned public key.
- `auto_merge` is always false. Signetry governs the agent; a human merges.
- This integration never reimplements policy; it pins `signetry-core`.
