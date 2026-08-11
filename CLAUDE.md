---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.2"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-08-11"
status: draft
source_skill: sf-docs
scope: technical
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: medium
docs_impact: yes
evidence:
  - "/home/claude/dotfiles/dotfiles/install.sh"
  - "/home/claude/dotfiles/dotfiles/termux.sh"
  - "/home/claude/dotfiles/dotfiles/config.sh"
  - "/home/claude/dotfiles/dotfiles/lib.sh"
depends_on:
  - "/home/claude/dotfiles/dotfiles/install.sh"
  - "/home/claude/dotfiles/CONTEXT.md"
linked_systems:
  - Bash
  - Git
  - CLI
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit CLAUDE.md
---

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Multi-platform dotfiles repository. Linux/Codespaces is the full development setup; Termux is a lightweight Android profile for Markdown and small text files.

## Installation Commands

```bash
# Linux/Codespaces (runs automatically on Codespace creation)
./dotfiles/install.sh

# Termux (Android) - Markdown only, lightweight
./dotfiles/termux.sh

# Windows (run as administrator)
.\dotfiles\windows.ps1

# Sync Neovim plugins
nvim --headless "+Lazy! sync" +qa

# Re-run installation after updates
cd ~/.dotfiles && ./dotfiles/install.sh
```

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ds` | `doppler-setup.sh` | Configure API keys on Linux/Codespaces |
| `i` | `install.sh` / `windows.ps1` | Re-run installation |
| `r` | `ranger` | File manager |
| `z <dir>` | `zoxide` | Smart directory jump |
| `mcp` | `mcpc` | MCP CLI client on Linux/Codespaces |

## Architecture

### Directory Structure
- **nvim/** - Neovim configs (LazyVim-based). Multiple variants: `nvim11/`, `nvim22/`, `MyNeovim/`, `MyNeovimTermux/`
- **starship/** - Shell prompt themes with `starship-switch.sh` for switching
- **lazygit/** - Git TUI configuration
- **mcp/** - MCP server configurations for Linux/Codespaces clients
- **_bmad/** - BMAD Method v6 (10 AI agents, 34 workflows)
- **docs/** - Comprehensive documentation organized by category

### Configuration System
- Configs are **symlinked** to `~/.config/`, not copied
- Environment variables configured via `.env` file (see `.env.example`) for the full installer
- Doppler manages secrets for Linux/Codespaces only

### Platform Differences
| Platform | Installer | Notes |
|----------|-----------|-------|
| Linux/Codespaces | `install.sh` | Full-featured, auto-runs on Codespace creation |
| Termux | `termux.sh` | Markdown-only, no Node.js, no GitHub CLI, no Doppler, no MCP, no AI agents |
| Windows | `windows.ps1` | Requires admin, uses winget |

## Code Style

### Shell Scripts (Bash)
- Use `set -euo pipefail` for error handling
- Functions: `snake_case()`, constants: `UPPER_SNAKE_CASE`, locals: `lower_snake_case`
- Format with `shfmt` (2-space indent), always quote variables: `"$VAR"`

### Lua (Neovim)
- Format with StyLua: 2-space indent, 120 column width
- Use return table pattern for modules; lazy.nvim spec format for plugins

## ShipGlows Skills

Global workflow skills are owned by ShipGlows and installed through the official
ShipGlows bootstrap/CLI. Dotfiles must not clone or execute a local
an unmanaged source tree because it may be stale. This repository may keep
historical samples or editor-facing notes, but it is not the source of truth
for live Claude/Codex skills.

### Task & Workflow Skills
- `/shipglows-tasks` — Update TASKS.md, mark completed items, suggest next steps
- `/shipglows-backlog` — Capture ideas, defer non-urgent tasks
- `/shipglows-priorities` — Re-rank tasks by impact/effort
- `/shipglows-review` — Session review, update docs, plan next
- `/sf-resume` — Fast thread summary with task statuses and close/keep-open verdict
- `/shipglows-ship` — Stage, commit, push + auto-sync ShipGlows data

### Audit Skills (8 domains, 3 modes: `@file` = page, no arg = project, `global` = all projects)
- `/shipglows-audit` — Master orchestrator: launches all 8 domains in parallel
- `/shipglows-audit-code` — Architecture, security, reliability
- `/shipglows-audit-design` — UI/UX, accessibility, responsiveness
- `/shipglows-audit-copy` — Copywriting, tone, CTAs, grammar
- `/shipglows-audit-seo` — Meta tags, structured data, internal linking
- `/shipglows-audit-gtm` — Go-to-market, conversion, trust, analytics
- `/shipglows-audit-translate` — i18n completeness, consistency, terminology
- `/shipglows-deps` — Dependencies: vulnerabilities, outdated, unused, licenses
- `/shipglows-perf` — Performance: bundle, rendering, CWV, data fetching

Project registry for global mode: `~/.shipglows/private/data/PROJECTS.md` (private) — lists all projects with domain applicability matrix (8 domains).

### DevOps & Shipping Skills
- `/shipglows-check` — Typecheck + lint + build, auto-fix errors
- `/shipglows-deploy` — Full deploy cycle: check → ship → restart → verify
- `/shipglows-status` — Cross-project git dashboard

### Scaffolding & Init Skills
- `/shipglows-init` — Bootstrap new project for ShipGlows tracking
- `/shipglows-scaffold` — Generate files matching existing project patterns

### Research & Documentation Skills
- `/shipglows-research` — Deep web research → structured markdown report
- `/shipglows-docs` — Generate/update docs from code (README, API, components)
- `/shipglows-enrich` — Web research + content upgrade

### Upgrade Skills
- `/shipglows-migrate` — Framework upgrade assistant with backup branch
- `/shipglows-changelog` — Auto-generate CHANGELOG.md from git history

### Interactive Prompts

All skills use `AskUserQuestion` for interactive selection when context is ambiguous:

- **Workspace root detection**: Every skill detects when run from `~/` (no project markers) and prompts "Which project(s)?" instead of failing silently.
- **Scope selection**: `/shipglows-review` prompts for time scope (daily/weekly/sprint/release). `/shipglows-check` prompts for which checks (typecheck/lint/build/test). `/shipglows-audit` prompts for which domains.
- **Global mode**: `/shipglows-audit global` and `/shipglows-audit-* global` prompt for project and domain selection with multiSelect checkboxes.
- **Content selection**: `/shipglows-enrich` with folder arg prompts which files to enrich.

When arguments are provided explicitly, prompts are skipped — the skill runs directly.

### ShipGlows Data

The separate ShipGlows private-data repository is stored under
`~/.shipglows/private/data/` by default and stores personal tracking data:
- `TASKS.md` — master task tracker (symlinked to `~/TASKS.md`)
- `AUDIT_LOG.md` — cross-project audit history (symlinked to `~/AUDIT_LOG.md`)

`install.sh` may synchronize that private-data repository, but the ShipGlows
runtime itself remains owned by the official ShipGlows installer.

## Key Conventions

- Test changes in Codespaces first, then Termux if Android-specific
- Keep configs lightweight for SSH latency
- Prefer built-in tools over npm/pip packages
- Check if tools already installed before installing
- Handle missing directories gracefully in scripts

## Termux Gotchas

- Different paths: `/data/data/com.termux/files/home/`
- Binaries install to `~/.cargo/bin` (Starship) and `~/.local/bin` (Zoxide)
- Requires `source ~/.bashrc` or shell restart after installation
- Limited permissions, no systemd
- Full app restart required after font installation
- Do not add web-dev, MCP, or AI-agent tooling to `termux.sh`; use Linux/Codespaces for that.

## Context MCP — Token-Saving Protocol

This project uses a local codebase MCP server for efficient context management. Follow this order strictly:

### Every turn:
1. **Call `context_continue` FIRST** — before any Read, Grep, Glob, or file exploration. This returns files already in memory and avoids re-reading.
2. **If you need more files**, call `context_retrieve` with your query BEFORE using Grep/Glob. It ranks files by relevance.
3. **Use `context_read`** instead of the Read tool when exploring code. It excerpts only relevant portions and tracks your token budget (18K chars/turn).
4. **After editing files**, always call `context_register_edit` with a one-sentence summary.
5. **Store key decisions** with `context_decide` (e.g., "using Vue for interactive islands").

### Rules:
- Do NOT use Read/Grep/Glob for broad exploration before calling `context_continue`
- Do NOT re-read files that `context_continue` says are already in memory
- Prefer `context_read` over Read for all code exploration (Read is fine for files you need in full)
- Do NOT exceed the turn read budget — if `context_read` says budget exhausted, stop reading and work with what you have
- After edits, ALWAYS call `context_register_edit` — this invalidates stale cache
- For large files: call `list_symbols` first, then `context_read "file::symbol"` to read just the function you need
- Call `count_tokens(text)` before reading any file > 200 lines to decide if it's worth the budget
- When user says "done", "bye", or "wrap up" — call `session_wrap` to save context for next session
