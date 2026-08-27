---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: dotfiles
created: "2026-08-27"
updated: "2026-08-27"
status: ready
source_skill: sg-development
scope: cross-platform-dotfiles-installer-hardening
owner: Diane
confidence: high
risk_level: high
security_impact: "yes"
docs_impact: "yes"
user_story: "En tant qu'operatrice Windows et Linux, je veux installer mes dotfiles et outils terminal de facon idempotente, recuperable et sans melanger le provisioning ShipGlows."
linked_systems:
  - Windows PowerShell
  - Linux Bash
  - WinGet
  - Native Linux package managers
depends_on:
  - "native-windows-dotfiles-bootstrap.md"
supersedes: []
evidence:
  - "Audit of the legacy Linux orchestrator and broad Windows provisioning script."
  - "Approved cross-platform hardening plan on 2026-08-27."
next_step: "Run syntax and temporary-profile behavior proofs on Windows and Ubuntu."
---

# Cross-platform Dotfiles installer hardening

## Outcome

Provide native Windows and Linux installers sharing a TSV component contract, with strict read-only modes, clean checkout updates, centralized recovery state, and ownership-proven uninstall. Dotfiles owns terminal configuration/tools; ShipGlows owns AI agents, skills, MCP, Doppler, secrets, and general developer provisioning.

## Scope

In: PowerShell/Bash engines, compatibility shims, manifest, terminal packages/config, checkout validation, backup/journal/restore, behavioral contracts, CI, and operator docs.

Out: Termux changes, production/server provisioning, credentials, execution policy, PowerShell profile edits, AI tooling, MCP client config, Doppler, package removal, destructive checkout repair, and publication.

## Acceptance criteria

- AC01: dry-run creates or changes nothing; check is read-only; incompatible or unknown input fails closed.
- AC02: update accepts only matching origin/branch, clean status, and fast-forward history.
- AC03: manifest selection/dependencies are validated natively without external parsing dependencies.
- AC04: conflicts use centralized backups and every managed artifact has a journal proof.
- AC05: uninstall refuses changed/unproven targets, restores backups, and leaves packages installed.
- AC06: Windows diagnoses WinGet, preserves process PATH, retains useful switches, and runs Yazi package installation only explicitly.
- AC07: Linux rejects Windows/MSYS and Termux, uses explicit native package managers, handles root directly, and has no active remote-script pipe.
- AC08: Yazi is modern/default; Ranger is Linux-only legacy and explicit.
- AC09: shims contain no provisioning; runtime and development-clone roles are documented.
- AC10: Windows/Ubuntu CI exercises syntax, contracts, and temporary profiles without heavy network installation.
- AC11: Windows Neovim uses upstream OS-specific builds, treats fzf-native as prerequisite-gated optional acceleration, and verifies pinned Codex ACP 0.16.0 plus its native x64/arm64 runtime.

## Security, OWASP, ZOMBIES, and recovery

Targets are restricted to the current user profile. Origin, branch, and dirtiness are checked before updates. No automatic reset, stash, force checkout, secret retrieval, profile mutation, or arbitrary recursive deletion is allowed. Link targets, copied-file hashes, marked shell blocks, and PATH entries provide ownership evidence. Changed targets are preserved and reported.

OWASP: command arguments are fixed or manifest-token validated; paths are quoted; remote script execution is absent; secrets are neither read nor logged; least privilege is used; journals contain paths/hashes only. ZOMBIES: broad Windows provisioning and Linux AI/MCP/Doppler flows are removed from active entrypoints, wrappers delegate, Ranger is isolated, and uninstall removes valid owned artifacts without removing packages.

## Proof order

1. Parse PowerShell and Bash sources.
2. Run static forbidden-pattern and manifest contracts.
3. Run dry-run/check invalid-input tests in temporary profiles.
4. Run link backup, idempotence, uninstall, and restoration tests.
5. Exercise isolated fresh Windows and Ubuntu profiles without credentials.
6. Record results before publication; this implementation claims no passing test yet.

## Skill run history

| Date UTC | Flow | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-27 | 100-sg-spec | inherited current model | Audited scope, ownership, safety contract, and proof order. | ready | 101-sg-ready |
| 2026-08-27 | 101-sg-ready | inherited current model | Resolved manifest, native engines, recovery, and exclusions. | ready | 102-sg-implementation |
| 2026-08-27 | 102-sg-implementation | inherited current model | Implementing engines, manifest, shims, contracts, CI, and docs. | implementation in progress; tests not run | Execute proof order. |
| 2026-08-27 | 106-sg-fix | inherited current model | Repaired Windows native plugin build assumptions and added manifest-driven Codex ACP installation/postconditions. | fix attempted; focused retest pending | Run focused Windows installer and Neovim contracts. |

## Current chantier flow

| Stage | Status | Evidence | Next step |
| --- | --- | --- | --- |
| 100-sg-spec | ready | Outcome, scope, acceptance, recovery, OWASP, ZOMBIES, and proofs are explicit. | 101-sg-ready |
| 101-sg-ready | ready | No unresolved material direction remains after approval. | 102-sg-implementation |
| 102-sg-implementation | in progress | Native engines now include Windows Neovim/ACP compatibility; focused retest remains required. | 103-sg-verify |
| 103-sg-verify | pending | Commands documented but intentionally not executed in this phase. | Run focused contracts. |
