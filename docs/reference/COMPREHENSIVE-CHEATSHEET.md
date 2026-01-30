# 🚀 Comprehensive Cheatsheet - Dotfiles BMAD
*Generated on: 2024-12-18 | Last update: AUTO*

## 📋 Quick Access
- 🔍 **Fuzzy search**: `docs` → Interactive file finder
- ⚡ **Quick cheat**: `cheat` → Full cheatsheet
- 🎯 **Tool-specific**: `cheat-[tool]` → Tool-specific shortcuts

---

## 🔄 1. Codespaces Management (NEW!)
### Current Codespace
| Command | Alias | Description |
|---------|-------|-------------|
| `gh codespace edit -c $CODESPACE_NAME -d "name"` | `csrename "name"` | Rename current codespace |
| `gh codespace stop -c $CODESPACE_NAME` | `csstop` | Stop current codespace |
| `gh codespace view -c $CODESPACE_NAME` | `csinfo` | Show codespace details |
| `gh codespace delete -c $CODESPACE_NAME` | `csdelete` | Delete current codespace |

### Any Repository
| Command | Alias | Description |
|---------|-------|-------------|
| `gh codespace create -r OWNER/REPO` | `cscreate-repo OWNER/REPO` | Create for any repo |
| `gh codespace create -r OWNER/REPO -b BRANCH` | `cscreate-branch OWNER REPO BRANCH` | With specific branch |
| `gh codespace create -r OWNER/REPO -m MACHINE` | `cscreate-machine OWNER REPO MACHINE` | With custom machine |

### Quick URL Creation
| Command | Alias | Description |
|---------|-------|-------------|
| `echo "https://codespaces.new/" && read repo` | `csurl` | Interactive repo creation |

### Examples
```bash
# Create for React
cscreate-repo facebook/react main

# Create with custom machine
cscreate-branch microsoft/vscode main standardLinux32gb  

# Rename current codespace
csrename "my-awesome-project"

# Open creation URL
csurl
```

---

## 🐚 2. Shell Aliases (Navigation & System)
| Alias | Command | Platform | Description |
|-------|---------|----------|-------------|
| `r` | `ranger` | Termux | File manager |
| `y` | `yazi` | Linux/Win | Modern file manager |
| `z <dir>` | `zoxide` | All | Smart directory jump |
| `re` | `source ~/.bashrc` | All | Reload shell config |
| `reload` | `source ~/.bashrc` | All | Reload shell config |
| `cls` | `clear` | All | Clear terminal |
| `h` | `history` | All | Command history |

### Directory Navigation
| Alias | Action |
|-------|--------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |

### Enhanced Commands
| Alias | Command | Description |
|-------|---------|-------------|
| `cat` | `bat --paging=never` | Better cat (if bat installed) |
| `ls` | `lsd` | Better ls (if lsd installed) |
| `ll` | `lsd -lh` | Long format |
| `la` | `lsd -lAh` | All files with details |
| `lt` | `lsd --tree --depth 2` | Tree view |

---

## 📝 3. Neovim Configuration
### Config Switching
| Command | Description |
|---------|-------------|
| `nvim-switch` | Interactive config selector |
| `nv-switch` | Quick switch version |
| `nv/nv3/nv6/nv11/nv22` | Launch specific config |
| `nv-list` | List available configs |
| `nv-current` | Show current config |

### OpenCode Integration
| Key | Action |
|-----|--------|
| `<leader>oa` | Ask OpenCode |
| `<leader>ox` | Execute action |
| `<leader>op` | Add to prompt |
| `<leader>ot` | Toggle panel |
| `<leader>ao` | Terminal OpenCode (Termux) |

---

## 🗂️ 4. File Managers
### Yazi (Modern)
| Key | Action |
|-----|--------|
| `u/e` | Page up/down (vim-style) |
| `U/E` | Jump 5 lines |
| `w` | Open shell |
| `q` | Quit |

### LazyGit
| Key | Action |
|-----|--------|
| `u/e/n/i` | Navigate (vim-style) |
| `v` | Checkout GitHub PR |
| `q` | Quit |

### Ranger
| Key | Action |
|-----|--------|
| `gF` | Fetch all git repos (parallel) |
| `zV` | Toggle VCS display on/off |
| `zh` | Toggle hidden files |
| `R` | Reload directory |

#### Ranger VCS Status Icons (Git)
| Icône | Signification |
|-------|---------------|
| `✓` | Repo propre (clean) |
| `+` | Fichiers stagés |
| `=` | Fichiers modifiés |
| `?` | Fichiers untracked |
| `>` | Ahead (commits à push) |
| `<` | Behind (commits à pull) |
| `⌂` | Repo avec stash |

---

## ⌨️ 5. Tool-Specific Hotkeys
### Cursor IDE
| Key | Action |
|-----|--------|
| `Alt+Q` | Toggle sidebar |
| `Alt+F` | Find |
| `Ctrl+Q` | Show commands |
| `Alt+X` | Fold code |

### MPV Media Player
| Key | Action |
|-----|--------|
| `u/e/i/n` | Navigation (vim-style) |
| `[/]` | Speed control |
| `Ctrl+1/2` | Anime4K presets |

### Rio Terminal
| Key | Action |
|-----|--------|
| `Alt+1/2/3` | Switch workspaces |
| `Ctrl+Shift+C` | Copy |
| `Ctrl+Shift+V` | Paste |

---

## 🔧 6. Development Workflow
### Git Aliases
| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Repository status |
| `ga` | `git add .` | Stage all changes |
| `gc` | `git commit -m` | Commit with message |
| `gf` | `git fetch` | Fetch updates |
| `gp` | `git push` | Push to remote |
| `gl` | `git pull` | Pull changes |
| `gd` | `git diff` | Show differences |
| `gr` | `git restore` | Restore file(s) |
| `glog` | `git log --oneline --graph` | Visual log |

### AI Coding Tools
| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kilocode` | Kilocode CLI |
| `o` | `opencode` | OpenCode AI |
| `c` | `claude` | Claude Code |

### SSH/Mosh Connections
| Alias | Command | Description |
|-------|---------|-------------|
| `root` | `mosh root@hetzner` | SSH as root + tmux |
| `cuser` | `mosh claude@hetzner` | SSH as claude + tmux |

### API Keys & Setup
| Command | Description |
|---------|-------------|
| `ds` | Doppler setup (all API keys) |
| `i` | Re-run installation script |

### Trash Commands
| Alias | Command | Description |
|-------|---------|-------------|
| `tp` | `trash-put` | Move to trash |
| `tl` | `trash-list` | List trash |
| `tr` | `trash-restore` | Restore from trash |
| `te` | `trash-empty` | Empty trash |

---

## 🎯 7. BMAD Agents Workflow
| Agent | Usage | Description |
|-------|---------|-------------|
| `@bmd-custom-core-bmad-master *workflow-init` | Project analysis | Initialize BMAD workflow |
| `@bmd-custom-bmm-quick-flow-solo-dev *workflow-quick-flow` | Quick changes | Fast development |
| `@bmd-custom-bmm-pm *workflow-planning-prd` | Features | Feature planning |
| `@bmd-custom-bmm-tech-writer *workflow-documentation` | Documentation | Write/update docs |
| `@bmd-custom-bmm-dev *workflow-development` | Development | Code implementation |

---

## 💡 8. Quick Tips & Workflows
### Daily Operations
```bash
# Start working session
cd ~/dotfiles
cslist  # Check codespaces
y       # Open file manager
nvim    # Open editor

# Update everything
cd ~/dotfiles && git pull && ./install.sh

# Quick troubleshooting
cheat   # Open this cheatsheet
docs    # Search documentation
dotfind # Find any dotfile
```

### Code Workflow
```bash
# New project setup
cscreate-repo OWNER/REPO main
csrename "project-name"
cd /workspaces
y       # Navigate to project
nvim    # Start coding

# Git workflow
gs      # Check status
ga      # Stage all
gc "feat: add new feature"  # Commit
gp      # Push
```

### Platform-Specific Notes
- **Termux**: `r` for ranger, restart after font install
- **Codespaces**: `csrename` works immediately, `csstop` to save credits
- **Windows**: PowerShell aliases in `windows.ps1`
- **Linux**: Full feature set available

---

## 🔄 9. Maintenance Commands
### Update Dotfiles
```bash
cd ~/dotfiles
git pull
./install.sh      # Linux/Codespaces
./windows.ps1      # Windows  
./termux.sh        # Termux
```

### Documentation
```bash
cheat      # Full cheatsheet (this file)
docs       # Fuzzy find in docs
dotfind    # Find any dotfile
cheats     # Search in aliases
```

### Tool-Specific Cheats
```bash
cheat-nvim    # Neovim configuration
cheat-git     # Git aliases only
cheat-codespace # Codespace commands only
```

### Starship Customization
```bash
# Test starship configuration
starship module custom.codespace

# Reload starship
eval "$(starship init bash)"
```

---

## 🔍 10. Troubleshooting Quick Reference
### Common Issues
| Problem | Solution |
|---------|----------|
| GitHub auth failed | `doppler secrets get GH_TOKEN` then `gh auth login` |
| Doppler not working | `doppler login` and `ds` |
| Neovim plugins missing | `nvim :Lazy sync` |
| Starship not updating | `eval "$(starship init bash)"` |

### Environment Variables
| Variable | Where Available | Description |
|----------|-----------------|-------------|
| `CODESPACES` | Codespaces only | Always `true` in codespaces |
| `CODESPACE_NAME` | Codespaces only | Permanent name identifier |
| `GH_TOKEN` | All platforms | GitHub authentication token |

---

## 📊 Statistics
- **Total aliases**: 30+
- **Hotkey mappings**: 20+ 
- **Tools covered**: 10+
- **Platforms**: Linux, Windows, Termux, Codespaces
- **Documentation files**: 15+

---

*Last auto-update: $(date)*
*Total aliases: 30+ | Hotkeys: 20+ | Tools: 10+*

---

## 🔗 Related Documentation
- [Quick Start Guide](installation/QUICK-START.md)
- [Neovim Configuration](configuration/NEOVIM.md)
- [AI CLI Tools](configuration/AI-CLI-TOOLS.md)
- [Daily Workflows](workflows/DAILY-USE.md)
- [BMAD Usage](workflows/BMAD-USAGE.md)