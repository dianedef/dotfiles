#!/bin/bash

# Script d'installation des dotfiles pour GitHub Codespaces
#
# Configuration:
#   - Edit .env file to customize installation (tokens, skip flags, etc.)
#   - See docs/ENV_CONFIGURATION.md for all options
#   - Safe defaults provided in .env (no tokens required)
#
# Usage:
#   ./install.sh                    # Run with .env config
#   LOG_LEVEL=DEBUG ./install.sh    # Override env vars
#   AUTO_INSTALL_NVIM_PLUGINS=true ./install.sh  # Force plugin install
#   USER_LOCAL_MODE=true ./install.sh  # Install without sudo (user-local)

# Déterminer le répertoire du script (pour trouver .env)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- OS and Environment Detection ---
detect_system() {
    # Detect OS
    case "$(uname -s)" in
        Linux*)
            OS="linux"
            # Detect Linux distro
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="$ID"
                DISTRO_FAMILY="$ID_LIKE"
            elif [ -f /etc/debian_version ]; then
                DISTRO="debian"
                DISTRO_FAMILY="debian"
            elif [ -f /etc/redhat-release ]; then
                DISTRO="rhel"
                DISTRO_FAMILY="rhel"
            else
                DISTRO="unknown"
                DISTRO_FAMILY="unknown"
            fi
            ;;
        Darwin*)
            OS="macos"
            DISTRO="macos"
            DISTRO_FAMILY="macos"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="windows"
            DISTRO="windows"
            DISTRO_FAMILY="windows"
            ;;
        *)
            OS="unknown"
            DISTRO="unknown"
            DISTRO_FAMILY="unknown"
            ;;
    esac

    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        aarch64|arm64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
    esac

    # Detect if we have sudo access
    if command -v sudo &> /dev/null && sudo -n true 2>/dev/null; then
        HAS_SUDO=true
    elif [ "$(id -u)" = "0" ]; then
        HAS_SUDO=true  # Running as root
    else
        HAS_SUDO=false
    fi

    # User-local mode: either forced via env var or auto-detected when no sudo
    if [ "${USER_LOCAL_MODE:-false}" = "true" ] || [ "$HAS_SUDO" = "false" ]; then
        USER_LOCAL_MODE=true
    else
        USER_LOCAL_MODE=false
    fi

    export OS DISTRO DISTRO_FAMILY ARCH HAS_SUDO USER_LOCAL_MODE
}

detect_system

# Load environment variables from .env file (if exists)
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "📋 Loading configuration from .env file..."
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | grep -v '^$' | xargs)
    echo "✅ Configuration loaded (LOG_LEVEL=$LOG_LEVEL, AUTO_INSTALL_NVIM_PLUGINS=${AUTO_INSTALL_NVIM_PLUGINS:-false})"
else
    echo "⚠️  No .env file found, using defaults"
    echo "💡 Copy .env.example to .env to customize installation"
fi

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

# Display detected system info
echo ""
echo "🖥️  System detected:"
echo "   OS: $OS ($DISTRO)"
echo "   Architecture: $ARCH"
echo "   Sudo access: $HAS_SUDO"
echo "   User-local mode: $USER_LOCAL_MODE"
echo ""

# Setup user-local paths if needed
if [ "$USER_LOCAL_MODE" = "true" ]; then
    echo "📦 USER-LOCAL MODE ENABLED"
    echo "   Installing to ~/.local/bin and ~/.npm-global"
    echo "   Some system packages may be skipped (require sudo)"
    echo ""

    # Create user-local directories
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.npm-global"

    # Configure npm for user-local installs
    if command -v npm &> /dev/null; then
        npm config set prefix "$HOME/.npm-global" 2>/dev/null
    fi

    # Add to PATH for this session
    export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

    # Ensure paths are in shell config
    if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# User-local binaries" >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
    fi

    log "INFO" "✅ User-local paths configured"
fi

# Detect execution mode
if [ ! -t 0 ]; then
    echo "🤖 Running in non-interactive mode (Codespaces auto-run)"
    echo "💡 For authentication setup: run './install.sh' manually after Doppler setup"
else
    echo "👤 Running in interactive mode"
fi
echo ""

# --- User Identity Configuration ---
echo "👤 Configuring user identity..."

# Get user info from .env, environment, or prompt
get_user_info() {
    # Priority: .env > environment > prompt

    # USER_NAME
    if [ -z "${USER_NAME}" ]; then
        if [ -t 0 ]; then
            read -p "📝 Enter your name (for git/espanso): " USER_NAME
            USER_NAME="${USER_NAME:-Diane}"
        else
            USER_NAME="Diane"
            log "INFO" "Using default name: $USER_NAME (set USER_NAME in .env to customize)"
        fi
    fi

    # USER_EMAIL
    if [ -z "${USER_EMAIL}" ]; then
        if [ -t 0 ]; then
            read -p "📧 Enter your email (for git/espanso): " USER_EMAIL
            USER_EMAIL="${USER_EMAIL:-noreply@example.com}"
        else
            USER_EMAIL="35034946+dianedef@users.noreply.github.com"
            log "INFO" "Using default email: $USER_EMAIL (set USER_EMAIL in .env to customize)"
        fi
    fi

    # GITHUB_USERNAME
    if [ -z "${GITHUB_USERNAME}" ]; then
        # Try to extract from email if it's a GitHub noreply
        if [[ "$USER_EMAIL" =~ \+(.+)@users\.noreply\.github\.com ]]; then
            GITHUB_USERNAME="${BASH_REMATCH[1]}"
        elif [ -t 0 ]; then
            read -p "🐙 Enter your GitHub username: " GITHUB_USERNAME
            GITHUB_USERNAME="${GITHUB_USERNAME:-dianedef}"
        else
            GITHUB_USERNAME="dianedef"
        fi
    fi

    export USER_NAME USER_EMAIL GITHUB_USERNAME
    log "INFO" "✅ User identity: $USER_NAME <$USER_EMAIL> (@$GITHUB_USERNAME)"
}

get_user_info

# --- Git Configuration ---
echo "🔧 Configuring git user identity..."
git config --global user.name "$USER_NAME"
git config --global user.email "$USER_EMAIL"
log "INFO" "✅ Git user identity configured"

# --- 1. Installation de Neovim ---
if [ "${SKIP_NEOVIM_INSTALL:-false}" = "true" ]; then
    log "INFO" "⏭️  Skipping Neovim installation (SKIP_NEOVIM_INSTALL=true)"
else
    log "INFO" "📦 Installing Neovim..."
fi

# Méthode 1 : Via tarball précompilé (la plus fiable)
install_neovim_tarball() {
    log "INFO" "Fetching latest Neovim stable release..."
    cd /tmp

    # Use already detected architecture
    local NVIM_ARCH=""
    case $ARCH in
        x86_64)
            NVIM_ARCH="x86_64"
            ;;
        arm64)
            NVIM_ARCH="arm64"
            ;;
        *)
            log "INFO" "⚠️  Unsupported architecture: $ARCH"
            return 1
            ;;
    esac

    # Determine install paths based on mode
    local INSTALL_DIR="$HOME/.local/nvim"
    local BIN_LINK="$HOME/.local/bin/nvim"
    if [ "$USER_LOCAL_MODE" = "false" ]; then
        INSTALL_DIR="/opt/nvim-linux-${NVIM_ARCH}"
        BIN_LINK="/usr/local/bin/nvim"
    fi

    log "INFO" "🔍 Architecture: $ARCH, Install to: $INSTALL_DIR"

    # Récupérer la dernière version stable depuis GitHub API
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$NVIM_VERSION" ]; then
        log "INFO" "❌ Failed to fetch latest version, using fallback v0.10.2"
        NVIM_VERSION="v0.10.2"
    fi

    # Handle macOS vs Linux download
    local NVIM_FILE=""
    if [ "$OS" = "macos" ]; then
        NVIM_FILE="nvim-macos-${NVIM_ARCH}.tar.gz"
    else
        NVIM_FILE="nvim-linux-${NVIM_ARCH}.tar.gz"
    fi

    log "INFO" "📦 Downloading Neovim $NVIM_VERSION ($NVIM_FILE)..."

    curl -sLO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_FILE}"

    # Vérifier si le téléchargement a réussi
    if [ ! -f "$NVIM_FILE" ]; then
        log "INFO" "❌ Download failed for $NVIM_FILE"
        return 1
    fi

    # Extraire et installer
    if [ "$USER_LOCAL_MODE" = "true" ]; then
        rm -rf "$INSTALL_DIR" 2>/dev/null
        mkdir -p "$HOME/.local"
        tar -C "$HOME/.local" -xzf "$NVIM_FILE" 2>/dev/null
        # Rename extracted folder
        local EXTRACTED_NAME="${NVIM_FILE%.tar.gz}"
        mv "$HOME/.local/$EXTRACTED_NAME" "$INSTALL_DIR" 2>/dev/null || true
        ln -sf "$INSTALL_DIR/bin/nvim" "$BIN_LINK" 2>/dev/null
    else
        sudo rm -rf /opt/nvim 2>/dev/null
        sudo tar -C /opt -xzf "$NVIM_FILE" 2>/dev/null
        sudo ln -sf "$INSTALL_DIR/bin/nvim" "$BIN_LINK" 2>/dev/null
    fi

    # Nettoyer
    rm "$NVIM_FILE"

    cd - > /dev/null
}

# Méthode 2 : Via AppImage si tarball échoue (Linux x86_64 only)
install_neovim_appimage() {
    if [ "$OS" != "linux" ] || [ "$ARCH" != "x86_64" ]; then
        log "INFO" "⚠️  AppImage only available for Linux x86_64"
        return 1
    fi

    log "INFO" "Fetching latest Neovim stable release..."
    cd /tmp

    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$NVIM_VERSION" ]; then
        log "INFO" "❌ Failed to fetch latest version, using fallback v0.10.2"
        NVIM_VERSION="v0.10.2"
    fi

    log "INFO" "📦 Downloading Neovim AppImage $NVIM_VERSION..."

    curl -sLO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
    chmod u+x nvim-linux-x86_64.appimage 2>/dev/null

    # Extraire l'AppImage
    ./nvim-linux-x86_64.appimage --appimage-extract >/dev/null 2>&1

    if [ "$USER_LOCAL_MODE" = "true" ]; then
        rm -rf "$HOME/.local/nvim" 2>/dev/null
        mv squashfs-root "$HOME/.local/nvim" 2>/dev/null
        ln -sf "$HOME/.local/nvim/usr/bin/nvim" "$HOME/.local/bin/nvim" 2>/dev/null
    else
        sudo rm -rf /opt/nvim 2>/dev/null
        sudo mv squashfs-root /opt/nvim 2>/dev/null
        sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim 2>/dev/null
    fi

    rm -f nvim-linux-x86_64.appimage
    cd - > /dev/null
}

# Toujours installer/mettre à jour Neovim (unless skipped)
if [ "${SKIP_NEOVIM_INSTALL:-false}" != "true" ]; then
    log "INFO" "Installing Neovim 0.10.2..."
    install_neovim_tarball || install_neovim_appimage
fi

# Vérifier l'installation
if command -v nvim &> /dev/null; then
    log "INFO" "✅ Neovim installed successfully: $(nvim --version | head -n 1)"
else
    log "ERROR" "❌ Neovim installation failed"
    exit 1
fi

# --- 2. Installation des dépendances ---
log "INFO" "📦 Installing dependencies..."

# Function to install a binary from GitHub releases
install_github_binary() {
    local repo="$1"      # e.g., "BurntSushi/ripgrep"
    local binary="$2"    # e.g., "rg"
    local pattern="$3"   # e.g., "ripgrep-*-x86_64-unknown-linux-musl.tar.gz"

    if command -v "$binary" &> /dev/null; then
        log "INFO" "✅ $binary already installed"
        return 0
    fi

    log "INFO" "📥 Installing $binary from GitHub..."
    cd /tmp

    local version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    local download_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep "browser_download_url.*$pattern" | head -1 | cut -d '"' -f 4)

    if [ -z "$download_url" ]; then
        log "WARN" "⚠️  Could not find download URL for $binary"
        return 1
    fi

    curl -sLO "$download_url"
    local filename=$(basename "$download_url")

    if [[ "$filename" == *.tar.gz ]]; then
        tar -xzf "$filename" 2>/dev/null
        find . -maxdepth 2 -name "$binary" -type f -exec mv {} "$HOME/.local/bin/" \; 2>/dev/null
    elif [[ "$filename" == *.zip ]]; then
        unzip -q "$filename" 2>/dev/null
        find . -maxdepth 2 -name "$binary" -type f -exec mv {} "$HOME/.local/bin/" \; 2>/dev/null
    fi

    rm -rf "$filename" "${filename%.tar.gz}" "${filename%.zip}" 2>/dev/null
    chmod +x "$HOME/.local/bin/$binary" 2>/dev/null
    cd - > /dev/null

    if command -v "$binary" &> /dev/null; then
        log "INFO" "✅ $binary installed"
        return 0
    else
        log "WARN" "⚠️  $binary installation may have failed"
        return 1
    fi
}

# Install system packages based on OS and mode
install_system_packages() {
    if [ "$OS" = "macos" ]; then
        # macOS: use Homebrew
        if command -v brew &> /dev/null; then
            log "INFO" "🍺 Installing via Homebrew..."
            brew install git curl wget unzip ripgrep fd bat lsd trash-cli 2>/dev/null
        else
            log "WARN" "⚠️  Homebrew not found. Install from https://brew.sh"
            log "INFO" "💡 Then re-run this script"
        fi
    elif [ "$OS" = "linux" ]; then
        if [ "$USER_LOCAL_MODE" = "true" ]; then
            # User-local mode: download binaries directly
            log "INFO" "📦 Installing tools via direct download (user-local mode)..."

            # Check for essential pre-installed tools
            for tool in git curl wget unzip; do
                if ! command -v "$tool" &> /dev/null; then
                    log "WARN" "⚠️  $tool not found - please ask admin to install it"
                fi
            done

            # Install tools from GitHub releases
            if [ "$ARCH" = "x86_64" ]; then
                install_github_binary "BurntSushi/ripgrep" "rg" "x86_64-unknown-linux-musl.tar.gz"
                install_github_binary "sharkdp/fd" "fd" "x86_64-unknown-linux-musl.tar.gz"
                install_github_binary "sharkdp/bat" "bat" "x86_64-unknown-linux-musl.tar.gz"
                install_github_binary "lsd-rs/lsd" "lsd" "x86_64-unknown-linux-musl.tar.gz"
            elif [ "$ARCH" = "arm64" ]; then
                install_github_binary "BurntSushi/ripgrep" "rg" "aarch64-unknown-linux-gnu.tar.gz"
                install_github_binary "sharkdp/fd" "fd" "aarch64-unknown-linux-gnu.tar.gz"
                install_github_binary "sharkdp/bat" "bat" "aarch64-unknown-linux-gnu.tar.gz"
                install_github_binary "lsd-rs/lsd" "lsd" "aarch64-unknown-linux-gnu.tar.gz"
            fi

            # Python tools via pip --user
            if command -v pip3 &> /dev/null || command -v pip &> /dev/null; then
                log "INFO" "🐍 Installing Python tools via pip --user..."
                pip3 install --user ranger-fm trash-cli 2>/dev/null || pip install --user ranger-fm trash-cli 2>/dev/null
            fi

            log "INFO" "⚠️  Some system tools skipped (no sudo). Pre-installed: git, curl, etc."
        else
            # Normal mode with sudo: use apt-get
            if [[ "$DISTRO_FAMILY" == *"debian"* ]] || [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
                log "INFO" "📦 Installing via apt-get..."
                sudo apt-get update >/dev/null 2>&1
                sudo apt-get install -y \
                    git curl wget unzip build-essential python3-pip \
                    ripgrep fd-find xclip ranger bat lsd trash-cli >/dev/null 2>&1

                # Create fd symlink (fd-find on Ubuntu)
                if [ -f /usr/bin/fdfind ] && [ ! -f /usr/bin/fd ]; then
                    sudo ln -s /usr/bin/fdfind /usr/bin/fd 2>/dev/null
                fi
            elif [[ "$DISTRO_FAMILY" == *"rhel"* ]] || [ "$DISTRO" = "fedora" ]; then
                log "INFO" "📦 Installing via dnf..."
                sudo dnf install -y git curl wget unzip gcc python3-pip ripgrep fd-find bat 2>/dev/null
            elif [ "$DISTRO" = "arch" ]; then
                log "INFO" "📦 Installing via pacman..."
                sudo pacman -S --noconfirm git curl wget unzip base-devel python-pip ripgrep fd bat lsd 2>/dev/null
            else
                log "WARN" "⚠️  Unknown distro: $DISTRO. Trying apt-get..."
                sudo apt-get update >/dev/null 2>&1
                sudo apt-get install -y git curl wget unzip 2>/dev/null
            fi
        fi
    else
        log "WARN" "⚠️  Unsupported OS: $OS"
    fi
}

install_system_packages

# Installer fzf (latest version from GitHub) - always user-local
if ! command -v fzf &> /dev/null; then
    log "INFO" "Installing latest fzf..."
    git clone --depth 1 --quiet https://github.com/junegunn/fzf.git ~/.fzf 2>/dev/null
    ~/.fzf/install --bin >/dev/null 2>&1
    # Link to user-local bin (works for both modes)
    ln -sf ~/.fzf/bin/fzf "$HOME/.local/bin/fzf" 2>/dev/null
    if [ "$USER_LOCAL_MODE" = "false" ]; then
        sudo ln -sf ~/.fzf/bin/fzf /usr/local/bin/fzf 2>/dev/null
    fi
    log "INFO" "✅ fzf installed: $(fzf --version 2>/dev/null || echo 'installed')"
else
    log "INFO" "✅ fzf already installed: $(fzf --version)"
fi

# Installer Nerd Fonts pour les icônes
if [ "${SKIP_NERD_FONTS:-false}" = "true" ]; then
    log "INFO" "⏭️  Skipping Nerd Fonts installation (SKIP_NERD_FONTS=true)"
elif ! fc-list | grep -iq "nerd"; then
    log "INFO" "📝 Installing Nerd Fonts (JetBrainsMono for icons)..."
    mkdir -p ~/.local/share/fonts
    cd /tmp
    
    # Télécharger JetBrainsMono Nerd Font (populaire et complet)
    FONT_VERSION="v3.2.1"
    curl -sLO "https://github.com/ryanoasis/nerd-fonts/releases/download/${FONT_VERSION}/JetBrainsMono.zip"
    
    if [ -f JetBrainsMono.zip ]; then
        unzip -q JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/ 2>/dev/null
        rm JetBrainsMono.zip
        
        # Mettre à jour le cache des fonts
        fc-cache -fv ~/.local/share/fonts >/dev/null 2>&1
        
        log "INFO" "✅ Nerd Fonts installed: $(fc-list | grep -i jetbrains | wc -l) variants"
    else
        log "WARN" "⚠️  Failed to download Nerd Fonts"
    fi
    
    cd - > /dev/null
else
    log "INFO" "✅ Nerd Fonts already installed"
fi

# Installer Node.js si nécessaire
if ! command -v node &> /dev/null; then
    log "INFO" "Installing Node.js..."
    if [ "$OS" = "macos" ]; then
        if command -v brew &> /dev/null; then
            brew install node 2>/dev/null
        else
            log "WARN" "⚠️  Install Node.js via Homebrew or https://nodejs.org"
        fi
    elif [ "$USER_LOCAL_MODE" = "true" ]; then
        # Install Node.js via nvm (user-local, no sudo needed)
        log "INFO" "Installing Node.js via nvm (user-local)..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts >/dev/null 2>&1
        nvm use --lts >/dev/null 2>&1
        log "INFO" "✅ Node.js installed via nvm: $(node --version 2>/dev/null || echo 'installed')"
    else
        # System install with sudo
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - >/dev/null 2>&1
        sudo apt-get install -y nodejs >/dev/null 2>&1
    fi
else
    log "INFO" "✅ Node.js already installed: $(node --version)"
fi

# Configure npm for user-local global installs (best practice - no sudo needed)
if command -v npm &> /dev/null; then
    log "INFO" "🔧 Configuring npm for user-local global installs..."
    mkdir -p "$HOME/.npm-global"
    npm config set prefix "$HOME/.npm-global" 2>/dev/null
    export PATH="$HOME/.npm-global/bin:$PATH"

    # Ensure it's in bashrc
    if ! grep -q 'npm-global' "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# npm global packages (user-local, no sudo needed)" >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc"
    fi
    log "INFO" "✅ npm configured: global packages install to ~/.npm-global"
fi

# Installer GitHub Copilot CLI and other tools via npm (user-local)
if [ "${SKIP_NPM_TOOLS:-false}" = "true" ]; then
    log "INFO" "⏭️  Skipping npm tools installation (SKIP_NPM_TOOLS=true)"
elif command -v npm &> /dev/null; then
    log "INFO" "Installing CLI tools via npm (user-local, no sudo)..."

    # GitHub Copilot CLI
    log "INFO" "Installing GitHub Copilot CLI..."
    if npm install -g @github/copilot 2>&1 | tee -a "$LOG_FILE" | grep -q "added\|updated\|already"; then
        log "INFO" "✅ GitHub Copilot CLI installed"
    else
        log "WARN" "⚠️  GitHub Copilot CLI installation may have failed"
    fi

    # Kilocode CLI
    log "INFO" "Installing Kilocode CLI..."
    if npm install -g @kilocode/cli 2>&1 | tee -a "$LOG_FILE" | grep -q "added\|updated\|already"; then
        log "INFO" "✅ Kilocode CLI installed"
    else
        log "WARN" "⚠️  Kilocode CLI installation may have failed"
    fi

    # OpenCode AI
    log "INFO" "Installing OpenCode AI..."
    if npm install -g opencode-ai 2>&1 | tee -a "$LOG_FILE" | grep -q "added\|updated\|already"; then
        log "INFO" "✅ OpenCode AI installed"
    else
        log "WARN" "⚠️  OpenCode AI installation may have failed"
    fi

    # TLDR pages
    log "INFO" "Installing TLDR pages..."
    if npm install -g tldr 2>&1 | tee -a "$LOG_FILE" | grep -q "added\|updated\|already"; then
        log "INFO" "✅ TLDR pages installed"
    else
        log "WARN" "⚠️  TLDR pages installation may have failed"
    fi

    # Verify installations
    hash -r 2>/dev/null
    echo ""
    log "INFO" "📦 Installed npm global packages:"
    npm list -g --depth=0 2>/dev/null | grep -E "@github/copilot|@kilocode|opencode|tldr" | tee -a "$LOG_FILE" || log "WARN" "No packages found in npm list"

    log "INFO" "✅ CLI tools installation complete (update with: npm update -g)"
else
    log "WARN" "⚠️  npm not found, skipping CLI tools installation"
fi

# Installer Starship si nécessaire
if ! command -v starship &> /dev/null; then
    log "INFO" "Installing Starship..."
    if [ "$USER_LOCAL_MODE" = "true" ]; then
        # Install to ~/.local/bin
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" >/dev/null 2>&1
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y >/dev/null 2>&1
    fi
    log "INFO" "✅ Starship installed: $(starship --version 2>/dev/null || echo 'installed')"
else
    log "INFO" "✅ Starship already installed"
fi

# Installer Zoxide si nécessaire
if ! command -v zoxide &> /dev/null; then
    log "INFO" "Installing Zoxide (smart cd)..."
    # Zoxide installer automatically detects and uses ~/.local/bin if no sudo
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash >/dev/null 2>&1
    log "INFO" "✅ Zoxide installed: $(zoxide --version 2>/dev/null || echo 'installed')"
else
    log "INFO" "✅ Zoxide already installed: $(zoxide --version)"
fi

# Installer Yazi si nécessaire
if [ "${SKIP_YAZI_INSTALL:-false}" = "true" ]; then
    log "INFO" "⏭️  Skipping Yazi installation (SKIP_YAZI_INSTALL=true)"
elif ! command -v yazi &> /dev/null; then
    log "INFO" "Installing Yazi..."
    cd /tmp

    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ -z "$YAZI_VERSION" ]; then
        log "WARN" "Failed to fetch latest Yazi version, using fallback v0.4.2"
        YAZI_VERSION="v0.4.2"
    fi

    # Determine download file based on OS and arch
    local YAZI_FILE=""
    if [ "$OS" = "macos" ]; then
        if [ "$ARCH" = "arm64" ]; then
            YAZI_FILE="yazi-aarch64-apple-darwin.zip"
        else
            YAZI_FILE="yazi-x86_64-apple-darwin.zip"
        fi
    else
        if [ "$ARCH" = "arm64" ]; then
            YAZI_FILE="yazi-aarch64-unknown-linux-gnu.zip"
        else
            YAZI_FILE="yazi-x86_64-unknown-linux-gnu.zip"
        fi
    fi

    log "INFO" "📦 Downloading Yazi $YAZI_VERSION ($YAZI_FILE)..."
    curl -sLO "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${YAZI_FILE}"

    if [ -f "$YAZI_FILE" ]; then
        unzip -q "$YAZI_FILE" 2>/dev/null
        local YAZI_DIR="${YAZI_FILE%.zip}"

        if [ "$USER_LOCAL_MODE" = "true" ]; then
            mv "$YAZI_DIR/yazi" "$HOME/.local/bin/yazi" 2>/dev/null
        else
            sudo mv "$YAZI_DIR/yazi" /usr/local/bin/yazi 2>/dev/null
        fi

        rm -rf "$YAZI_DIR" "$YAZI_FILE"
    fi

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
if [ "${SKIP_DOPPLER_INSTALL:-false}" = "true" ]; then
    log "INFO" "⏭️  Skipping Doppler CLI installation (SKIP_DOPPLER_INSTALL=true)"
elif ! command -v doppler &> /dev/null; then
    log "INFO" "Installing Doppler CLI..."

    if [ "$OS" = "macos" ]; then
        if command -v brew &> /dev/null; then
            brew install dopplerhq/cli/doppler 2>/dev/null
        else
            log "WARN" "⚠️  Install Doppler via: brew install dopplerhq/cli/doppler"
        fi
    elif [ "$USER_LOCAL_MODE" = "true" ]; then
        # User-local: download binary directly
        log "INFO" "Installing Doppler to ~/.local/bin..."
        cd /tmp

        local DOPPLER_FILE=""
        if [ "$ARCH" = "x86_64" ]; then
            DOPPLER_FILE="doppler_3.69.0_linux_amd64.tar.gz"
        elif [ "$ARCH" = "arm64" ]; then
            DOPPLER_FILE="doppler_3.69.0_linux_arm64.tar.gz"
        fi

        # Get latest version
        DOPPLER_VERSION=$(curl -s https://api.github.com/repos/DopplerHQ/cli/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [ -n "$DOPPLER_VERSION" ]; then
            if [ "$ARCH" = "x86_64" ]; then
                DOPPLER_FILE="doppler_${DOPPLER_VERSION}_linux_amd64.tar.gz"
            else
                DOPPLER_FILE="doppler_${DOPPLER_VERSION}_linux_arm64.tar.gz"
            fi
        fi

        curl -sLO "https://github.com/DopplerHQ/cli/releases/latest/download/${DOPPLER_FILE}"
        if [ -f "$DOPPLER_FILE" ]; then
            tar -xzf "$DOPPLER_FILE" doppler 2>/dev/null
            mv doppler "$HOME/.local/bin/doppler" 2>/dev/null
            chmod +x "$HOME/.local/bin/doppler"
            rm -f "$DOPPLER_FILE"
        fi

        cd - > /dev/null
    else
        # System install with sudo (Debian/Ubuntu)
        if [[ "$DISTRO_FAMILY" == *"debian"* ]] || [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
            sudo apt-get install -y apt-transport-https ca-certificates curl gnupg >/dev/null 2>&1
            curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | sudo gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg 2>/dev/null
            echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | sudo tee /etc/apt/sources.list.d/doppler-cli.list >/dev/null 2>&1
            sudo apt-get update >/dev/null 2>&1
            sudo apt-get install -y doppler >/dev/null 2>&1
        else
            # Fallback to shell script
            curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sudo sh >/dev/null 2>&1
        fi
    fi

    if command -v doppler &> /dev/null; then
        log "INFO" "✅ Doppler CLI installed: $(doppler --version)"
    else
        log "WARN" "⚠️  Doppler CLI installation failed"
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

# Configurer Espanso (si présent)
if [ -d "$SOURCE_DIR/espanso/.config/espanso" ]; then
    log "INFO" "Setting up Espanso text expander..."

    # Inject user info into espanso config
    ESPANSO_BASE="$SOURCE_DIR/espanso/.config/espanso/match/base.yml"
    if [ -f "$ESPANSO_BASE" ]; then
        log "INFO" "Injecting user info into Espanso config..."
        sed -i "s/{{USER_NAME}}/$USER_NAME/g" "$ESPANSO_BASE"
        sed -i "s/{{USER_EMAIL}}/$USER_EMAIL/g" "$ESPANSO_BASE"
        sed -i "s/{{GITHUB_USERNAME}}/$GITHUB_USERNAME/g" "$ESPANSO_BASE"
        log "INFO" "✅ Espanso config personalized"
    fi

    # Create symlink
    create_symlink "$SOURCE_DIR/espanso/.config/espanso" "$HOME/.config/espanso"
    log "INFO" "✅ Espanso config linked to $HOME/.config/espanso"

    # Install espanso if not present
    if ! command -v espanso &> /dev/null; then
        log "INFO" "Installing Espanso..."
        if [ "$OS" = "macos" ]; then
            if command -v brew &> /dev/null; then
                brew install espanso 2>/dev/null && log "INFO" "✅ Espanso installed via Homebrew"
            fi
        elif [ "$USER_LOCAL_MODE" = "true" ]; then
            log "WARN" "⚠️  Espanso requires system install (snap/dpkg). Skipping in user-local mode."
            log "INFO" "💡 Ask admin to run: sudo snap install espanso --classic"
        else
            # Try snap first (most common on Ubuntu)
            if command -v snap &> /dev/null; then
                sudo snap install espanso --classic 2>/dev/null && log "INFO" "✅ Espanso installed via snap"
            # Fallback to manual install
            elif [ "$ARCH" = "x86_64" ]; then
                cd /tmp
                curl -sLO "https://github.com/espanso/espanso/releases/latest/download/espanso-debian-x11-amd64.deb"
                sudo dpkg -i espanso-debian-x11-amd64.deb 2>/dev/null || sudo apt-get install -f -y 2>/dev/null
                rm -f espanso-debian-x11-amd64.deb
                cd - > /dev/null
                command -v espanso &> /dev/null && log "INFO" "✅ Espanso installed"
            fi
        fi
    else
        log "INFO" "✅ Espanso already installed: $(espanso --version 2>/dev/null || echo 'installed')"
    fi
fi

# Configurer Starship avec détection automatique de l'environnement
if [ -d "$SOURCE_DIR/starship" ]; then
    log "INFO" "Setting up Starship with environment detection..."
    mkdir -p "$HOME/.config"
    
    # Rendre le script de commutation exécutable
    if [ -f "$SOURCE_DIR/starship/starship-switch.sh" ]; then
        chmod +x "$SOURCE_DIR/starship/starship-switch.sh"
        log "INFO" "Made starship-switch.sh executable"
        
        # Appliquer la configuration automatique
        "$SOURCE_DIR/starship/starship-switch.sh" auto
        log "INFO" "✅ Starship configuration applied with environment detection"
    else
        # Fallback: lier la configuration par défaut
        create_symlink "$SOURCE_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
        log "INFO" "✅ Starship config linked to $HOME/.config/starship.toml (fallback)"
    fi
fi

# Configurer tmux
if [ -f "$SOURCE_DIR/.tmux.conf" ]; then
    log "INFO" "Setting up tmux configuration..."
    create_symlink "$SOURCE_DIR/.tmux.conf" "$HOME/.tmux.conf"
    log "INFO" "✅ Tmux config linked to $HOME/.tmux.conf"
fi

# Lier d'autres configs si présentes
# Shell configuration is now integrated via shell-integration.sh
# Add to your ~/.bashrc: source $SCRIPT_DIR/nvim/shell-integration.sh

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

# Configurer Neovim comme éditeur par défaut
if command -v nvim &> /dev/null; then
    if ! grep -q "export VISUAL=nvim" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# Set default editor" >> "$HOME/.bashrc"
        echo "export VISUAL=nvim" >> "$HOME/.bashrc"
        echo "export EDITOR=nvim" >> "$HOME/.bashrc"
        log "INFO" "✅ Set Neovim as default editor (VISUAL/EDITOR)"
    else
        log "INFO" "✅ Neovim already set as default editor"
    fi
fi

# Ajouter les aliases utiles à ~/.bashrc
if ! grep -q "# Productivity aliases" "$HOME/.bashrc" 2>/dev/null; then
    echo "" >> "$HOME/.bashrc"
    echo "# Productivity aliases" >> "$HOME/.bashrc"
    echo "alias re='source ~/.bashrc && echo \"✓ Shell reloaded\"'" >> "$HOME/.bashrc"
    echo "alias reload='source ~/.bashrc && echo \"✓ Shell reloaded\"'" >> "$HOME/.bashrc"
    echo "alias clr='clear && echo \"✓ Cleared\"'" >> "$HOME/.bashrc"
    echo "alias h='history'" >> "$HOME/.bashrc"
    echo "alias c='claude'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Navigation shortcuts (shows first 10 items)" >> "$HOME/.bashrc"
    echo "alias ..='cd .. && (l=\$(ls -p 2>/dev/null | head -10 | xargs); [ -z \"\$l\" ] && echo \"📁 Vide\" || echo \"\$l\")'" >> "$HOME/.bashrc"
    echo "alias ...='cd ../.. && (l=\$(ls -p 2>/dev/null | head -10 | xargs); [ -z \"\$l\" ] && echo \"📁 Vide\" || echo \"\$l\")'" >> "$HOME/.bashrc"
    echo "alias ....='cd ../../.. && (l=\$(ls -p 2>/dev/null | head -10 | xargs); [ -z \"\$l\" ] && echo \"📁 Vide\" || echo \"\$l\")'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Git shortcuts" >> "$HOME/.bashrc"
    echo "alias gs='git status'" >> "$HOME/.bashrc"
    echo "alias ga='git add . && echo \"✓ All files staged\"'" >> "$HOME/.bashrc"
    echo "gc() { git commit -m \"\${1:-up}\"; }" >> "$HOME/.bashrc"
    echo "alias gf='git fetch'" >> "$HOME/.bashrc"
    echo "alias gp='git push'" >> "$HOME/.bashrc"
    echo "alias gl='git pull'" >> "$HOME/.bashrc"
    echo "alias gd='git diff'" >> "$HOME/.bashrc"
    echo "alias gr='git restore'" >> "$HOME/.bashrc"
    echo "alias glog='git log --oneline --graph'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Better tools (if installed)" >> "$HOME/.bashrc"
    echo "command -v bat >/dev/null && alias cat='bat --paging=never'" >> "$HOME/.bashrc"
    echo "command -v lsd >/dev/null && alias ls='lsd' && alias ll='lsd -lh' && alias la='lsd -lAh' && alias lt='lsd --tree --depth 2'" >> "$HOME/.bashrc"
    echo "command -v trash-put >/dev/null && alias tp='trash-put' && alias tl='trash-list' && alias tr='trash-restore' && alias te='trash-empty'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# File managers" >> "$HOME/.bashrc"
    echo "alias r='ranger'" >> "$HOME/.bashrc"
    echo "alias y='yazi'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# Doppler shortcuts" >> "$HOME/.bashrc"
    echo "alias ds='bash $SOURCE_DIR/doppler-setup.sh'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# AI coding tools" >> "$HOME/.bashrc"
    echo "alias k='kilocode'" >> "$HOME/.bashrc"
    echo "alias o='opencode'" >> "$HOME/.bashrc"
    echo "" >> "$HOME/.bashrc"
    echo "# SSH/Mosh connections" >> "$HOME/.bashrc"
    echo "alias root='mosh root@5.75.134.202 -- sh -c \"tmux a || tmux\"'" >> "$HOME/.bashrc"
    echo "alias cuser='mosh claude@5.75.134.202 -- sh -c \"tmux a || tmux\"'" >> "$HOME/.bashrc"
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
    echo "    elif [ -f \"\$SOURCE_DIR/doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"\$SOURCE_DIR/doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    elif [ -f \"\$HOME/dotfiles/doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"\$HOME/dotfiles/doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    elif [ -f \"\$HOME/storage/shared/dotfiles/doppler-setup.sh\" ]; then" >> "$HOME/.bashrc"
    echo "        script=\"\$HOME/storage/shared/dotfiles/doppler-setup.sh\"" >> "$HOME/.bashrc"
    echo "    else" >> "$HOME/.bashrc"
    echo "        echo \"❌ doppler-setup.sh not found. Searched: \$HOME/.config/nvim/../, \$SOURCE_DIR/, \$HOME/dotfiles/, \$HOME/storage/shared/dotfiles/\"" >> "$HOME/.bashrc"
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
if [ "${AUTO_INSTALL_NVIM_PLUGINS:-false}" = "true" ]; then
    log "INFO" "📥 Installing Neovim plugins (AUTO_INSTALL_NVIM_PLUGINS=true)..."
    if command -v nvim &> /dev/null; then
        nvim --headless "+Lazy! sync" +qa >/tmp/nvim-install.log 2>&1 || log "WARN" "Plugin installation had issues, but this is usually fine"
        log "INFO" "✅ Neovim plugins installed"
    else
        log "WARN" "⚠️  Neovim not found, skipping plugin installation"
    fi
else
    # Deferred installation (default)
    log "INFO" "⏭️  Skipping automatic plugin installation (plugins will install on first Neovim launch)"
    log "INFO" "💡 Tip: Plugins will auto-install when you first run 'nvim' (~130 plugins, takes 2-3 minutes)"
    log "INFO" "💡 Or set AUTO_INSTALL_NVIM_PLUGINS=true in .env to install during setup"
fi

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

# --- 7. Doppler Authentication (non-interactive via DOPPLER_TOKEN) ---
echo "════════════════════════════════════════════════════════════════"
echo ""

if command -v doppler &> /dev/null; then
    # Try non-interactive authentication first (via DOPPLER_TOKEN from .env)
    if [ ! -z "${DOPPLER_TOKEN}" ]; then
        log "INFO" "🔐 Authenticating Doppler with service token from .env..."
        export DOPPLER_TOKEN="${DOPPLER_TOKEN}"
        
        if doppler me &>/dev/null 2>&1; then
            log "INFO" "✅ Doppler authenticated via service token"
            DOPPLER_AUTHENTICATED=true
        else
            log "WARN" "⚠️  Doppler token authentication failed"
            DOPPLER_AUTHENTICATED=false
        fi
    # Check if already authenticated
    elif doppler me &>/dev/null 2>&1; then
        log "INFO" "✅ Doppler already authenticated"
        DOPPLER_AUTHENTICATED=true
    else
        log "INFO" "⚠️  Doppler not authenticated"
        DOPPLER_AUTHENTICATED=false
        
        # Interactive mode: offer to configure
        if [ -t 0 ]; then
            read -p "🔐 Configure Doppler API keys now? (y/N): " SETUP_DOPPLER
            
            if [ "$SETUP_DOPPLER" = "y" ] || [ "$SETUP_DOPPLER" = "Y" ]; then
                if [ -f "$SOURCE_DIR/doppler-setup.sh" ]; then
                    log "INFO" "🚀 Launching Doppler setup..."
                    bash "$SOURCE_DIR/doppler-setup.sh"
                else
                    log "WARN" "⚠️  doppler-setup.sh not found"
                    echo "⚠️  Run manually: ./doppler-setup.sh"
                fi
            else
                echo "⏭️  Doppler setup skipped"
                echo "💡 Setup later with: ds (alias for doppler-setup.sh)"
                echo "💡 Or add DOPPLER_TOKEN to .env for auto-auth"
            fi
        else
            # Non-interactive: skip prompt
            log "INFO" "🤖 Non-interactive mode: Doppler setup skipped"
            echo "💡 To auto-authenticate: Add DOPPLER_TOKEN to .env"
            echo "💡 Get service token: https://dashboard.doppler.com → Project → Access → Service Tokens"
        fi
    fi
else
    log "WARN" "⚠️  Doppler CLI not installed. Skipping configuration."
    echo "💡 Install Doppler, then run: ./doppler-setup.sh"
fi

# --- 8. GitHub CLI Authentication (with .env, Doppler, or manual fallback) ---
echo ""
log "INFO" "🔐 Setting up GitHub CLI..."

GH_TOKEN_FINAL=""

# Try 1: .env file token (highest priority)
if [ ! -z "${GH_TOKEN}" ] || [ ! -z "${GITHUB_TOKEN}" ]; then
    GH_TOKEN_FINAL="${GH_TOKEN:-${GITHUB_TOKEN}}"
    log "INFO" "Found GitHub token in .env file"
fi

# Try 2: Doppler token (if .env empty and Doppler authenticated)
if [ -z "$GH_TOKEN_FINAL" ] && [ "${DOPPLER_AUTHENTICATED:-false}" = "true" ]; then
    GH_TOKEN_FINAL=$(doppler secrets get GH_TOKEN --plain 2>/dev/null || doppler secrets get GITHUB_TOKEN --plain 2>/dev/null)
    
    if [ ! -z "$GH_TOKEN_FINAL" ]; then
        log "INFO" "Found GitHub token in Doppler"
    fi
fi

# Authenticate if we have a token
if [ ! -z "$GH_TOKEN_FINAL" ]; then
    log "INFO" "Authenticating with GitHub token..."
    echo "$GH_TOKEN_FINAL" | gh auth login --with-token >/dev/null 2>&1
    
    if gh auth status &>/dev/null 2>&1; then
        log "INFO" "✅ GitHub authenticated successfully"
    else
        log "WARN" "⚠️ Token authentication failed, manual login needed"
    fi
# Check if already authenticated
elif gh auth status &>/dev/null 2>&1; then
    log "INFO" "✅ GitHub already authenticated"
# No token and not authenticated
else
    log "INFO" "⚠️ GitHub not authenticated"
    log "INFO" "📝 Add GH_TOKEN to .env, setup Doppler, or run: gh auth login"
    
    if [ ! -t 0 ]; then
        # Non-interactive (Codespaces auto-run)
        log "INFO" "🤖 Non-interactive mode: skipping auth prompt"
        log "INFO" "💡 Quick setup: run 'ds' (doppler-setup.sh) then re-run ./install.sh"
    else
        # Interactive mode
        read -p "Authenticate now? (y/N): " AUTH_NOW
        if [ "$AUTH_NOW" = "y" ] || [ "$AUTH_NOW" = "Y" ]; then
            gh auth login
        fi
    fi
fi

# Display mode-specific summary
if [ "$USER_LOCAL_MODE" = "true" ]; then
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "📦 USER-LOCAL MODE SUMMARY"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "✅ Installed to user directories (no sudo required):"
    echo "   • ~/.local/bin     - binaries (nvim, fzf, starship, etc.)"
    echo "   • ~/.npm-global    - npm packages"
    echo "   • ~/.config        - configuration files"
    echo ""
    echo "⚠️  Some features may be limited without sudo:"
    echo "   • System packages (git, curl) - must be pre-installed"
    echo "   • Espanso - requires snap/dpkg install by admin"
    echo "   • xclip - X11 clipboard (server environments)"
    echo ""
    echo "💡 For BuildFlowz/Caddy operations, use your sudo-enabled session"
    echo ""
fi

echo ""
echo "🎊 Installation complète! Profitez bien de votre environnement!"