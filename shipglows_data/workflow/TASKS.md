# Tasks — dotfiles

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Maintenance

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Harden Termux local secret handling: silent input, shell-safe env serialization, and `0600` permissions for generated Shell-GPT config | ✅ done |
| 🟠 | Stop destructive replacement of existing user config targets when dotfiles manages first-party config symlinks; unknown files should be backed up, not deleted | ✅ done |
| 🟠 | MCP shared secrets/OAuth broker for Claude + Codex via a single `mcp/run-mcp <server>` wrapper and per-server env injection | 📋 todo |
| 🟡 | Add a non-network installer smoke test that exercises `--dry-run`, `--only=mcp`, and symlink sync behavior under a temporary `HOME` | 📋 todo |
| 🟡 | Replace remote install-script pipes with downloaded, pinned, checksum-verified artifacts where upstream releases make that practical | 📋 todo |
| 🟡 | Ajouter `colors.properties` dans `dotfiles/termux/` pour choisir le thème Termux | 📋 todo |

---

## Historical completed work

| Pri | Task | Status |
|-----|------|--------|
| ✅ | Termux properties config + symlink dans `termux.sh` | ✅ done |
| ✅ | Tmux prefix `C-a` -> `C-w` + double status bar | ✅ done |
| ✅ | MCP servers: secrets -> env vars (DFS, PostHog, Firecrawl) | ✅ done |
| ✅ | `install.sh`: TPM auto-install + Codex config symlink | ✅ done |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟢 | Evaluer un durcissement plus large de la chaine d'installation avec verification de provenance sur tous les binaires tiers | 💤 deferred |

---

## Audit Findings

### Audit: Code (2026-04-28)

**Fixed:**
- [x] Removed `eval` from Claude MCP stdio registration and from `parallel_run`.
- [x] Stopped copying `/root/.ssh/id_ed25519` into newly created non-root users.

**Remaining:**
- [x] 🟠 Harden Termux local secret handling: silent input, shell-safe env serialization, and `0600` permissions for generated Shell-GPT config. `Done`
- [x] 🟠 Stop destructive replacement of existing user config targets when dotfiles manages first-party config symlinks; unknown files should be backed up, not deleted. `Done`
- [ ] 🟡 Add a non-network installer smoke test that exercises `--dry-run`, `--only=mcp`, and symlink sync behavior under a temporary `HOME`.
- [ ] 🟡 Replace remote install-script pipes with downloaded, pinned, checksum-verified artifacts where upstream releases make that practical.
