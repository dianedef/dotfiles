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

# Vérifier si unzip est installé
if ! command -v unzip &> /dev/null; then
    log "INFO" "Installing unzip..."
    pkg install -y unzip >/dev/null 2>&1
fi

FONT_INSTALLED=false

if [ ! -f "$FONT_DIR/font.ttf" ]; then
    log "INFO" "Downloading JetBrainsMono Nerd Font..."
    cd "$HOME/tmp" || cd /tmp
    
    # Télécharger JetBrainsMono Nerd Font (version complète avec icônes)
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"
    
    if curl -fsSL "$FONT_URL" -o JetBrainsMono.zip; then
        log "INFO" "Download complete, extracting..."
        
        if unzip -q JetBrainsMono.zip "JetBrainsMonoNerdFont-Regular.ttf" 2>/dev/null; then
            if [ -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
                cp "JetBrainsMonoNerdFont-Regular.ttf" "$FONT_DIR/font.ttf"
                chmod 644 "$FONT_DIR/font.ttf"
                log "INFO" "✅ Nerd Font installed to ~/.termux/font.ttf"
                FONT_INSTALLED=true
            else
                log "WARN" "⚠️  Font file not found after extraction"
            fi
        else
            log "WARN" "⚠️  Failed to extract font from zip"
        fi
        
        rm -rf JetBrainsMono.zip JetBrainsMono* *.ttf *.otf 2>/dev/null
    else
        log "ERROR" "❌ Failed to download Nerd Font from GitHub"
        log "INFO" "💡 Alternative: Install 'Termux:Styling' app from F-Droid"
    fi
    
    cd - > /dev/null
else
    log "INFO" "✅ Nerd Font already configured in ~/.termux/font.ttf"
    FONT_INSTALLED=true
fi

# --- 3. Outils légers uniquement ---
log "INFO" "📦 Installing lightweight tools..."

# Create bin directories first
mkdir -p "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/tmp"

# Starship (prompt)
if ! command -v starship &> /dev/null; then
    log "INFO" "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$HOME/.local/bin" >/dev/null 2>&1
    if [ $? -eq 0 ] && [ -f "$HOME/.local/bin/starship" ]; then
        log "INFO" "✅ Starship installed to ~/.local/bin"
    else
        log "ERROR" "❌ Starship installation failed"
    fi
else
    log "INFO" "✅ Starship already installed"
fi

# Zoxide (smart cd) - available in Termux repos
if ! command -v zoxide &> /dev/null; then
    log "INFO" "Installing Zoxide..."
    pkg install -y zoxide >/dev/null 2>&1
    if command -v zoxide &> /dev/null; then
        log "INFO" "✅ Zoxide installed via pkg"
    else
        log "ERROR" "❌ Zoxide installation failed"
    fi
else
    log "INFO" "✅ Zoxide already installed"
fi

# Doppler (secret management)
if ! command -v doppler &> /dev/null; then
    log "INFO" "Installing Doppler..."
    # Doppler requires architecture detection
    ARCH=$(uname -m)
    case $ARCH in
        aarch64|arm64)
            DOPPLER_ARCH="arm64"
            ;;
        x86_64|amd64)
            DOPPLER_ARCH="amd64"
            ;;
        *)
            log "WARN" "⚠️ Unsupported architecture: $ARCH (skipping Doppler)"
            DOPPLER_ARCH=""
            ;;
    esac
    
    if [ ! -z "$DOPPLER_ARCH" ]; then
        # Download Doppler CLI for Linux ARM64/AMD64
        DOPPLER_URL="https://cli.doppler.com/install.sh"
        curl -sL "$DOPPLER_URL" | sh -s -- --no-install --no-package-manager >/dev/null 2>&1
        
        if [ -f "./doppler" ]; then
            mv ./doppler "$HOME/.local/bin/doppler"
            chmod +x "$HOME/.local/bin/doppler"
            log "INFO" "✅ Doppler installed to ~/.local/bin"
        else
            log "ERROR" "❌ Doppler installation failed"
        fi
    fi
else
    log "INFO" "✅ Doppler already installed"
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
    echo '[ -f "$HOME/dotfiles/nvim/shell-integration.sh" ] && source "$HOME/dotfiles/nvim/shell-integration.sh"' >> "$BASHRC"
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
    echo 'command -v starship >/dev/null && eval "$(starship init bash)"' >> "$BASHRC"
    log "INFO" "✅ Added Starship to bashrc"
fi

# Zoxide (check PATH after adding it above)
if ! grep -q "zoxide init" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# Zoxide' >> "$BASHRC"
    echo 'command -v zoxide >/dev/null && eval "$(zoxide init bash)"' >> "$BASHRC"
    log "INFO" "✅ Added Zoxide to bashrc"
fi

# Aliases essentiels - Toujours écraser pour avoir la dernière version
# Remove old aliases block (between markers)
sed -i '/# Termux aliases/,/# END Termux aliases/d' "$BASHRC" 2>/dev/null
cat >> "$BASHRC" << 'EOF'

# Termux aliases
alias reload='source "$HOME/.bashrc" && echo "✓ Shell rechargé!"'
alias i='bash ~/dotfiles/termux.sh'
alias ds='bash ~/dotfiles/doppler-setup.sh'
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

# AI Agents
alias ai='aider'
alias shk='sheikh'
alias cx='cd ~/codex-termux && python codex.py'
alias ao='proot-distro login alpine -- /bin/sh -c "cd /root/opencode_termux_alpine_aarch64 && ./opencode-termux-wrapper.sh"'

# END Termux aliases
EOF
log "INFO" "✅ Added/Updated Termux aliases"

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
            
            # --- OpenCode Authentication & AI Providers (with Doppler) ---
            log "INFO" "🔐 Setting up OpenCode authentication & AI providers..."
            
            # Try Doppler for OpenCode + AI providers (automated)
            if command -v doppler &>/dev/null && doppler me &>/dev/null; then
                OPENCODE_KEY=$(doppler secrets get OPENCODE_API_KEY --plain 2>/dev/null)
                OPENAI_KEY=$(doppler secrets get OPENAI_API_KEY --plain 2>/dev/null)
                ANTHROPIC_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain 2>/dev/null)
                GEMINI_KEY=$(doppler secrets get GEMINI_AI --plain 2>/dev/null)
                GROQ_KEY=$(doppler secrets get GROQ --plain 2>/dev/null)
                
                # Configure OpenCode auth + AI provider keys in Alpine
                if [ ! -z "$OPENCODE_KEY" ] || [ ! -z "$OPENAI_KEY" ] || [ ! -z "$ANTHROPIC_KEY" ]; then
                    log "INFO" "Configuring OpenCode with Doppler secrets..."
                    proot-distro login alpine -- /bin/sh -c "
                        # OpenCode auth
                        mkdir -p /root/.opencode
                        echo '{\"apiKey\":\"$OPENCODE_KEY\"}' > /root/.opencode/config.json
                        chmod 600 /root/.opencode/config.json
                        
                        # AI Provider environment variables in Alpine profile
                        cat >> /root/.profile << 'PROFILE_EOF'

# AI Provider API Keys (from Doppler)
export OPENAI_API_KEY='$OPENAI_KEY'
export ANTHROPIC_API_KEY='$ANTHROPIC_KEY'
export GOOGLE_GENERATIVE_AI_API_KEY='$GEMINI_KEY'
export GROQ_API_KEY='$GROQ_KEY'
PROFILE_EOF
                    " 2>/dev/null
                    
                    if [ $? -eq 0 ]; then
                        log "INFO" "✅ OpenCode + AI providers configured via Doppler"
                        [ ! -z "$OPENAI_KEY" ] && log "INFO" "   • OpenAI (GPT)"
                        [ ! -z "$ANTHROPIC_KEY" ] && log "INFO" "   • Anthropic (Claude)"
                        [ ! -z "$GEMINI_KEY" ] && log "INFO" "   • Google (Gemini)"
                        [ ! -z "$GROQ_KEY" ] && log "INFO" "   • Groq"
                    else
                        log "WARN" "⚠️ Doppler configuration failed"
                    fi
                else
                    log "INFO" "⚠️ No API keys found in Doppler"
                fi
            fi
            
            # Check if authenticated, otherwise prompt
            OPENCODE_CONFIGURED=$(proot-distro login alpine -- /bin/sh -c "test -f /root/.opencode/config.json && echo 'yes' || echo 'no'" 2>/dev/null)
            
            if [ "$OPENCODE_CONFIGURED" != "yes" ]; then
                log "INFO" "⚠️ OpenCode not authenticated"
                log "INFO" "📝 To authenticate later:"
                log "INFO" "   1. proot-distro login alpine"
                log "INFO" "   2. cd /root/opencode_termux_alpine_aarch64"
                log "INFO" "   3. opencode auth login"
                
                read -p "Authenticate OpenCode now? (y/N): " AUTH_OC
                if [ "$AUTH_OC" = "y" ] || [ "$AUTH_OC" = "Y" ]; then
                    proot-distro login alpine -- /bin/sh -c "cd /root/opencode_termux_alpine_aarch64 && opencode auth login"
                fi
            fi
            
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
echo ""
echo "🎨 CONFIGURATION DES ICÔNES (Nerd Font):"
if [ -f "$HOME/.termux/font.ttf" ]; then
    echo "✅ Font installée dans ~/.termux/font.ttf"
    echo ""
    echo "📱 Pour activer les icônes dans Neovim:"
    echo "   1. TUEZ complètement l'app Termux:"
    echo "      • Paramètres Android > Apps > Termux > Forcer l'arrêt"
    echo "      • Ou glissez Termux hors du multitâche"
    echo "   2. Rouvrez Termux"
    echo "   3. Lancez Neovim: nvim"
    echo ""
    echo "🧪 Testez si les icônes fonctionnent:"
    echo "   echo '    '"
    echo ""
fi
echo "❌ Si les icônes ne s'affichent TOUJOURS PAS après redémarrage:"
echo "   Solution recommandée: Installez 'Termux:Styling' (officiel)"
echo "   1. Ouvrez F-Droid"
echo "   2. Cherchez 'Termux:Styling'"
echo "   3. Installez l'app"
echo "   4. Lancez Termux:Styling et choisissez une Nerd Font"
echo ""
echo "   Alternative: Supprimez ~/.termux/font.ttf pour désactiver"
echo ""
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
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 ALIASES DISPONIBLES (ajoutés à ~/.bashrc):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔄 Système:"
echo "   reload       → Recharger .bashrc"
echo "   i            → Relancer le script d'installation"
echo "   cls          → Effacer l'écran (clear)"
echo "   ..           → cd .."
echo "   ...          → cd ../.."
echo ""
echo "📁 Git:"
echo "   gs           → git status"
echo "   ga           → git add ."
echo "   gc <msg>     → git commit -m '<msg>'"
echo "   gp           → git push"
echo "   gl           → git pull"
echo "   gd           → git diff"
echo ""
echo "📱 Termux:"
echo "   termux-wake  → Garder l'écran allumé"
echo "   termux-sleep → Autoriser veille"
echo "   storage      → cd ~/storage/shared"
echo "   dl           → cd ~/storage/downloads"
echo ""
echo "📂 File Managers:"
echo "   r            → ranger"
echo ""
echo "🤖 AI Agents (terminal):"
echo "   ai           → Aider (AI pair programming)"
echo "   shk          → Sheikh CLI assistant"
echo "   cx           → Codex-Termux"
echo "   ao           → OpenCode (Alpine proot)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- GitHub CLI Authentication (with Doppler fallback) ---
log "INFO" "🔐 Setting up GitHub CLI..."

# Try 1: Doppler token (automated)
if command -v doppler &>/dev/null && doppler me &>/dev/null; then
    GH_TOKEN=$(doppler secrets get GH_TOKEN --plain 2>/dev/null || doppler secrets get GITHUB_TOKEN --plain 2>/dev/null)
    
    if [ ! -z "$GH_TOKEN" ]; then
        log "INFO" "Authenticating with Doppler token..."
        echo "$GH_TOKEN" | gh auth login --with-token >/dev/null 2>&1
        
        if gh auth status &>/dev/null; then
            log "INFO" "✅ GitHub authenticated via Doppler"
        else
            log "WARN" "⚠️ Doppler token failed, manual login needed"
            GH_TOKEN=""
        fi
    fi
fi

# Try 2: Already authenticated
if [ -z "$GH_TOKEN" ] && gh auth status &>/dev/null; then
    log "INFO" "✅ GitHub already authenticated"

# Try 3: Manual login (interactive fallback)
elif [ -z "$GH_TOKEN" ]; then
    log "INFO" "⚠️ GitHub not authenticated"
    log "INFO" "📝 Run: gh auth login  (or setup Doppler with GH_TOKEN)"
    
    read -p "Authenticate now? (y/N): " AUTH_NOW
    if [ "$AUTH_NOW" = "y" ] || [ "$AUTH_NOW" = "Y" ]; then
        gh auth login
    fi
fi

# --- Git Identity Configuration ---
log "INFO" "👤 Configuring Git identity..."
git config --global user.name "Diane"
git config --global user.email "deforesd@gmail.com"
log "INFO" "✅ Git identity configured"
