#!/usr/bin/env bash

# Example shell configuration snippet for Neovim config switcher
# Add this to your ~/.bashrc, ~/.zshrc, or equivalent

# ============================================
# Neovim Configuration Switcher
# ============================================

# Method 1: Source the aliases file (recommended)
if [ -f "/workspaces/dotfiles/nvim/aliases.sh" ]; then
    source "/workspaces/dotfiles/nvim/aliases.sh"
fi

# Method 2: Manual aliases (if you prefer to customize)
# Uncomment the following lines if you don't want to source aliases.sh

# alias nvim-switch="/workspaces/dotfiles/nvim/switch-config.sh"
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
    # Liste des configurations disponibles
    local items=("nvim" "nvim3" "nvim6" "nvim11" "nvim22")
    
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
