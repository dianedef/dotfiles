#!/usr/bin/env bash

# Example shell configuration snippet for Neovim config switcher
# Add this to your ~/.bashrc, ~/.zshrc, or equivalent

# ============================================
# Neovim Configuration Switcher
# ============================================

# Method 1: Source the aliases file (recommended)
# Get the directory of this script to find aliases.sh
DOTFILES_NVIM_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${DOTFILES_NVIM_SCRIPT_DIR}/aliases.sh" ]; then
    source "${DOTFILES_NVIM_SCRIPT_DIR}/aliases.sh"
fi

# Method 2: Manual aliases (if you prefer to customize)
# Uncomment the following lines if you don't want to source aliases.sh

# alias nvim-switch="$DOTFILES_NVIM_SCRIPT_DIR/switch-config.sh"
# alias nv11="NVIM_APPNAME=nvim11 nvim"
# alias nv22="NVIM_APPNAME=nvim22 nvim"

# Method 3: Set a default NVIM_APPNAME (optional)
# Uncomment to always use a specific config by default
# export NVIM_APPNAME=nvim11

# ============================================
# Additional Neovim helpers
# ============================================

# Function to quickly switch and launch Neovim with fzf
nvims() {
    # Get the directory of this script to find nvim configs dynamically
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local nvim_dir="$script_dir"
    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    
    # If running from aliases.sh, determine script_dir differently
    if [[ -z "$script_dir" || "$script_dir" == "." ]]; then
        # Try to find the nvim directory relative to common locations
        if [[ -f "${BASH_SOURCE[1]}" ]]; then
            script_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"
        elif [[ -d "/root/.dotfiles/nvim" ]]; then
            script_dir="/root/.dotfiles/nvim"
        elif [[ -d "$HOME/.dotfiles/nvim" ]]; then
            script_dir="$HOME/.dotfiles/nvim"
        else
            echo "Error: Cannot determine nvim config directory"
            return 1
        fi
    fi
    
    # Use the parent directory if we're in a subdirectory of nvim
    if [[ -f "$script_dir/shell-integration.sh" ]]; then
        nvim_dir="$script_dir"
    elif [[ -f "$script_dir/../nvim/shell-integration.sh" ]]; then
        nvim_dir="$(cd "$script_dir/../nvim" && pwd)"
    fi
    local items=()
    
    # Check if nvim directory exists
    if [[ ! -d "${nvim_dir}" ]]; then
        echo "Error: Neovim config directory not found: ${nvim_dir}"
        return 1
    fi
    
    # Auto-detect configurations
    # Add default nvim if it has init file
    if [[ -f "${nvim_dir}/init.lua" ]] || [[ -f "${nvim_dir}/init.vim" ]]; then
        items+=("nvim")
    fi
    
    # Find all subdirectories with init.lua or init.vim
    while IFS= read -r -d '' dir; do
        local name=$(basename "$dir")
        # Skip hidden directories and common non-config directories
        if [[ ! "$name" =~ ^\. ]] && [[ "$name" != "lua" ]] && [[ "$name" != "plugin" ]] && [[ "$name" != "queries" ]] && [[ "$name" != "scripts" ]] && [[ "$name" != "tests" ]] && [[ "$name" != "doc" ]]; then
            if [[ -f "${dir}/init.lua" ]] || [[ -f "${dir}/init.vim" ]]; then
                items+=("$name")
                # Auto-create symlink if it doesn't exist (for NVIM_APPNAME to work)
                if [[ ! -e "${config_home}/${name}" ]]; then
                    ln -s "${dir}" "${config_home}/${name}" 2>/dev/null
                fi
            fi
        fi
    done < <(find "${nvim_dir}" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
    
    # Utiliser fzf pour choisir avec des couleurs rose/violet/orange
    local config=$(printf "%s\n" "${items[@]}" | fzf \
        --prompt="󰈸  Neovim Config  " \
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --border-label="󰅂 Select Config " \
        --color='fg:#e0aaff,bg:#0d0221,hl:#ff6d00' \
        --color='fg+:#ffd60a,bg+:#240046,hl+:#ff006e' \
        --color='info:#ff6d00,prompt:#ff006e,pointer:#c77dff' \
        --color='marker:#ff006e,spinner:#ffd60a,header:#c77dff' \
        --color='border:#7209b7,label:#ffd60a' \
        --exit-0)
    
    # Si rien n'est sélectionné, ne rien faire
    if [[ -z $config ]]; then
        echo "Nothing selected"
        return 0
    fi
    
    # Si "nvim" est sélectionné (config par défaut), ne pas utiliser NVIM_APPNAME
    if [[ $config == "nvim" ]]; then
        config=""
    fi
    
    # Lancer Neovim avec la config choisie
    NVIM_APPNAME=$config nvim "$@"
}

# Function to try a config without switching permanently
nvim-try() {
    local config=${1:-nvim}
    echo "Launching Neovim with config: $config"
    NVIM_APPNAME="$config" nvim "${@:2}"
}

# Completion function for nvims (bash)
if [ -n "$BASH_VERSION" ]; then
    _nvims_complete() {
        local configs="nvim nvim3 nvim6 nvim11 nvim22"
        COMPREPLY=($(compgen -W "$configs" -- "${COMP_WORDS[1]}"))
    }
    complete -F _nvims_complete nvims
    complete -F _nvims_complete nvim-try
fi
