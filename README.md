# My Dotfiles

Multi-platform development environment with modern terminal tools and AI-assisted workflows.

- 🎨 Neovim for code editing
- 📁 Yazi as terminal file manager  
- ✨ Starship prompt with git integration
- 🔍 FZF, Ripgrep, and Zoxide for navigation
- 🤖 BMAD Method for AI-driven development

## 📚 Documentation

**→ [Complete Documentation Index](docs/INDEX.md)** - Start here for comprehensive guides

### Quick Links
- **[⚡ Quick Start](docs/installation/QUICK-START.md)** - Get started in 5 minutes
- **[🪟 Windows Setup](docs/installation/WINDOWS.md)** - Windows installation
- **[🐧 Linux/Codespaces](docs/installation/LINUX.md)** - Linux installation  
- **[📱 Termux/Android](docs/installation/TERMUX.md)** - Android installation
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

### Termux/Android

```bash
# Clone and run lightweight installation
git clone https://github.com/dianedef/dotfiles.git ~/dotfiles
cd ~/dotfiles && chmod +x termux.sh && ./termux.sh
source ~/.bashrc
```

**[→ Detailed Termux Guide](docs/installation/TERMUX.md)**

## What's Included

### Core Tools
- **Neovim** - LazyVim-based configuration with LSP support
- **Yazi** - Fast terminal file manager with previews
- **Starship** - Beautiful customizable shell prompt
- **FZF** - Fuzzy finder for files and command history
- **Ripgrep** - Lightning-fast text search
- **Zoxide** - Smart directory navigation

### Additional Tools
- **Lazygit** - Terminal UI for git operations
- **Ranger** - Alternative file manager
- **Nushell** - Modern shell (configs available)

### AI-Powered CLI Tools
- **GitHub Copilot CLI** (`copilot`) - AI assistant in your terminal
- **Kilocode** (`kilocode` or `kilo`) - AI-powered code generation
- **OpenCode AI** (`opencode`) - Open-source AI coding assistant
  - Supports: OpenAI (GPT), Anthropic (Claude), Google (Gemini), Groq
  - Neovim integration with `opencode.nvim` plugin
  - Automated setup via Doppler secrets

### Secrets Management
- **Doppler** - Secure API key management across devices
  - Auto-configures GitHub CLI authentication
  - Manages AI provider API keys (OpenAI, Claude, Gemini, Groq)
  - Syncs secrets between Termux, Codespaces, and local machines

### Fonts & Icons
- **Nerd Fonts** - Automatically installed for icons in Neovim, Starship, and Yazi
- **JetBrainsMono Nerd Font** - Professional monospace with complete icon coverage
- **Note for Termux**: Requires full restart after installation to apply font

### Platform Support
| Tool | Windows | Linux | Termux |
|------|---------|-------|--------|
| Neovim | ✅ Full | ✅ Full | ✅ Basic |
| Yazi | ✅ | ✅ | ❌ (Ranger) |
| Starship | ✅ | ✅ | ✅ |
| Nerd Fonts | ✅ | ✅ | ✅ |
| GitHub Copilot | ✅ | ✅ | ❌ |
| OpenCode AI | ✅ | ✅ | ✅ (Alpine) |
| Doppler | ✅ | ✅ | ✅ |

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