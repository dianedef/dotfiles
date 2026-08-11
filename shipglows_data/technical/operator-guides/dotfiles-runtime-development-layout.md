---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "dotfiles"
created: "2026-08-11"
updated: "2026-08-11"
status: active
source_skill: sf-docs
scope: dotfiles-runtime-development-layout
owner: Diane
confidence: high
risk_level: medium
security_impact: low
docs_impact: yes
depends_on:
  - README.md
  - install-dotfiles.ps1
evidence:
  - tests/runtime-layout-contract.sh
  - tests/windows-bootstrap-contract.sh
supersedes: []
next_step: none
---

# Dotfiles runtime and development layout

Keep the installed runtime and the editable Git clone separate.

| Role | Linux / Termux | Windows |
|---|---|---|
| Installed runtime | `~/.dotfiles` | `%USERPROFILE%\.dotfiles` |
| Development clone | `~/ShipGlows/dotfiles` | `%USERPROFILE%\ShipGlows\dotfiles` |

The installer owns the hidden runtime. Do not edit or commit from it. On Linux and
Termux, active configuration files symlink into that runtime. On Windows, the
bootstrap copies managed configuration files from it because native symlink setup
is less portable.

Develop in the visible clone on a branch. To test a branch on Windows, run:

```powershell
.\install-dotfiles.ps1 -Branch my-branch -ConfigureTools -ConfigureWezTerm
```

After merging, reinstall `master` from the development clone:

```powershell
.\install-dotfiles.ps1 -Branch master -ConfigureTools -ConfigureWezTerm
```

The bootstrap may switch the clean installed runtime between these branches. It
refuses to overwrite a non-Git runtime or a runtime containing local changes. A
legacy `~/dotfiles` or `%USERPROFILE%\dotfiles` checkout is reported and left
untouched so its migration remains explicit and recoverable.
