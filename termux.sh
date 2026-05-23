#!/usr/bin/env bash

# Script d'installation ALLÉGÉ pour Termux (Android)
# Version minimaliste pour édition Markdown: pas d'agents IA, pas de stack web.

## Configuration logging
LOG_FILE="${TERMUX_DOTFILES_LOG_FILE:-$HOME/termux-install.log}"
VERBOSE="${TERMUX_DOTFILES_VERBOSE:-0}"
mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"

log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    case "$level" in
        ERROR|WARN) echo "$message" ;;
        INFO) [ "$VERBOSE" = "1" ] && echo "$message" ;;
    esac
}

step() {
    log "INFO" "$1"
    echo "$1"
}

step "Installation Termux dotfiles..."

if ! command -v pkg >/dev/null 2>&1; then
    log "ERROR" "❌ This installer must run inside Termux (pkg command not found)"
    exit 1
fi

mkdir -p "$HOME/.local/bin" "$HOME/.cargo/bin" "$HOME/tmp"

# --- 1. Packages Termux essentiels ---
step "1/6 Installation des paquets Termux..."
pkg update -y >/dev/null 2>&1
pkg install -y \
  git \
  curl \
  wget \
  neovim \
  ripgrep \
  fd \
  fzf \
  openssh \
  autossh \
  mosh \
  tmux \
  lsof \
  netcat-openbsd \
  tar \
  unzip \
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
step "2/6 Configuration de la Nerd Font..."

# Termux utilise un système de fonts différent
FONT_DIR="$HOME/.termux"
mkdir -p "$FONT_DIR"

# Vérifier si unzip est installé
if ! command -v unzip &> /dev/null; then
    log "INFO" "Installing unzip..."
    pkg install -y unzip >/dev/null 2>&1
fi

FONT_INSTALLED=false

if [ -f "$FONT_DIR/font.ttf" ] && [ ! -s "$FONT_DIR/font.ttf" ]; then
    log "WARN" "⚠️  Existing ~/.termux/font.ttf is empty, reinstalling Nerd Font"
    rm -f "$FONT_DIR/font.ttf"
fi

if [ ! -f "$FONT_DIR/font.ttf" ]; then
    log "INFO" "Downloading JetBrainsMono Nerd Font..."
    FONT_TMP_DIR="$(mktemp -d "$HOME/tmp/nerd-font.XXXXXX")"

    # Télécharger JetBrainsMono Nerd Font (version complète avec icônes)
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"

    if curl -fsSL "$FONT_URL" -o "$FONT_TMP_DIR/JetBrainsMono.zip"; then
        log "INFO" "Download complete, extracting..."

        if unzip -q "$FONT_TMP_DIR/JetBrainsMono.zip" "JetBrainsMonoNerdFont-Regular.ttf" -d "$FONT_TMP_DIR" 2>/dev/null; then
            if [ -f "$FONT_TMP_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
                if cp "$FONT_TMP_DIR/JetBrainsMonoNerdFont-Regular.ttf" "$FONT_DIR/font.ttf" && [ -s "$FONT_DIR/font.ttf" ]; then
                    chmod 644 "$FONT_DIR/font.ttf"
                    log "INFO" "✅ Nerd Font installed to ~/.termux/font.ttf"
                    FONT_INSTALLED=true
                else
                    rm -f "$FONT_DIR/font.ttf"
                    log "ERROR" "❌ Failed to install Nerd Font to ~/.termux/font.ttf"
                fi
            else
                log "WARN" "⚠️  Font file not found after extraction"
            fi
        else
            log "WARN" "⚠️  Failed to extract font from zip"
        fi
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
step "3/6 Installation des outils légers..."

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

# Termux theme picker
log "INFO" "🎨 Installing termux-theme..."
if curl -fsSL https://raw.githubusercontent.com/dianedef/termux-theme/main/install.sh -o "$HOME/tmp/termux-theme-install.sh"; then
    if sh "$HOME/tmp/termux-theme-install.sh" >/dev/null 2>&1 && command -v termux-theme &> /dev/null; then
        log "INFO" "✅ termux-theme installed"
    else
        log "WARN" "⚠️  termux-theme installation failed"
    fi
    rm -f "$HOME/tmp/termux-theme-install.sh"
else
    log "WARN" "⚠️  Could not download termux-theme installer"
fi

# File manager - Use Ranger (already installed via pkg)
if command -v ranger &> /dev/null; then
    log "INFO" "✅ Ranger file manager installed (use 'ranger' command)"
else
    log "WARN" "⚠️  Ranger not found, install with: pkg install ranger"
fi

# ShipFlow local tunnel tools (urls/tunnel)
SHIPFLOW_LOCAL_INSTALLED=false
SHIPFLOW_DIR="$HOME/shipflow"
step "4/6 Installation des tunnels ShipFlow..."
if [ -d "$SHIPFLOW_DIR/.git" ]; then
    if git -C "$SHIPFLOW_DIR" diff --quiet && git -C "$SHIPFLOW_DIR" diff --cached --quiet; then
        git -C "$SHIPFLOW_DIR" pull --ff-only >/dev/null 2>&1 || log "WARN" "⚠️  Could not update existing ShipFlow repo"
    else
        log "WARN" "⚠️  Existing ShipFlow repo has local changes; skipping update"
    fi
elif [ -e "$SHIPFLOW_DIR" ]; then
    log "WARN" "⚠️  $SHIPFLOW_DIR exists but is not a git repository; skipping ShipFlow local tools"
else
    if ! GIT_TERMINAL_PROMPT=0 git clone https://github.com/diane-defores/shipflow.git "$SHIPFLOW_DIR" >/dev/null 2>&1; then
        log "WARN" "⚠️  Could not clone ShipFlow repo; urls/tunnel aliases not installed"
    fi
fi

if [ -f "$SHIPFLOW_DIR/local/install.sh" ]; then
    if bash "$SHIPFLOW_DIR/local/install.sh" >> "$LOG_FILE" 2>&1; then
        SHIPFLOW_LOCAL_INSTALLED=true
        log "INFO" "✅ ShipFlow local tunnel tools installed (urls/tunnel)"
    else
        log "WARN" "⚠️  ShipFlow local tunnel installer failed"
    fi
fi

# --- 4. Configuration Neovim (MyNeovimTermux) ---
step "5/6 Configuration de Neovim..."

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# --- 5. Symlinks ---
log "INFO" "Creating symlinks..."

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

# Termux Neovim is plugin-free; remove leftovers from older LazyVim/Mason runs.
if [ -d "$HOME/.local/share/nvim/lazy" ] || [ -d "$HOME/.local/share/nvim/mason" ]; then
    rm -rf "$HOME/.local/share/nvim/lazy" "$HOME/.local/share/nvim/mason"
    log "INFO" "Removed old Neovim Lazy/Mason data"
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
step "6/6 Configuration du shell..."

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

# autossh on Termux can need the OpenSSH binary path explicitly.
if ! grep -q "AUTOSSH_PATH" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo '# autossh on Termux' >> "$BASHRC"
    echo 'command -v ssh >/dev/null && export AUTOSSH_PATH="$(command -v ssh)"' >> "$BASHRC"
    log "INFO" "✅ Added autossh path to bashrc"
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
alias re='source "$HOME/.bashrc" && echo "✓ Shell rechargé!"'
alias reload='source "$HOME/.bashrc" && echo "✓ Shell rechargé!"'
alias i='bash ~/dotfiles/termux.sh'
alias dot='~/dotfiles/termux.sh'
alias dotfiles='~/dotfiles/termux.sh'
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

# Termux specific
alias termux-wake='termux-wake-lock'
alias termux-sleep='termux-wake-unlock'
alias storage='cd ~/storage/shared'
alias dl='cd ~/storage/downloads'

# File managers
alias n='nvim'
alias r='ranger'
alias thermux='termux-theme'

# END Termux aliases
EOF
log "INFO" "✅ Added/Updated Termux aliases"

# --- 7. Agents / web tooling intentionally skipped ---
log "INFO" "🤖 Skipping AI agents, MCP, and web tooling on Termux"
log "INFO" "✅ Termux profile kept focused on Markdown editing"

# --- Git Identity Configuration ---
log "INFO" "👤 Configuring Git identity..."
git config --global user.name "Diane"
git config --global user.email "deforesd@gmail.com"
log "INFO" "✅ Git identity configured"

# --- 8. Finalisation ---
echo ""
log "INFO" "Termux installation complete"
echo "Installation Termux terminée."
echo "Log détaillé: $LOG_FILE"
echo ""
echo "À faire maintenant:"
echo "  source ~/.bashrc"
echo "  re"
echo ""
echo "Installé: Neovim Markdown, Nerd Font, Starship, Zoxide, Ranger, Mosh/tmux, termux-theme."
if [ "$SHIPFLOW_LOCAL_INSTALLED" = true ]; then
    echo "Installé aussi: ShipFlow local tunnels (urls/tunnel)."
fi
echo ""
if [ "$FONT_INSTALLED" = true ] && [ -s "$HOME/.termux/font.ttf" ]; then
    echo "Pour activer les icônes: fermez complètement Termux puis rouvrez-le."
else
    echo "Font non installée automatiquement. Voir le log ou utiliser Termux:Styling."
fi
echo ""
echo "Commandes utiles: nvim, r, thermux, urls, tunnel."
echo "Non installé volontairement: Node.js, MCP, agents IA, Copilot, Claude/Codex/OpenCode."
echo "Pour plus de détails: TERMUX_DOTFILES_VERBOSE=1 bash ~/dotfiles/termux.sh"
