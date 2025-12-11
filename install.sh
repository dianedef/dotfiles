#!/bin/bash

# Script d'installation des dotfiles pour GitHub Codespaces

## Configuration du système de logging
# Use workspace directory for persistence with repository
LOG_FILE="$PWD/install.log"
LOG_LEVEL=${LOG_LEVEL:-INFO}  # Niveaux possibles: DEBUG, INFO, WARN, ERROR
DEBUG_MODE=${DEBUG_MODE:-false}

# Fonction de logging avec timestamps et niveaux de sévérité
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [$level] $message"

    # Afficher dans la console (seulement INFO et erreurs)
    if [ "$level" = "INFO" ] || [ "$level" = "ERROR" ]; then
        echo "$message"
    fi

    # Écrire dans le fichier de log
    echo "$log_entry" >> "$LOG_FILE"

    # Si DEBUG_MODE est activé, afficher plus de détails
    if [ "$DEBUG_MODE" = "true" ] && [ "$level" = "DEBUG" ]; then
        echo "[DEBUG_MODE] $message" >> "$LOG_FILE"
    fi
}

# Vérifier et créer le fichier de log
touch "$LOG_FILE"
log "INFO" "Starting installation script - Log file: $LOG_FILE"

echo "🚀 Starting dotfiles installation..."

# --- 1. Installation de Neovim ---
log "INFO" "📦 Installing Neovim..."

# Méthode 1 : Via tarball précompilé (la plus fiable)
install_neovim_tarball() {
    log "INFO" "Fetching latest Neovim stable release..."
    cd /tmp
    
    # Récupérer la dernière version stable depuis GitHub API
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$NVIM_VERSION" ]; then
        log "INFO" "❌ Failed to fetch latest version, using fallback v0.10.2"
        NVIM_VERSION="v0.10.2"
    fi
    
    log "INFO" "📦 Downloading Neovim $NVIM_VERSION (latest stable)..."
    
    curl -sLO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
    
    # Extraire et installer
    sudo rm -rf /opt/nvim 2>/dev/null
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz 2>/dev/null
    sudo mv /opt/nvim-linux-x86_64 /opt/nvim 2>/dev/null
    
    # Créer le lien symbolique
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim 2>/dev/null
    
    # Nettoyer
    rm nvim-linux-x86_64.tar.gz
    
    cd - > /dev/null
}

# Méthode 2 : Via AppImage si tarball échoue
install_neovim_appimage() {
    log "INFO" "Fetching latest Neovim stable release..."
    cd /tmp
    
    # Récupérer la dernière version stable
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$NVIM_VERSION" ]; then
        log "INFO" "❌ Failed to fetch latest version, using fallback v0.10.2"
        NVIM_VERSION="v0.10.2"
    fi
    
    log "INFO" "📦 Downloading Neovim AppImage $NVIM_VERSION (latest stable)..."
    
    curl -sLO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
    chmod u+x nvim-linux-x86_64.appimage 2>/dev/null
    
    # Extraire l'AppImage
    ./nvim-linux-x86_64.appimage --appimage-extract >/dev/null 2>&1
    sudo rm -rf /opt/nvim 2>/dev/null
    sudo mv squashfs-root /opt/nvim 2>/dev/null
    sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim 2>/dev/null
    
    cd - > /dev/null
}

# Toujours installer/mettre à jour Neovim
log "INFO" "Installing Neovim 0.10.2..."
install_neovim_tarball || install_neovim_appimage

# Vérifier l'installation
if command -v nvim &> /dev/null; then
    log "INFO" "✅ Neovim installed successfully: $(nvim --version | head -n 1)"
else
    log "ERROR" "❌ Neovim installation failed"
    exit 1
fi

# --- 2. Installation des dépendances ---
log "INFO" "📦 Installing dependencies..."

sudo apt-get update >/dev/null 2>&1
sudo apt-get install -y \
  git \
  curl \
  wget \
  unzip \
  build-essential \
  python3-pip \
  ripgrep \
  fd-find \
  xclip \
  ranger \
  bat \
  lsd \
  trash-cli >/dev/null 2>&1

# Créer un lien pour fd (fd-find sur Ubuntu)
if [ -f /usr/bin/fdfind ] && [ ! -f /usr/bin/fd ]; then
    sudo ln -s /usr/bin/fdfind /usr/bin/fd 2>/dev/null
fi

# Installer fzf (latest version from GitHub)
if ! command -v fzf &> /dev/null; then
    log "INFO" "Installing latest fzf..."
    git clone --depth 1 --quiet https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null
    ~/.fzf/install --bin >/dev/null 2>&1
    sudo ln -sf ~/.fzf/bin/fzf /usr/local/bin/fzf 2>/dev/null
    log "INFO" "✅ fzf installed: $(fzf --version)"
else
    log "INFO" "✅ fzf already installed: $(fzf --version)"
fi

# Installer Node.js si nécessaire
if ! command -v node &> /dev/null; then
    log "INFO" "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y nodejs >/dev/null 2>&1
else
    log "INFO" "✅ Node.js already installed: $(node --version)"
fi

# Installer GitHub Copilot CLI and other tools via npm
if command -v npm &> /dev/null; then
    log "INFO" "Installing CLI tools via npm..."
    
    log "INFO" "Installing GitHub Copilot CLI..."
    npm install -g @github/copilot >/dev/null 2>&1
    
    log "INFO" "Installing Kilocode CLI..."
    npm install -g @kilocode/cli >/dev/null 2>&1
    
    log "INFO" "Installing OpenCode AI..."
    npm install -g opencode-ai >/dev/null 2>&1
    
    log "INFO" "✅ CLI tools installed via npm (update with: npm update -g)"
else
    log "WARN" "⚠️  npm not found, skipping CLI tools installation"
fi

# Installer Starship si nécessaire
if ! command -v starship &> /dev/null; then
    log "INFO" "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
else
    log "INFO" "✅ Starship already installed"
fi

# Installer Zoxide si nécessaire
if ! command -v zoxide &> /dev/null; then
    log "INFO" "Installing Zoxide (smart cd)..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >/dev/null 2>&1
    log "INFO" "✅ Zoxide installed: $(zoxide --version 2>/dev/null || echo 'installed')"
else
    log "INFO" "✅ Zoxide already installed: $(zoxide --version)"
fi

# Installer Yazi si nécessaire
if ! command -v yazi &> /dev/null; then
    log "INFO" "Installing Yazi..."
    cd /tmp
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$YAZI_VERSION" ]; then
        log "WARN" "Failed to fetch latest Yazi version, using fallback v0.2.5"
        YAZI_VERSION="v0.2.5"
    fi
    
    log "INFO" "📦 Downloading Yazi $YAZI_VERSION..."
    curl -sLO "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.tar.gz"
    
    tar -xzf yazi-x86_64-unknown-linux-gnu.tar.gz
    sudo mv yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/yazi
    rm -rf yazi-x86_64-unknown-linux-gnu yazi-x86_64-unknown-linux-gnu.tar.gz
    
    cd - > /dev/null
    
    if command -v yazi &> /dev/null; then
        log "INFO" "✅ Yazi installed: $(yazi --version)"
    else
        log "WARN" "⚠️  Yazi installation failed"
    fi
else
    log "INFO" "✅ Yazi already installed: $(yazi --version)"
fi

# Installer Doppler CLI si nécessaire
if ! command -v doppler &> /dev/null; then
    log "INFO" "Installing Doppler CLI..."
    
    # Install prerequisites for Debian/Ubuntu
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg >/dev/null 2>&1
    
    # Add Doppler GPG key
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg 2>/dev/null
    
    # Add Doppler APT repository
    echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list >/dev/null 2>&1
    
    # Install Doppler CLI
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -y doppler >/dev/null 2>&1
    
    if command -v doppler &> /dev/null; then
        log "INFO" "✅ Doppler CLI installed: $(doppler --version)"
    else
        log "WARN" "⚠️  Doppler CLI installation failed, trying alternative method..."
        # Fallback to shell script installation
        curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sudo sh >/dev/null 2>&1
        if command -v doppler &> /dev/null; then
            log "INFO" "✅ Doppler CLI installed via shell script: $(doppler --version)"
        else
            log "WARN" "⚠️  Doppler CLI installation failed"
        fi
    fi
else
    log "INFO" "✅ Doppler CLI already installed: $(doppler --version)"
fi

# --- 3. Configuration de Neovim ---
log "INFO" "⚙️ Setting up Neovim configuration..."

NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Déterminer le répertoire des dotfiles (celui où se trouve ce script)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sauvegarder la config existante
if [ -d "$NVIM_CONFIG_DIR" ]; then
    log "INFO" "Backing up existing Neovim config..."
    mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%s)"
fi

# Vérifier si vous avez votre propre config nvim
if [ -d "$SOURCE_DIR/nvim/init.lua" ] || [ -f "$SOURCE_DIR/nvim/init.lua" ]; then
    log "INFO" "✅ Using your custom Neovim configuration from dotfiles"
else
    # Sinon, cloner LazyVim
    log "INFO" "Installing LazyVim starter..."
    git clone --quiet https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR" 2>/dev/null
    rm -rf "$NVIM_CONFIG_DIR/.git"
fi

# --- 4. Liens symboliques pour vos dotfiles personnalisés ---
log "INFO" "🔗 Creating symlinks for custom configs..."

# Fonction pour créer les liens symboliques
create_symlink() {
    local SOURCE=$1
    local TARGET=$2
    
    if [ ! -e "$SOURCE" ]; then
        log "WARN" "⚠️  Source $SOURCE does not exist, skipping..."
        return
    fi
    
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        log "INFO" "Removing existing $TARGET..."
        rm -rf "$TARGET"
    fi
    
    mkdir -p "$(dirname "$TARGET")"
    
    log "INFO" "Creating symlink: $TARGET -> $SOURCE"
    ln -s "$SOURCE" "$TARGET"
}

# Lier votre configuration nvim personnalisée (si elle existe dans dotfiles/nvim)
if [ -d "$SOURCE_DIR/nvim" ] && [ -f "$SOURCE_DIR/nvim/init.lua" ]; then
    log "INFO" "Linking custom nvim config..."
    # Supprimer la config existante et utiliser votre config
    rm -rf "$NVIM_CONFIG_DIR"
    create_symlink "$SOURCE_DIR/nvim" "$NVIM_CONFIG_DIR"
    log "INFO" "✅ Neovim config linked to $NVIM_CONFIG_DIR"
fi

# Lier yazi (si présent)
if [ -d "$SOURCE_DIR/yazi" ]; then
    log "INFO" "Linking yazi config..."
    create_symlink "$SOURCE_DIR/yazi" "$HOME/.config/yazi"
fi

# Lier ranger (si présent)
if [ -d "$SOURCE_DIR/ranger" ]; then
    log "INFO" "Linking ranger config..."
    create_symlink "$SOURCE_DIR/ranger" "$HOME/.config/ranger"
fi

# Lier starship (si présent)
if [ -d "$SOURCE_DIR/starship" ]; then
    log "INFO" "Linking starship config..."
    mkdir -p "$HOME/.config"
    create_symlink "$SOURCE_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    log "INFO" "✅ Starship config linked to $HOME/.config/starship.toml"
fi

# Lier d'autres configs si présentes
# Shell configuration is now integrated via shell-integration.sh
# Add to your ~/.bashrc: source /workspaces/dotfiles/nvim/shell-integration.sh

# --- 5. Setup Neovim config switcher ---
log "INFO" "🔄 Setting up Neovim config switcher..."

# Make scripts executable (only if they exist)
for script in "switch-config.sh" "nvim-multi" "aliases.sh" "shell-integration.sh"; do
    if [ -f "$SOURCE_DIR/nvim/$script" ]; then
        chmod +x "$SOURCE_DIR/nvim/$script"
        log "INFO" "✅ Made $script executable"
    else
        log "WARN" "⚠️  Script $script not found at $SOURCE_DIR/nvim/$script"
    fi
done

echo ""
log "INFO" "🔧 Setting up shell integration..."

# Ajouter automatiquement à ~/.bashrc si pas déjà présent
BASHRC_LINE="source $SOURCE_DIR/nvim/shell-integration.sh"
if ! grep -q "shell-integration.sh" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Neovim config switcher" >> "$HOME/.bashrc"
    echo "$BASHRC_LINE" >> "$HOME/.bashrc"
    log "INFO" "✅ Added shell integration to ~/.bashrc"
else
    log "INFO" "✅ Shell integration already in ~/.bashrc"
fi

# Ajouter Starship à ~/.bashrc si installé
if command -v starship &> /dev/null; then
    if ! grep -q "eval.*starship init" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Starship prompt" >> "$HOME/.bashrc"
        echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
        log "INFO" "✅ Added starship integration to ~/.bashrc"
    else
        log "INFO" "✅ Starship integration already in ~/.bashrc"
    fi
fi

# Ajouter Zoxide à ~/.bashrc si installé
if command -v zoxide &> /dev/null; then
    if ! grep -q "eval.*zoxide init" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Zoxide - smart cd" >> "$HOME/.bashrc"
        echo 'eval "$(zoxide init bash)"' >> "$HOME/.bashrc"
        log "INFO" "✅ Added zoxide integration to ~/.bashrc"
    else
        log "INFO" "✅ Zoxide integration already in ~/.bashrc"
    fi
fi

# Ajouter les aliases utiles à ~/.bashrc
if ! grep -q "# Productivity aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Productivity aliases" >> "$HOME/.bashrc"
    echo "alias reload='source ~/.bashrc && echo \"✓ Shell rechargé!\"'" >> "$HOME/.bashrc"
    echo "alias cls='clear'" >> "$HOME/.bashrc"
    echo "alias h='history'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Navigation shortcuts" >> "$HOME/.bashrc"
    echo "alias ..='cd ..'" >> "$HOME/.bashrc"
    echo "alias ...='cd ../..'" >> "$HOME/.bashrc"
    echo "alias ....='cd ../../..'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Git shortcuts" >> "$HOME/.bashrc"
    echo "alias gs='git status'" >> "$HOME/.bashrc"
    echo "alias ga='git add .'" >> "$HOME/.bashrc"
    echo "alias gc='git commit -m'" >> "$HOME/.bashrc"
    echo "alias gf='git fetch'" >> "$HOME/.bashrc"
    echo "alias gp='git push'" >> "$HOME/.bashrc"
    echo "alias gl='git pull'" >> "$HOME/.bashrc"
    echo "alias gd='git diff'" >> "$HOME/.bashrc"
    echo "alias glog='git log --oneline --graph'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Better tools (if installed)" >> "$HOME/.bashrc"
    echo "command -v bat >/dev/null && alias cat='bat --paging=never'" >> "$HOME/.bashrc"
    echo "command -v lsd >/dev/null && alias ls='lsd' && alias ll='lsd -lh' && alias la='lsd -lAh' && alias lt='lsd --tree --depth 2'" >> "$HOME/.bashrc"
    echo "command -v trash-put >/dev/null && alias tp='trash-put' && alias tl='trash-list' && alias tr='trash-restore' && alias te='trash-empty'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Doppler shortcuts" >> "$HOME/.bashrc"
    echo "alias ds='bash $SOURCE_DIR/doppler-setup.sh'" >> "$HOME/.bashrc"
    log "INFO" "✅ Added productivity aliases to ~/.bashrc"
else
    log "INFO" "✅ Productivity aliases already in ~/.bashrc"
fi

# Ajouter l'alias/fonction ds séparément si manquant (pour les installations existantes)
if ! grep -q "ds()" "$HOME/.bashrc" 2>/dev/null && ! grep -q "alias ds=" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Doppler shortcuts - finds doppler-setup.sh dynamically" >> "$HOME/.bashrc"
    echo "ds() {" >> "$HOME/.bashrc"
    echo "    # Try common locations" >> "$HOME/.bashrc"
    echo "    local script=\"\"" >> "$HOME/.bashrc"
    echo "    if [ -f \"\$HOME/.config/nvim/../doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"\$HOME/.config/nvim/../doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    elif [ -f \"/workspaces/dotfiles/doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"/workspaces/dotfiles/doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    elif [ -f \"\$HOME/dotfiles/doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"\$HOME/dotfiles/doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    elif [ -f \"\$HOME/storage/shared/dotfiles/doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"\$HOME/storage/shared/dotfiles/doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    else" >> "$HOME/.bashrc"
    echo "        echo \"❌ doppler-setup.sh not found. Searched common locations.\"" >> "$HOME/.bashrc"
    echo "        return 1" >> "$HOME/.bashrc"
    echo "    fi" >> "$HOME/.bashrc"
    echo "    bash \"\$script\"" >> "$HOME/.bashrc"
    echo "}" >> "$HOME/.bashrc"
    log "INFO" "✅ Added Doppler function (ds) to ~/.bashrc"
fi

# Sourcer pour cette session
source "$SOURCE_DIR/nvim/shell-integration.sh" 2>/dev/null
log "INFO" "✅ Shell integration activated for current session"

# Clear bash command hash to recognize newly installed binaries
hash -r 2>/dev/null

# --- 6. Installation des plugins Neovim ---
# NOTE: Plugin installation is now deferred to first Neovim launch
# This reduces Codespace setup time from ~10 minutes to ~1 minute
log "INFO" "⏭️  Skipping automatic plugin installation (plugins will install on first Neovim launch)"
log "INFO" "💡 Tip: Plugins will auto-install when you first run 'nvim' (~130 plugins, takes 2-3 minutes)"

# Uncomment below to restore automatic plugin installation during setup:
# if command -v nvim &> /dev/null; then
#     log "INFO" "📥 Installing Neovim plugins..."
#     nvim --headless "+Lazy! sync" +qa >/tmp/nvim-install.log 2>&1 || log "WARN" "Plugin installation had issues, but this is usually fine"
# else
#     log "WARN" "⚠️  Neovim not found, skipping plugin installation"
# fi

echo ""
log "INFO" "✨ Dotfiles installation complete!"
log "INFO" "📝 Installation log saved to /tmp/nvim-install.log"
log "INFO" "📄 Main installation log persisted with repository: $LOG_FILE"
log "INFO" "🔍 You can view logs with: cat $LOG_FILE"
log "INFO" "📖 Or monitor in real-time with: tail -f $LOG_FILE"
log "INFO" "📁 Log file is accessible via VS Code file explorer"

echo ""
echo "✨ Dotfiles installation complete!"
echo "🎉 Your Neovim is ready to use!"
echo ""
echo "📝 Installation log saved to /tmp/nvim-install.log"
echo "📄 Full installation log: $LOG_FILE"
echo ""
echo "✅ Shell integration configured automatically!"
echo "   Commands available: nvims, nv11, nv22, nvim11, nvim22, etc."
echo ""
echo "🚀 Zoxide (smart cd) installed - use 'z' command after restart"
echo "   Example: z nvim (jumps to most used nvim directory)"
echo ""
echo "🔄 Run 'hash -r' or start a new shell to use newly installed commands"
echo "🚀 Or run: source ~/.bashrc"
echo "📄 Main installation log persisted with repository: $LOG_FILE"
echo ""

# --- 7. Configuration de Doppler (optionnel) ---
echo "════════════════════════════════════════════════════════════════"
echo ""

# Vérifier si Doppler est installé avant de proposer la configuration
if command -v doppler &> /dev/null; then
    read -p "🔐 Voulez-vous configurer vos API keys avec Doppler maintenant? (y/N): " SETUP_DOPPLER

    if [ "$SETUP_DOPPLER" = "y" ] || [ "$SETUP_DOPPLER" = "Y" ]; then
        if [ -f "$SOURCE_DIR/doppler-setup.sh" ]; then
            log "INFO" "🚀 Lancement de la configuration Doppler..."
            bash "$SOURCE_DIR/doppler-setup.sh"
        else
            log "WARN" "⚠️  Script doppler-setup.sh non trouvé"
            echo "⚠️  Lancez manuellement: ./doppler-setup.sh"
        fi
    else
        echo "⏭️  Configuration Doppler skippée"
        echo "💡 Lancez plus tard avec: ./doppler-setup.sh"
    fi
else
    log "WARN" "⚠️  Doppler CLI n'est pas installé. Configuration skippée."
    echo "💡 Installez Doppler puis lancez: ./doppler-setup.sh"
fi

echo ""
echo "🎊 Installation complète! Profitez bien de votre environnement!"