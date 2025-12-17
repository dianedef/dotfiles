# Quick Start Guide

Get up and running with these dotfiles in under 5 minutes!

## Choose Your Platform

### 🪟 Windows

```powershell
# 1. Clone the repository
git clone https://github.com/dianedef/dotfiles.git $HOME/dotfiles

# 2. Run installation (as administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
$HOME/dotfiles/windows.ps1
```

### 🐧 Linux / GitHub Codespaces

```bash
# 1. Clone the repository
git clone https://github.com/dianedef/dotfiles.git ~/dotfiles

# 2. Run installation
cd ~/dotfiles
chmod +x install.sh
./install.sh

# 3. Activate shell integration
source ~/.bashrc
```

### 📱 Termux (Android)

```bash
# 1. Clone the repository
git clone https://github.com/dianedef/dotfiles.git ~/dotfiles

# 2. Run lightweight installation
cd ~/dotfiles
chmod +x termux.sh
./termux.sh

# 3. Restart shell or reload
source ~/.bashrc
```

## What Gets Installed?

### All Platforms
- ✅ **Neovim** - Modern code editor
- ✅ **Starship** - Beautiful shell prompt
- ✅ **Zoxide** - Smart cd replacement
- ✅ **FZF** - Fuzzy file finder
- ✅ **Ripgrep** - Fast text search

### Windows & Linux (Full Install)
- ✅ **Yazi** - Terminal file manager
- ✅ **GitHub Copilot** - AI coding assistant
- ✅ **LSP Servers** - Language support

### Termux (Lightweight)
- ✅ Core tools only (limited resources)
- ❌ No Copilot (too heavy for mobile)
- ❌ Minimal LSP servers

## First Steps After Installation

### 1. Test Neovim
```bash
nvim
```
Press `:checkhealth` to verify installation.

### 2. Test Starship Prompt
Your prompt should now show:
- Current directory with icons
- Git branch and status
- Language versions (if in project)

### 3. Test Yazi (Windows/Linux only)
```bash
yazi
```
Navigate with arrow keys, press `q` to quit.

### 4. Test Quick Navigation
```bash
# Zoxide will learn your directories
cd ~/dotfiles
z dot      # Should jump to ~/dotfiles
```

## Common First-Time Issues

### Issue: "Neovim won't start"
**Solution**: Check Node.js is installed
```bash
node --version  # Should be v20+
```

### Issue: "Starship prompt not showing"
**Solution**: Restart your shell
```bash
source ~/.bashrc  # Linux/Termux
# Or restart terminal on Windows
```

### Issue: "Yazi shows squares/broken icons"
**Solution**: Install a Nerd Font
- Windows: Install "CascadiaCode Nerd Font"
- Linux: Font is auto-installed
- Termux: Use Termux:Styling app

## Next Steps

1. 📖 Read the [full installation guide](../installation) for your platform
2. ⚙️ Customize [Neovim](../configuration/NEOVIM.md) or [Starship](../configuration/STARSHIP.md)
3. 📚 Learn [daily workflows](../workflows/DAILY-USE.md)
4. 🤖 Explore [BMAD Method](../workflows/BMAD-USAGE.md) for AI-assisted development

## Need Help?

- [Common Issues](../troubleshooting/COMMON-ISSUES.md)
- [Platform-Specific Issues](../troubleshooting/PLATFORM-SPECIFIC.md)
- [FAQ](../troubleshooting/FAQ.md)

---

**Installation successful?** Star the repo ⭐ and start coding!
