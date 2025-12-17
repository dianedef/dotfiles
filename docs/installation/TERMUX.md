# Termux/Android Installation Guide

Complete guide to install dotfiles on Android using Termux.

## 📱 Prerequisites

1. **Termux** installed from F-Droid (NOT Google Play)
   - Download: https://f-droid.org/packages/com.termux/
2. **Internet connection** for package downloads
3. **~500MB storage** (basic install) or **~1GB** (with OpenCode)

## 🚀 Quick Installation

```bash
# Update Termux packages
pkg update -y && pkg upgrade -y

# Clone dotfiles
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles

# Run lightweight installation
cd ~/dotfiles
chmod +x termux.sh
./termux.sh

# Apply changes
source ~/.bashrc
```

**⚠️ Important**: Restart Termux completely after installation to apply Nerd Font.

## 🔐 Automated Authentication (Optional)

The script supports automated authentication via **Doppler** secrets management.

### Setup Doppler Authentication

#### 1. Install Doppler in Termux

```bash
pkg install curl
curl -sS https://cli.doppler.com/install.sh | sh
```

#### 2. Login to Doppler

```bash
doppler login
```

#### 3. Setup Project

```bash
cd ~/dotfiles
doppler setup --project dotfiles --config dev
```

#### 4. Add API Keys

Create tokens at:
- **GitHub Token**: https://github.com/settings/tokens (scopes: `repo`, `read:org`, `gist`)
- **OpenAI**: https://platform.openai.com/api-keys
- **Anthropic**: https://console.anthropic.com/settings/keys
- **Google Gemini**: https://aistudio.google.com/apikey
- **Groq**: https://console.groq.com/keys

```bash
# Add secrets to Doppler
doppler secrets set GH_TOKEN="ghp_your_github_token"
doppler secrets set OPENAI_API_KEY="sk-..."
doppler secrets set ANTHROPIC_API_KEY="sk-ant-..."
doppler secrets set GEMINI_AI="your_gemini_key"
doppler secrets set GROQ="your_groq_key"
doppler secrets set OPENCODE_API_KEY="your_opencode_key"
```

#### 5. Re-run Installation

```bash
cd ~/dotfiles
./termux.sh
```

The script will now automatically:
- ✅ Authenticate GitHub CLI
- ✅ Configure OpenCode with your API key
- ✅ Setup all AI providers (OpenAI, Claude, Gemini, Groq)

## 📦 What Gets Installed

### Core Tools
- **Neovim** (v0.11+) - Lightweight config (MyNeovimTermux)
- **Starship** - Shell prompt with git integration
- **Zoxide** - Smart `cd` replacement
- **FZF** - Fuzzy finder
- **Ripgrep** - Fast text search
- **Ranger** - File manager (primary for Termux)

### Optional AI Tools
- **OpenCode** - AI coding assistant (runs in Alpine proot)
  - Requires ~500MB additional space
  - Supports: OpenAI, Claude, Gemini, Groq

### What's NOT Included (Termux Limitations)
- ❌ GitHub Copilot (requires Node.js features not available)
- ❌ Heavy LSP servers (use minimal configs)
- ❌ Yazi (compatibility issues, use Ranger instead)

## 🎨 Nerd Font Installation

The script automatically installs **JetBrainsMono Nerd Font** to `~/.termux/font.ttf`.

**To apply the font:**
1. Completely close Termux (swipe away from recent apps)
2. Reopen Termux
3. Icons should now display correctly in Neovim, Starship, and file managers

**Alternative**: Use "Termux:Styling" app from F-Droid.

## 🐧 Alpine Linux (for OpenCode)

OpenCode runs in an **Alpine Linux** environment via `proot-distro`:

### What is proot-distro?
- Lightweight Linux containerization for Termux
- No root required
- Isolated environment for apps that need full Linux

### Access Alpine

```bash
# Enter Alpine environment
proot-distro login alpine

# Run OpenCode
cd /root/opencode_termux_alpine_aarch64
./opencode-termux-wrapper.sh

# Exit Alpine
exit
```

### Use OpenCode from Termux (no manual login)

```bash
# Quick access via alias
ao

# Or from Neovim
# Press <leader>ao in normal mode
```

## ⚙️ Configuration

### Neovim Configuration
- Located: `~/.config/nvim` → symlink to `~/dotfiles/nvim/MyNeovimTermux`
- Lightweight: No Copilot, essential plugins only
- LSP: Basic support (avoid heavy servers)

### Starship Prompt
- Config: `~/.config/starship.toml`
- Shows: Git status, language versions, battery, time

### Shell Integration
All tools integrate via `~/.bashrc`:
- Starship prompt
- Zoxide (`z` command)
- FZF keybindings (`Ctrl+R`, `Ctrl+T`)
- Custom aliases

## 🔑 Keybindings

### Neovim AI Agents
| Keymap | Description |
|--------|-------------|
| `<leader>ai` | Open Aider (AI pair programmer) |
| `<leader>ao` | Open OpenCode (Alpine) |
| `<leader>oa` | Ask OpenCode (inline) |
| `<leader>ox` | Execute OpenCode action |
| `<leader>ot` | Toggle OpenCode panel |

### Terminal
| Command | Description |
|---------|-------------|
| `z <dir>` | Jump to directory (zoxide) |
| `Ctrl+R` | Search command history (fzf) |
| `r` | Launch Ranger file manager |
| `ao` | Launch OpenCode in Alpine |

## 🔧 Post-Installation

### Verify Installation

```bash
# Check versions
nvim --version
starship --version
zoxide --version
gh auth status  # (if Doppler configured)

# Test Neovim
nvim
```

### Customize Configuration

```bash
# Edit Neovim config
nvim ~/.config/nvim/lua/config/options.lua

# Edit Starship prompt
nvim ~/.config/starship.toml

# Edit bash aliases
nvim ~/dotfiles/nvim/aliases.sh
```

## 🐛 Troubleshooting

### Font Icons Not Showing
**Solution**: Completely restart Termux app (don't just exit shell)

### Starship Not Loading
```bash
# Check if in bashrc
grep starship ~/.bashrc

# Re-source
source ~/.bashrc
```

### GitHub Auth Failed
```bash
# Manual authentication
gh auth login

# Or check Doppler token
doppler secrets get GH_TOKEN
```

### OpenCode Installation Failed
```bash
# Check Alpine installation
proot-distro list

# Reinstall Alpine
proot-distro remove alpine
proot-distro install alpine

# Re-run script
cd ~/dotfiles && ./termux.sh
```

### Neovim Plugins Not Loading
```bash
# Open Neovim
nvim

# In Neovim, run:
:Lazy sync
:Mason
```

## 📊 Storage Usage

- **Basic Install**: ~200MB
- **With OpenCode**: ~700MB
- **With full plugin cache**: ~1GB

To reduce space:
- Skip OpenCode installation when prompted
- Use `:Lazy clean` in Neovim to remove unused plugins

## 🔄 Updates

```bash
# Update dotfiles
cd ~/dotfiles
git pull

# Re-run installation (safe, won't duplicate)
./termux.sh
source ~/.bashrc

# Update Termux packages
pkg update && pkg upgrade
```

## 🔗 Related Documentation

- [Neovim Configuration](../configuration/NEOVIM.md)
- [AI CLI Tools Setup](../configuration/AI-CLI-TOOLS.md)
- [Doppler Secrets Management](../configuration/DOPPLER.md)
- [Troubleshooting](../troubleshooting/TERMUX-ISSUES.md)

## 💡 Tips

1. **Battery Optimization**: Termux may be killed by Android. Use `termux-wake-lock` to keep it alive during long tasks.
2. **Storage Access**: Run `termux-setup-storage` to access Android files.
3. **SSH to Codespaces**: Use `ssh` to connect to GitHub Codespaces for full development environment.
4. **Keyboard**: Install "Hacker's Keyboard" from F-Droid for better terminal experience.

---

*Last Updated: December 2024*
