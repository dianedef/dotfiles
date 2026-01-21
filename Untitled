# Quick Reference - Dotfiles

## 🚀 First Time Setup (Codespaces)

```bash
# 1. First run happens automatically (skip auth - normal!)

# 2. Setup Doppler (one command does everything)
ds

# 3. Re-run installation
cd ~/dotfiles && ./install.sh

# ✅ Done! Everything auto-authenticates
```

## 📝 Useful Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ds` | `doppler-setup.sh` | Configure all API keys |
| `i` | `install.sh` / `windows.ps1` | Re-run installation |
| `r` | `ranger` | File manager (Termux) |
| `y` | `yazi` | File manager (Linux/Windows) |
| `z <dir>` | `zoxide` | Smart directory jump |
| `ao` | OpenCode Alpine | AI coding (Termux) |

## 🔑 API Keys Setup

Run `ds` and it will prompt for:

| Service | URL | Purpose |
|---------|-----|---------|
| **GitHub** | [github.com/settings/tokens](https://github.com/settings/tokens) | CLI auth |
| **OpenAI** | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) | GPT models |
| **Anthropic** | [console.anthropic.com/settings/keys](https://console.anthropic.com/settings/keys) | Claude |
| **Gemini** | [aistudio.google.com/apikey](https://aistudio.google.com/apikey) | Google AI |
| **Groq** | [console.groq.com/keys](https://console.groq.com/keys) | Fast inference |

### GitHub Token Scopes Required:
- ✅ `repo` - Repository access
- ✅ `read:org` - Organization membership
- ✅ `gist` - Create gists

## ⌨️ Neovim OpenCode Keybindings

| Key | Action |
|-----|--------|
| `<leader>oa` | Ask OpenCode |
| `<leader>ox` | Execute action |
| `<leader>op` | Add to prompt |
| `<leader>ot` | Toggle panel |
| `<leader>ao` | Terminal OpenCode (Termux) |

## 🔄 Update Dotfiles

```bash
cd ~/dotfiles
git pull
./install.sh  # Linux/Codespaces
.\windows.ps1  # Windows
./termux.sh    # Termux
```

## 🐛 Troubleshooting

### GitHub Auth Failed
```bash
# Check Doppler
doppler secrets get GH_TOKEN

# Manual auth
gh auth login
```

### Doppler Not Working
```bash
# Re-login
doppler login
ds

# Verify
doppler me
doppler secrets
```

### Neovim Plugins Not Loading
```bash
nvim
:Lazy sync
:Mason
```

## 📚 Full Documentation

- [Installation Guides](docs/installation/)
- [Configuration](docs/configuration/)
- [Troubleshooting](docs/troubleshooting/)
- [Complete Index](docs/INDEX.md)

## 💡 Quick Tips

1. **Termux Font**: Full restart required after installation
2. **Codespaces**: First run always skips auth (expected)
3. **Doppler Sync**: Secrets sync automatically across devices
4. **Token Rotation**: Update with `ds` anytime

---

*Keep this file handy - it has everything you need!*
