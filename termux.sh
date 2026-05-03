#!/usr/bin/env bash

# Script d'installation ALLÉGÉ pour Termux (Android)
# Version minimaliste - pas de copilot, neovim léger, outils essentiels seulement

## Configuration logging
LOG_FILE="${TERMUX_DOTFILES_LOG_FILE:-$HOME/termux-install.log}"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    case "$level" in
        INFO|ERROR|WARN) echo "$message" ;;
    esac
}

log "INFO" "🤖 Starting TERMUX dotfiles installation (lightweight)"

if ! command -v pkg >/dev/null 2>&1; then
    log "ERROR" "❌ This installer must run inside Termux (pkg command not found)"
    exit 1
fi

mkdir -p "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/tmp"

write_sgpt_config() {
    local key="$1"
    local sgpt_dir="$HOME/.config/shell_gpt"
    local sgpt_file="$sgpt_dir/.sgptrc"
    local previous_umask
    previous_umask="$(umask)"

    mkdir -p "$sgpt_dir" || return 1
    umask 077
    # Keep .sgptrc shell-safe and private even with special chars/newlines in keys.
    if ! printf 'OPENAI_API_KEY=%q\n' "$key" > "$sgpt_file"; then
        umask "$previous_umask"
        return 1
    fi
    umask "$previous_umask"
    chmod 600 "$sgpt_file" 2>/dev/null || return 1
}

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
  gh \
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
    FONT_TMP_DIR="$(mktemp -d "$HOME/tmp/nerd-font.XXXXXX")"

    # Télécharger JetBrainsMono Nerd Font (version complète avec icônes)
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"

    if curl -fsSL "$FONT_URL" -o "$FONT_TMP_DIR/JetBrainsMono.zip"; then
        log "INFO" "Download complete, extracting..."

        if unzip -q "$FONT_TMP_DIR/JetBrainsMono.zip" "JetBrainsMonoNerdFont-Regular.ttf" -d "$FONT_TMP_DIR" 2>/dev/null; then
            if [ -f "$FONT_TMP_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
                cp "$FONT_TMP_DIR/JetBrainsMonoNerdFont-Regular.ttf" "$FONT_DIR/font.ttf"
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

    rm -rf "$FONT_TMP_DIR"
else
    log "INFO" "✅ Nerd Font already configured in ~/.termux/font.ttf"
    FONT_INSTALLED=true
fi

# --- 3. Outils légers uniquement ---
log "INFO" "📦 Installing lightweight tools..."

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

    if [ -n "$DOPPLER_ARCH" ]; then
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

# --- 5. Symlinks ---
log "INFO" "🔗 Creating symlinks..."

next_backup_path() {
    local TARGET=$1
    local BACKUP_PATH="${TARGET}.backup.$(date +%s)"
    local SUFFIX=1

    while [ -e "$BACKUP_PATH" ] || [ -L "$BACKUP_PATH" ]; do
        BACKUP_PATH="${TARGET}.backup.$(date +%s).$SUFFIX"
        SUFFIX=$((SUFFIX + 1))
    done

    echo "$BACKUP_PATH"
}

create_symlink() {
    local SOURCE=$1
    local TARGET=$2
    local SOURCE_REAL

    [ ! -e "$SOURCE" ] && { log "WARN" "⚠️  $SOURCE not found"; return; }
    SOURCE_REAL="$(readlink -f "$SOURCE" 2>/dev/null || echo "$SOURCE")"

    if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
        if [ -L "$TARGET" ]; then
            local TARGET_REAL
            TARGET_REAL="$(readlink -f "$TARGET" 2>/dev/null || true)"
            if [ "$TARGET_REAL" = "$SOURCE_REAL" ]; then
                log "INFO" "Already linked: $TARGET -> $SOURCE"
                return
            fi
            if ! rm -f "$TARGET"; then
                log "ERROR" "Failed to remove stale symlink: $TARGET"
                return 1
            fi
            log "INFO" "Removed stale symlink: $TARGET"
        else
            local BACKUP_PATH
            BACKUP_PATH="$(next_backup_path "$TARGET")"
            if ! mv "$TARGET" "$BACKUP_PATH"; then
                log "ERROR" "Failed to back up existing target: $TARGET -> $BACKUP_PATH"
                return 1
            fi
            log "WARN" "Existing target backed up: $TARGET -> $BACKUP_PATH"
        fi
    fi

    mkdir -p "$(dirname "$TARGET")"
    if ! ln -s "$SOURCE" "$TARGET"; then
        log "ERROR" "Failed to link: $TARGET -> $SOURCE"
        return 1
    fi
    log "INFO" "Linked: $TARGET -> $SOURCE"
}

# Neovim config - Use MyNeovimTermux, fallback to MyNeovim
if [ -d "$SOURCE_DIR/nvim/MyNeovimTermux" ]; then
    create_symlink "$SOURCE_DIR/nvim/MyNeovimTermux" "$NVIM_CONFIG_DIR"
elif [ -d "$SOURCE_DIR/nvim/MyNeovim" ]; then
    create_symlink "$SOURCE_DIR/nvim/MyNeovim" "$NVIM_CONFIG_DIR"
fi

# Termux properties
[ -f "$SOURCE_DIR/termux/termux.properties" ] && create_symlink "$SOURCE_DIR/termux/termux.properties" "$HOME/.termux/termux.properties"

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
alias dot='~/dotfiles/termux.sh'
alias dotfiles='~/dotfiles/termux.sh'
alias ds='bash ~/dotfiles/doppler-setup-termux.sh'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

# Git shortcuts
alias gs='git status'
alias ga='git add .'
gc() { git commit -m "${1:-up}"; }
function gp { if [ -n "$(git status --porcelain)" ]; then git add -A && git commit -m "${1:-up}"; fi; git push; }
alias gl='git pull'
alias gd='git diff'

# Codespace
alias cs='gh cs ssh'                 # SSH into any codespace (interactive)

# Termux specific
alias termux-wake='termux-wake-lock'
alias termux-sleep='termux-wake-unlock'
alias storage='cd ~/storage/shared'
alias dl='cd ~/storage/downloads'

# File managers
alias r='ranger'

# AI Agents (verified working on Termux)
alias ai='llm'                       # LLM CLI - multi-provider (Gemini, Claude, GPT)
alias gpt='sgpt'                     # Shell-GPT - quick OpenAI queries
alias chat='llm chat'                # Interactive chat mode

# END Termux aliases
EOF
log "INFO" "✅ Added/Updated Termux aliases"

# --- 7. AI Coding Agents Installation ---
log "INFO" "🤖 Installing AI coding agents..."

# Shell-GPT (sgpt) - Lightweight, works great on Termux
if ! command -v sgpt &> /dev/null; then
    log "INFO" "Installing Shell-GPT (sgpt)..."
    pip install shell-gpt >/dev/null 2>&1
    if command -v sgpt &> /dev/null; then
        log "INFO" "✅ Shell-GPT installed"
    else
        log "WARN" "⚠️  Shell-GPT installation failed"
    fi
else
    log "INFO" "✅ Shell-GPT already installed"
fi

# LLM by Simon Willison - Multi-provider support with plugins
if ! command -v llm &> /dev/null; then
    log "INFO" "Installing LLM CLI..."
    pip install llm >/dev/null 2>&1
    if command -v llm &> /dev/null; then
        log "INFO" "✅ LLM CLI installed"

        # Install Gemini plugin (lightweight, free tier available)
        log "INFO" "Installing LLM plugins (Gemini, Claude)..."
        llm install llm-gemini >/dev/null 2>&1 && log "INFO" "   ✅ Gemini plugin"
        llm install llm-anthropic >/dev/null 2>&1 && log "INFO" "   ✅ Anthropic plugin"
    else
        log "WARN" "⚠️  LLM CLI installation failed"
    fi
else
    log "INFO" "✅ LLM CLI already installed"
fi

# TLDR pages
if ! command -v tldr &> /dev/null; then
    log "INFO" "Installing TLDR pages..."
    npm install -g tldr >/dev/null 2>&1
    if command -v tldr &> /dev/null; then
        log "INFO" "✅ TLDR pages installed"
    else
        log "WARN" "⚠️  TLDR pages installation failed"
    fi
else
    log "INFO" "✅ TLDR pages already installed"
fi

# Configure API keys from Doppler (if available)
if command -v doppler &>/dev/null && doppler me &>/dev/null; then
    log "INFO" "🔐 Configuring AI API keys from Doppler..."

    # Get keys from Doppler
    OPENAI_KEY=$(doppler secrets get OPENAI_API_KEY --plain 2>/dev/null)
    GEMINI_KEY=$(doppler secrets get GEMINI_AI --plain 2>/dev/null)
    ANTHROPIC_KEY=$(doppler secrets get ANTHROPIC_API_KEY --plain 2>/dev/null)

    # Configure LLM CLI keys
    if command -v llm &>/dev/null; then
        [ -n "$OPENAI_KEY" ] && llm keys set openai "$OPENAI_KEY" 2>/dev/null && log "INFO" "   ✅ OpenAI key configured"
        [ -n "$GEMINI_KEY" ] && llm keys set gemini "$GEMINI_KEY" 2>/dev/null && log "INFO" "   ✅ Gemini key configured"
        [ -n "$ANTHROPIC_KEY" ] && llm keys set anthropic "$ANTHROPIC_KEY" 2>/dev/null && log "INFO" "   ✅ Anthropic key configured"
    fi

    # Configure Shell-GPT (uses OPENAI_API_KEY env var)
    if [ -n "$OPENAI_KEY" ]; then
        if write_sgpt_config "$OPENAI_KEY"; then
            log "INFO" "   ✅ Shell-GPT configured"
        else
            log "WARN" "   ⚠️  Shell-GPT config write failed"
        fi
    fi
elif [ -f "$HOME/.dotfiles-secrets.env" ]; then
    log "INFO" "📝 Using local secrets from ~/.dotfiles-secrets.env"
    # shellcheck disable=SC1091
    source "$HOME/.dotfiles-secrets.env"

    if command -v llm &>/dev/null; then
        [ -n "${OPENAI_API_KEY:-}" ] && llm keys set openai "$OPENAI_API_KEY" 2>/dev/null
        [ -n "${GOOGLE_AI_API_KEY:-}" ] && llm keys set gemini "$GOOGLE_AI_API_KEY" 2>/dev/null
        [ -n "${ANTHROPIC_API_KEY:-}" ] && llm keys set anthropic "$ANTHROPIC_API_KEY" 2>/dev/null
    fi

    if [ -n "${OPENAI_API_KEY:-}" ]; then
        if write_sgpt_config "$OPENAI_API_KEY"; then
            log "INFO" "   ✅ Shell-GPT configured from local secrets"
        else
            log "WARN" "   ⚠️  Shell-GPT config write failed from local secrets"
        fi
    fi
else
    log "INFO" "💡 Configure API keys later with: llm keys set <provider>"
    log "INFO" "   Providers: openai, gemini, anthropic"
fi

log "INFO" "✅ AI coding agents setup complete"

# --- GitHub CLI Authentication (with Doppler fallback) ---
log "INFO" "🔐 Setting up GitHub CLI..."
GH_TOKEN="${GH_TOKEN:-}"

# Try 1: Doppler token (automated)
if command -v doppler &>/dev/null && doppler me &>/dev/null; then
    GH_TOKEN=$(doppler secrets get GH_TOKEN --plain 2>/dev/null || doppler secrets get GITHUB_TOKEN --plain 2>/dev/null)

    if [ -n "$GH_TOKEN" ] && command -v gh &>/dev/null; then
        log "INFO" "Authenticating with Doppler token..."
        echo "$GH_TOKEN" | gh auth login --with-token >/dev/null 2>&1

        if gh auth status &>/dev/null; then
            log "INFO" "✅ GitHub authenticated via Doppler"
        else
            log "WARN" "⚠️ Doppler token failed, manual login needed"
            GH_TOKEN=""
        fi
    fi
# Try 1b: Local .env file
elif [ -f "$HOME/.dotfiles-secrets.env" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.dotfiles-secrets.env"

    if [ -n "${GITHUB_TOKEN:-}" ] && command -v gh &>/dev/null; then
        log "INFO" "Authenticating with local .env token..."
        echo "$GITHUB_TOKEN" | gh auth login --with-token >/dev/null 2>&1

        if gh auth status &>/dev/null; then
            log "INFO" "✅ GitHub authenticated via local .env"
        else
            log "WARN" "⚠️ Local token failed, manual login needed"
            GH_TOKEN=""
        fi
    fi
fi

# Try 2: Already authenticated
if ! command -v gh &>/dev/null; then
    log "WARN" "⚠️ GitHub CLI not installed (pkg install gh)"
elif [ -z "$GH_TOKEN" ] && gh auth status &>/dev/null; then
    log "INFO" "✅ GitHub already authenticated"

# Try 3: Manual login (interactive fallback)
elif [ -z "$GH_TOKEN" ]; then
    log "INFO" "⚠️ GitHub not authenticated"
    log "INFO" "📝 Run: gh auth login  (or bash ~/dotfiles/doppler-setup-termux.sh)"

    read -r -p "Authenticate now? (y/N): " AUTH_NOW
    if [ "$AUTH_NOW" = "y" ] || [ "$AUTH_NOW" = "Y" ]; then
        gh auth login
    fi
fi

# --- Git Identity Configuration ---
log "INFO" "👤 Configuring Git identity..."
git config --global user.name "Diane"
git config --global user.email "deforesd@gmail.com"
log "INFO" "✅ Git identity configured"

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
echo "   • GitHub CLI"
echo "   • Starship prompt"
echo "   • Zoxide (smart cd)"
echo "   • Node.js LTS"
echo "   • JetBrainsMono Nerd Font (icônes)"
echo "   • Ranger file manager (use 'ranger' command)"
echo ""
echo "🤖 AI Coding Agents:"
[ -x "$(command -v sgpt)" ] && echo "   • Shell-GPT (sgpt/gpt command)"
[ -x "$(command -v llm)" ] && echo "   • LLM CLI (ai/llm command) - Gemini, Claude, GPT"
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
echo "   ✗ GitHub Copilot"
echo "   ✗ Aider (dépendances lourdes)"
echo "   ✗ Neovim compilé from source"
echo "   ✗ Plugins LSP lourds"
echo ""
echo "🎯 Utilisation des AI Agents:"
echo "   ai 'question'      → LLM CLI (multi-provider)"
echo "   gpt 'question'     → Shell-GPT (OpenAI)"
echo "   chat               → Mode conversation interactif"
echo "   llm -m gemini-2.0-flash 'question'  → Gemini"
echo "   llm -m claude-3-haiku 'question'    → Claude"
echo ""
echo "📚 Configuration API keys:"
echo "   Via Doppler (recommandé): déjà configuré automatiquement"
echo "   Manuel: llm keys set openai / gemini / anthropic"
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
echo "   ai            → LLM CLI (multi-provider: Gemini, Claude, GPT)"
echo "   gpt           → Shell-GPT (OpenAI quick queries)"
echo "   chat          → Mode conversation interactif"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
