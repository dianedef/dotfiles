---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: dotfiles
created: "2026-07-13"
updated: "2026-08-27"
status: ready
source_skill: sg-development
scope: code-docs-map
owner: Diane
confidence: high
risk_level: medium
security_impact: "yes"
docs_impact: "yes"
depends_on: []
evidence:
  - "Cross-platform installer hardening implementation."
next_review: "2026-11-27"
next_step: "Keep contracts and guides aligned with the manifest schema."
---

# Code/docs map

| Code | Documentation | Proof |
| --- | --- | --- |
| `install-dotfiles.ps1` | `docs/installation/WINDOWS.md` | PowerShell parser and behavior contract |
| `dotfiles/install-dotfiles.sh`, `lib.sh`, `config.sh` | `docs/installation/LINUX.md` | Bash syntax and temporary-HOME contracts |
| `dotfiles/components.tsv` | `docs/installation/QUICK-START.md` | manifest/schema and selection contracts |
| journal/backup behavior | `shipglows_data/technical/README.md` | symlink safety and restoration |
| compatibility shims | `README.md` | runtime layout contract |
| `dotfiles/termux.sh` | existing Termux documentation | unchanged by this chantier |

Any behavior change updates its guide and active spec. Proof artifacts contain no secrets or local machine values.
