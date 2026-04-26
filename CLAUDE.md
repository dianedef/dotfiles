# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Multi-platform dotfiles repository for **Termux (Android) → SSH → GitHub Codespaces (Linux)** workflow. Also supports Windows and local Linux machines.

## Installation Commands

```bash
# Linux/Codespaces (runs automatically on Codespace creation)
./install.sh

# Termux (Android) - lightweight
./termux.sh

# Windows (run as administrator)
.\windows.ps1

# Sync Neovim plugins
nvim --headless "+Lazy! sync" +qa

# Re-run installation after updates
cd ~/dotfiles && ./install.sh
```

## Key Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ds` | `doppler-setup.sh` | Configure all API keys |
| `i` | `install.sh` / `windows.ps1` | Re-run installation |
| `y` | `yazi` | File manager (Linux/Windows) |
| `r` | `ranger` | File manager (Termux) |
| `z <dir>` | `zoxide` | Smart directory jump |
| `mcp` | `mcpc` | MCP CLI client for testing servers |

## Architecture

### Directory Structure
- **nvim/** - Neovim configs (LazyVim-based). Multiple variants: `nvim11/`, `nvim22/`, `MyNeovim/`, `MyNeovimTermux/`
- **yazi/** - Yazi file manager with plugins and flavors
- **starship/** - Shell prompt themes with `starship-switch.sh` for switching
- **lazygit/** - Git TUI configuration
- **mcp/** - MCP server configurations (single source of truth for Claude Code, Kilocode, etc.)
- **_bmad/** - BMAD Method v6 (10 AI agents, 34 workflows)
- **docs/** - Comprehensive documentation organized by category

### Configuration System
- Configs are **symlinked** to `~/.config/`, not copied
- Environment variables configured via `.env` file (see `.env.example`)
- Doppler manages secrets (API keys for GitHub, OpenAI, Anthropic, Gemini, Groq)

### Platform Differences
| Platform | Installer | Notes |
|----------|-----------|-------|
| Linux/Codespaces | `install.sh` | Full-featured, auto-runs on Codespace creation |
| Termux | `termux.sh` | Lightweight, no Copilot, uses `~/.cargo/bin` and `~/.local/bin` |
| Windows | `windows.ps1` | Requires admin, uses winget |

## Code Style

### Shell Scripts (Bash)
- Use `set -euo pipefail` for error handling
- Functions: `snake_case()`, constants: `UPPER_SNAKE_CASE`, locals: `lower_snake_case`
- Format with `shfmt` (2-space indent), always quote variables: `"$VAR"`

### Lua (Neovim/Yazi)
- Format with StyLua: 2-space indent, 120 column width
- Use return table pattern for modules; lazy.nvim spec format for plugins

### JavaScript/TypeScript (yazi/rules)
- Format with Prettier: tabs, no semicolons, double quotes, 120 print width

## Claude Code Skills

Global skills live in `claude/skills/` and are symlinked to `~/.claude/skills/`. Available across all projects.

### Task & Workflow Skills
- `/shipflow-tasks` — Update TASKS.md, mark completed items, suggest next steps
- `/shipflow-backlog` — Capture ideas, defer non-urgent tasks
- `/shipflow-priorities` — Re-rank tasks by impact/effort
- `/shipflow-review` — Session review, update docs, plan next
- `/sf-resume` — Fast thread summary with task statuses and close/keep-open verdict
- `/shipflow-ship` — Stage, commit, push + auto-sync ShipFlow data

### Audit Skills (8 domains, 3 modes: `@file` = page, no arg = project, `global` = all projects)
- `/shipflow-audit` — Master orchestrator: launches all 8 domains in parallel
- `/shipflow-audit-code` — Architecture, security, reliability
- `/shipflow-audit-design` — UI/UX, accessibility, responsiveness
- `/shipflow-audit-copy` — Copywriting, tone, CTAs, grammar
- `/shipflow-audit-seo` — Meta tags, structured data, internal linking
- `/shipflow-audit-gtm` — Go-to-market, conversion, trust, analytics
- `/shipflow-audit-translate` — i18n completeness, consistency, terminology
- `/shipflow-deps` — Dependencies: vulnerabilities, outdated, unused, licenses
- `/shipflow-perf` — Performance: bundle, rendering, CWV, data fetching

Project registry for global mode: `~/ShipFlow/PROJECTS.md` (private) — lists all projects with domain applicability matrix (8 domains).

### DevOps & Shipping Skills
- `/shipflow-check` — Typecheck + lint + build, auto-fix errors
- `/shipflow-deploy` — Full deploy cycle: check → ship → restart → verify
- `/shipflow-status` — Cross-project git dashboard

### Scaffolding & Init Skills
- `/shipflow-init` — Bootstrap new project for ShipFlow tracking
- `/shipflow-scaffold` — Generate files matching existing project patterns

### Research & Documentation Skills
- `/shipflow-research` — Deep web research → structured markdown report
- `/shipflow-docs` — Generate/update docs from code (README, API, components)
- `/shipflow-enrich` — Web research + content upgrade

### Upgrade Skills
- `/shipflow-migrate` — Framework upgrade assistant with backup branch
- `/shipflow-changelog` — Auto-generate CHANGELOG.md from git history

### Interactive Prompts

All skills use `AskUserQuestion` for interactive selection when context is ambiguous:

- **Workspace root detection**: Every skill detects when run from `~/` (no project markers) and prompts "Which project(s)?" instead of failing silently.
- **Scope selection**: `/shipflow-review` prompts for time scope (daily/weekly/sprint/release). `/shipflow-check` prompts for which checks (typecheck/lint/build/test). `/shipflow-audit` prompts for which domains.
- **Global mode**: `/shipflow-audit global` and `/shipflow-audit-* global` prompt for project and domain selection with multiSelect checkboxes.
- **Content selection**: `/shipflow-enrich` with folder arg prompts which files to enrich.

When arguments are provided explicitly, prompts are skipped — the skill runs directly.

### ShipFlow Data

The `ShipFlow` private repo (`~/ShipFlow/`) stores personal tracking data:
- `TASKS.md` — master task tracker (symlinked to `~/TASKS.md`)
- `AUDIT_LOG.md` — cross-project audit history (symlinked to `~/AUDIT_LOG.md`)

`install.sh` clones it automatically via `git@github.com:${GITHUB_USERNAME}/ShipFlow.git`.

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
