# GitHub Copilot Instructions - Dotfiles Repository

## Context
This repository contains personal dotfiles primarily used in **Termux on Android** via SSH to **GitHub Codespaces**. The setup is multi-platform (Windows, Linux, Android/Termux).

## Primary Use Case
- **Environment**: Termux (Android) → SSH → GitHub Codespaces (Linux)
- **Main tools**: Neovim, Yazi (file manager), Starship prompt, FZF, Ripgrep
- **Shell**: Bash (primary), with Nushell configs available

## Repository Structure
```
dotfiles/
├── nvim/           # Neovim configuration (LazyVim-based)
├── yazi/           # Yazi file manager config
├── starship/       # Starship prompt theme
├── ranger/         # Ranger file manager (backup)
├── lazygit/        # Git TUI config
├── nushell/        # Nushell configs
├── install.sh      # Linux/Codespaces installer
└── windows.ps1     # Windows PowerShell installer
```

## Installation Context
- **Linux/Codespaces**: Use `install.sh` (automatically runs on Codespace creation)
- **Windows**: Use `windows.ps1` (requires admin, uses symbolic links)
- **Termux (Android)**: Use `termux.sh` (lightweight, no Copilot, essential tools only)

### Installation Scripts Behavior
1. **`install.sh`** (Codespaces/Linux)
   - Runs automatically on each new Codespace startup
   - Installs full development environment (Neovim, LSPs, Copilot, etc.)
   - Creates symlinks to `~/.config/`
   - Full-featured, optimized for cloud development

2. **`termux.sh`** (Android/Termux)
   - Run manually: `bash ~/dotfiles/termux.sh`
   - Lightweight installation (limited Android resources)
   - Installs: Neovim, Starship, Zoxide, Yazi (optional)
   - Excludes: GitHub Copilot, heavy LSPs
   - **Important**: Binaries install to `~/.cargo/bin` and `~/.local/bin`
   - Adds PATH to `~/.bashrc` for Starship/Zoxide
   - Use `source ~/.bashrc` or restart shell after installation

3. **`windows.ps1`** (Windows)
   - Manual installation with admin privileges
   - Full Windows development setup

## Key Technologies
- **Neovim**: Modern Vim with Lua config, LSP, Treesitter
- **Yazi**: Fast terminal file manager with preview
- **Starship**: Cross-shell prompt (shows git, languages, etc.)
- **FZF**: Fuzzy finder for files/history
- **Zoxide**: Smart `cd` replacement

## Coding Guidelines for This Repo

### When modifying configs:
1. **Paths**: Always use cross-platform paths when possible
2. **Symlinks**: Configs are symlinked, not copied
3. **Bash**: Primary shell in Codespaces (not PowerShell)
4. **Termux constraints**: Limited permissions, no systemd

### For Neovim changes:
- Use lazy.nvim plugin manager syntax
- Follow LazyVim conventions
- Test in Codespaces environment
- Consider terminal limitations (colors, fonts)

### For installation scripts:
- `install.sh`: Focus on Debian/Ubuntu packages (Codespaces base)
- Check if tools already installed before installing
- Create backups before symlinking
- Handle missing directories gracefully

## Common Gotchas
1. **Android/Termux**: 
   - Different paths (`/data/data/com.termux/files/home/`)
   - Binaries install to `~/.cargo/bin` (Starship) and `~/.local/bin` (Zoxide)
   - Need to restart shell or `source ~/.bashrc` after `termux.sh`
   - PATH is automatically added by script
2. **SSH performance**: Configs should be lightweight for SSH latency
3. **Clipboard**: Different between local Termux and remote Codespaces
4. **File permissions**: Termux runs as non-root user
5. **Codespaces**: `install.sh` runs automatically, no manual action needed

## Development Workflow
1. Edit configs in dotfiles repo
2. Changes take effect immediately (symlinks)
3. Test in Codespaces first
4. Then test in Termux if Android-specific

## Helpful Assumptions
- **Current environment**: You are running in GitHub Codespaces (not Termux)
- When suggesting changes, assume Linux/Bash environment
- Prefer built-in tools over npm/pip packages when possible
- Keep configs minimal and fast (SSH latency matters)
- Document Android-specific workarounds clearly

## Debugging Installation Issues
When helping with `termux.sh` problems:
1. Check if binaries are installed: `ls ~/.cargo/bin/starship ~/.local/bin/zoxide`
2. Check if PATH was added: `grep -E "(cargo|local)" ~/.bashrc`
3. Verify current PATH: `echo $PATH`
4. Remind user to restart shell or run: `source ~/.bashrc`
