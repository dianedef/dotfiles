#!/bin/bash
# ============================================================================
# Dotfiles Library - Reusable functions
# ============================================================================
# This file contains all reusable utility functions for the dotfiles installer.

# ============================================================================
# COLORS AND FORMATTING
# ============================================================================
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

# ============================================================================
# LOGGING SYSTEM
# ============================================================================
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Level priority filtering
    local level_priority config_priority
    case "$level" in
        DEBUG) level_priority=0 ;;
        INFO) level_priority=1 ;;
        WARN) level_priority=2 ;;
        ERROR) level_priority=3 ;;
        *) level_priority=1 ;;
    esac
    case "${DOTFILES_LOG_LEVEL:-INFO}" in
        DEBUG) config_priority=0 ;;
        INFO) config_priority=1 ;;
        WARN) config_priority=2 ;;
        ERROR) config_priority=3 ;;
        *) config_priority=1 ;;
    esac

    [ "$level_priority" -lt "$config_priority" ] && return 0

    # Write to log file
    if [ -n "${DOTFILES_LOG_FILE:-}" ]; then
        echo "[$timestamp] [$level] $message" >> "$DOTFILES_LOG_FILE" 2>/dev/null
    fi

    # Console output with colors
    case "$level" in
        ERROR) echo -e "${RED}$message${NC}" >&2 ;;
        WARN) echo -e "${YELLOW}$message${NC}" ;;
        INFO) echo -e "$message" ;;
        DEBUG) [ "${DOTFILES_DEBUG_MODE:-false}" = "true" ] && echo -e "${BLUE}[DEBUG] $message${NC}" ;;
    esac
}

success() { log INFO "${GREEN}✅${NC} $1"; }
error() { log ERROR "❌ $1"; }
warn() { log WARN "⚠️  $1"; }
info() { log INFO "📋 $1"; }

# ============================================================================
# LOG INITIALIZATION AND ROTATION
# ============================================================================
init_logging() {
    mkdir -p "$(dirname "$DOTFILES_LOG_FILE")" 2>/dev/null

    if [ -f "$DOTFILES_LOG_FILE" ]; then
        local log_size
        log_size=$(stat -c%s "$DOTFILES_LOG_FILE" 2>/dev/null || stat -f%z "$DOTFILES_LOG_FILE" 2>/dev/null || echo 0)
        if [ "$log_size" -gt "${DOTFILES_LOG_ROTATION_SIZE:-10485760}" ]; then
            mv "$DOTFILES_LOG_FILE" "$DOTFILES_LOG_FILE.$(date +%s)"
            find "$(dirname "$DOTFILES_LOG_FILE")" -name "*.log.*" -mtime +"${DOTFILES_LOG_RETENTION_DAYS:-30}" -delete 2>/dev/null
        fi
    fi

    touch "$DOTFILES_LOG_FILE" 2>/dev/null
    log INFO "Starting installation script - Log file: $DOTFILES_LOG_FILE"
}

# ============================================================================
# ERROR HANDLING
# ============================================================================
error_trap_handler() {
    local exit_code=$?
    local line_number=$1
    log ERROR "Script failed at line $line_number with exit code $exit_code"
}

setup_error_traps() {
    trap 'error_trap_handler ${LINENO}' ERR
}

# ============================================================================
# SYSTEM DETECTION
# ============================================================================
detect_system() {
    # Detect OS
    case "$(uname -s)" in
        Linux*)
            OS="linux"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="$ID"
                DISTRO_FAMILY="${ID_LIKE:-$ID}"
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
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
        *) ARCH="$(uname -m)" ;;
    esac

    # Detect sudo access
    if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
        HAS_SUDO=true
    elif [ "$(id -u)" = "0" ]; then
        HAS_SUDO=true
    else
        HAS_SUDO=false
    fi

    # User-local mode: forced via env var or auto-detected when no sudo
    if [ "${USER_LOCAL_MODE:-false}" = "true" ] || [ "$HAS_SUDO" = "false" ]; then
        USER_LOCAL_MODE=true
    else
        USER_LOCAL_MODE=false
    fi

    export OS DISTRO DISTRO_FAMILY ARCH HAS_SUDO USER_LOCAL_MODE
}

# ============================================================================
# COMMAND UTILITIES
# ============================================================================
is_installed() {
    command -v "$1" &>/dev/null
}

require_command() {
    local cmd=$1
    local install_hint=${2:-"Please install $cmd"}
    if ! is_installed "$cmd"; then
        error "$cmd is required but not installed. $install_hint"
        return 1
    fi
}

# ============================================================================
# GITHUB API CACHING
# ============================================================================
# Cache storage (associative arrays not available in all bash versions)
declare -A CACHE_VALUES 2>/dev/null || true
declare -A CACHE_TIMES 2>/dev/null || true

get_latest_release() {
    local repo=$1
    local fallback=$2
    local current_time
    current_time=$(date +%s)
    local cache_key="github_${repo//\//_}"

    # Check cache (use file-based cache for compatibility)
    if [ "${DOTFILES_CACHE_ENABLED:-true}" = "true" ]; then
        local cache_file="/tmp/dotfiles_cache_$cache_key"
        if [ -f "$cache_file" ]; then
            local cached_time cached_value
            cached_time=$(head -1 "$cache_file" 2>/dev/null || echo 0)
            cached_value=$(tail -1 "$cache_file" 2>/dev/null || echo "")
            local cache_age=$((current_time - cached_time))

            if [ "$cache_age" -lt "${DOTFILES_CACHE_TTL:-300}" ] && [ -n "$cached_value" ]; then
                log DEBUG "Using cached version for $repo: $cached_value"
                echo "$cached_value"
                return 0
            fi
        fi
    fi

    # Fetch from GitHub API
    local version=""
    if is_installed jq; then
        version=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | jq -r '.tag_name // empty' 2>/dev/null)
    else
        version=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    fi

    if [ -z "$version" ]; then
        log WARN "Failed to fetch latest version for $repo, using fallback: $fallback"
        version="$fallback"
    fi

    # Update cache
    if [ "${DOTFILES_CACHE_ENABLED:-true}" = "true" ]; then
        local cache_file="/tmp/dotfiles_cache_$cache_key"
        echo "$current_time" > "$cache_file"
        echo "$version" >> "$cache_file"
    fi

    echo "$version"
}

invalidate_cache() {
    local repo=$1
    local cache_key="github_${repo//\//_}"
    rm -f "/tmp/dotfiles_cache_$cache_key" 2>/dev/null
}

# ============================================================================
# PATH MANAGEMENT
# ============================================================================
get_install_path() {
    local type=$1  # "bin" or "opt"
    if [ "$USER_LOCAL_MODE" = "true" ]; then
        case "$type" in
            bin) echo "$HOME/.local/bin" ;;
            opt) echo "$HOME/.local" ;;
            *) echo "$HOME/.local" ;;
        esac
    else
        case "$type" in
            bin) echo "/usr/local/bin" ;;
            opt) echo "/opt" ;;
            *) echo "/opt" ;;
        esac
    fi
}

run_privileged() {
    if [ "$USER_LOCAL_MODE" = "true" ] || [ "$HAS_SUDO" = "false" ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# ============================================================================
# BASHRC MODIFICATION
# ============================================================================
append_to_bashrc() {
    local search_string=$1
    local content=$2
    local comment=${3:-"Added by dotfiles installer"}

    if ! grep -q "$search_string" "$HOME/.bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# $comment"
            echo "$content"
        } >> "$HOME/.bashrc"
        log DEBUG "Added to .bashrc: $search_string"
        return 0
    fi
    log DEBUG "Already in .bashrc: $search_string"
    return 1
}

# ============================================================================
# FILE DOWNLOAD UTILITIES
# ============================================================================
download_file() {
    local url=$1
    local output=$2
    local retries=${3:-3}

    log DEBUG "Downloading: $url"

    for i in $(seq 1 "$retries"); do
        if curl -sL --fail --retry 2 -o "$output" "$url" 2>/dev/null; then
            if [ -f "$output" ] && [ -s "$output" ]; then
                log DEBUG "Download successful: $output"
                return 0
            fi
        fi
        log WARN "Download attempt $i/$retries failed for $url"
        sleep 1
    done

    error "Failed to download after $retries attempts: $url"
    return 1
}

download_and_extract() {
    local url=$1
    local dest_dir=$2
    local archive_type=${3:-auto}

    local tmp_file
    tmp_file=$(mktemp)

    if ! download_file "$url" "$tmp_file"; then
        rm -f "$tmp_file"
        return 1
    fi

    # Auto-detect archive type
    if [ "$archive_type" = "auto" ]; then
        case "$url" in
            *.tar.gz|*.tgz) archive_type="tar.gz" ;;
            *.tar.xz) archive_type="tar.xz" ;;
            *.zip) archive_type="zip" ;;
            *) archive_type="tar.gz" ;;  # Default
        esac
    fi

    mkdir -p "$dest_dir"

    local result=0
    case "$archive_type" in
        tar.gz) tar -xzf "$tmp_file" -C "$dest_dir" 2>/dev/null || result=1 ;;
        tar.xz) tar -xJf "$tmp_file" -C "$dest_dir" 2>/dev/null || result=1 ;;
        zip) unzip -q -o "$tmp_file" -d "$dest_dir" 2>/dev/null || result=1 ;;
        *) result=1 ;;
    esac

    rm -f "$tmp_file"

    if [ $result -ne 0 ]; then
        error "Failed to extract archive to $dest_dir"
        return 1
    fi

    log DEBUG "Extracted to: $dest_dir"
    return 0
}

# ============================================================================
# SYMLINK MANAGEMENT
# ============================================================================
create_symlink() {
    local source=$1
    local target=$2
    local backup=${3:-true}

    # Validation
    if [ ! -e "$source" ]; then
        warn "Source does not exist: $source"
        return 1
    fi

    # Backup existing
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ "$backup" = "true" ]; then
            local backup_path="${target}.backup.$(date +%s)"
            mv "$target" "$backup_path"
            log DEBUG "Backed up: $target -> $backup_path"
        else
            rm -rf "$target"
        fi
    fi

    # Create parent directory
    mkdir -p "$(dirname "$target")"

    # Create symlink
    if ln -s "$source" "$target"; then
        success "Linked: $target -> $source"
        return 0
    else
        error "Failed to create symlink: $target -> $source"
        return 1
    fi
}

# ============================================================================
# INPUT VALIDATION
# ============================================================================
validate_path() {
    local path=$1

    [ -z "$path" ] && { error "Path cannot be empty"; return 1; }
    [[ "$path" != /* ]] && { error "Path must be absolute"; return 1; }
    [[ "$path" == *..* ]] && { error "Path traversal blocked"; return 1; }
    [[ "$path" =~ ${DOTFILES_DANGEROUS_CHARS_REGEX:-'[;&|$`]'} ]] && { error "Invalid characters in path"; return 1; }

    return 0
}

# ============================================================================
# DRY-RUN SUPPORT
# ============================================================================
# Wrapper that logs action in dry-run mode, executes otherwise
run_action() {
    local description="$1"
    shift

    if [ "${DOTFILES_DRY_RUN:-false}" = "true" ]; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would: $description"
        return 0
    else
        "$@"
    fi
}

# Check if we should skip due to dry-run
is_dry_run() {
    [ "${DOTFILES_DRY_RUN:-false}" = "true" ]
}

# ============================================================================
# SELECTIVE INSTALLATION (--only flag)
# ============================================================================
# Check if a component should be installed
should_install() {
    local component="$1"

    # If no --only specified, install everything
    if [ -z "${DOTFILES_ONLY:-}" ]; then
        return 0
    fi

    # Check if component is in the list
    if [[ ",$DOTFILES_ONLY," == *",$component,"* ]]; then
        return 0
    fi

    log DEBUG "Skipping $component (not in --only list)"
    return 1
}

# ============================================================================
# HEALTH CHECK (--check flag)
# ============================================================================
declare -A HEALTH_STATUS 2>/dev/null || true

health_check_tool() {
    local name="$1"
    local cmd="$2"
    local version_flag="${3:---version}"

    if is_installed "$cmd"; then
        local version
        version=$("$cmd" $version_flag 2>&1 | head -1) || version="installed"
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name: not installed"
        return 1
    fi
}

health_check_symlink() {
    local name="$1"
    local path="$2"

    if [ -L "$path" ]; then
        local target
        target=$(readlink -f "$path" 2>/dev/null || readlink "$path")
        if [ -e "$target" ]; then
            echo -e "${GREEN}✓${NC} $name: $path -> $target"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} $name: broken symlink $path -> $target"
            return 1
        fi
    elif [ -e "$path" ]; then
        echo -e "${YELLOW}⚠${NC} $name: exists but not a symlink: $path"
        return 1
    else
        echo -e "${RED}✗${NC} $name: missing $path"
        return 1
    fi
}

health_check_bashrc() {
    local name="$1"
    local pattern="$2"

    if grep -q "$pattern" "$HOME/.bashrc" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $name: configured in ~/.bashrc"
        return 0
    else
        echo -e "${RED}✗${NC} $name: not in ~/.bashrc"
        return 1
    fi
}

# ============================================================================
# HELP MENU
# ============================================================================
run_help_menu() {
    while true; do
        clear
        echo "════════════════════════════════════════════════════════════════"
        echo "                         🆘 HELP"
        echo "════════════════════════════════════════════════════════════════"
        echo ""

        local choice
        choice=$(gum choose --header "Select a topic:" \
            "🚀 Quick Start" \
            "⌨️  Aliases & Commands" \
            "🔑 API Keys Setup" \
            "🛠️  Troubleshooting" \
            "📖 About this project" \
            "⬅️  Back to main menu")

        case "$choice" in
            *"Quick Start"*)
                show_help_quickstart
                ;;
            *"Aliases"*)
                show_help_aliases
                ;;
            *"API Keys"*)
                show_help_apikeys
                ;;
            *"Troubleshooting"*)
                show_help_troubleshooting
                ;;
            *"About"*)
                show_help_about
                ;;
            *"Back"*|"")
                return 0
                ;;
        esac
    done
}

show_help_quickstart() {
    local content
    content=$(cat <<'EOF'
══════════════════════════════════════════════════════════════
                    🚀 QUICK START
══════════════════════════════════════════════════════════════

## First Time Setup

1. Clone the repository:
   git clone https://github.com/dianedef/dotfiles.git ~/dotfiles

2. Run installation:
   cd ~/dotfiles && ./install.sh

3. (Optional) Setup API keys:
   ds    # Doppler setup - configures all keys

4. Reload your shell:
   re    # or: source ~/.bashrc

## Platforms

┌─────────────┬────────────────────────────────────┐
│ Platform    │ Command                            │
├─────────────┼────────────────────────────────────┤
│ Linux       │ ./install.sh                       │
│ Codespaces  │ (runs automatically)               │
│ Termux      │ ./termux.sh                        │
│ Windows     │ .\windows.ps1 (as admin)           │
└─────────────┴────────────────────────────────────┘

## After Installation

- Use 'dot -i' for interactive menu
- Use 'dot -u' to check for updates
- Use 'dot -c' for health check

EOF
)
    echo "$content" | gum pager
}

show_help_aliases() {
    local content
    content=$(cat <<'EOF'
══════════════════════════════════════════════════════════════
                   ⌨️  ALIASES & COMMANDS
══════════════════════════════════════════════════════════════

## Shell Aliases

┌─────────┬─────────────────────────┬─────────────────────────┐
│ Alias   │ Command                 │ Description             │
├─────────┼─────────────────────────┼─────────────────────────┤
│ re      │ source ~/.bashrc        │ Reload shell            │
│ c       │ claude                  │ Claude Code CLI         │
│ dot     │ ~/dotfiles/install.sh   │ Run installer           │
│ ds      │ doppler-setup.sh        │ Setup API keys          │
├─────────┼─────────────────────────┼─────────────────────────┤
│ y       │ yazi                    │ File manager            │
│ r       │ ranger                  │ File manager (Termux)   │
│ z <dir> │ zoxide                  │ Smart cd                │
├─────────┼─────────────────────────┼─────────────────────────┤
│ gs      │ git status              │ Git status              │
│ ga      │ git add .               │ Stage all               │
│ gc      │ git commit -m           │ Commit                  │
│ gp      │ git push                │ Push                    │
│ gl      │ git pull                │ Pull                    │
│ glog    │ git log --oneline       │ Log graph               │
└─────────┴─────────────────────────┴─────────────────────────┘

## Dotfiles Commands

┌──────────┬──────────────────────────────────────────────────┐
│ Command  │ Description                                      │
├──────────┼──────────────────────────────────────────────────┤
│ dot      │ Run installer (same as ./install.sh)             │
│ dot -i   │ Interactive menu                                 │
│ dot -u   │ Check & install updates                          │
│ dot -c   │ Health check                                     │
│ dot -n   │ Dry-run (preview changes)                        │
│ dot -h   │ Show help                                        │
└──────────┴──────────────────────────────────────────────────┘

EOF
)
    echo "$content" | gum pager
}

show_help_apikeys() {
    local content
    content=$(cat <<'EOF'
══════════════════════════════════════════════════════════════
                     🔑 API KEYS SETUP
══════════════════════════════════════════════════════════════

## Quick Setup with Doppler

Run: ds (or doppler-setup.sh)

This will prompt for all keys and store them securely.

## Manual Setup

Add to ~/.bashrc or use Doppler:

┌─────────────┬─────────────────────────────────────────────────┐
│ Service     │ Get your key at                                 │
├─────────────┼─────────────────────────────────────────────────┤
│ GitHub      │ github.com/settings/tokens                      │
│ OpenAI      │ platform.openai.com/api-keys                    │
│ Anthropic   │ console.anthropic.com/settings/keys             │
│ Gemini      │ aistudio.google.com/apikey                      │
│ Groq        │ console.groq.com/keys                           │
└─────────────┴─────────────────────────────────────────────────┘

## GitHub Token Scopes Required

✅ repo        - Repository access
✅ read:org    - Organization membership
✅ gist        - Create gists
✅ workflow    - GitHub Actions (optional)

## Verify Setup

doppler secrets        # List all secrets
gh auth status         # Check GitHub auth
echo $ANTHROPIC_API_KEY # Check if key is set

EOF
)
    echo "$content" | gum pager
}

show_help_troubleshooting() {
    local content
    content=$(cat <<'EOF'
══════════════════════════════════════════════════════════════
                    🛠️  TROUBLESHOOTING
══════════════════════════════════════════════════════════════

## Command not found after install

→ Reload your shell:
  re   # or: source ~/.bashrc

→ Check PATH includes ~/.local/bin:
  echo $PATH | tr ':' '\n' | grep local

## GitHub auth failed

→ Check token:
  doppler secrets get GH_TOKEN

→ Re-authenticate:
  gh auth login

## Doppler not working

→ Re-login:
  doppler login
  ds

→ Verify:
  doppler me
  doppler secrets

## Neovim plugins not loading

→ Sync plugins:
  nvim --headless "+Lazy! sync" +qa

→ Check health:
  nvim
  :checkhealth

## Tool not updating

→ Check if installed via apt (manual update):
  which <tool>

→ If in /usr/bin, update via apt:
  sudo apt update && sudo apt upgrade

## Yazi/Neovim not found after install

→ Ensure ~/.local/bin is in PATH:
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  re

## Permission denied

→ Don't use sudo with this installer
→ Everything installs to ~/.local/bin

EOF
)
    echo "$content" | gum pager
}

show_help_about() {
    local content
    content=$(cat <<'EOF'
══════════════════════════════════════════════════════════════
                   📖 ABOUT THIS PROJECT
══════════════════════════════════════════════════════════════

## Dotfiles Repository

Multi-platform dotfiles for developers who work across:
- GitHub Codespaces
- Linux servers (SSH)
- Termux (Android)
- Windows

## What's Included

📦 Tools installed:
   - Neovim (with LazyVim)
   - Starship prompt
   - Zoxide (smart cd)
   - Yazi (file manager)
   - fzf (fuzzy finder)
   - bat, lsd, ripgrep, fd

🔧 Configurations:
   - Shell aliases & functions
   - Git config
   - Tmux config
   - MCP servers for Claude

## Philosophy

- No sudo required (installs to ~/.local/bin)
- Symlinks configs (easy updates with git pull)
- Fast & lightweight (optimized for SSH)
- Interactive menu (dot -i)

## Repository

github.com/dianedef/dotfiles

## Credits

Built with Claude Code 🤖

EOF
)
    echo "$content" | gum pager
}

run_health_check() {
    echo "════════════════════════════════════════════════════════════════"
    echo "                    DOTFILES HEALTH CHECK"
    echo "════════════════════════════════════════════════════════════════"
    echo ""

    local failed=0

    echo "📦 Tools:"
    health_check_tool "Neovim" "nvim" || failed=$((failed + 1))
    health_check_tool "Node.js" "node" || failed=$((failed + 1))
    health_check_tool "npm" "npm" || failed=$((failed + 1))
    health_check_tool "fzf" "fzf" || failed=$((failed + 1))
    health_check_tool "Starship" "starship" || failed=$((failed + 1))
    health_check_tool "Zoxide" "zoxide" || failed=$((failed + 1))
    health_check_tool "Yazi" "yazi" || failed=$((failed + 1))
    health_check_tool "Doppler" "doppler" || failed=$((failed + 1))
    health_check_tool "ripgrep" "rg" || failed=$((failed + 1))
    health_check_tool "fd" "fd" || failed=$((failed + 1))
    health_check_tool "bat" "bat" || failed=$((failed + 1))
    health_check_tool "lsd" "lsd" || failed=$((failed + 1))
    health_check_tool "Git" "git" || failed=$((failed + 1))
    health_check_tool "GitHub CLI" "gh" || failed=$((failed + 1))
    health_check_tool "mcpc (MCP CLI)" "mcpc" || failed=$((failed + 1))

    echo ""
    echo "🔗 Symlinks:"
    health_check_symlink "Neovim config" "$HOME/.config/nvim" || failed=$((failed + 1))
    health_check_symlink "Yazi config" "$HOME/.config/yazi" || failed=$((failed + 1))
    health_check_symlink "Starship config" "$HOME/.config/starship.toml" || failed=$((failed + 1))
    health_check_symlink "Tmux config" "$HOME/.tmux.conf" || failed=$((failed + 1))
    health_check_symlink "MCP config" "$HOME/.config/mcp/servers.json" || failed=$((failed + 1))

    echo ""
    echo "🐚 Shell integration:"
    health_check_bashrc "Starship" "starship init" || failed=$((failed + 1))
    health_check_bashrc "Zoxide" "zoxide init" || failed=$((failed + 1))
    health_check_bashrc "Shell integration" "shell-integration.sh" || failed=$((failed + 1))
    health_check_bashrc "PATH (local bin)" ".local/bin" || failed=$((failed + 1))
    health_check_bashrc "PATH (npm-global)" "npm-global" || failed=$((failed + 1))

    echo ""
    echo "🔐 Authentication:"
    if gh auth status &>/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} GitHub CLI: authenticated"
    else
        echo -e "${RED}✗${NC} GitHub CLI: not authenticated"
        failed=$((failed + 1))
    fi

    if is_installed doppler && doppler me &>/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Doppler: authenticated"
    else
        echo -e "${YELLOW}⚠${NC} Doppler: not authenticated (optional)"
    fi

    echo ""
    echo "════════════════════════════════════════════════════════════════"
    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}All checks passed!${NC}"
    else
        echo -e "${YELLOW}$failed issue(s) found${NC}"
    fi
    echo "════════════════════════════════════════════════════════════════"

    return $failed
}

# ============================================================================
# UPDATE MODE (--update flag)
# ============================================================================
update_tool() {
    local name="$1"
    local current_version="$2"
    local latest_version="$3"
    local update_fn="$4"

    if [ "$current_version" = "$latest_version" ]; then
        success "$name is up to date ($current_version)"
        return 0
    fi

    info "Updating $name: $current_version -> $latest_version"

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would update $name from $current_version to $latest_version"
        return 0
    fi

    # Call the update function
    "$update_fn"
}

get_installed_version() {
    local tool="$1"

    case "$tool" in
        neovim)
            nvim --version 2>/dev/null | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        yazi)
            yazi --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown"
            ;;
        starship)
            starship --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        zoxide)
            zoxide --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        fzf)
            fzf --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        doppler)
            doppler --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown"
            ;;
        node)
            node --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        gum)
            gum --version 2>/dev/null | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown"
            ;;
        gh)
            gh --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        bat)
            bat --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown"
            ;;
        lsd)
            lsd --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            ;;
        lazygit)
            lazygit --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Normalize version string (remove 'v' prefix, handle different formats)
normalize_version() {
    local version="$1"
    echo "$version" | sed 's/^v//' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}

# Compare two version strings: returns 0 if v1 >= v2, 1 otherwise
version_gte() {
    local v1="$1"
    local v2="$2"

    v1=$(normalize_version "$v1")
    v2=$(normalize_version "$v2")

    [ -z "$v1" ] && return 1
    [ -z "$v2" ] && return 0

    # Use sort -V for version comparison
    local highest
    highest=$(printf '%s\n%s' "$v1" "$v2" | sort -V | tail -1)
    [ "$v1" = "$highest" ]
}

# Get latest version for a tool
get_latest_version() {
    local tool="$1"

    case "$tool" in
        neovim)
            get_latest_release "$DOTFILES_REPO_NEOVIM" "$DOTFILES_NVIM_VERSION"
            ;;
        yazi)
            get_latest_release "$DOTFILES_REPO_YAZI" "$DOTFILES_YAZI_VERSION"
            ;;
        starship)
            get_latest_release "starship/starship" "v1.18.0"
            ;;
        zoxide)
            get_latest_release "ajeetdsouza/zoxide" "v0.9.0"
            ;;
        fzf)
            get_latest_release "$DOTFILES_REPO_FZF" "0.50.0"
            ;;
        doppler)
            get_latest_release "$DOTFILES_REPO_DOPPLER" "$DOTFILES_DOPPLER_VERSION"
            ;;
        gum)
            get_latest_release "charmbracelet/gum" "v0.14.0"
            ;;
        gh)
            get_latest_release "cli/cli" "v2.40.0"
            ;;
        node)
            # Detect install source and check version from same source
            if [ -d "$HOME/.nvm" ]; then
                # nvm: check latest LTS
                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null
                nvm ls-remote --lts 2>/dev/null | tail -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            elif [ -f /usr/bin/node ] && command -v apt-cache >/dev/null 2>&1; then
                # apt/nodesource: check candidate version
                apt-cache policy nodejs 2>/dev/null | grep Candidate | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown"
            elif command -v n >/dev/null 2>&1; then
                # n: check latest lts
                n --lts 2>/dev/null | head -1 || echo "unknown"
            else
                echo "unknown"
            fi
            ;;
        bat)
            get_latest_release "sharkdp/bat" "v0.24.0"
            ;;
        lsd)
            get_latest_release "lsd-rs/lsd" "v1.0.0"
            ;;
        lazygit)
            get_latest_release "jesseduffield/lazygit" "v0.40.0"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Global array for updates available (used by run_interactive_update)
declare -a DOTFILES_UPDATES_AVAILABLE=()

# Run update check and display status
run_update_check() {
    echo "════════════════════════════════════════════════════════════════"
    echo "                    DOTFILES UPDATE CHECK"
    echo "════════════════════════════════════════════════════════════════"
    echo ""

    local tools=("neovim" "yazi" "starship" "zoxide" "fzf" "doppler" "gum" "gh" "node" "bat" "lsd" "lazygit")
    DOTFILES_UPDATES_AVAILABLE=()

    info "Checking for updates..."
    echo ""

    printf "%-15s %-15s %-15s %s\n" "Tool" "Installed" "Latest" "Status"
    printf "%-15s %-15s %-15s %s\n" "────" "─────────" "──────" "──────"

    for tool in "${tools[@]}"; do
        local installed latest status_icon

        if ! is_installed "$tool" && [ "$tool" != "neovim" ]; then
            # Check for nvim vs neovim
            [ "$tool" = "neovim" ] && ! is_installed nvim && continue
            continue
        fi

        # Special case for neovim binary name
        [ "$tool" = "neovim" ] && ! is_installed nvim && continue

        installed=$(get_installed_version "$tool")
        latest=$(get_latest_version "$tool")

        installed_norm=$(normalize_version "$installed")
        latest_norm=$(normalize_version "$latest")

        if [ "$installed_norm" = "$latest_norm" ]; then
            status_icon="${GREEN}✓ up to date${NC}"
        elif version_gte "$installed" "$latest"; then
            status_icon="${GREEN}✓ up to date${NC}"
        else
            status_icon="${YELLOW}⬆ update available${NC}"
            DOTFILES_UPDATES_AVAILABLE+=("$tool")
        fi

        printf "%-15s %-15s %-15s %b\n" "$tool" "$installed_norm" "$latest_norm" "$status_icon"
    done

    # Check npm global packages
    if is_installed npm; then
        echo ""
        echo "NPM Global Packages:"
        printf "%-20s %-15s %-15s %s\n" "Package" "Installed" "Latest" "Status"
        printf "%-20s %-15s %-15s %s\n" "───────" "─────────" "──────" "──────"

        local npm_packages=("@anthropic-ai/claude-code" "@apify/mcpc" "@kilocode/cli" "opencode-ai" "tldr")
        for pkg in "${npm_packages[@]}"; do
            local pkg_installed pkg_latest pkg_status
            pkg_installed=$(npm list -g "$pkg" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)

            if [ -z "$pkg_installed" ]; then
                continue  # Package not installed
            fi

            pkg_latest=$(npm view "$pkg" version 2>/dev/null || echo "unknown")

            if [ "$pkg_installed" = "$pkg_latest" ]; then
                pkg_status="${GREEN}✓ up to date${NC}"
            else
                pkg_status="${YELLOW}⬆ update available${NC}"
                DOTFILES_UPDATES_AVAILABLE+=("npm:$pkg")
            fi

            printf "%-20s %-15s %-15s %b\n" "$pkg" "$pkg_installed" "$pkg_latest" "$pkg_status"
        done
    fi

    echo ""

    if [ ${#DOTFILES_UPDATES_AVAILABLE[@]} -eq 0 ]; then
        success "All tools are up to date!"
        return 0
    else
        # Separate auto-updatable from manual updates
        local auto_update=() manual_update=()
        for item in "${DOTFILES_UPDATES_AVAILABLE[@]}"; do
            case "$item" in
                neovim|yazi|starship|zoxide|fzf|doppler|gum|gh|bat|lsd|npm:*)
                    auto_update+=("$item")
                    ;;
                node|lazygit)
                    manual_update+=("$item")
                    ;;
            esac
        done

        if [ ${#auto_update[@]} -gt 0 ]; then
            echo "Auto-update available: ${auto_update[*]}"
        fi
        if [ ${#manual_update[@]} -gt 0 ]; then
            echo -e "${YELLOW}Manual update: ${manual_update[*]}${NC}"
            # Show instructions for manual updates
            for item in "${manual_update[@]}"; do
                case "$item" in
                    node)
                        if [ -d "$HOME/.nvm" ]; then
                            echo -e "  ${BLUE}→ nvm install --lts && nvm use --lts${NC}"
                        elif command -v n >/dev/null 2>&1; then
                            echo -e "  ${BLUE}→ sudo n lts${NC}"
                        elif command -v fnm >/dev/null 2>&1; then
                            echo -e "  ${BLUE}→ fnm install --lts && fnm use lts${NC}"
                        elif command -v volta >/dev/null 2>&1; then
                            echo -e "  ${BLUE}→ volta install node@lts${NC}"
                        elif [ -f /usr/bin/node ]; then
                            echo -e "  ${BLUE}→ sudo apt update && sudo apt install -y nodejs${NC}"
                        else
                            echo -e "  ${BLUE}→ Check your package manager${NC}"
                        fi
                        ;;
                    lazygit)
                        echo -e "  ${BLUE}→ go install github.com/jesseduffield/lazygit@latest${NC}"
                        ;;
                esac
            done
        fi
        echo ""
        return 1
    fi
}

# Update npm packages
update_npm_packages() {
    local packages=("$@")
    for pkg in "${packages[@]}"; do
        # Remove npm: prefix
        pkg="${pkg#npm:}"
        info "Updating $pkg..."
        npm install -g "$pkg" 2>/dev/null && success "$pkg updated" || warn "$pkg update failed"
    done
}

# Direct update for a single tool (without full install)
update_tool() {
    local tool="$1"
    local script_dir="${DOTFILES_DIR:-$HOME/dotfiles}"

    case "$tool" in
        neovim)
            info "Updating Neovim..."
            local latest arch
            latest=$(get_latest_release "neovim/neovim" "v0.10.0")
            arch="linux64"
            [ "$(uname -m)" = "aarch64" ] && arch="linux-arm64"
            curl -fsSL "https://github.com/neovim/neovim/releases/download/${latest}/nvim-${arch}.tar.gz" -o /tmp/nvim.tar.gz 2>/dev/null
            if [ -f /tmp/nvim.tar.gz ]; then
                mkdir -p ~/.local
                rm -rf ~/.local/nvim-${arch} 2>/dev/null
                tar -C ~/.local -xzf /tmp/nvim.tar.gz 2>/dev/null
                mkdir -p ~/.local/bin
                ln -sf ~/.local/nvim-${arch}/bin/nvim ~/.local/bin/nvim
                rm -f /tmp/nvim.tar.gz
                success "Neovim updated to $latest"
            fi
            ;;
        starship)
            info "Updating Starship..."
            curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh 2>/dev/null
            if [ -f /tmp/starship-install.sh ]; then
                sh /tmp/starship-install.sh -y </dev/null >/dev/null 2>&1
                rm -f /tmp/starship-install.sh
                success "Starship updated"
            else
                warn "Failed to download starship installer"
            fi
            ;;
        zoxide)
            info "Updating Zoxide..."
            curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -o /tmp/zoxide-install.sh 2>/dev/null
            if [ -f /tmp/zoxide-install.sh ]; then
                bash /tmp/zoxide-install.sh </dev/null >/dev/null 2>&1
                rm -f /tmp/zoxide-install.sh
                success "Zoxide updated"
            else
                warn "Failed to download zoxide installer"
            fi
            ;;
        fzf)
            info "Updating fzf..."
            if [ -d "$HOME/.fzf" ]; then
                cd "$HOME/.fzf" && git pull >/dev/null 2>&1 && ./install --all >/dev/null 2>&1
                success "fzf updated"
            fi
            ;;
        doppler)
            info "Updating Doppler..."
            curl -fsSL https://cli.doppler.com/install.sh -o /tmp/doppler-install.sh 2>/dev/null
            if [ -f /tmp/doppler-install.sh ]; then
                sudo sh /tmp/doppler-install.sh </dev/null >/dev/null 2>&1
                rm -f /tmp/doppler-install.sh
                success "Doppler updated"
            else
                warn "Failed to download doppler installer"
            fi
            ;;
        gum)
            info "Updating gum..."
            local latest arch
            latest=$(get_latest_release "charmbracelet/gum" "v0.14.0")
            arch="x86_64"
            [ "$(uname -m)" = "aarch64" ] && arch="arm64"
            curl -fsSL "https://github.com/charmbracelet/gum/releases/download/${latest}/gum_${latest#v}_Linux_${arch}.tar.gz" -o /tmp/gum.tar.gz 2>/dev/null
            if [ -f /tmp/gum.tar.gz ]; then
                tar -xzf /tmp/gum.tar.gz -C /tmp gum 2>/dev/null
                mkdir -p ~/.local/bin
                mv /tmp/gum ~/.local/bin/
                rm -f /tmp/gum.tar.gz
                success "gum updated to $latest"
            fi
            ;;
        gh)
            info "Updating GitHub CLI..."
            local latest arch_deb
            latest=$(get_latest_release "cli/cli" "v2.40.0")
            arch_deb="amd64"
            [ "$(uname -m)" = "aarch64" ] && arch_deb="arm64"
            curl -fsSL "https://github.com/cli/cli/releases/download/${latest}/gh_${latest#v}_linux_${arch_deb}.deb" -o /tmp/gh.deb 2>/dev/null
            if [ -f /tmp/gh.deb ]; then
                sudo dpkg -i /tmp/gh.deb >/dev/null 2>&1 && success "GitHub CLI updated to $latest" || warn "gh update failed"
                rm -f /tmp/gh.deb
            fi
            ;;
        node)
            # Node has too many install methods (nvm, n, apt, snap, brew, fnm, volta...)
            # Safer to show manual instructions
            warn "Node.js requires manual update:"
            if [ -d "$HOME/.nvm" ]; then
                echo "  → nvm install --lts && nvm use --lts"
            elif command -v n >/dev/null 2>&1; then
                echo "  → sudo n lts"
            elif command -v fnm >/dev/null 2>&1; then
                echo "  → fnm install --lts && fnm use lts"
            elif command -v volta >/dev/null 2>&1; then
                echo "  → volta install node@lts"
            elif [ -f /usr/bin/node ]; then
                echo "  → sudo apt update && sudo apt install -y nodejs"
            else
                echo "  → Check your package manager (apt, brew, snap...)"
            fi
            ;;
        lsd)
            info "Updating lsd..."
            local latest arch_deb
            latest=$(get_latest_release "lsd-rs/lsd" "v1.0.0")
            arch_deb="amd64"
            [ "$(uname -m)" = "aarch64" ] && arch_deb="arm64"
            curl -fsSL "https://github.com/lsd-rs/lsd/releases/download/${latest}/lsd_${latest#v}_${arch_deb}.deb" -o /tmp/lsd.deb 2>/dev/null
            if [ -f /tmp/lsd.deb ]; then
                sudo dpkg -i /tmp/lsd.deb >/dev/null 2>&1 && success "lsd updated to $latest" || warn "lsd update failed"
                rm -f /tmp/lsd.deb
            fi
            ;;
        bat)
            info "Updating bat..."
            local latest arch_deb
            latest=$(get_latest_release "sharkdp/bat" "v0.24.0")
            arch_deb="amd64"
            [ "$(uname -m)" = "aarch64" ] && arch_deb="arm64"
            curl -fsSL "https://github.com/sharkdp/bat/releases/download/${latest}/bat_${latest#v}_${arch_deb}.deb" -o /tmp/bat.deb 2>/dev/null
            if [ -f /tmp/bat.deb ]; then
                sudo dpkg -i /tmp/bat.deb >/dev/null 2>&1 && success "bat updated to $latest" || warn "bat update failed"
                rm -f /tmp/bat.deb
            fi
            ;;
        yazi)
            info "Updating Yazi..."
            local latest arch
            latest=$(get_latest_release "sxyazi/yazi" "v0.4.0")
            arch="x86_64"
            [ "$(uname -m)" = "aarch64" ] && arch="aarch64"
            curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${latest}/yazi-${arch}-unknown-linux-gnu.zip" -o /tmp/yazi.zip 2>/dev/null
            if [ -f /tmp/yazi.zip ]; then
                unzip -o /tmp/yazi.zip -d /tmp >/dev/null 2>&1
                mkdir -p ~/.local/bin
                mv /tmp/yazi-${arch}-unknown-linux-gnu/yazi ~/.local/bin/
                rm -rf /tmp/yazi.zip /tmp/yazi-*
                success "Yazi updated to $latest"
            fi
            ;;
        *)
            warn "Unknown tool: $tool"
            ;;
    esac
}

# Run direct updates for selected tools
run_direct_updates() {
    local tools=("$@")

    echo ""
    info "Running updates..."
    echo ""

    for tool in "${tools[@]}"; do
        if [[ "$tool" == npm:* ]]; then
            local pkg="${tool#npm:}"
            info "Updating $pkg..."
            npm install -g "$pkg" </dev/null >/dev/null 2>&1 && success "$pkg updated" || warn "$pkg update failed"
        else
            update_tool "$tool"
        fi
    done

    echo ""
    success "Updates completed!"
    echo ""
    info "Run 're' or 'source ~/.bashrc' to reload your shell"
}

# Interactive update with selection
run_interactive_update() {
    if ! run_update_check; then
        echo ""

        # Separate npm packages from tools (only auto-updatable)
        local all_auto=()
        for item in "${DOTFILES_UPDATES_AVAILABLE[@]}"; do
            if [[ "$item" == npm:* ]] || [[ "$item" =~ ^(neovim|yazi|starship|zoxide|fzf|doppler|gum|gh|bat|lsd)$ ]]; then
                all_auto+=("$item")
            fi
        done

        if [ ${#all_auto[@]} -eq 0 ]; then
            info "No auto-updatable tools available"
            return 0
        fi

        local selected_tools=()

        if use_gum && [ -t 0 ]; then
            # Menu loop (ESC in sub-menu returns here)
            while true; do
                local choice
                choice=$(gum choose --header "How to update?" "✨ Update all" "🔧 Select tools" "❌ Cancel")

                case "$choice" in
                    "✨ Update all")
                        selected_tools=("${all_auto[@]}")
                        break
                        ;;
                    "🔧 Select tools")
                        local tools_to_update
                        tools_to_update=$(gum choose --no-limit --header "Select tools (SPACE=select, ENTER=confirm, ESC=back):" "${all_auto[@]}" 2>/dev/null)
                        local gum_exit=$?

                        # ESC pressed or error = back to main menu
                        if [ $gum_exit -ne 0 ]; then
                            continue
                        fi

                        if [ -n "$tools_to_update" ]; then
                            while IFS= read -r item; do
                                [ -n "$item" ] && selected_tools+=("$item")
                            done <<< "$tools_to_update"
                            break
                        fi
                        # Empty selection = back to main menu
                        ;;
                    *)
                        info "Cancelled"
                        return 0
                        ;;
                esac
            done
        else
            # Non-gum: ask once then update all
            read -r -p "Update all? (y/N): " confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                selected_tools=("${all_auto[@]}")
            fi
        fi

        # Run direct updates if tools were selected
        if [ ${#selected_tools[@]} -gt 0 ]; then
            run_direct_updates "${selected_tools[@]}"
        fi
    fi

    return 0
}

# ============================================================================
# UNINSTALL MODE (--uninstall flag)
# ============================================================================
uninstall_tool() {
    local name="$1"
    local binary_path="$2"
    local config_paths="${3:-}"  # Comma-separated

    info "Uninstalling $name..."

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would remove binary: $binary_path"
        if [ -n "$config_paths" ]; then
            echo -e "${BLUE}[DRY-RUN]${NC} Would remove configs: $config_paths"
        fi
        return 0
    fi

    # Remove binary
    if [ -f "$binary_path" ] || [ -L "$binary_path" ]; then
        rm -f "$binary_path"
        log DEBUG "Removed: $binary_path"
    fi

    # Remove config directories
    if [ -n "$config_paths" ]; then
        IFS=',' read -ra paths <<< "$config_paths"
        for path in "${paths[@]}"; do
            if [ -e "$path" ] || [ -L "$path" ]; then
                rm -rf "$path"
                log DEBUG "Removed: $path"
            fi
        done
    fi

    success "Uninstalled $name"
}

remove_from_bashrc() {
    local pattern="$1"
    local description="$2"

    if is_dry_run; then
        echo -e "${BLUE}[DRY-RUN]${NC} Would remove from ~/.bashrc: $description"
        return 0
    fi

    if grep -q "$pattern" "$HOME/.bashrc" 2>/dev/null; then
        # Create backup
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%s)"
        # Remove matching lines and the comment line before it
        sed -i "/$pattern/d" "$HOME/.bashrc"
        log DEBUG "Removed from ~/.bashrc: $pattern"
    fi
}

run_uninstall() {
    echo "════════════════════════════════════════════════════════════════"
    echo "                    DOTFILES UNINSTALL"
    echo "════════════════════════════════════════════════════════════════"
    echo ""

    warn "This will remove installed tools and configurations."

    if ! is_dry_run && [ -t 0 ]; then
        read -r -p "Are you sure? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Aborted."
            return 1
        fi
    fi

    echo ""

    # Uninstall tools (user-local paths)
    local bin_dir="$HOME/.local/bin"
    local opt_dir="$HOME/.local"

    uninstall_tool "Neovim" "$bin_dir/nvim" "$opt_dir/nvim,$HOME/.config/nvim,$HOME/.local/share/nvim,$HOME/.local/state/nvim"
    uninstall_tool "Starship" "$bin_dir/starship" "$HOME/.config/starship.toml"
    uninstall_tool "Zoxide" "$bin_dir/zoxide" ""
    uninstall_tool "Yazi" "$bin_dir/yazi" "$HOME/.config/yazi"
    uninstall_tool "fzf" "$bin_dir/fzf" "$HOME/.fzf"
    uninstall_tool "Doppler" "$bin_dir/doppler" ""

    # Remove shell integrations
    echo ""
    info "Removing shell integrations..."
    remove_from_bashrc "starship init" "Starship prompt"
    remove_from_bashrc "zoxide init" "Zoxide"
    remove_from_bashrc "shell-integration.sh" "Neovim config switcher"
    remove_from_bashrc "Productivity aliases" "Aliases"
    remove_from_bashrc ".local/bin" "Local bin PATH"
    remove_from_bashrc "npm-global" "npm global PATH"

    echo ""
    success "Uninstall complete. Run 'source ~/.bashrc' to apply changes."
}

# ============================================================================
# PARALLEL EXECUTION
# ============================================================================
# Array to store background job PIDs
declare -a PARALLEL_JOBS=()
declare -a PARALLEL_NAMES=()

parallel_run() {
    local name="$1"
    shift
    local cmd="$*"

    if [ "${DOTFILES_PARALLEL:-false}" = "true" ]; then
        log DEBUG "Starting parallel: $name"
        eval "$cmd" &
        PARALLEL_JOBS+=($!)
        PARALLEL_NAMES+=("$name")
    else
        eval "$cmd"
    fi
}

parallel_wait() {
    if [ "${DOTFILES_PARALLEL:-false}" != "true" ]; then
        return 0
    fi

    if [ ${#PARALLEL_JOBS[@]} -eq 0 ]; then
        return 0
    fi

    info "Waiting for parallel jobs to complete..."

    local failed=0
    for i in "${!PARALLEL_JOBS[@]}"; do
        local pid="${PARALLEL_JOBS[$i]}"
        local name="${PARALLEL_NAMES[$i]}"

        if wait "$pid"; then
            success "$name completed"
        else
            warn "$name failed"
            failed=$((failed + 1))
        fi
    done

    # Reset arrays
    PARALLEL_JOBS=()
    PARALLEL_NAMES=()

    return $failed
}

# ============================================================================
# CHECKSUM VERIFICATION
# ============================================================================
verify_checksum() {
    local file="$1"
    local expected_sha256="$2"

    if [ -z "$expected_sha256" ]; then
        log DEBUG "No checksum provided, skipping verification"
        return 0
    fi

    if ! is_installed sha256sum && ! is_installed shasum; then
        warn "No sha256sum or shasum available, skipping verification"
        return 0
    fi

    local actual_sha256
    if is_installed sha256sum; then
        actual_sha256=$(sha256sum "$file" | cut -d' ' -f1)
    else
        actual_sha256=$(shasum -a 256 "$file" | cut -d' ' -f1)
    fi

    if [ "$actual_sha256" = "$expected_sha256" ]; then
        log DEBUG "Checksum verified: $file"
        return 0
    else
        error "Checksum mismatch for $file"
        error "Expected: $expected_sha256"
        error "Got:      $actual_sha256"
        return 1
    fi
}

# Download with optional checksum verification
download_verified() {
    local url="$1"
    local output="$2"
    local expected_sha256="${3:-}"

    if ! download_file "$url" "$output"; then
        return 1
    fi

    if [ -n "$expected_sha256" ]; then
        if ! verify_checksum "$output" "$expected_sha256"; then
            rm -f "$output"
            return 1
        fi
    fi

    return 0
}

# ============================================================================
# CLI ARGUMENT PARSING
# ============================================================================
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run|-n)
                export DOTFILES_DRY_RUN=true
                info "Dry-run mode enabled"
                ;;
            --update|-u)
                export DOTFILES_UPDATE_MODE=true
                ;;
            --uninstall)
                export DOTFILES_UNINSTALL_MODE=true
                ;;
            --check|-c)
                export DOTFILES_CHECK_MODE=true
                ;;
            --only=*)
                export DOTFILES_ONLY="${1#*=}"
                info "Installing only: $DOTFILES_ONLY"
                ;;
            --only)
                shift
                export DOTFILES_ONLY="$1"
                info "Installing only: $DOTFILES_ONLY"
                ;;
            --parallel|-p)
                export DOTFILES_PARALLEL=true
                info "Parallel mode enabled"
                ;;
            --interactive|-i)
                export DOTFILES_INTERACTIVE=true
                ;;
            --no-gum)
                export DOTFILES_NO_GUM=true
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            --debug)
                export DOTFILES_DEBUG_MODE=true
                export DOTFILES_LOG_LEVEL=DEBUG
                ;;
            *)
                warn "Unknown option: $1"
                ;;
        esac
        shift
    done
}

show_help() {
    cat << 'EOF'
Dotfiles Installation Script

Usage: ./install.sh [OPTIONS]

Options:
  -i, --interactive  Interactive mode with UI menu (uses gum)
  -n, --dry-run      Show what would be done without making changes
  -u, --update       Update installed tools to latest versions
  -c, --check        Run health check on installed components
  --uninstall        Remove installed tools and configurations
  --only=COMPONENTS  Install only specified components (comma-separated)
                     Available: neovim,fzf,nerd-fonts,node,npm-tools,
                                starship,zoxide,yazi,doppler,configs,
                                shell-integration
  -p, --parallel     Run independent installations in parallel
  --no-gum           Disable gum UI (use plain text)
  --debug            Enable debug output
  -h, --help         Show this help message

Examples:
  ./install.sh                      # Full installation
  ./install.sh -i                   # Interactive mode with menu
  ./install.sh --dry-run            # Preview what would be installed
  ./install.sh --check              # Check installation health
  ./install.sh --update             # Update all tools
  ./install.sh --only=neovim,yazi   # Install only Neovim and Yazi
  ./install.sh --uninstall          # Remove everything
  ./install.sh --parallel           # Parallel installation (faster)

Environment Variables:
  SKIP_NEOVIM_INSTALL=true    Skip Neovim
  SKIP_NERD_FONTS=true        Skip Nerd Fonts
  SKIP_NPM_TOOLS=true         Skip npm tools
  SKIP_YAZI_INSTALL=true      Skip Yazi
  SKIP_DOPPLER_INSTALL=true   Skip Doppler
  SKIP_MCP_INSTALL=true       Skip MCP config setup
  USER_LOCAL_MODE=true        Install to ~/.local (no sudo)
EOF
}

# ============================================================================
# GUM INTERACTIVE UI (https://github.com/charmbracelet/gum)
# ============================================================================

# Install gum if not present
install_gum() {
    if is_installed gum; then
        return 0
    fi

    info "Installing gum (interactive UI)..."

    local gum_version="0.14.5"
    local gum_file=""

    case "$OS-$ARCH" in
        linux-x86_64) gum_file="gum_${gum_version}_Linux_x86_64.tar.gz" ;;
        linux-arm64) gum_file="gum_${gum_version}_Linux_arm64.tar.gz" ;;
        macos-x86_64) gum_file="gum_${gum_version}_Darwin_x86_64.tar.gz" ;;
        macos-arm64) gum_file="gum_${gum_version}_Darwin_arm64.tar.gz" ;;
        *)
            warn "Gum not available for $OS-$ARCH"
            return 1
            ;;
    esac

    local url="https://github.com/charmbracelet/gum/releases/download/v${gum_version}/${gum_file}"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if download_and_extract "$url" "$tmp_dir"; then
        mv "$tmp_dir/gum" "$DOTFILES_BIN_DIR/gum" 2>/dev/null
        chmod +x "$DOTFILES_BIN_DIR/gum"
        success "gum installed"
        return 0
    else
        warn "Failed to install gum"
        return 1
    fi

    rm -rf "$tmp_dir"
}

# Check if gum is available and should be used
use_gum() {
    [ "${DOTFILES_NO_GUM:-false}" = "true" ] && return 1
    [ ! -t 0 ] && return 1  # Non-interactive
    is_installed gum
}

# Styled header
gum_header() {
    local title="$1"
    if use_gum; then
        gum style \
            --foreground 212 --border-foreground 99 --border double \
            --align center --width 60 --margin "1 2" --padding "1 2" \
            "$title"
    else
        echo ""
        echo "════════════════════════════════════════════════════════════════"
        echo "  $title"
        echo "════════════════════════════════════════════════════════════════"
        echo ""
    fi
}

# Confirmation dialog
gum_confirm() {
    local prompt="$1"
    local default="${2:-yes}"

    if use_gum; then
        if [ "$default" = "yes" ]; then
            gum confirm --default=true "$prompt"
        else
            gum confirm --default=false "$prompt"
        fi
    else
        local yn
        if [ "$default" = "yes" ]; then
            read -r -p "$prompt [Y/n] " yn
            [ -z "$yn" ] || [ "$yn" = "y" ] || [ "$yn" = "Y" ]
        else
            read -r -p "$prompt [y/N] " yn
            [ "$yn" = "y" ] || [ "$yn" = "Y" ]
        fi
    fi
}

# Text input
gum_input() {
    local prompt="$1"
    local default="${2:-}"
    local placeholder="${3:-}"

    if use_gum; then
        gum input --prompt "$prompt " --value "$default" --placeholder "$placeholder"
    else
        local value
        read -r -p "$prompt [$default] " value
        echo "${value:-$default}"
    fi
}

# Spinner for long operations
gum_spin() {
    local title="$1"
    shift

    if use_gum; then
        gum spin --title "$title" -- "$@"
    else
        echo -n "$title... "
        if "$@" >/dev/null 2>&1; then
            echo "done"
            return 0
        else
            echo "failed"
            return 1
        fi
    fi
}

# Multi-select checkboxes
gum_choose_multi() {
    local header="$1"
    shift
    local options=("$@")

    if use_gum; then
        printf '%s\n' "${options[@]}" | gum choose --no-limit --header "$header"
    else
        # Fallback: show numbered list
        echo "$header"
        echo "(Enter numbers separated by spaces, or 'all' for everything)"
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt"
            ((i++))
        done
        read -r -p "Selection: " selection

        if [ "$selection" = "all" ]; then
            printf '%s\n' "${options[@]}"
        else
            for num in $selection; do
                if [ "$num" -ge 1 ] && [ "$num" -le "${#options[@]}" ]; then
                    echo "${options[$((num-1))]}"
                fi
            done
        fi
    fi
}

# Single select
gum_choose() {
    local header="$1"
    shift
    local options=("$@")

    if use_gum; then
        printf '%s\n' "${options[@]}" | gum choose --header "$header"
    else
        echo "$header"
        local i=1
        for opt in "${options[@]}"; do
            echo "  $i) $opt"
            ((i++))
        done
        read -r -p "Selection [1]: " selection
        selection="${selection:-1}"
        if [ "$selection" -ge 1 ] && [ "$selection" -le "${#options[@]}" ]; then
            echo "${options[$((selection-1))]}"
        else
            echo "${options[0]}"
        fi
    fi
}

# Interactive component selection menu
run_interactive_menu() {
    while true; do
        clear
        gum_header "🚀 Dotfiles Installer"

        # Ask what to do
        local action
        action=$(gum_choose "What would you like to do?" \
            "📦 Install (full)" \
            "🎯 Install (select components)" \
            "🔄 Update installed tools" \
            "🩺 Health check" \
            "🆘 Help" \
            "🗑️  Uninstall" \
            "❌ Exit")

        case "$action" in
            *"Install (full)"*)
                return 0  # Continue with normal install
                ;;
            *"Install (select"*)
                select_components || true
                echo ""
                read -rp "Press Enter to return to menu..."
                ;;
            *"Update"*)
                run_interactive_update
                echo ""
                read -rp "Press Enter to return to menu..."
                ;;
            *"Health check"*)
                run_health_check || true
                echo ""
                read -rp "Press Enter to return to menu..."
                ;;
            *"Help"*)
                run_help_menu
                ;;
            *"Uninstall"*)
                run_uninstall
                echo ""
                read -rp "Press Enter to return to menu..."
                ;;
            *"Exit"*|"")
                echo "Bye!"
                exit 0
                ;;
        esac
    done
}

# Component selection submenu
select_components() {
    local components
    # Pass options as arguments (not via pipe) to preserve TTY
    components=$(gum choose --no-limit --header "Select components to install (SPACE=select, ENTER=confirm):" \
        "neovim      │ Neovim editor" \
        "fzf         │ Fuzzy finder" \
        "nerd-fonts  │ Nerd Fonts (icons)" \
        "node        │ Node.js + npm" \
        "npm-tools   │ CLI tools (copilot, tldr...)" \
        "starship    │ Shell prompt" \
        "zoxide      │ Smart cd" \
        "yazi        │ File manager" \
        "doppler     │ Secrets manager" \
        "gh          │ GitHub CLI" \
        "bat         │ cat with syntax highlighting" \
        "lsd         │ ls with icons" \
        "configs     │ Config symlinks" \
        "shell       │ Shell integration")

    if [ -z "$components" ]; then
        warn "No components selected"
        return 1
    fi

    # Extract component names and install directly
    local selected=()
    while IFS= read -r line; do
        local comp
        # Use awk instead of cut (cut doesn't handle Unicode delimiters)
        comp=$(echo "$line" | awk -F'│' '{print $1}' | xargs)
        [ "$comp" = "shell" ] && comp="shell-integration"
        selected+=("$comp")
    done <<< "$components"

    info "Installing: ${selected[*]}"
    echo ""

    # Install each selected component directly
    for comp in "${selected[@]}"; do
        install_component "$comp"
    done

    echo ""
    success "Installation completed!"
    echo ""
    info "Run 're' or 'source ~/.bashrc' to reload your shell"
}

# Install a single component directly
install_component() {
    local comp="$1"
    local script_dir="${DOTFILES_DIR:-$HOME/dotfiles}"

    case "$comp" in
        neovim)
            info "Installing Neovim..."
            local latest
            latest=$(get_latest_release "neovim/neovim" "v0.10.0")
            local arch="linux64"
            [ "$(uname -m)" = "aarch64" ] && arch="linux-arm64"
            curl -fsSL "https://github.com/neovim/neovim/releases/download/${latest}/nvim-${arch}.tar.gz" -o /tmp/nvim.tar.gz 2>/dev/null
            if [ -f /tmp/nvim.tar.gz ]; then
                mkdir -p ~/.local
                rm -rf ~/.local/nvim-${arch} 2>/dev/null
                tar -C ~/.local -xzf /tmp/nvim.tar.gz 2>/dev/null
                mkdir -p ~/.local/bin
                ln -sf ~/.local/nvim-${arch}/bin/nvim ~/.local/bin/nvim
                rm -f /tmp/nvim.tar.gz
                success "Neovim installed ($latest)"
            else
                warn "Failed to download Neovim"
            fi
            ;;
        starship)
            info "Installing Starship..."
            curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh 2>/dev/null
            if [ -f /tmp/starship-install.sh ]; then
                sh /tmp/starship-install.sh -y </dev/null >/dev/null 2>&1
                rm -f /tmp/starship-install.sh
                success "Starship installed"
            else
                warn "Failed to download Starship"
            fi
            ;;
        zoxide)
            info "Installing Zoxide..."
            curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -o /tmp/zoxide-install.sh 2>/dev/null
            if [ -f /tmp/zoxide-install.sh ]; then
                bash /tmp/zoxide-install.sh </dev/null >/dev/null 2>&1
                rm -f /tmp/zoxide-install.sh
                success "Zoxide installed"
            else
                warn "Failed to download Zoxide"
            fi
            ;;
        yazi)
            info "Installing Yazi..."
            local latest arch
            latest=$(get_latest_release "sxyazi/yazi" "v0.4.0")
            arch="x86_64"
            [ "$(uname -m)" = "aarch64" ] && arch="aarch64"
            curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${latest}/yazi-${arch}-unknown-linux-gnu.zip" -o /tmp/yazi.zip 2>/dev/null
            if [ -f /tmp/yazi.zip ]; then
                unzip -o /tmp/yazi.zip -d /tmp >/dev/null 2>&1
                mkdir -p ~/.local/bin
                mv /tmp/yazi-${arch}-unknown-linux-gnu/yazi ~/.local/bin/ 2>/dev/null
                rm -rf /tmp/yazi.zip /tmp/yazi-*
                success "Yazi installed ($latest)"
            else
                warn "Failed to download Yazi"
            fi
            ;;
        fzf)
            info "Installing fzf..."
            if [ -d "$HOME/.fzf" ]; then
                cd "$HOME/.fzf" && git pull >/dev/null 2>&1
            else
                git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" >/dev/null 2>&1
            fi
            "$HOME/.fzf/install" --all </dev/null >/dev/null 2>&1
            success "fzf installed"
            ;;
        doppler)
            info "Installing Doppler..."
            curl -fsSL https://cli.doppler.com/install.sh -o /tmp/doppler-install.sh 2>/dev/null
            if [ -f /tmp/doppler-install.sh ]; then
                sudo sh /tmp/doppler-install.sh </dev/null >/dev/null 2>&1
                rm -f /tmp/doppler-install.sh
                success "Doppler installed"
            else
                warn "Failed to download Doppler"
            fi
            ;;
        gh)
            info "Installing GitHub CLI..."
            local latest arch_deb
            latest=$(get_latest_release "cli/cli" "v2.40.0")
            arch_deb="amd64"
            [ "$(uname -m)" = "aarch64" ] && arch_deb="arm64"
            curl -fsSL "https://github.com/cli/cli/releases/download/${latest}/gh_${latest#v}_linux_${arch_deb}.deb" -o /tmp/gh.deb 2>/dev/null
            if [ -f /tmp/gh.deb ]; then
                sudo dpkg -i /tmp/gh.deb >/dev/null 2>&1 && success "GitHub CLI installed ($latest)" || warn "gh install failed"
                rm -f /tmp/gh.deb
            fi
            ;;
        bat)
            info "Installing bat..."
            local latest arch_deb
            latest=$(get_latest_release "sharkdp/bat" "v0.24.0")
            arch_deb="amd64"
            [ "$(uname -m)" = "aarch64" ] && arch_deb="arm64"
            curl -fsSL "https://github.com/sharkdp/bat/releases/download/${latest}/bat_${latest#v}_${arch_deb}.deb" -o /tmp/bat.deb 2>/dev/null
            if [ -f /tmp/bat.deb ]; then
                sudo dpkg -i /tmp/bat.deb >/dev/null 2>&1 && success "bat installed ($latest)" || warn "bat install failed"
                rm -f /tmp/bat.deb
            fi
            ;;
        lsd)
            info "Installing lsd..."
            local latest arch_deb
            latest=$(get_latest_release "lsd-rs/lsd" "v1.0.0")
            arch_deb="amd64"
            [ "$(uname -m)" = "aarch64" ] && arch_deb="arm64"
            curl -fsSL "https://github.com/lsd-rs/lsd/releases/download/${latest}/lsd_${latest#v}_${arch_deb}.deb" -o /tmp/lsd.deb 2>/dev/null
            if [ -f /tmp/lsd.deb ]; then
                sudo dpkg -i /tmp/lsd.deb >/dev/null 2>&1 && success "lsd installed ($latest)" || warn "lsd install failed"
                rm -f /tmp/lsd.deb
            fi
            ;;
        node)
            warn "Node.js requires manual installation:"
            echo "  → curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -"
            echo "  → sudo apt install -y nodejs"
            ;;
        npm-tools)
            info "Installing npm tools..."
            if is_installed npm; then
                for pkg in "@anthropic-ai/claude-code" "@apify/mcpc" "tldr"; do
                    npm install -g "$pkg" </dev/null >/dev/null 2>&1 && success "$pkg installed" || warn "$pkg failed"
                done
            else
                warn "npm not found, install Node.js first"
            fi
            ;;
        nerd-fonts)
            info "Installing Nerd Fonts..."
            mkdir -p ~/.local/share/fonts
            local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            curl -fsSL "$font_url" -o /tmp/nerd-font.zip 2>/dev/null
            if [ -f /tmp/nerd-font.zip ]; then
                unzip -o /tmp/nerd-font.zip -d ~/.local/share/fonts >/dev/null 2>&1
                fc-cache -fv >/dev/null 2>&1
                rm -f /tmp/nerd-font.zip
                success "Nerd Fonts installed"
            else
                warn "Failed to download Nerd Fonts"
            fi
            ;;
        configs)
            info "Setting up config symlinks..."
            mkdir -p ~/.config
            ln -sf "$script_dir/nvim" ~/.config/nvim 2>/dev/null && success "nvim config linked"
            ln -sf "$script_dir/yazi" ~/.config/yazi 2>/dev/null && success "yazi config linked"
            ln -sf "$script_dir/starship/starship.toml" ~/.config/starship.toml 2>/dev/null && success "starship config linked"
            ln -sf "$script_dir/.tmux.conf" ~/.tmux.conf 2>/dev/null && success "tmux config linked"
            ;;
        shell-integration)
            info "Setting up shell integration..."
            # Add to bashrc if not present
            local bashrc="$HOME/.bashrc"
            grep -q "starship init" "$bashrc" 2>/dev/null || echo 'eval "$(starship init bash)"' >> "$bashrc"
            grep -q "zoxide init" "$bashrc" 2>/dev/null || echo 'eval "$(zoxide init bash)"' >> "$bashrc"
            success "Shell integration configured"
            ;;
        *)
            warn "Unknown component: $comp"
            ;;
    esac
}

# Progress display for installations
show_progress() {
    local current="$1"
    local total="$2"
    local name="$3"

    if use_gum; then
        local pct=$((current * 100 / total))
        local filled=$((pct / 5))
        local empty=$((20 - filled))
        local bar=""
        for ((i=0; i<filled; i++)); do bar+="█"; done
        for ((i=0; i<empty; i++)); do bar+="░"; done
        echo -e "\r\033[K[$bar] $pct% │ $name"
    else
        echo "[$current/$total] $name"
    fi
}
