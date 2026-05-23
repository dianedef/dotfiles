---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-05-22"
status: draft
source_skill: sf-docs
scope: readme
owner: "dianedef"
confidence: medium
security_impact: low
risk_level: low
docs_impact: yes
depends_on: []
supersedes: []
evidence: []
next_step: "/sf-docs audit README.md"
---

# My Dotfiles

Multi-platform dotfiles repository with a full Linux/Codespaces setup and a deliberately lightweight Termux profile.

- 🎨 Neovim for code editing
- ✨ Starship prompt with git integration
- 🔍 FZF, Ripgrep, and Zoxide for navigation
- 📱 Termux profile for Markdown editing on Android

## 📚 Documentation

**→ [Complete Documentation Index](docs/INDEX.md)** - Start here for comprehensive guides

### Quick Links
- **[⚡ Quick Start](docs/installation/QUICK-START.md)** - Get started in 5 minutes
- **[🪟 Windows Setup](docs/installation/WINDOWS.md)** - Windows installation
- **[🐧 Linux/Codespaces](docs/installation/LINUX.md)** - Linux installation  
- **[📱 Termux/Android](nvim/MyNeovimTermux/README-TERMUX.md)** - Android Markdown profile
- **[🤖 BMAD Usage](docs/workflows/BMAD-USAGE.md)** - AI-assisted development

<!-- toc -->

- [Quick Installation](#quick-installation)
  - [Windows](#windows)
  - [Linux/Codespaces](#linuxcodespaces)
  - [Termux/Android](#termuxandroid)
- [What's Included](#whats-included)
- [BMAD Method Integration](#bmad-method-integration)
- [Documentation](#documentation)
- [Credits](#credits)

<!-- tocstop -->

## Quick Installation

### Windows

```powershell
# Clone and run installation (as administrator)
git clone https://github.com/dianedef/dotfiles.git $HOME/dotfiles
Set-ExecutionPolicy Bypass -Scope Process -Force
$HOME/dotfiles/windows.ps1
```

**[→ Detailed Windows Guide](docs/installation/WINDOWS.md)**

### Linux/Codespaces

```bash
# Clone and run installation
git clone https://github.com/dianedef/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x install.sh && ./install.sh
source ~/.bashrc
```

**🔧 Pre-configure for Codespaces**: Edit `.env` before first boot (optional)

**[→ Detailed Linux Guide](docs/installation/LINUX.md)** | **[→ .env Configuration](docs/ENV_CONFIGURATION.md)**

### Installation scope and root usage

`dotfiles` is primarily a user-level installer. Its normal target is the current user's home directory:

- `~/.local/bin` for user-local binaries
- `~/.npm-global` for npm global tools without writing to `/usr/local`
- `~/.config` and `~/.bashrc` for editor, shell, and terminal configuration

When sudo is available, the script may install generic system packages such as `git`, `curl`, `ripgrep`, `fd`, `bat`, `lsd`, `tmux`, or `mosh`. User configuration still remains scoped to the current `$HOME`.

When launched without sudo or with `USER_LOCAL_MODE=true`, root-only extras are not applied: apt/dpkg packages, `/opt`, `/usr/local/bin`, system services, and new sudo user creation. The install log now reports this explicitly so the operator can see what was installed user-local and what still requires root.

ShipFlow is separate: its system installer must be run as `sudo ~/shipflow/install.sh`. dotfiles links or clones ShipFlow, but does not silently elevate into the ShipFlow system installer from a non-root run.

### Component-aware shell integration

`dotfiles` applies shell aliases and config symlinks only for components that are actually installed when the run finishes.

- `alias r='ranger'` is added only when `ranger` is available.
- `alias k`, `alias o`, `alias mcp` are added when available. `alias co` is owned by ShipFlow.
- `~/.config/ranger` is created only when Ranger is installed.
- In `--dry-run`, no `.bashrc` or config symlink is actually modified.
- Synchronization runs on the final component state, including `--only` modes, so stale aliases/symlinks are removed and only installed-component artifacts are kept.

### Termux/Android

```bash
# Install without manually cloning the repository
curl -fsSL https://winflowz.com/termux-script | sh
source ~/.bashrc
```

Manual equivalent:

```bash
git clone https://github.com/dianedef/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x termux.sh && ./termux.sh
source ~/.bashrc
```

After the first activation, use `re` to reload `.bashrc`.

The installer attempts to repair a broken Termux `curl`/OpenSSL stack automatically. If `curl` cannot download the script at all, repair Termux packages first:

```bash
apt update && apt full-upgrade -y
apt install --reinstall curl openssl libngtcp2 -y
```

Termux is intentionally scoped to Markdown and small text files. It does not install Node.js, GitHub CLI, Doppler, MCP, Copilot, Claude/Codex/OpenCode, or Neovim AI agents.

**[→ Detailed Termux Guide](nvim/MyNeovimTermux/README-TERMUX.md)**

## What's Included

### Core Tools
- **Neovim** - LazyVim-based configuration with LSP support
- **Starship** - Beautiful customizable shell prompt
- **FZF** - Fuzzy finder for files and command history
- **Ripgrep** - Lightning-fast text search
- **Zoxide** - Smart directory navigation

### Additional Tools
- **Lazygit** - Terminal UI for git operations
- **Ranger** - Alternative file manager
- **Nushell** - Modern shell (configs available)

### AI-Powered CLI Tools
Linux/Codespaces only. The Termux installer intentionally skips this category.

- **GitHub Copilot CLI** (`copilot`) - AI assistant in your terminal
- **OpenCode AI** (`opencode`) - Open-source AI coding assistant
  - Supports: OpenAI (GPT), Anthropic (Claude), Google (Gemini), Groq
  - Neovim integration with `opencode.nvim` plugin
  - Automated setup via Doppler secrets

### MCP Servers
Linux/Codespaces only. The Termux installer does not configure MCP clients or registries.

- Shared MCP configuration lives in `mcp/mcp-servers.json`
- Includes `consensus` at `https://mcp.consensus.app/mcp`
- Consensus does not require an API key to get started; OAuth can trigger automatically on first use in supported clients
- ShipFlow owns Claude/Codex MCP client configuration. Dotfiles only links shared MCP registry files via `./install.sh --only=mcp`.

### Secrets Management
Linux/Codespaces only. The Termux Markdown profile does not install Doppler or local API-key setup.

- **Doppler** - Secure API key management across devices
  - Auto-configures GitHub CLI authentication
  - Manages AI provider API keys (OpenAI, Claude, Gemini, Groq)
  - Syncs secrets between Codespaces and local Linux machines

### Fonts & Icons
- **Nerd Fonts** - Automatically installed for icons in Neovim and Starship
- **JetBrainsMono Nerd Font** - Professional monospace with complete icon coverage
- **Note for Termux**: Requires full restart after installation to apply font

### Platform Support
| Tool | Windows | Linux | Termux |
|------|---------|-------|--------|
| Neovim | ✅ Full | ✅ Full | ✅ Basic |
| Starship | ✅ | ✅ | ✅ |
| Nerd Fonts | ✅ | ✅ | ✅ |
| Mosh / tmux | ✅ | ✅ | ✅ |
| GitHub Copilot | ✅ | ✅ | ❌ |
| OpenCode AI | ✅ | ✅ | ❌ |
| Doppler | ✅ | ✅ | ❌ |
| MCP config | ✅ | ✅ | ❌ |

## ShipFlow Ownership

Claude Code skills, Codex config, Claude settings, and ShipFlow AI aliases are owned by the ShipFlow installer. Dotfiles no longer writes `~/.claude` or `~/.codex` for that workflow.

## Audit System (8 domains)

Run `/shipflow-audit` in any project to launch a full 8-domain audit (code, design, copy, SEO, GTM, translation, dependencies, performance) with parallel agents. Three modes:

```bash
# Page mode — audit a single file
/shipflow-audit-seo @src/pages/index.astro

# Project mode — audit the current project
/shipflow-audit-code
/shipflow-audit                      # All 8 domains in parallel

# Global mode — audit ALL projects in the workspace
/shipflow-audit-seo global           # SEO across all web projects
/shipflow-audit global               # Everything, everywhere, all at once
/shipflow-deps global                # Dependencies across all projects
```

Global mode reads `~/shipflow/PROJECTS.md` (private, 8-domain applicability matrix) and launches parallel agents per project.

Each audit:
- Scores every category A/B/C/D
- Fixes issues directly (or asks first for `/shipflow-audit` master)
- Logs scores to `AUDIT_LOG.md` (global + project-local)
- Creates tasks in `TASKS.md` for all issues found

### Task Tracking

```bash
/shipflow-tasks       # Update task tracker
/shipflow-backlog     # Capture ideas
/shipflow-priorities  # Re-rank by impact/effort
/shipflow-review      # Session review + planning
/sf-resume            # Fast thread summary + close/keep-open verdict
/shipflow-ship        # Commit, push, sync ShipFlow
```

### DevOps & Shipping

```bash
/shipflow-check       # Typecheck + lint + build + auto-fix
/shipflow-deploy      # Full deploy: check → ship → restart → verify
/shipflow-status      # Cross-project git dashboard
```

### Scaffolding & Init

```bash
/shipflow-init        # Bootstrap new project for ShipFlow tracking
/shipflow-scaffold page about    # Generate files matching project patterns
```

### Research & Documentation

```bash
/shipflow-research "topic"  # Deep web research → saved report
/shipflow-docs readme       # Generate/update docs from code
/shipflow-enrich @file      # Web research + content upgrade
```

### Upgrades

```bash
/shipflow-migrate astro@5   # Framework upgrade assistant
/shipflow-changelog         # Auto-generate CHANGELOG from git
```

### Interactive Prompts

All skills are **context-aware** with interactive selection prompts:

- **Workspace root detection** — Run any skill from `~/` and it detects you're not inside a project. Instead of failing, it asks "Which project(s)?" with checkboxes.
- **Scope selection** — `/shipflow-review` asks time scope (daily/weekly/sprint), `/shipflow-check` asks which checks (typecheck/lint/build/test), `/shipflow-audit` asks which domains.
- **Global mode** — `/shipflow-audit global` prompts both "Which projects?" and "Which domains?" before launching.
- **Content targeting** — `/shipflow-enrich` with a folder prompts which files to process.

When arguments are provided explicitly, prompts are skipped.

### ShipFlow Data (Private)

Personal tracking data lives in a separate private repo (`~/shipflow/`):
- `TASKS.md` — master tracker across all projects
- `AUDIT_LOG.md` — audit history with scores over time
- `PROJECTS.md` — project registry with domain applicability matrix

`install.sh` clones it automatically. Create yours with `gh repo create shipflow --private`.

## BMAD Method Integration

This repository now includes the **BMAD (Build More, Architect Dreams) Method** - a structured AI-driven development framework.

### What is BMAD?

BMAD provides specialized AI agents for different development roles:
- 🤖 **10 Specialized Agents** - Developer, Architect, Tech Writer, PM, etc.
- 📋 **34 Workflows** - Structured processes for any task size
- 🎯 **Scale-Adaptive** - From quick fixes to enterprise features
- 📚 **Documentation-First** - Maintain quality through structure

### Quick BMAD Usage

```bash
# Initialize BMAD (first time)
@bmd-custom-core-bmad-master *workflow-init

# Quick bug fix or small feature
@bmd-custom-bmm-quick-flow-solo-dev *workflow-quick-flow

# Documentation improvement
@bmd-custom-bmm-tech-writer
```

**[→ Complete BMAD Guide](docs/workflows/BMAD-USAGE.md)**

## Documentation

This repository follows structured documentation organization:

```
docs/
├── installation/     # Platform-specific setup guides
├── configuration/    # Per-tool configuration guides
├── workflows/        # Usage and BMAD workflows
├── troubleshooting/ # Common issues and solutions
└── reference/       # Technical reference materials
```

**[→ Browse Complete Documentation](docs/INDEX.md)**

## Credits

[The Youtube Inspiration behind this repo](https://youtu.be/G27MHyT-u2I)

<div align="left">
    <a href=" https://youtu.be/G27MHyT-u2I ">
        <img
          src="./assets/img/imgs/250218-thux-snacks-image.avif"
          alt=" Images in Neovim | Setting up Snacks Image and Comparing it to Image.nvim "
          width="400"
        />
    </a>
</div>
