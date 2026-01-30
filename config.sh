#!/bin/bash
# ============================================================================
# Dotfiles Configuration - Centralized settings
# ============================================================================
# This file contains all configurable values for the dotfiles installer.
# Values can be overridden via environment variables or .env file.

# ============================================================================
# DIRECTORY CONFIGURATION
# ============================================================================
export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export DOTFILES_BIN_DIR="${DOTFILES_BIN_DIR:-$HOME/.local/bin}"
export DOTFILES_CONFIG_DIR="${DOTFILES_CONFIG_DIR:-$HOME/.config}"
export DOTFILES_NPM_DIR="${DOTFILES_NPM_DIR:-$HOME/.npm-global}"
export DOTFILES_FONTS_DIR="${DOTFILES_FONTS_DIR:-$HOME/.local/share/fonts}"
export DOTFILES_BACKUP_DIR="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"

# ============================================================================
# LOGGING CONFIGURATION
# ============================================================================
export DOTFILES_LOG_FILE="${DOTFILES_LOG_FILE:-$DOTFILES_DIR/install.log}"
export DOTFILES_LOG_LEVEL="${DOTFILES_LOG_LEVEL:-INFO}"
export DOTFILES_LOG_ROTATION_SIZE="${DOTFILES_LOG_ROTATION_SIZE:-10485760}"  # 10MB
export DOTFILES_LOG_RETENTION_DAYS="${DOTFILES_LOG_RETENTION_DAYS:-30}"
export DOTFILES_DEBUG_MODE="${DOTFILES_DEBUG_MODE:-false}"

# ============================================================================
# TOOL VERSIONS (fallbacks if GitHub API fails)
# ============================================================================
export DOTFILES_NVIM_VERSION="${DOTFILES_NVIM_VERSION:-v0.10.2}"
export DOTFILES_NVM_VERSION="${DOTFILES_NVM_VERSION:-v0.39.7}"
export DOTFILES_YAZI_VERSION="${DOTFILES_YAZI_VERSION:-v0.4.2}"
export DOTFILES_NERD_FONTS_VERSION="${DOTFILES_NERD_FONTS_VERSION:-v3.2.1}"
export DOTFILES_DOPPLER_VERSION="${DOTFILES_DOPPLER_VERSION:-3.69.0}"

# ============================================================================
# GITHUB REPOSITORIES
# ============================================================================
export DOTFILES_REPO_NEOVIM="neovim/neovim"
export DOTFILES_REPO_YAZI="sxyazi/yazi"
export DOTFILES_REPO_DOPPLER="DopplerHQ/cli"
export DOTFILES_REPO_FZF="junegunn/fzf"
export DOTFILES_REPO_LAZYVIM="LazyVim/starter"

# ============================================================================
# FEATURE FLAGS
# ============================================================================
export SKIP_NEOVIM_INSTALL="${SKIP_NEOVIM_INSTALL:-false}"
export SKIP_NERD_FONTS="${SKIP_NERD_FONTS:-false}"
export SKIP_NPM_TOOLS="${SKIP_NPM_TOOLS:-false}"
export SKIP_YAZI_INSTALL="${SKIP_YAZI_INSTALL:-false}"
export SKIP_DOPPLER_INSTALL="${SKIP_DOPPLER_INSTALL:-false}"
export AUTO_INSTALL_NVIM_PLUGINS="${AUTO_INSTALL_NVIM_PLUGINS:-false}"
export USER_LOCAL_MODE="${USER_LOCAL_MODE:-false}"

# ============================================================================
# PACKAGE LISTS
# ============================================================================
export DOTFILES_APT_PACKAGES="git curl wget unzip tar build-essential"
export DOTFILES_NPM_PACKAGES="@anthropic-ai/claude-code"

# ============================================================================
# CACHE CONFIGURATION
# ============================================================================
export DOTFILES_CACHE_ENABLED="${DOTFILES_CACHE_ENABLED:-true}"
export DOTFILES_CACHE_TTL="${DOTFILES_CACHE_TTL:-300}"  # 5 minutes

# ============================================================================
# VALIDATION PATTERNS
# ============================================================================
export DOTFILES_SAFE_PATH_REGEX='^(/home/|/root/|/opt/)'
export DOTFILES_DANGEROUS_CHARS_REGEX='[;&|$`]'
