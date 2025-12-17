# MyNeovim for Termux

Configuration Neovim optimisée pour Android/Termux avec intégration d'agents IA.

## 🚀 AI Coding Agents Installés

### 1. **Aider** (Recommandé - Léger)
Agent de code IA le plus simple pour Termux.

**Installation:**
```bash
pip install aider-chat
```

**Utilisation:**
```bash
# Avec OpenAI
export OPENAI_API_KEY="your-key"
aider

# Avec Anthropic Claude
export ANTHROPIC_API_KEY="your-key"
aider --model claude-3-5-sonnet-20241022

# Mode local avec Ollama
aider --model ollama/codellama
```

**Configuration Neovim:**
- Commande `:Aider` pour ouvrir dans terminal
- `<leader>ai` pour démarrer Aider

---

### 2. **Codex-Termux** (Léger ARM64)
Agent de code optimisé pour Termux.

**Installation:**
```bash
cd ~
git clone https://github.com/nasarman/codex-termux.git
cd codex-termux
pip install -r requirements.txt
```

**Utilisation:**
```bash
cd codex-termux
python codex.py
```

---

### 3. **OpenCode Termux (Alpine proot)**
Version complète d'OpenCode pour mobile.

**Installation:**
```bash
# Installer proot-distro Alpine
pkg install proot-distro
proot-distro install alpine

# Entrer dans Alpine
proot-distro login alpine

# Dans Alpine, installer OpenCode fork
apk add git nodejs npm
git clone https://github.com/Charlie6F/opencode_termux_alpine_aarch64.git
cd opencode_termux_alpine_aarch64
./install.sh
```

**Utilisation:**
```bash
proot-distro login alpine
cd opencode_termux_alpine_aarch64
./opencode-termux-wrapper.sh
```

---

### 4. **Sheikh CLI Assistant** (100% Local)
Agent IA offline pour Termux.

**Installation:**
```bash
pip install sheikh-cli-assistant
```

**Utilisation:**
```bash
sheikh init  # Configuration initiale
sheikh       # Mode interactif
sheikh "explain this code" file.py
```

**Features:**
- ✅ Fonctionne 100% offline
- ✅ Intégration llama.cpp possible
- ✅ Analyse de code naturelle
- ✅ File operations

---

## 🔧 Configuration Neovim

### Plugins ajoutés pour Termux:

```lua
-- lua/plugins/ai-agents.lua
return {
  -- Aider integration
  {
    "vim-test/vim-test",
    optional = true,
    config = function()
      vim.g["test#strategy"] = "neovim"
    end,
  },
}
```

### Keybindings:

| Key | Action |
|-----|--------|
| `<leader>ai` | Ouvrir Aider |
| `<leader>ax` | Ouvrir Codex |
| `<leader>as` | Sheikh assistant |
| `<leader>ao` | OpenCode (Alpine) |

---

## 📦 Installation Rapide (Script Automatique)

Le script `termux.sh` installe automatiquement:
1. ✅ MyNeovimTermux config
2. ✅ Aider (pip)
3. ✅ Codex-Termux (git clone)
4. ⚠️ OpenCode optionnel (nécessite proot Alpine)
5. ✅ Sheikh CLI Assistant

---

## 🎯 Recommandations Termux

### Agents IA par ordre de légèreté:
1. **Aider** ⭐ (plus simple, API cloud)
2. **Codex-Termux** (léger, ARM64 natif)
3. **Sheikh** (100% local, mais consomme RAM)
4. **OpenCode** (complet mais lourd, Alpine requis)

### Modèles recommandés:
- Claude 3.5 Sonnet (via API)
- GPT-4 (via API)
- Codellama 7B (Ollama local - 4GB+ RAM)
- Deepseek Coder (Ollama local)

---

## ⚠️ Limitations Termux

- **RAM**: 4GB+ recommandé pour modèles locaux
- **Stockage**: 2GB+ pour OpenCode + modèles
- **CPU**: Performance mobile limitée
- **Réseau**: Agents API nécessitent connexion stable

---

## 🆘 Troubleshooting

### Aider ne trouve pas l'API key:
```bash
echo 'export OPENAI_API_KEY="sk-..."' >> ~/.bashrc
source ~/.bashrc
```

### Erreur pip install:
```bash
pkg update
pkg upgrade
pkg install python python-pip binutils
pip install --upgrade pip
```

### OpenCode ne démarre pas:
```bash
# Vérifier Alpine
proot-distro list
proot-distro login alpine

# Dans Alpine, vérifier Node.js
node --version
npm --version
```

---

## 📚 Ressources

- [Aider Docs](https://aider.chat/docs/)
- [Codex-Termux GitHub](https://github.com/nasarman/codex-termux)
- [OpenCode Termux Fork](https://github.com/Charlie6F/opencode_termux_alpine_aarch64)
- [Sheikh CLI](https://pypi.org/project/sheikh-cli-assistant/)
- [Termux Wiki](https://wiki.termux.com/)
