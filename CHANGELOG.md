# Changelog

## [Unreleased] - 2024-12-17

### ✨ Added

#### Doppler Integration
- **Automated secrets management** across all platforms
- Automatic GitHub CLI authentication via `GH_TOKEN`
- AI provider keys (OpenAI, Anthropic, Gemini, Groq) auto-configured
- OpenCode authentication integrated with Doppler
- New `doppler-setup.sh` script for interactive key setup

#### OpenCode Enhancements
- **opencode.nvim plugin** added to MyNeovim and MyNeovimTermux
- Multi-provider support (OpenAI, Claude, Gemini, Groq)
- Alpine Linux environment auto-configured with API keys
- Keybindings: `<leader>oa`, `<leader>ox`, `<leader>op`, `<leader>ot`
- Terminal access via `<leader>ao` in Termux

#### Documentation
- New `docs/installation/TERMUX.md` - Complete Termux setup guide
- New `docs/configuration/DOPPLER.md` - Secrets management guide
- New `docs/configuration/GITHUB-AUTH.md` - GitHub CLI auth guide
- Updated README.md with Doppler and OpenCode information
- Enhanced MyNeovimTermux README with auto-install instructions

### 🔧 Changed

#### Installation Scripts
- **termux.sh**: GitHub CLI auto-auth + OpenCode AI providers
- **install.sh**: GitHub CLI auto-auth with non-interactive detection
- **windows.ps1**: GitHub CLI auto-auth with PowerShell support
- Starship installation output suppressed (cleaner logs)
- Interactive prompts for manual auth if Doppler unavailable
- Non-interactive mode detection (Codespaces auto-run)

#### Neovim Configurations
- OpenCode plugin added to both MyNeovim and MyNeovimTermux
- Unified keybindings using `<leader>o` prefix
- Which-key integration for OpenCode group
- Alpine-specific command for Termux OpenCode

### 🐛 Fixed
- Starship verbose installation messages removed
- OpenCode Termux path corrected in ai-agents.lua

### 📚 Documentation Structure
```
docs/
├── installation/
│   ├── TERMUX.md (NEW)
│   └── ...
├── configuration/
│   ├── DOPPLER.md (NEW)
│   └── ...
```

### 🔐 Security
- All API keys now managed via Doppler (encrypted)
- No plain-text secrets in dotfiles
- Automated token rotation support

---

## Previous Releases

See git history for earlier changes.
