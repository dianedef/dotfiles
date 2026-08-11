# Test Log

## 2026-08-09 - Fresh Linux user-local Dotfiles installation

- Scope: BUG-2026-08-09-001
- Environment: disposable Ubuntu 24.04 x86_64 VM, Node.js 24, fresh non-root HOME
- Tester: Codex tooling
- Source: 003-sg-bug
- Status: pass
- Confidence: high
- Result summary: Full user-local installation exited zero, installed and verified mcpc plus the native Codex ACP runtime, cloned the canonical ShipGlows repository, synchronized Ranger from the correct source, and passed the subsequent health check.
- Bug pointer: BUG-2026-08-09-001 -> shipglows_data/workflow/bugs/BUG-2026-08-09-001.md
- Evidence pointer: transient VM console output; no host, credential, key material, or private payload retained
- Follow-up: none
