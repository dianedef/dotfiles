#!/bin/bash

# Script d'installation des dotfiles pour GitHub Codespaces

echo "🚀 Starting dotfiles installation..."

# --- 1. Installation de Neovim ---
echo "📦 Installing Neovim..."

# Méthode 1 : Essayer via AppImage (la plus fiable pour Codespaces)
install_neovim_appimage() {
    echo "Installing Neovim via AppImage..."
    cd /tmp
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    sudo mv nvim.appimage /usr/local/bin/nvim
    
    # Vérifier si ça fonctionne, sinon extraire l'AppImage
    if ! /usr/local/bin/nvim --version &> /dev/null; then
        echo "AppImage needs extraction..."
        cd /tmp
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        ./nvim.appimage --appimage-extract
        sudo mv squashfs-root /opt/nvim
        sudo ln -sf /opt/nvim/usr/bin/nvim /usr/local/bin/nvim
    fi
}

# Méthode 2 : Via le package Ubuntu (version plus ancienne mais stable)
install_neovim_apt() {
    echo "Installing Neovim via apt..."
    sudo apt-get update
    sudo apt-get install -y neovim
}

# Essayer l'AppImage d'abord, sinon utiliser apt
if ! command -v nvim &> /dev/null; then
    install_neovim_appimage || install_neovim_apt
fi

# Vérifier l'installation
if command -v nvim &> /dev/null; then
    echo "✅ Neovim installed successfully: $(nvim --version | head -n 1)"
else
    echo "❌ Neovim installation failed"
    exit 1
fi

# --- 2. Installation des dépendances ---
echo "📦 Installing dependencies..."

sudo apt-get update
sudo apt-get install -y \
  git \
  curl \
  wget \
  unzip \
  build-essential \
  python3-pip \
  ripgrep \
  fd-find \
  xclip

# Créer un lien pour fd (fd-find sur Ubuntu)
if [ -f /usr/bin/fdfind ] && [ ! -f /usr/bin/fd ]; then
    sudo ln -s /usr/bin/fdfind /usr/bin/fd
fi

# Installer Node.js si nécessaire
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# --- 3. Configuration de LazyVim ---
echo "⚙️ Setting up LazyVim..."

NVIM_CONFIG_DIR="$HOME/.config/nvim"

# Sauvegarder la config existante
if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "Backing up existing Neovim config..."
    mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%s)"
fi

# Cloner LazyVim starter
git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
rm -rf "$NVIM_CONFIG_DIR/.git"

# --- 4. Liens symboliques pour vos dotfiles personnalisés ---
echo "🔗 Creating symlinks for custom configs..."

SOURCE_DIR="$HOME/dotfiles"

# Fonction pour créer les liens symboliques
create_symlink() {
    local SOURCE=$1
    local TARGET=$2
    
    if [ ! -e "$SOURCE" ]; then
        echo "⚠️  Source $SOURCE does not exist, skipping..."
        return
    fi
    
    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        echo "Removing existing $TARGET..."
        rm -rf "$TARGET"
    fi
    
    mkdir -p "$(dirname "$TARGET")"
    
    echo "Creating symlink: $TARGET -> $SOURCE"
    ln -s "$SOURCE" "$TARGET"
}

# Lier votre configuration nvim personnalisée (si elle existe dans dotfiles/nvim)
if [ -d "$SOURCE_DIR/nvim" ]; then
    echo "Linking custom nvim config..."
    # Supprimer le starter LazyVim et utiliser votre config
    rm -rf "$NVIM_CONFIG_DIR"
    create_symlink "$SOURCE_DIR/nvim" "$NVIM_CONFIG_DIR"
fi

# Lier yazi (si présent)
if [ -d "$SOURCE_DIR/yazi" ]; then
    echo "Linking yazi config..."
    create_symlink "$SOURCE_DIR/yazi" "$HOME/.config/yazi"
fi

# Lier d'autres configs si présentes
if [ -f "$SOURCE_DIR/.bashrc" ]; then
    echo "Linking .bashrc..."
    create_symlink "$SOURCE_DIR/.bashrc" "$HOME/.bashrc"
fi

if [ -f "$SOURCE_DIR/.zshrc" ]; then
    echo "Linking .zshrc..."
    create_symlink "$SOURCE_DIR/.zshrc" "$HOME/.zshrc"
fi

# --- 5. Installation des plugins Neovim ---
echo "📥 Installing Neovim plugins..."

# Installer les plugins en mode headless
nvim --headless "+Lazy! sync" +qa 2>&1 | tee /tmp/nvim-install.log

echo ""
echo "✨ Dotfiles installation complete!"
echo "🎉 Run 'nvim' to start Neovim with LazyVim"
echo ""
echo "📝 Installation log saved to /tmp/nvim-install.log"