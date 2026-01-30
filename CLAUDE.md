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
