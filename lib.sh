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
