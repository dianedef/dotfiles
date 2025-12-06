#!/usr/bin/env bash

# Neovim Config Switcher - Installation snippet
# Add this to your main install.sh or run standalone

# Source logging if available
if [ -f "./logs/logging.sh" ]; then
    source ./logs/logging.sh
else
    log() { echo "[$1] $2"; }
fi

install_nvim_switcher() {
    log "INFO" "Installing Neovim Config Switcher..."
    
    local NVIM_DIR="/workspaces/dotfiles/nvim"
    local SHELL_CONFIG=""
    
    # Detect shell config file
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    
    # Make scripts executable
    if [ -f "${NVIM_DIR}/switch-config.sh" ]; then
        chmod +x "${NVIM_DIR}/switch-config.sh"
        log "INFO" "Made switch-config.sh executable"
    fi
    
    if [ -f "${NVIM_DIR}/nvim-multi" ]; then
        chmod +x "${NVIM_DIR}/nvim-multi"
        log "INFO" "Made nvim-multi executable"
    fi
    
    # Add to shell config if not already present
    if [ -n "$SHELL_CONFIG" ]; then
        local INTEGRATION_LINE="source ${NVIM_DIR}/shell-integration.sh"
        
        if ! grep -q "shell-integration.sh" "$SHELL_CONFIG"; then
            echo "" >> "$SHELL_CONFIG"
            echo "# Neovim Config Switcher" >> "$SHELL_CONFIG"
            echo "$INTEGRATION_LINE" >> "$SHELL_CONFIG"
            log "INFO" "Added Neovim Config Switcher to $SHELL_CONFIG"
        else
            log "INFO" "Neovim Config Switcher already in $SHELL_CONFIG"
        fi
    fi
    
    # Show quick info
    log "INFO" "✓ Neovim Config Switcher installed!"
    log "INFO" "  Run: ${NVIM_DIR}/switch-config.sh --list"
    log "INFO" "  Or reload shell: source $SHELL_CONFIG"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" -eq "${0}" ]; then
    install_nvim_switcher
fi
