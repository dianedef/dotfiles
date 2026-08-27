---
artifact: architecture_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: dotfiles
created: "2026-04-26"
updated: "2026-08-27"
status: ready
source_skill: sg-development
scope: cross-platform-installer
owner: dianedef
confidence: high
risk_level: high
security_impact: "yes"
docs_impact: "yes"
depends_on:
  - "../workflow/specs/cross-platform-dotfiles-installer-hardening.md"
evidence:
  - "../../install-dotfiles.ps1"
  - "../../dotfiles/install-dotfiles.sh"
  - "../../dotfiles/components.tsv"
next_review: "2026-11-27"
next_step: "Run the documented Windows and Ubuntu contract suites."
---

# Architecture

Two native engines consume one dependency-free TSV manifest:

```text
components.tsv
|-- install-dotfiles.ps1         Windows checkout, WinGet, config, journal
`-- dotfiles/install-dotfiles.sh Linux package manager, config, shell, journal
```

`dotfiles/install.sh` and `dotfiles/bootstrap.sh` delegate to Bash. `dotfiles/windows.ps1` delegates to PowerShell and defaults a bare legacy invocation to dry-run. Termux remains independent.

State is stored below `%LOCALAPPDATA%\dotfiles\state` on Windows and `${XDG_STATE_HOME:-~/.local/state}/dotfiles` on Linux. Conflicts move to run-specific backup directories. Journal proofs record managed link targets, copied-file SHA-256, shell markers, or PATH entries. Uninstall refuses changed targets, restores available backups, and leaves packages installed.

The engines install terminal tools/config only. ShipGlows owns AI agents, skills, MCP, Doppler, secrets, and developer-machine provisioning.
