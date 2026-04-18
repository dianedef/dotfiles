#!/bin/bash
# ============================================================================
# Dotfiles Installation Script - Orchestrator
# ============================================================================
# Modern, modular installation script with advanced features.
#
# Usage:
#   ./install.sh                      # Full installation
#   ./install.sh -i                   # Interactive mode with UI menu
#   ./install.sh --dry-run            # Preview what would be installed
#   ./install.sh --check              # Check installation health
#   ./install.sh --update             # Update all tools
#   ./install.sh --only=neovim,yazi   # Install only specific components
#   ./install.sh --only=mcp           # Setup MCP servers only
#   ./install.sh --uninstall          # Remove everything
#   ./install.sh --parallel           # Parallel installation (faster)
#   ./install.sh --help               # Show help
#
# MCP Servers:
#   Edit mcp/mcp-servers.json to configure MCP servers for Claude Code,
#   Kilocode, and Claude Desktop. Run ./install.sh --only=mcp to apply.
#   Manual: claude mcp add --transport http <name> <url> --scope user

set -uo pipefail

# ============================================================================
# INITIALIZATION
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source configuration and library
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib.sh"

# Parse command-line arguments FIRST
parse_arguments "$@"

# Load .env file (if exists)
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "📋 Loading configuration from .env file..."
    set -a
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/.env"
    set +a
    echo "✅ Configuration loaded"
else
    echo "⚠️  No .env file found, using defaults"
    echo "💡 Copy .env.example to .env to customize installation"
fi

# Initialize logging and error handling
init_logging
setup_error_traps
detect_system

# ============================================================================
# SPECIAL MODES (exit early)
# ============================================================================
if [ "${DOTFILES_CHECK_MODE:-false}" = "true" ]; then
    run_health_check
    exit $?
fi

if [ "${DOTFILES_UNINSTALL_MODE:-false}" = "true" ]; then
    run_uninstall
    exit $?
fi

# Update mode: run interactive update and exit
if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ]; then
    run_interactive_update  # This function handles everything and exits
    exit 0  # Should not reach here, but just in case
fi

# ============================================================================
# INTERACTIVE vs AUTOMATIC MODE
# ============================================================================
# Logic:
#   - Terminal present (interactive) → show menu to select components
#   - No terminal (CI/script) → full auto install
#   - --only=... flag → install only specified components
#   - -i flag → force interactive menu

# Install gum if interactive mode requested or auto-detect
if [ "${DOTFILES_INTERACTIVE:-auto}" = "true" ] || \
   { [ "${DOTFILES_INTERACTIVE:-auto}" = "auto" ] && [ -t 0 ] && [ -z "${DOTFILES_ONLY:-}" ]; }; then

    # Try to install gum if not present and interactive
    if [ -t 0 ] && ! is_installed gum && [ "${DOTFILES_NO_GUM:-false}" != "true" ]; then
        install_gum 2>/dev/null || true
    fi

    # Run interactive menu if gum is available
    if use_gum; then
        run_interactive_menu
        # run_interactive_menu exits or sets DOTFILES_ONLY - either way, continue to main install
    fi
fi

# ============================================================================
# MAIN INSTALLATION
# ============================================================================
echo "🚀 Starting dotfiles installation..."
echo ""
echo "🖥️  System detected:"
echo "   OS: $OS ($DISTRO)"
echo "   Architecture: $ARCH"
echo "   Sudo access: $HAS_SUDO"
echo "   User-local mode: $USER_LOCAL_MODE"
if is_dry_run; then
    echo "   Mode: DRY-RUN (no changes will be made)"
fi
if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ]; then
    echo "   Mode: UPDATE"
fi
echo ""

# ============================================================================
# USER-LOCAL MODE SETUP
# ============================================================================
setup_user_local_mode() {
    if [ "$USER_LOCAL_MODE" != "true" ]; then
        return 0
    fi

    echo "📦 USER-LOCAL MODE ENABLED"
    echo "   Installing to ~/.local/bin and ~/.npm-global"
    echo ""

    run_action "Create ~/.local/bin" mkdir -p "$DOTFILES_BIN_DIR"
    run_action "Create ~/.npm-global" mkdir -p "$DOTFILES_NPM_DIR"

    if is_installed npm && ! is_dry_run; then
        npm config set prefix "$DOTFILES_NPM_DIR" 2>/dev/null
    fi

    export PATH="$DOTFILES_BIN_DIR:$DOTFILES_NPM_DIR/bin:$PATH"

    if ! is_dry_run; then
        append_to_bashrc '.local/bin' 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' "User-local binaries" || true
    fi

    success "User-local paths configured"
}

setup_user_local_mode

# Detect execution mode
if [ ! -t 0 ]; then
    echo "🤖 Running in non-interactive mode"
else
    echo "👤 Running in interactive mode"
fi
echo ""

# ============================================================================
# USER IDENTITY CONFIGURATION (skip in update mode)
# ============================================================================
get_user_info() {
    # Try to auto-detect from GitHub CLI if authenticated
    if is_installed gh && gh auth status &>/dev/null; then
        if [ -z "${GITHUB_USERNAME:-}" ]; then
            GITHUB_USERNAME=$(gh api user --jq '.login' 2>/dev/null || echo "")
        fi
        if [ -z "${USER_NAME:-}" ]; then
            USER_NAME=$(gh api user --jq '.name // empty' 2>/dev/null || echo "")
        fi
        if [ -z "${USER_EMAIL:-}" ] && [ -n "${GITHUB_USERNAME:-}" ]; then
            # Use GitHub noreply email by default
            local gh_id
            gh_id=$(gh api user --jq '.id' 2>/dev/null || echo "")
            if [ -n "$gh_id" ]; then
                USER_EMAIL="${gh_id}+${GITHUB_USERNAME}@users.noreply.github.com"
            fi
        fi
    fi

    # Fallback: ask interactively or use defaults
    if [ -z "${USER_NAME:-}" ]; then
        if [ -t 0 ]; then
            read -r -p "📝 Enter your name (for git): " USER_NAME
            USER_NAME="${USER_NAME:-Diane}"
        else
            USER_NAME="Diane"
        fi
    fi

    if [ -z "${USER_EMAIL:-}" ]; then
        if [ -t 0 ]; then
            read -r -p "📧 Enter your email (for git): " USER_EMAIL
            USER_EMAIL="${USER_EMAIL:-noreply@example.com}"
        else
            USER_EMAIL="35034946+dianedef@users.noreply.github.com"
        fi
    fi

    if [ -z "${GITHUB_USERNAME:-}" ]; then
        if [ -t 0 ]; then
            read -r -p "🐙 Enter your GitHub username: " GITHUB_USERNAME
            GITHUB_USERNAME="${GITHUB_USERNAME:-dianedef}"
        else
            GITHUB_USERNAME="dianedef"
        fi
    fi

    export USER_NAME USER_EMAIL GITHUB_USERNAME
    success "User identity: $USER_NAME <$USER_EMAIL> (@$GITHUB_USERNAME)"
}

# Skip identity config in update mode or when only installing components that don't need it
# Components needing identity: configs (git uses USER_NAME, USER_EMAIL, GITHUB_USERNAME)
needs_identity() {
    [ -z "${DOTFILES_ONLY:-}" ] || [[ ",$DOTFILES_ONLY," == *",configs,"* ]]
}

if [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ] && needs_identity; then
    echo "👤 Configuring user identity..."
    get_user_info

    # Git configuration
    if ! is_dry_run; then
        git config --global user.name "$USER_NAME"
        git config --global user.email "$USER_EMAIL"
    fi
    success "Git user identity configured"
fi

# ============================================================================
# NEOVIM INSTALLATION
# ============================================================================
install_neovim() {
    if ! should_install "neovim"; then return 0; fi
    if [ "$SKIP_NEOVIM_INSTALL" = "true" ]; then
        info "Skipping Neovim (SKIP_NEOVIM_INSTALL=true)"
        return 0
    fi

    # Update mode: check version
    if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ] && is_installed nvim; then
        local current latest
        current=$(get_installed_version neovim)
        latest=$(get_latest_release "$DOTFILES_REPO_NEOVIM" "$DOTFILES_NVIM_VERSION")
        if [ "$current" = "$latest" ]; then
            success "Neovim is up to date ($current)"
            return 0
        fi
        info "Updating Neovim: $current -> $latest"
    elif is_installed nvim && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "Neovim already installed: $(nvim --version | head -n 1)"
        return 0
    fi

    info "Installing Neovim..."

    local nvim_arch=""
    case $ARCH in
        x86_64) nvim_arch="x86_64" ;;
        arm64) nvim_arch="arm64" ;;
        *)
            warn "Unsupported architecture for Neovim: $ARCH"
            return 1
            ;;
    esac

    local install_dir bin_link
    install_dir="$(get_install_path opt)/nvim"
    bin_link="$(get_install_path bin)/nvim"

    local version
    version=$(get_latest_release "$DOTFILES_REPO_NEOVIM" "$DOTFILES_NVIM_VERSION")

    local nvim_file
    if [ "$OS" = "macos" ]; then
        nvim_file="nvim-macos-${nvim_arch}.tar.gz"
    else
        nvim_file="nvim-linux-${nvim_arch}.tar.gz"
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would download Neovim $version ($nvim_file)"
        echo -e "${BLUE}[DRY-RUN]${NC} Would install to $install_dir"
        echo -e "${BLUE}[DRY-RUN]${NC} Would create symlink $bin_link"
        return 0
    fi

    info "Downloading Neovim $version ($nvim_file)..."
    local url="https://github.com/$DOTFILES_REPO_NEOVIM/releases/download/$version/$nvim_file"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if download_and_extract "$url" "$tmp_dir"; then
        rm -rf "$install_dir" 2>/dev/null
        mkdir -p "$(dirname "$install_dir")"
        local extracted_dir
        extracted_dir=$(find "$tmp_dir" -maxdepth 1 -type d -name "nvim*" | head -1)
        if [ -n "$extracted_dir" ]; then
            mv "$extracted_dir" "$install_dir"
        else
            mv "$tmp_dir"/* "$install_dir" 2>/dev/null || true
        fi
        ln -sf "$install_dir/bin/nvim" "$bin_link"
        success "Neovim $version installed"
    else
        error "Neovim installation failed"
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
}

# ============================================================================
# SYSTEM DEPENDENCIES
# ============================================================================
install_github_binary() {
    local repo="$1"
    local binary="$2"
    local pattern="$3"

    if is_installed "$binary"; then
        success "$binary already installed"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install $binary from $repo"
        return 0
    fi

    info "Installing $binary from GitHub..."
    cd /tmp

    local download_url
    download_url=$(curl -s "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | grep "browser_download_url.*$pattern" | head -1 | cut -d '"' -f 4)

    if [ -z "$download_url" ]; then
        warn "Could not find download URL for $binary"
        return 1
    fi

    local filename
    filename=$(basename "$download_url")
    curl -sLO "$download_url"

    if [[ "$filename" == *.tar.gz ]]; then
        tar -xzf "$filename" 2>/dev/null || true
        find . -maxdepth 2 -name "$binary" -type f -exec mv {} "$DOTFILES_BIN_DIR/" \; 2>/dev/null || true
    elif [[ "$filename" == *.zip ]]; then
        unzip -q "$filename" 2>/dev/null || true
        find . -maxdepth 2 -name "$binary" -type f -exec mv {} "$DOTFILES_BIN_DIR/" \; 2>/dev/null || true
    fi

    rm -rf "$filename" "${filename%.tar.gz}" "${filename%.zip}" 2>/dev/null || true
    chmod +x "$DOTFILES_BIN_DIR/$binary" 2>/dev/null || true
    cd - > /dev/null

    if is_installed "$binary"; then
        success "$binary installed"
        return 0
    else
        warn "$binary installation may have failed"
        return 1
    fi
}

install_system_packages() {
    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install system packages"
        return 0
    fi

    if [ "$OS" = "macos" ]; then
        if is_installed brew; then
            info "Installing via Homebrew..."
            brew install git curl wget unzip ripgrep fd bat lsd trash-cli 2>/dev/null || true
        fi
    elif [ "$OS" = "linux" ]; then
        if [ "$USER_LOCAL_MODE" = "true" ]; then
            info "Installing tools via direct download (user-local mode)..."

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
        else
            if [[ "$DISTRO_FAMILY" == *"debian"* ]] || [ "$DISTRO" = "ubuntu" ] || [ "$DISTRO" = "debian" ]; then
                info "Installing via apt-get..."
                sudo apt-get update >/dev/null 2>&1 || true
                sudo apt-get install -y git curl wget unzip build-essential python3-pip ripgrep fd-find xclip bat lsd trash-cli >/dev/null 2>&1 || true
                if [ -f /usr/bin/fdfind ] && [ ! -f /usr/bin/fd ]; then
                    sudo ln -s /usr/bin/fdfind /usr/bin/fd 2>/dev/null || true
                fi
            fi
        fi
    fi
}

# ============================================================================
# FZF INSTALLATION
# ============================================================================
install_fzf() {
    if ! should_install "fzf"; then return 0; fi

    if is_installed fzf && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "fzf already installed"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install fzf"
        return 0
    fi

    info "Installing fzf..."

    # Clone if not exists
    if [ ! -d ~/.fzf ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    fi

    # Install binary
    ~/.fzf/install --bin

    # Link to local bin
    mkdir -p "$DOTFILES_BIN_DIR"
    ln -sf ~/.fzf/bin/fzf "$DOTFILES_BIN_DIR/fzf"

    if is_installed fzf; then
        success "fzf installed: $(fzf --version 2>/dev/null | head -1)"
    else
        warn "fzf installation may have failed"
    fi
}

# ============================================================================
# NERD FONTS INSTALLATION
# ============================================================================
install_nerd_fonts() {
    if ! should_install "nerd-fonts"; then return 0; fi
    if [ "$SKIP_NERD_FONTS" = "true" ]; then
        info "Skipping Nerd Fonts (SKIP_NERD_FONTS=true)"
        return 0
    fi

    if fc-list 2>/dev/null | grep -iq "nerd"; then
        success "Nerd Fonts already installed"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install Nerd Fonts (JetBrainsMono)"
        return 0
    fi

    info "Installing Nerd Fonts (JetBrainsMono)..."
    mkdir -p "$DOTFILES_FONTS_DIR"

    local font_version
    font_version=$(get_latest_release "ryanoasis/nerd-fonts" "$DOTFILES_NERD_FONTS_VERSION")
    local url="https://github.com/ryanoasis/nerd-fonts/releases/download/$font_version/JetBrainsMono.zip"

    if download_and_extract "$url" "$DOTFILES_FONTS_DIR/JetBrainsMono" "zip"; then
        fc-cache -fv "$DOTFILES_FONTS_DIR" >/dev/null 2>&1 || true
        success "Nerd Fonts installed"
    else
        warn "Failed to install Nerd Fonts"
    fi
}

# ============================================================================
# NODE.JS INSTALLATION
# ============================================================================
install_node() {
    if ! should_install "node"; then return 0; fi

    # Update mode: upgrade to latest LTS
    if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ] && is_installed node; then
        if is_dry_run; then
            echo -e "${BLUE}[DRY-RUN]${NC} Would update Node.js via nvm"
            return 0
        fi
        info "Updating Node.js via nvm..."
        export NVM_DIR="$HOME/.nvm"
        # shellcheck disable=SC1091
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install --lts >/dev/null 2>&1
        nvm use --lts >/dev/null 2>&1
        success "Node.js updated to $(node --version)"
        return 0
    fi

    if is_installed node && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "Node.js already installed: $(node --version)"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install Node.js via nvm"
        return 0
    fi

    info "Installing Node.js via nvm..."
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$DOTFILES_NVM_VERSION/install.sh" 2>/dev/null | bash >/dev/null 2>&1
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts >/dev/null 2>&1
    nvm use --lts >/dev/null 2>&1
    success "Node.js installed via nvm"
}

# ============================================================================
# NPM TOOLS INSTALLATION
# ============================================================================
install_npm_tools() {
    if ! should_install "npm-tools"; then return 0; fi
    if [ "$SKIP_NPM_TOOLS" = "true" ]; then
        info "Skipping npm tools (SKIP_NPM_TOOLS=true)"
        return 0
    fi

    if ! is_installed npm; then
        warn "npm not found, skipping npm tools"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install npm tools: tldr, @apify/mcpc, @openai/codex"
        return 0
    fi

    info "Configuring npm for user-local global installs..."
    mkdir -p "$DOTFILES_NPM_DIR"
    npm config set prefix "$DOTFILES_NPM_DIR" 2>/dev/null
    export PATH="$DOTFILES_NPM_DIR/bin:$PATH"

    info "Installing CLI tools via npm..."
    for pkg in "tldr" "@apify/mcpc" "@openai/codex"; do
        npm install -g "$pkg" 2>/dev/null && success "$pkg installed" || warn "$pkg failed"
    done

    hash -r 2>/dev/null
}

# ============================================================================
# GITHUB CLI INSTALLATION
# ============================================================================
install_gh() {
    if ! should_install "gh"; then return 0; fi

    # Update mode
    if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ] && is_installed gh; then
        if is_dry_run; then
            echo -e "${BLUE}[DRY-RUN]${NC} Would update GitHub CLI"
            return 0
        fi
        info "Updating GitHub CLI..."
        if gh extension upgrade --all 2>/dev/null; then
            success "GitHub CLI extensions updated"
        fi
        # gh itself is updated via apt or the gh upgrade command if available
        if gh upgrade 2>/dev/null; then
            success "GitHub CLI updated"
        else
            # Fallback: reinstall from GitHub releases
            local latest
            latest=$(get_latest_release "cli/cli" "v2.40.0")
            local current
            current=$(gh --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
            if [ "$current" != "${latest#v}" ]; then
                local gh_arch="amd64"
                [ "$ARCH" = "arm64" ] && gh_arch="arm64"
                curl -fsSL "https://github.com/cli/cli/releases/download/${latest}/gh_${latest#v}_linux_${gh_arch}.deb" -o /tmp/gh.deb 2>/dev/null
                if [ -f /tmp/gh.deb ]; then
                    run_with_sudo dpkg -i /tmp/gh.deb >/dev/null 2>&1 && success "GitHub CLI updated to $latest" || warn "GitHub CLI update failed"
                    rm -f /tmp/gh.deb
                fi
            fi
        fi
        return 0
    fi

    if is_installed gh && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "GitHub CLI already installed: $(gh --version | head -1)"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install GitHub CLI"
        return 0
    fi

    info "Installing GitHub CLI..."
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | run_with_sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | run_with_sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    run_with_sudo apt update >/dev/null 2>&1
    run_with_sudo apt install -y gh >/dev/null 2>&1
    success "GitHub CLI installed"
}

# ============================================================================
# LSD INSTALLATION (LSDeluxe - modern ls replacement)
# ============================================================================
install_lsd() {
    if ! should_install "lsd"; then return 0; fi

    local current latest
    if is_installed lsd; then
        current=$(lsd --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    fi

    # Update mode
    if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ] && is_installed lsd; then
        if is_dry_run; then
            echo -e "${BLUE}[DRY-RUN]${NC} Would update lsd"
            return 0
        fi
        latest=$(get_latest_release "lsd-rs/lsd" "v1.0.0")
        latest="${latest#v}"
        if [ "$current" = "$latest" ]; then
            success "lsd is up to date ($current)"
            return 0
        fi
        info "Updating lsd: $current -> $latest"
    elif is_installed lsd && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "lsd already installed: $current"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install lsd"
        return 0
    fi

    info "Installing lsd..."
    latest="${latest:-$(get_latest_release "lsd-rs/lsd" "v1.0.0")}"
    latest="${latest#v}"
    local deb_arch="amd64"
    [ "$ARCH" = "arm64" ] && deb_arch="arm64"
    local url="https://github.com/lsd-rs/lsd/releases/download/v${latest}/lsd_${latest}_${deb_arch}.deb"
    curl -fsSL "$url" -o /tmp/lsd.deb 2>/dev/null
    if [ -f /tmp/lsd.deb ]; then
        run_with_sudo dpkg -i /tmp/lsd.deb >/dev/null 2>&1 && success "lsd installed ($latest)" || warn "lsd installation failed"
        rm -f /tmp/lsd.deb
    else
        warn "Failed to download lsd"
    fi
}

# ============================================================================
# BAT INSTALLATION (cat with syntax highlighting)
# ============================================================================
install_bat() {
    if ! should_install "bat"; then return 0; fi

    local current latest
    if is_installed bat; then
        current=$(bat --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi

    # Update mode
    if [ "${DOTFILES_UPDATE_MODE:-false}" = "true" ] && is_installed bat; then
        if is_dry_run; then
            echo -e "${BLUE}[DRY-RUN]${NC} Would update bat"
            return 0
        fi
        latest=$(get_latest_release "sharkdp/bat" "v0.24.0")
        latest="${latest#v}"
        if [ "$current" = "$latest" ]; then
            success "bat is up to date ($current)"
            return 0
        fi
        info "Updating bat: $current -> $latest"
    elif is_installed bat && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "bat already installed: $current"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install bat"
        return 0
    fi

    info "Installing bat..."
    latest="${latest:-$(get_latest_release "sharkdp/bat" "v0.24.0")}"
    latest="${latest#v}"
    local deb_arch="amd64"
    [ "$ARCH" = "arm64" ] && deb_arch="arm64"
    local url="https://github.com/sharkdp/bat/releases/download/v${latest}/bat_${latest}_${deb_arch}.deb"
    curl -fsSL "$url" -o /tmp/bat.deb 2>/dev/null
    if [ -f /tmp/bat.deb ]; then
        run_with_sudo dpkg -i /tmp/bat.deb >/dev/null 2>&1 && success "bat installed ($latest)" || warn "bat installation failed"
        rm -f /tmp/bat.deb
    else
        warn "Failed to download bat"
    fi
}

# ============================================================================
# STARSHIP INSTALLATION
# ============================================================================
install_starship() {
    if ! should_install "starship"; then return 0; fi

    if is_installed starship && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "Starship already installed"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install Starship"
        return 0
    fi

    info "Installing Starship..."
    local install_result=0
    if [ "$USER_LOCAL_MODE" = "true" ]; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$DOTFILES_BIN_DIR" || install_result=1
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y || install_result=1
    fi

    # Fallback: build from source if prebuilt binary unavailable (arm64)
    if [ $install_result -ne 0 ]; then
        # Source rustup cargo (not system cargo which may be too old)
        [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

        # Install rustup if cargo not available
        if ! is_installed cargo; then
            info "Installing Rust toolchain for Starship compilation..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null || true
            [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
        fi

        if is_installed cargo; then
            info "No prebuilt binary for arm64, building Starship from source (~5 min)..."
            install_result=0
            cargo install starship 2>/dev/null || install_result=1
            # Symlink to local bin
            [ -f "$HOME/.cargo/bin/starship" ] && ln -sf "$HOME/.cargo/bin/starship" "$DOTFILES_BIN_DIR/starship" 2>/dev/null || true
        fi
    fi

    if [ $install_result -eq 0 ] && is_installed starship; then
        success "Starship installed: $(starship --version 2>/dev/null | head -1)"
    else
        warn "Starship installation failed"
    fi
}

# ============================================================================
# ZOXIDE INSTALLATION
# ============================================================================
install_zoxide() {
    if ! should_install "zoxide"; then return 0; fi

    if is_installed zoxide && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "Zoxide already installed"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install Zoxide"
        return 0
    fi

    info "Installing Zoxide..."

    # Zoxide installs to ~/.local/bin by default
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        # Refresh PATH to find newly installed binary
        export PATH="$HOME/.local/bin:$PATH"
        hash -r 2>/dev/null

        if is_installed zoxide; then
            success "Zoxide installed: $(zoxide --version 2>/dev/null || echo 'OK')"
        else
            warn "Zoxide installed but not in PATH. Add ~/.local/bin to PATH"
        fi
    else
        warn "Zoxide installation failed"
    fi
}

# ============================================================================
# YAZI INSTALLATION
# ============================================================================
install_yazi() {
    if ! should_install "yazi"; then return 0; fi
    if [ "$SKIP_YAZI_INSTALL" = "true" ]; then
        info "Skipping Yazi (SKIP_YAZI_INSTALL=true)"
        return 0
    fi

    if is_installed yazi && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "Yazi already installed"
        return 0
    fi

    local yazi_version
    yazi_version=$(get_latest_release "$DOTFILES_REPO_YAZI" "$DOTFILES_YAZI_VERSION")

    local yazi_file
    if [ "$OS" = "macos" ]; then
        yazi_file="yazi-${ARCH}-apple-darwin.zip"
    else
        yazi_file="yazi-${ARCH}-unknown-linux-gnu.zip"
    fi
    # Fix arch naming
    yazi_file="${yazi_file/arm64/aarch64}"

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install Yazi $yazi_version"
        return 0
    fi

    info "Installing Yazi $yazi_version..."
    local url="https://github.com/$DOTFILES_REPO_YAZI/releases/download/$yazi_version/$yazi_file"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if download_and_extract "$url" "$tmp_dir" "zip"; then
        find "$tmp_dir" -name "yazi" -type f -exec mv {} "$DOTFILES_BIN_DIR/yazi" \;
        chmod +x "$DOTFILES_BIN_DIR/yazi"
        success "Yazi $yazi_version installed"
    else
        warn "Yazi installation failed"
    fi

    rm -rf "$tmp_dir"
}

# ============================================================================
# DOPPLER INSTALLATION
# ============================================================================
install_doppler() {
    if ! should_install "doppler"; then return 0; fi
    if [ "$SKIP_DOPPLER_INSTALL" = "true" ]; then
        info "Skipping Doppler (SKIP_DOPPLER_INSTALL=true)"
        return 0
    fi

    if is_installed doppler && [ "${DOTFILES_UPDATE_MODE:-false}" != "true" ]; then
        success "Doppler CLI already installed"
        return 0
    fi

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would install Doppler CLI"
        return 0
    fi

    info "Installing Doppler CLI..."

    if [ "$USER_LOCAL_MODE" = "true" ]; then
        local doppler_version
        doppler_version=$(get_latest_release "$DOTFILES_REPO_DOPPLER" "$DOTFILES_DOPPLER_VERSION")
        doppler_version="${doppler_version#v}"

        local doppler_file="doppler_${doppler_version}_linux_amd64.tar.gz"
        [ "$ARCH" = "arm64" ] && doppler_file="doppler_${doppler_version}_linux_arm64.tar.gz"

        local url="https://github.com/$DOTFILES_REPO_DOPPLER/releases/latest/download/$doppler_file"
        local tmp_dir
        tmp_dir=$(mktemp -d)

        if download_file "$url" "$tmp_dir/$doppler_file"; then
            tar -xzf "$tmp_dir/$doppler_file" -C "$tmp_dir" doppler 2>/dev/null
            mv "$tmp_dir/doppler" "$DOTFILES_BIN_DIR/doppler" 2>/dev/null
            chmod +x "$DOTFILES_BIN_DIR/doppler"
            success "Doppler CLI installed"
        else
            warn "Doppler CLI installation failed"
        fi

        rm -rf "$tmp_dir"
    else
        curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh 2>/dev/null | sudo sh >/dev/null 2>&1
        is_installed doppler && success "Doppler CLI installed" || warn "Doppler CLI installation failed"
    fi
}

# ============================================================================
# MCP (MODEL CONTEXT PROTOCOL) CONFIGURATION
# ============================================================================
setup_mcp_config() {
    if ! should_install "mcp"; then return 0; fi
    if [ "$SKIP_MCP_INSTALL" = "true" ]; then
        info "Skipping MCP config (SKIP_MCP_INSTALL=true)"
        return 0
    fi

    if [ ! -f "$SCRIPT_DIR/mcp/mcp-servers.json" ]; then
        log DEBUG "No mcp/mcp-servers.json found, skipping MCP setup"
        return 0
    fi

    # Guard: jq required for parsing MCP config
    if ! is_installed jq; then
        warn "jq not installed, skipping MCP setup (install jq and re-run with --only=mcp)"
        return 0
    fi

    # Ensure claude CLI is discoverable
    export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
    hash -r 2>/dev/null || true

    info "Setting up MCP server configurations..."

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would setup MCP configs for Claude Code, Kilocode, etc."
        return 0
    fi

    # Function to merge MCP servers into existing JSON config
    merge_mcp_config() {
        local source_mcp="$1"
        local target_file="$2"
        local target_dir
        target_dir=$(dirname "$target_file")

        mkdir -p "$target_dir"

        if is_installed jq; then
            if [ -f "$target_file" ]; then
                local mcp_servers
                mcp_servers=$(jq '.mcpServers // {}' "$source_mcp" 2>/dev/null)
                jq --argjson mcp "$mcp_servers" '.mcpServers = ($mcp + (.mcpServers // {}))' "$target_file" > "${target_file}.tmp" && mv "${target_file}.tmp" "$target_file"
                log DEBUG "Merged MCP servers into $target_file"
            else
                jq '{mcpServers: .mcpServers}' "$source_mcp" > "$target_file"
                log DEBUG "Created $target_file with MCP servers"
            fi
        else
            ln -sf "$source_mcp" "${target_dir}/mcp-servers.json"
            log DEBUG "Created symlink (jq not available)"
        fi
    }

    # Claude Code: use `claude mcp add` command (stores in ~/.claude.json)
    if is_installed claude; then
        log DEBUG "Configuring Claude Code MCP servers via CLI..."

        # Read servers from mcp-servers.json and add them via CLI
        if is_installed jq; then
            local servers
            servers=$(jq -r '.mcpServers | to_entries[] | .key' "$SCRIPT_DIR/mcp/mcp-servers.json" 2>/dev/null)

            for server_name in $servers; do
                local server_type server_url server_command server_args
                server_type=$(jq -r ".mcpServers[\"$server_name\"].type // \"stdio\"" "$SCRIPT_DIR/mcp/mcp-servers.json")
                server_url=$(jq -r ".mcpServers[\"$server_name\"].url // empty" "$SCRIPT_DIR/mcp/mcp-servers.json")
                server_command=$(jq -r ".mcpServers[\"$server_name\"].command // empty" "$SCRIPT_DIR/mcp/mcp-servers.json")

                # Skip if server already exists
                if claude mcp get "$server_name" &>/dev/null; then
                    log DEBUG "MCP server '$server_name' already configured, skipping"
                    continue
                fi

                if [ -n "$server_url" ]; then
                    # HTTP/SSE remote server
                    claude mcp add --transport "$server_type" "$server_name" "$server_url" --scope user 2>/dev/null || true
                    log DEBUG "Added remote MCP server: $server_name"
                elif [ -n "$server_command" ]; then
                    # Stdio local server
                    server_args=$(jq -r ".mcpServers[\"$server_name\"].args | @sh" "$SCRIPT_DIR/mcp/mcp-servers.json" 2>/dev/null | tr -d "'")
                    eval "claude mcp add --transport stdio \"$server_name\" --scope user -- $server_command $server_args" 2>/dev/null || true
                    log DEBUG "Added stdio MCP server: $server_name"
                fi
            done
        fi
        success "Claude Code MCP config updated"
    else
        log DEBUG "Claude Code CLI not installed, skipping MCP setup for Claude Code"
    fi

    # Kilocode: symlink to settings directory
    if [ -d "$HOME/.kilocode" ]; then
        local kilocode_dir="$HOME/.kilocode/cli/global/settings"
        mkdir -p "$kilocode_dir"
        merge_mcp_config "$SCRIPT_DIR/mcp/mcp-servers.json" "$kilocode_dir/mcp_settings.json"
        success "Kilocode MCP config updated"
    fi

    # Claude Desktop (if exists)
    if [ -d "$HOME/.config/claude" ]; then
        merge_mcp_config "$SCRIPT_DIR/mcp/mcp-servers.json" "$HOME/.config/claude/claude_desktop_config.json"
        success "Claude Desktop MCP config updated"
    fi

    # Create reference symlink in ~/.config for easy access
    mkdir -p "$HOME/.config/mcp"
    ln -sf "$SCRIPT_DIR/mcp/mcp-servers.json" "$HOME/.config/mcp/servers.json"

    # Interactive API key prompts for optional MCP servers
    if [ -t 0 ] && is_installed claude && ! is_dry_run; then
        echo ""
        info "Optional MCP servers requiring API keys (Enter to skip):"
        echo ""

        # Firecrawl
        local firecrawl_key="${FIRECRAWL_API_KEY:-}"
        if [ -z "$firecrawl_key" ]; then
            if use_gum; then
                firecrawl_key=$(gum input --placeholder "fc-..." --header "Firecrawl API key (firecrawl.dev):" 2>/dev/null || echo "")
            elif [ -t 0 ]; then
                read -r -p "  Firecrawl API key (Enter to skip): " firecrawl_key
            fi
        fi
        if [ -n "$firecrawl_key" ]; then
            claude mcp add --transport http firecrawl "https://mcp.firecrawl.dev/${firecrawl_key}/v2/mcp" --scope user 2>/dev/null || true
            success "Firecrawl MCP configured"
        fi

        # DeepL
        local deepl_key="${DEEPL_API_KEY:-}"
        if [ -z "$deepl_key" ]; then
            if use_gum; then
                deepl_key=$(gum input --placeholder "..." --header "DeepL API key (deepl.com/pro-api):" 2>/dev/null || echo "")
            elif [ -t 0 ]; then
                read -r -p "  DeepL API key (Enter to skip): " deepl_key
            fi
        fi
        if [ -n "$deepl_key" ]; then
            DEEPL_API_KEY="$deepl_key" claude mcp add --transport stdio deepl --scope user -- npx -y deepl-mcp-server 2>/dev/null || true
            success "DeepL MCP configured"
        fi

        # DataForSEO
        local dfs_key="${DFS_API_KEY:-}"
        if [ -z "$dfs_key" ]; then
            if use_gum; then
                dfs_key=$(gum input --placeholder "user:pass en Base64" --header "DataForSEO Authorization Basic token:" 2>/dev/null || echo "")
            elif [ -t 0 ]; then
                read -r -p "  DataForSEO Basic auth token (Enter to skip): " dfs_key
            fi
        fi
        if [ -n "$dfs_key" ]; then
            claude mcp add --transport http dfs-mcp "https://mcp.dataforseo.com/http" --header "Authorization: Basic $dfs_key" --scope user 2>/dev/null || true
            success "DataForSEO MCP configured"
        fi

    fi

    success "MCP configuration complete"
}

# ============================================================================
# CONFIGURATION SYMLINKS
# ============================================================================
setup_configs() {
    if ! should_install "configs"; then return 0; fi

    info "Setting up configuration symlinks..."

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would setup Neovim config"
        echo -e "${BLUE}[DRY-RUN]${NC} Would setup Yazi config"
        echo -e "${BLUE}[DRY-RUN]${NC} Would setup Starship config"
        return 0
    fi

    # Neovim config
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    if [ -d "$NVIM_CONFIG_DIR" ]; then
        mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup.$(date +%s)" 2>/dev/null || true
    fi

    if [ -d "$SCRIPT_DIR/nvim/MyNeovim" ]; then
        create_symlink "$SCRIPT_DIR/nvim/MyNeovim" "$NVIM_CONFIG_DIR" false
    fi

    # Yazi
    [ -d "$SCRIPT_DIR/yazi" ] && create_symlink "$SCRIPT_DIR/yazi" "$HOME/.config/yazi" false

    # Ranger
    [ -d "$SCRIPT_DIR/ranger" ] && create_symlink "$SCRIPT_DIR/ranger" "$HOME/.config/ranger" false

    # Starship
    if [ -d "$SCRIPT_DIR/starship" ]; then
        mkdir -p "$HOME/.config"
        if [ -f "$SCRIPT_DIR/starship/starship-switch.sh" ]; then
            chmod +x "$SCRIPT_DIR/starship/starship-switch.sh" 2>/dev/null || true
            "$SCRIPT_DIR/starship/starship-switch.sh" auto 2>/dev/null || true
        else
            create_symlink "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml" false
        fi
    fi

    # Tmux
    [ -f "$SCRIPT_DIR/.tmux.conf" ] && create_symlink "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf" false
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        log "Installing TPM (Tmux Plugin Manager)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" 2>/dev/null || true
    fi

    # Ghostty
    if [ -d "$SCRIPT_DIR/ghostty" ]; then
        mkdir -p "$HOME/.config/ghostty"
        create_symlink "$SCRIPT_DIR/ghostty/config" "$HOME/.config/ghostty/config" false
    fi

    # Codex
    if [ -f "$SCRIPT_DIR/codex/config.toml" ]; then
        mkdir -p "$HOME/.codex"
        create_symlink "$SCRIPT_DIR/codex/config.toml" "$HOME/.codex/config.toml" false
    fi

    # Claude Code skills (flat symlinks — one per skill)
    if [ -d "$SCRIPT_DIR/claude/skills" ]; then
        mkdir -p "$HOME/.claude/skills"
        for skill_dir in "$SCRIPT_DIR/claude/skills"/*/; do
            skill_name=$(basename "$skill_dir")
            [ -d "$skill_dir" ] && create_symlink "$skill_dir" "$HOME/.claude/skills/$skill_name" false
        done
    fi

    # Claude Code statusLine — now managed by ShipFlow/install.sh
    log DEBUG "Claude Code statusLine is configured by ShipFlow install"

    # ShipFlow
    if [ "${SKIP_SHIPFLOW:-false}" != "true" ]; then
        local shipflow_dir="$HOME/ShipFlow"
        if [ ! -d "$shipflow_dir" ]; then
            info "Cloning ShipFlow..."
            # Try SSH first, fallback to HTTPS
            git clone "git@github.com:${GITHUB_USERNAME:-dianedef}/ShipFlow.git" "$shipflow_dir" 2>/dev/null || \
                git clone "https://github.com/${GITHUB_USERNAME:-dianedef}/ShipFlow.git" "$shipflow_dir" 2>/dev/null || \
                warn "Could not clone ShipFlow repo"
        fi
        if [ -d "$shipflow_dir" ]; then
            [ -f "$shipflow_dir/TASKS.md" ] && create_symlink "$shipflow_dir/TASKS.md" "$HOME/TASKS.md" false
            [ -f "$shipflow_dir/AUDIT_LOG.md" ] && create_symlink "$shipflow_dir/AUDIT_LOG.md" "$HOME/AUDIT_LOG.md" false
            [ -f "$shipflow_dir/CLAUDE.md" ] && create_symlink "$shipflow_dir/CLAUDE.md" "$HOME/CLAUDE.md" false
            success "ShipFlow linked"

            # Run ShipFlow installer automatically
            if [ -f "$shipflow_dir/install.sh" ] && ! is_dry_run; then
                info "Running ShipFlow installer (PM2, Flox, Caddy)..."
                bash "$shipflow_dir/install.sh" 2>&1 || warn "ShipFlow installation had issues"
            fi
        fi
    fi
}

# ============================================================================
# SHELL INTEGRATION
# ============================================================================
setup_shell_integration() {
    if ! should_install "shell-integration"; then return 0; fi

    info "Setting up shell integration..."

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would add shell integration to ~/.bashrc"
        return 0
    fi

    # Make scripts executable
    for script in "switch-config.sh" "nvim-multi" "aliases.sh" "shell-integration.sh"; do
        [ -f "$SCRIPT_DIR/nvim/$script" ] && chmod +x "$SCRIPT_DIR/nvim/$script" 2>/dev/null || true
    done

    # Shell integration
    append_to_bashrc "shell-integration.sh" "source $SCRIPT_DIR/nvim/shell-integration.sh" "Neovim config switcher" || true

    # Starship
    is_installed starship && append_to_bashrc 'starship init' 'eval "$(starship init bash)"' "Starship prompt" || true

    # Zoxide
    is_installed zoxide && append_to_bashrc 'zoxide init' 'eval "$(zoxide init bash)"' "Zoxide - smart cd" || true

    # Default editor
    is_installed nvim && append_to_bashrc 'export VISUAL=nvim' $'export VISUAL=nvim\nexport EDITOR=nvim' "Default editor" || true

    # Cargo/Rustup PATH
    [ -f "$HOME/.cargo/env" ] && append_to_bashrc 'cargo/env' 'source "$HOME/.cargo/env"' "Rust/Cargo PATH" || true

    # Productivity aliases
    if ! grep -q "# Productivity aliases" "$HOME/.bashrc" 2>/dev/null; then
        cat >> "$HOME/.bashrc" << 'ALIASES'

# Productivity aliases
alias re='source ~/.bashrc && echo "✓ Shell reloaded"'
alias reload='source ~/.bashrc && echo "✓ Shell reloaded"'
alias c='claude'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# Git
alias gs='git status'
alias ga='git add .'
gc() { git commit -m "${1:-up}"; }
function gp { if [ -n "$(git status --porcelain)" ]; then git add -A && git commit -m "${1:-up}"; fi; git push; }
alias gl='git pull'
alias glog='git log --oneline --graph'

# Better tools (if installed)
command -v bat >/dev/null && alias cat='bat --paging=never'
command -v lsd >/dev/null && alias ls='lsd' && alias ll='lsd -lh' && alias la='lsd -lAh'

# File managers
alias r='ranger'
alias y='yazi'

# AI coding tools
alias k='kilocode'
alias o='opencode'
alias mcp='mcpc'

# Dotfiles management
alias dot='~/dotfiles/install.sh'
alias dotfiles='~/dotfiles/install.sh -i'
ALIASES
        success "Added productivity aliases"
    else
        # Migrate old gc/gp aliases to functions
        if grep -q "alias gc='git commit -m'" "$HOME/.bashrc" 2>/dev/null; then
            sed -i "s|alias gc='git commit -m'|function gc { git commit -m \"\${1:-up}\"; }|" "$HOME/.bashrc"
            success "Migrated gc alias to function"
        fi
        if grep -q "alias gp='git push'" "$HOME/.bashrc" 2>/dev/null; then
            sed -i "s|alias gp='git push'|function gp { if [ -n \"\$(git status --porcelain)\" ]; then git add -A \&\& git commit -m \"\${1:-up}\"; fi; git push; }|" "$HOME/.bashrc"
            success "Migrated gp alias to smart function"
        fi

        # Ensure dotfiles aliases exist even if section was added previously
        if ! grep -q "alias dot=" "$HOME/.bashrc" 2>/dev/null; then
            cat >> "$HOME/.bashrc" << 'DOTALIASES'

# Dotfiles management
alias dot='~/dotfiles/install.sh'
alias dotfiles='~/dotfiles/install.sh -i'
DOTALIASES
            success "Added dotfiles aliases"
        fi
    fi

    # Source for current session
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/nvim/shell-integration.sh" 2>/dev/null || true
    hash -r 2>/dev/null
}

# ============================================================================
# RUN INSTALLATION
# ============================================================================
# Only install system packages for full install or components that need them
needs_system_packages() {
    [ -z "${DOTFILES_ONLY:-}" ] || \
    [[ ",$DOTFILES_ONLY," == *",neovim,"* ]] || \
    [[ ",$DOTFILES_ONLY," == *",yazi,"* ]] || \
    [[ ",$DOTFILES_ONLY," == *",fzf,"* ]]
}

if needs_system_packages; then
    info "Installing dependencies..."
    install_system_packages
fi

# --- Phase 2: Tools (no dependencies between them) ---
if [ "${DOTFILES_PARALLEL:-false}" = "true" ]; then
    info "Running installations in parallel..."
    parallel_run "Neovim" install_neovim
    parallel_run "fzf" install_fzf
    parallel_run "Nerd Fonts" install_nerd_fonts
    parallel_run "GitHub CLI" install_gh
    parallel_run "lsd" install_lsd
    parallel_run "bat" install_bat
    parallel_wait
else
    install_neovim
    install_fzf
    install_nerd_fonts
    install_gh
    install_lsd
    install_bat
fi

# --- Phase 3: Node.js ecosystem (order matters) ---
install_node

# Refresh PATH so npm/node are available for subsequent steps
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null || true
export PATH="$HOME/.npm-global/bin:${DOTFILES_NPM_DIR:-$HOME/.npm-global}/bin:$PATH"
hash -r 2>/dev/null || true

install_npm_tools

# --- Phase 4: Shell tools ---
if [ "${DOTFILES_PARALLEL:-false}" = "true" ]; then
    parallel_run "Starship" install_starship
    parallel_run "Zoxide" install_zoxide
    parallel_run "Yazi" install_yazi
    parallel_run "Doppler" install_doppler
    parallel_wait
else
    install_starship
    install_zoxide
    install_yazi
    install_doppler
fi

# --- Phase 5: AI Coding Tools ---
install_ai_tools() {
    if ! should_install "ai-tools"; then return 0; fi

    # Claude Code
    if ! is_installed claude; then
        if is_installed npm; then
            info "Installing Claude Code..."
            if is_dry_run; then
                echo -e "${BLUE}[DRY-RUN]${NC} Would install @anthropic-ai/claude-code"
            else
                npm install -g @anthropic-ai/claude-code 2>/dev/null && success "Claude Code installed" || warn "Claude Code installation failed"
                hash -r 2>/dev/null || true
            fi
        else
            warn "npm not found, skipping Claude Code"
        fi
    else
        success "Claude Code already installed"
    fi

    # OpenAI Codex (already in npm_tools but ensure it's present)
    if ! command -v codex >/dev/null 2>&1; then
        if is_installed npm; then
            info "Installing OpenAI Codex..."
            if is_dry_run; then
                echo -e "${BLUE}[DRY-RUN]${NC} Would install @openai/codex"
            else
                npm install -g @openai/codex 2>/dev/null && success "Codex installed" || warn "Codex installation failed"
            fi
        fi
    else
        success "Codex already installed"
    fi
}
install_ai_tools

# Ensure claude CLI is in PATH for MCP setup
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:${DOTFILES_NPM_DIR:-$HOME/.npm-global}/bin:$PATH"
hash -r 2>/dev/null || true

# --- Phase 6: Configuration ---
setup_configs
setup_mcp_config
setup_shell_integration

# ============================================================================
# NEOVIM PLUGINS
# ============================================================================
if [ "${AUTO_INSTALL_NVIM_PLUGINS:-false}" = "true" ] && ! is_dry_run; then
    info "Installing Neovim plugins..."
    nvim --headless "+Lazy! sync" +qa >/tmp/nvim-install.log 2>&1 || warn "Plugin installation had issues"
    success "Neovim plugins installed"
fi

# ============================================================================
# AUTHENTICATION (only for full install or auth-related components)
# ============================================================================
needs_auth() {
    [ -z "${DOTFILES_ONLY:-}" ] || \
    [[ ",$DOTFILES_ONLY," == *",doppler,"* ]] || \
    [[ ",$DOTFILES_ONLY," == *",gh,"* ]]
}

if ! is_dry_run && needs_auth; then
    DOPPLER_AUTHENTICATED=false
    if is_installed doppler; then
        if [ -n "${DOPPLER_TOKEN:-}" ]; then
            export DOPPLER_TOKEN
            doppler me &>/dev/null 2>&1 && DOPPLER_AUTHENTICATED=true && success "Doppler authenticated"
        elif doppler me &>/dev/null 2>&1; then
            DOPPLER_AUTHENTICATED=true
            success "Doppler already authenticated"
        fi
    fi

    # GitHub CLI
    GH_TOKEN_FINAL="${GH_TOKEN:-${GITHUB_TOKEN:-}}"
    if [ -z "$GH_TOKEN_FINAL" ] && [ "$DOPPLER_AUTHENTICATED" = "true" ]; then
        GH_TOKEN_FINAL=$(doppler secrets get GH_TOKEN --plain 2>/dev/null || echo "")
    fi

    if [ -n "$GH_TOKEN_FINAL" ]; then
        echo "$GH_TOKEN_FINAL" | gh auth login --with-token >/dev/null 2>&1 && success "GitHub authenticated"
    elif gh auth status &>/dev/null 2>&1; then
        success "GitHub already authenticated"
    fi
fi

# ============================================================================
# NON-ROOT USER CREATION
# ============================================================================
setup_non_root_user() {
    # Only when running as root and in interactive mode
    if [ "$(id -u)" -ne 0 ] || ! [ -t 0 ] || is_dry_run; then
        return 0
    fi

    echo ""
    info "Creation d'un utilisateur non-root..."

    local username=""
    if use_gum; then
        username=$(gum input --placeholder "dev" --header "Nom de l'utilisateur a creer (Enter pour 'dev'):" 2>/dev/null || echo "")
    else
        read -r -p "Nom de l'utilisateur a creer (defaut: dev): " username
    fi
    username="${username:-dev}"

    # Validate username
    if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        warn "Nom d'utilisateur invalide: $username"
        return 0
    fi

    # Create user if doesn't exist
    if id "$username" &>/dev/null; then
        success "Utilisateur '$username' existe deja"
    else
        useradd -m -s /bin/bash "$username" 2>/dev/null || { warn "Impossible de creer l'utilisateur '$username'"; return 0; }
        success "Utilisateur '$username' cree"
    fi

    local user_home="/home/$username"

    # Copy SSH keys
    if [ -d /root/.ssh ]; then
        mkdir -p "$user_home/.ssh"
        [ -f /root/.ssh/authorized_keys ] && cp /root/.ssh/authorized_keys "$user_home/.ssh/" 2>/dev/null || true
        [ -f /root/.ssh/id_ed25519 ] && cp /root/.ssh/id_ed25519 "$user_home/.ssh/" 2>/dev/null || true
        [ -f /root/.ssh/id_ed25519.pub ] && cp /root/.ssh/id_ed25519.pub "$user_home/.ssh/" 2>/dev/null || true
        [ -f /root/.ssh/known_hosts ] && cp /root/.ssh/known_hosts "$user_home/.ssh/" 2>/dev/null || true
        chown -R "$username:$username" "$user_home/.ssh"
        chmod 700 "$user_home/.ssh"
        chmod 600 "$user_home/.ssh/id_ed25519" 2>/dev/null || true
        chmod 600 "$user_home/.ssh/authorized_keys" 2>/dev/null || true
        success "Cles SSH copiees"
    fi

    # Add to sudo group
    usermod -aG sudo "$username" 2>/dev/null || true

    # Configure PATH in user's bashrc
    if ! grep -q ".local/bin" "$user_home/.bashrc" 2>/dev/null; then
        cat >> "$user_home/.bashrc" << 'USERPATH'

# Tool paths
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.cargo/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
USERPATH
    fi
    chown "$username:$username" "$user_home/.bashrc"

    # Run dotfiles install for this user (user-local mode)
    info "Installation des dotfiles pour '$username'..."
    sudo -u "$username" bash -c "cd $SCRIPT_DIR && ./install.sh --only=configs,shell-integration,mcp" 2>&1 || warn "User dotfiles setup had issues"

    success "Utilisateur '$username' configure avec SSH + sudo"
    echo ""
    echo -e "  Connexion: ${CYAN}ssh $username@$(hostname)${NC}"
}

if [ -t 0 ] && [ "$(id -u)" -eq 0 ] && ! is_dry_run; then
    setup_non_root_user
fi

# ============================================================================
# COMPLETION
# ============================================================================
echo ""
echo "════════════════════════════════════════════════════════════════"
if is_dry_run; then
    echo "  Dry-run complete! No changes were made."
    echo "  Run without --dry-run to apply changes."
else
    echo "  Installation complete!"
    echo ""
    echo "  Log: $DOTFILES_LOG_FILE"
    echo "  Reload: source ~/.bashrc"
    echo ""
    # Quick status summary
    echo "  Tools:"
    command -v nvim >/dev/null 2>&1 && echo "    Neovim ........... OK" || echo "    Neovim ........... MISSING"
    command -v node >/dev/null 2>&1 && echo "    Node.js .......... OK ($(node --version 2>/dev/null))" || echo "    Node.js .......... MISSING"
    command -v claude >/dev/null 2>&1 && echo "    Claude Code ...... OK" || echo "    Claude Code ...... MISSING"
    command -v codex >/dev/null 2>&1 && echo "    Codex ............ OK" || echo "    Codex ............ MISSING"
    command -v pm2 >/dev/null 2>&1 && echo "    PM2 .............. OK" || echo "    PM2 .............. MISSING"
    command -v starship >/dev/null 2>&1 && echo "    Starship ......... OK" || echo "    Starship ......... MISSING"
    command -v flox >/dev/null 2>&1 && echo "    Flox ............. OK" || echo "    Flox ............. MISSING"
    command -v caddy >/dev/null 2>&1 && echo "    Caddy ............ OK" || echo "    Caddy ............ MISSING"
    echo ""
    echo "  Launch: sf (or shipflow)"
fi
echo "════════════════════════════════════════════════════════════════"
