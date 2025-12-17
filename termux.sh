#!/data/data/com.termux/files/usr/bin/bash

# Script d'installation ALLÉGÉ pour Termux (Android)
# Version minimaliste - pas de copilot, neovim léger, outils essentiels seulement

## Configuration logging
LOG_FILE="$PWD/termux-install.log"
touch "$LOG_FILE"

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    [ "$level" = "INFO" ] || [ "$level" = "ERROR" ] && echo "$message"
}

log "INFO" "🤖 Starting TERMUX dotfiles installation (lightweight)"

# --- 1. Packages Termux essentiels ---
log "INFO" "📦 Installing Termux packages..."
pkg update -y >/dev/null 2>&1
pkg install -y \
  git \
  curl \
  wget \
  neovim \
  ripgrep \
  fd \
  fzf \
  python \
  nodejs-lts \
  ranger \
  tree \
  termux-api >/dev/null 2>&1

log "INFO" "✅ Termux packages installed"

# Vérifier Neovim
if command -v nvim &> /dev/null; then
    log "INFO" "✅ Neovim: $(nvim --version | head -n 1)"
else
    log "ERROR" "❌ Neovim installation failed"
    exit 1
fi

# --- 2. Nerd Fonts pour Termux ---
log "INFO" "📝 Installing Nerd Fonts for Termux..."

# Termux utilise un système de fonts différent
FONT_DIR="$HOME/.termux"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/font.ttf" ]; then
    log "INFO" "Downloading JetBrainsMono Nerd Font..."
    cd /tmp
    
    # Télécharger JetBrainsMono Nerd Font (version complète avec icônes)
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    curl -sLO "$FONT_URL"
    
    if [ -f JetBrainsMono.zip ]; then
        unzip -q JetBrainsMono.zip 2>/dev/null
        
        # Utiliser la version Regular pour Termux
        if [ -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
            cp "JetBrainsMonoNerdFont-Regular.ttf" "$FONT_DIR/font.ttf"
            log "INFO" "✅ Nerd Font installed to ~/.termux/font.ttf"
            log "INFO" "⚠️  You need to restart Termux to apply the new font!"
        else
            log "WARN" "⚠️  Font file not found in archive"
        fi
        
        rm -rf JetBrainsMono* *.ttf *.otf 2>/dev/null
    else
        log "WARN" "⚠️  Failed to download Nerd Fonts"
    fi
    
    cd - > /dev/null
else
    log "INFO" "✅ Nerd Font already configured in ~/.termux/font.ttf"
fi

# --- 3. Outils légers uniquement ---
log "INFO" "📦 Installing lightweight tools..."

# Create bin directories first
mkdir -p "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/tmp"

# Starship (prompt)
if ! command -v starship &> /dev/null; then
    log "INFO" "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$HOME/.local/bin"
    if [ $? -eq 0 ] && [ -f "$HOME/.local/bin/starship" ]; then
        log "INFO" "✅ Starship installed to ~/.local/bin"
    else
        log "ERROR" "❌ Starship installation failed"
    fi
else
    log "INFO" "✅ Starship already installed"
fi

# Zoxide (smart cd) - use HOME/tmp instead of /tmp for Termux
if ! command -v zoxide &> /dev/null; then
    log "INFO" "Installing Zoxide..."
    log "INFO" "Detected architecture: $(uname -m)"
    export TMPDIR="$HOME/tmp"
    mkdir -p "$TMPDIR"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    if [ $? -eq 0 ] && [ -f "$HOME/.local/bin/zoxide" ]; then
        log "INFO" "✅ Zoxide installed to ~/.local/bin"
    else
        log "ERROR" "❌ Zoxide installation failed"
    fi
else
    log "INFO" "✅ Zoxide already installed"
fi

# File manager - Use Ranger (already installed via pkg)
# Yazi has compatibility issues on Termux/Android
if command -v ranger &> /dev/null; then
    log "INFO" "✅ Ranger file manager installed (use 'ranger' command)"
else
    log "WARN" "⚠️  Ranger not found, install with: pkg install ranger"
fi

# --- 4. Configuration Neovim (MyNeovimTermux) ---
log "INFO" "⚙️ Setting up Neovim (MyNeovimTermux config)..."

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Backup existing config
if [ -d "$NVIM_CONFIG_DIR" ]; then
    log "INFO" "Backing up existing config..."
    mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%s)"
fi

# --- 5. Symlinks ---
log "INFO" "🔗 Creating symlinks..."

create_symlink() {
    local SOURCE=$1
    local TARGET=$2
    
    [ ! -e "$SOURCE" ] && { log "WARN" "⚠️  $SOURCE not found"; return; }
    [ -e "$TARGET" ] || [ -L "$TARGET" ] && rm -rf "$TARGET"
    
    mkdir -p "$(dirname "$TARGET")"
    ln -s "$SOURCE" "$TARGET"
    log "INFO" "Linked: $TARGET -> $SOURCE"
}

# Neovim config - Use MyNeovimTermux
if [ -d "$SOURCE_DIR/nvim/MyNeovimTermux" ] && [ -f "$SOURCE_DIR/nvim/MyNeovimTermux/init.lua" ]; then
    create_symlink "$SOURCE_DIR/nvim/MyNeovimTermux" "$NVIM_CONFIG_DIR"
elif [ -d "$SOURCE_DIR/nvim/MyNeovim" ] && [ -f "$SOURCE_DIR/nvim/MyNeovim/init.lua" ]; then
    # Fallback to MyNeovim if MyNeovimTermux not found
    create_symlink "$SOURCE_DIR/nvim/MyNeovim" "$NVIM_CONFIG_DIR"
elif [ -d "$SOURCE_DIR/nvim" ] && [ -f "$SOURCE_DIR/nvim/init.lua" ]; then
    # Fallback to nvim root
    create_symlink "$SOURCE_DIR/nvim" "$NVIM_CONFIG_DIR"
fi

# Ranger (primary file manager for Termux)
[ -d "$SOURCE_DIR/ranger" ] && create_symlink "$SOURCE_DIR/ranger" "$HOME/.config/ranger"

# Starship (utilise la version simplifiée)
if [ -f "$SOURCE_DIR/starship/starship-simple.toml" ]; then
    create_symlink "$SOURCE_DIR/starship/starship-simple.toml" "$HOME/.config/starship.toml"
    log "INFO" "✅ Using simplified Starship config"
elif [ -f "$SOURCE_DIR/starship/starship.toml" ]; then
    create_symlink "$SOURCE_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# --- 6. Shell integration ---
log "INFO" "🔧 Setting up shell integration..."

# Make scripts executable
for script in "switch-config.sh" "nvim-multi" "aliases.sh" "shell-integration.sh"; do
    [ -f "$SOURCE_DIR/nvim/$script" ] && chmod +x "$SOURCE_DIR/nvim/$script"
done

# Ajouter à ~/.bashrc
BASHRC="$HOME/.bashrc"
touch "$BASHRC"

# Shell integration
if ! grep -q "shell-integration.sh" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# Neovim config switcher" >> "$BASHRC"
    echo "source $SOURCE_DIR/nvim/shell-integration.sh" >> "$BASHRC"
    log "INFO" "✅ Added shell integration"
fi

# Add cargo/local bin to PATH for Starship/Zoxide
if ! grep -q "\.cargo/bin" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# Cargo and local binaries' >> "$BASHRC"
    echo 'export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"' >> "$BASHRC"
    log "INFO" "✅ Added cargo/local bin to PATH"
fi

# Starship (check PATH after adding it above)
if ! grep -q "starship init" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# Starship prompt' >> "$BASHRC"
    echo 'eval "$(starship init bash)"' >> "$BASHRC"
    log "INFO" "✅ Added Starship to bashrc"
fi

# Zoxide (check PATH after adding it above)
if ! grep -q "zoxide init" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# Zoxide' >> "$BASHRC"
    echo 'eval "$(zoxide init bash)"' >> "$BASHRC"
    log "INFO" "✅ Added Zoxide to bashrc"
fi

# Aliases essentiels
if ! grep -q "# Termux aliases" "$BASHRC"; then
    cat >> "$BASHRC" << 'EOF'

# Termux aliases
alias reload='source ~/.bashrc'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

# Git shortcuts
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# Termux specific
alias termux-wake='termux-wake-lock'
alias termux-sleep='termux-wake-unlock'
alias storage='cd ~/storage/shared'
alias dl='cd ~/storage/downloads'

# File managers
alias r='ranger'

EOF
    log "INFO" "✅ Added Termux aliases"
fi

# --- 7. AI Coding Agents Installation ---
log "INFO" "🤖 Installing AI coding agents..."

# Aider (Recommandé - léger)
if ! command -v aider &> /dev/null; then
    log "INFO" "Installing Aider..."
    pip install aider-chat >/dev/null 2>&1
    if command -v aider &> /dev/null; then
        log "INFO" "✅ Aider installed"
    else
        log "WARN" "⚠️  Aider installation failed (pip issue)"
    fi
else
    log "INFO" "✅ Aider already installed"
fi

# Codex-Termux (Léger ARM64)
if [ ! -d "$HOME/codex-termux" ]; then
    log "INFO" "Installing Codex-Termux..."
    cd ~
    git clone --quiet https://github.com/nasarman/codex-termux.git 2>/dev/null
    if [ -d "$HOME/codex-termux" ]; then
        cd codex-termux
        pip install -r requirements.txt >/dev/null 2>&1
        log "INFO" "✅ Codex-Termux installed to ~/codex-termux"
    else
        log "WARN" "⚠️  Codex-Termux installation failed"
    fi
    cd - > /dev/null
else
    log "INFO" "✅ Codex-Termux already installed"
fi

# Sheikh CLI Assistant (100% local)
if ! command -v sheikh &> /dev/null; then
    log "INFO" "Installing Sheikh CLI Assistant..."
    pip install sheikh-cli-assistant >/dev/null 2>&1
    if command -v sheikh &> /dev/null; then
        log "INFO" "✅ Sheikh CLI installed"
    else
        log "WARN" "⚠️  Sheikh installation failed (pip issue)"
    fi
else
    log "INFO" "✅ Sheikh CLI already installed"
fi

# OpenCode (Optionnel - nécessite proot Alpine)
read -p "🗂️  Install OpenCode in proot Alpine? (requires 500MB+) (y/N): " INSTALL_OPENCODE
if [ "$INSTALL_OPENCODE" = "y" ] || [ "$INSTALL_OPENCODE" = "Y" ]; then
    if ! command -v proot-distro &> /dev/null; then
        log "INFO" "Installing proot-distro..."
        pkg install -y proot-distro >/dev/null 2>&1
    fi
    
    if command -v proot-distro &> /dev/null; then
        log "INFO" "Setting up Alpine Linux..."
        proot-distro install alpine 2>/dev/null
        
        log "INFO" "Installing OpenCode in Alpine (this may take a while)..."
        proot-distro login alpine -- /bin/sh -c "
            apk add git nodejs npm >/dev/null 2>&1
            cd /root
            git clone --quiet https://github.com/Charlie6F/opencode_termux_alpine_aarch64.git 2>/dev/null
            cd opencode_termux_alpine_aarch64
            chmod +x install.sh opencode-termux-wrapper.sh
            ./install.sh
        " 2>/dev/null
        
        if [ $? -eq 0 ]; then
            log "INFO" "✅ OpenCode installed in Alpine"
            log "INFO" "   Run: proot-distro login alpine"
            log "INFO" "   Then: cd /root/opencode_termux_alpine_aarch64 && ./opencode-termux-wrapper.sh"
        else
            log "WARN" "⚠️  OpenCode installation failed"
        fi
    fi
else
    log "INFO" "⏭️  Skipped OpenCode installation"
fi

log "INFO" "✅ AI coding agents setup complete"

# --- 8. Finalisation ---
echo ""
log "INFO" "✨ Termux installation complete!"
echo ""
echo "✅ Installation Termux terminée!"
echo "📝 Log: $LOG_FILE"
echo ""
echo "🚀 Pour activer: source ~/.bashrc"
echo "💡 Ou redémarrez Termux"
echo ""
echo "📦 Packages installés:"
echo "   • Neovim (MyNeovimTermux config)"
echo "   • Ripgrep, fd, fzf"
echo "   • Starship prompt"
echo "   • Zoxide (smart cd)"
echo "   • Node.js LTS"
echo "   • JetBrainsMono Nerd Font (icônes)"
echo "   • Ranger file manager (use 'ranger' command)"
echo ""
echo "🤖 AI Coding Agents:"
[ -x "$(command -v aider)" ] && echo "   • Aider (aider command)"
[ -d "$HOME/codex-termux" ] && echo "   • Codex-Termux (~/codex-termux)"
[ -x "$(command -v sheikh)" ] && echo "   • Sheikh CLI (sheikh command)"
[ -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/alpine/root/opencode_termux_alpine_aarch64" ] && echo "   • OpenCode (proot Alpine)"
echo ""
if [ -f "$HOME/.termux/font.ttf" ]; then
    echo "🎨 Nerd Font installée! Pour l'activer:"
    echo "   1. Fermez complètement Termux (pas juste sortir)"
    echo "   2. Rouvrez Termux"
    echo "   3. Les icônes devraient maintenant s'afficher!"
    echo ""
fi
echo "⚠️  EXCLUS de cette installation (trop lourds):"
echo "   ✗ GitHub Copilot (remplacé par Aider/Codex)"
echo "   ✗ Neovim compilé from source"
echo "   ✗ Plugins LSP lourds"
echo ""
echo "🎯 Utilisation des AI Agents dans Neovim:"
echo "   <leader>ai  → Aider"
echo "   <leader>ax  → Codex-Termux"
echo "   <leader>as  → Sheikh CLI"
echo "   <leader>ao  → OpenCode (Alpine)"
echo ""
echo "📚 Configuration API keys (exemple):"
echo "   export OPENAI_API_KEY=\"sk-...\""
echo "   export ANTHROPIC_API_KEY=\"sk-ant-...\""
echo "   Puis: source ~/.bashrc"
echo ""
echo "💡 Pour Codespaces, utilisez: bash install.sh"
echo ""
