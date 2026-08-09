---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "dotfiles"
created: "2026-08-09"
updated: "2026-08-09"
status: ready
source_skill: sg-development
scope: "native-windows-dotfiles-bootstrap"
owner: "Diane"
confidence: high
risk_level: high
security_impact: "yes"
docs_impact: "yes"
user_story: "En tant qu'utilisatrice Windows sans WSL, je veux installer le profil Dotfiles depuis shipglows.com sans exécuter un provisioning massif ni modifier le profil PowerShell."
linked_systems:
  - "/home/claude/dotfiles"
  - "/home/claude/shipglows_app/site"
  - "shipglows.com/dotfiles-script"
depends_on: []
supersedes: []
evidence:
  - "The public dotfiles endpoint currently downloads a non-existent GitHub path and returns a 404 during bootstrap."
  - "dotfiles/windows.ps1 performs a broad all-app machine setup and is unsuitable as a safe Shadow-first public bootstrap."
  - "ShipGlows native Windows bootstrap provides the established temporary-file, explicit PowerShell execution and profile-independent model."
next_step: "Implement the safe native PowerShell bootstrap, negotiate it at the public endpoint, then prove local and hosted responses."
---

# Native Windows Dotfiles Bootstrap

## Outcome

Give Windows users a safe, profile-independent Dotfiles installation path from `shipglows.com`, modeled on the verified ShipGlows bootstrap: download an inspectable temporary PowerShell file, clone or update the public Dotfiles repository without overwriting local work, and optionally install/configure WezTerm only.

## Scope

### In

- Canonical `install-dotfiles.ps1` in the Dotfiles repository.
- Public endpoint negotiation: shell by default; PowerShell for `format=powershell|ps1|windows`.
- Correct existing Unix bootstrap source path.
- Optional WezTerm installation and backup-safe configuration copy.
- Focused tests, README/site wording and endpoint parity checks.

### Out

- Re-running the legacy broad `dotfiles/windows.ps1` application catalogue.
- WSL installation, machine-wide execution-policy changes, profile aliases, credentials, secrets, AI agent installation or administrator-only changes.
- Automatic overwriting, stashing or deleting of an existing Dotfiles checkout or WezTerm configuration.

## Invariants

- The public command downloads to a file and invokes `powershell.exe -NoProfile -ExecutionPolicy Bypass -File`; it never pipes text into PowerShell evaluation.
- Git is installed through WinGet only when absent; failure is explicit.
- Existing non-git destination directories fail without modification.
- Existing modified Git checkouts are not reset, stashed or pulled.
- WezTerm remains an explicit optional choice; existing `wezterm.lua` is backed up before replacement.
- The bootstrap does not read/write the PowerShell profile and works on hosts that block profile script execution.
- Shell and PowerShell public artifacts are byte-identical to canonical Dotfiles sources.

## Acceptance Criteria

- [ ] AC01: `shipglows.com/dotfiles-script` serves the valid Unix bootstrap by default.
- [ ] AC02: `format=powershell`, `ps1`, and `windows` serve the canonical native Windows bootstrap with text/plain cache headers.
- [ ] AC03: a missing Git executable installs Git with WinGet; an available executable is reused.
- [ ] AC04: a fresh checkout clones the public repository; a clean existing checkout fast-forwards only; an unclean checkout remains untouched and reports why.
- [ ] AC05: WezTerm installation/configuration is optional, backup-safe and does not depend on profile execution.
- [ ] AC06: the public page distinguishes the focused Windows profile from the legacy full-machine script.
- [ ] AC07: focused static/endpoint/parity tests, shell syntax, metadata and production endpoint responses pass.

## Execution Batches

### A — Dotfiles canonical bootstrap

Create the PowerShell source, its safety tests and operator documentation in Dotfiles. The legacy broad Windows script remains untouched.

### B — ShipGlows public surface

Add the generated Dotfiles artifacts, negotiated endpoint, tests and Windows copy to the ShipGlows site. This batch is activated after Batch A sources are locally proven.

## Failure Behavior

- Unsupported `format` values return the shell bootstrap.
- Non-interactive PowerShell runs skip optional WezTerm setup unless `-ConfigureWezTerm` is explicit.
- Missing WinGet/Git, a dirty checkout, unavailable clone/update, or configuration-copy failure stops with an actionable error and preserves existing state.

## Proof Order

1. Parse shell and PowerShell sources; inspect forbidden destructive/profile patterns.
2. Run focused contract tests with temporary homes/fixtures where possible.
3. Verify generated-artifact byte parity and endpoint response negotiation.
4. Build the ShipGlows site.
5. Deploy Dotfiles source, then ShipGlows site; fetch the live shell and PowerShell endpoint bodies and compare hashes.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-08-09 | sg-development | GPT-5 Codex | Audited the broken public bootstrap and legacy Windows installer; recorded a safe Windows-first contract based on the verified ShipGlows bootstrap. | ready | Implement batches A then B. |

## Current Chantier Flow

| Stage | Status | Evidence | Next step |
|---|---|---|---|
| 100-sg-spec | complete | Scope, safety boundary, endpoint behavior and proof order are explicit. | 101-sg-ready |
| 101-sg-ready | complete | No unresolved product decision; WezTerm is the deliberately bounded optional setup. | 001-sg-build |
| 001-sg-build | in_progress | Canonical Windows bootstrap and public endpoint remain to implement. | Execute A then B. |
| 103-sg-verify | pending | Awaiting implementation. | Run local and hosted proof. |
| 104-sg-end | pending | Awaiting verification. | Close evidence. |
| 005-sg-ship | pending | Awaiting scoped commits and deployment. | Ship after proof. |
