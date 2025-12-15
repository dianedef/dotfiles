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

# --- 2. Outils légers uniquement ---
log "INFO" "📦 Installing lightweight tools..."

# Starship (prompt)
if ! command -v starship &> /dev/null; then
    log "INFO" "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
    log "INFO" "✅ Starship installed"
else
    log "INFO" "✅ Starship already installed"
fi

# Zoxide (smart cd)
if ! command -v zoxide &> /dev/null; then
    log "INFO" "Installing Zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >/dev/null 2>&1
    log "INFO" "✅ Zoxide installed"
else
    log "INFO" "✅ Zoxide already installed"
fi

# Yazi (file manager) - optionnel, peut être lourd
read -p "🗂️  Install Yazi file manager? (Y/n): " INSTALL_YAZI
if [ "$INSTALL_YAZI" != "n" ] && [ "$INSTALL_YAZI" != "N" ]; then
    if ! command -v yazi &> /dev/null; then
        log "INFO" "Installing Yazi..."
        cd /tmp
        YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        [ -z "$YAZI_VERSION" ] && YAZI_VERSION="v0.2.5"
        
        # Termux utilise ARM64 généralement
        ARCH=$(uname -m)
        if [ "$ARCH" = "aarch64" ]; then
            YAZI_FILE="yazi-aarch64-unknown-linux-musl.tar.gz"
        else
            log "WARN" "⚠️  Architecture $ARCH non supportée pour Yazi"
            YAZI_FILE=""
        fi
        
        if [ -n "$YAZI_FILE" ]; then
            curl -sLO "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${YAZI_FILE}"
            tar -xzf "$YAZI_FILE" 2>/dev/null
            mv yazi-*/yazi "$PREFIX/bin/" 2>/dev/null
            rm -rf yazi-* 2>/dev/null
            log "INFO" "✅ Yazi installed"
        fi
        cd - > /dev/null
    else
        log "INFO" "✅ Yazi already installed"
    fi
fi

# --- 3. Configuration Neovim LIGHT ---
log "INFO" "⚙️ Setting up Neovim (LIGHT config)..."

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Backup existing config
if [ -d "$NVIM_CONFIG_DIR" ]; then
    log "INFO" "Backing up existing config..."
    mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%s)"
fi

# --- 4. Symlinks ---
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

# Neovim config
if [ -d "$SOURCE_DIR/nvim" ] && [ -f "$SOURCE_DIR/nvim/init.lua" ]; then
    create_symlink "$SOURCE_DIR/nvim" "$NVIM_CONFIG_DIR"
fi

# Yazi (si installé)
[ -d "$SOURCE_DIR/yazi" ] && create_symlink "$SOURCE_DIR/yazi" "$HOME/.config/yazi"

# Ranger
[ -d "$SOURCE_DIR/ranger" ] && create_symlink "$SOURCE_DIR/ranger" "$HOME/.config/ranger"

# Starship (utilise la version simplifiée)
if [ -f "$SOURCE_DIR/starship/starship-simple.toml" ]; then
    create_symlink "$SOURCE_DIR/starship/starship-simple.toml" "$HOME/.config/starship.toml"
    log "INFO" "✅ Using simplified Starship config"
elif [ -f "$SOURCE_DIR/starship/starship.toml" ]; then
    create_symlink "$SOURCE_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# --- 5. Shell integration ---
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

# Starship
if command -v starship &> /dev/null && ! grep -q "starship init" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# Starship prompt' >> "$BASHRC"
    echo 'eval "$(starship init bash)"' >> "$BASHRC"
    log "INFO" "✅ Added Starship"
fi

# Zoxide
if command -v zoxide &> /dev/null && ! grep -q "zoxide init" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# Zoxide' >> "$BASHRC"
    echo 'eval "$(zoxide init bash)"' >> "$BASHRC"
    log "INFO" "✅ Added Zoxide"
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

EOF
    log "INFO" "✅ Added Termux aliases"
fi

# --- 6. Configuration Neovim allégée ---
log "INFO" "📝 Applying lightweight Neovim settings..."

# Créer un fichier de config local pour désactiver les plugins lourds
mkdir -p "$NVIM_CONFIG_DIR/lua/config"
cat > "$NVIM_CONFIG_DIR/lua/config/termux.lua" << 'EOF'
-- Termux: Désactiver plugins lourds
return {
  -- Désactiver Copilot sur Termux
  { "zbirenbaum/copilot.lua", enabled = false },
  { "zbirenbaum/copilot-cmp", enabled = false },
  
  -- LSP léger uniquement
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Garder seulement les LSP légers
        lua_ls = {},
        bashls = {},
        -- Désactiver les autres
      },
    },
  },
}
EOF

log "INFO" "✅ Created termux-optimized config"

# --- 7. Finalisation ---
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
echo "   • Neovim (version Termux)"
echo "   • Ripgrep, fd, fzf"
echo "   • Starship prompt"
echo "   • Zoxide (smart cd)"
echo "   • Node.js LTS"
[ -x "$(command -v yazi)" ] && echo "   • Yazi file manager"
echo ""
echo "⚠️  EXCLUS de cette installation (trop lourds):"
echo "   ✗ GitHub Copilot"
echo "   ✗ Neovim compilé from source"
echo "   ✗ Plugins LSP lourds"
echo ""
echo "💡 Pour Codespaces, utilisez: bash install.sh"
echo ""
