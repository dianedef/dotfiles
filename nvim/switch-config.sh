#!/usr/bin/env bash

# Neovim Config Switcher
# This script allows you to easily switch between multiple Neovim configurations
# using the NVIM_APPNAME environment variable

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="/workspaces/dotfiles"
NVIM_DIR="${DOTFILES_DIR}/nvim"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# Available configurations (relative to dotfiles/nvim)
CONFIGS=(
    "nvim:Default configuration (current)"
    "nvim3:Alternative config 3"
    "nvim6:Alternative config 6"
    "nvim11:Alternative config 11"
    "nvim22:Alternative config 22"
)

# Function to display usage
usage() {
    cat << EOF
${BLUE}Neovim Configuration Switcher${NC}

Usage: $0 [OPTIONS] [CONFIG_NAME]

Options:
    -l, --list              List all available configurations
    -s, --set CONFIG        Set a specific configuration
    -c, --current           Show current configuration
    -h, --help              Show this help message

Config Names:
    nvim                    Default configuration
    nvim3                   Alternative config 3
    nvim6                   Alternative config 6
    nvim11                  Alternative config 11
    nvim22                  Alternative config 22

Examples:
    $0 --list               # List all configs
    $0 --set nvim11         # Switch to nvim11 config
    $0 nvim22               # Switch to nvim22 config (shorthand)
    
Environment:
    The script works by symlinking the selected config to ~/.config/nvim
    You can also use NVIM_APPNAME environment variable:
    
    export NVIM_APPNAME=nvim11
    nvim

EOF
}

# Function to list available configurations
list_configs() {
    echo -e "${BLUE}Available Neovim Configurations:${NC}\n"
    
    local current_config
    current_config=$(get_current_config)
    
    for config in "${CONFIGS[@]}"; do
        IFS=':' read -r name desc <<< "$config"
        
        if [[ -d "${NVIM_DIR}/${name}" ]] || [[ "$name" == "nvim" && -d "${NVIM_DIR}" ]]; then
            if [[ "$name" == "$current_config" ]]; then
                echo -e "  ${GREEN}* $name${NC} - $desc ${YELLOW}(active)${NC}"
            else
                echo -e "    $name - $desc"
            fi
        else
            echo -e "    ${RED}$name${NC} - $desc ${RED}(not found)${NC}"
        fi
    done
    echo ""
}

# Function to get current configuration
get_current_config() {
    if [[ -L "${CONFIG_HOME}/nvim" ]]; then
        local target
        target=$(readlink -f "${CONFIG_HOME}/nvim")
        basename "$target"
    elif [[ -d "${CONFIG_HOME}/nvim" && ! -L "${CONFIG_HOME}/nvim" ]]; then
        echo "nvim"
    else
        echo "none"
    fi
}

# Function to show current configuration
show_current() {
    local current
    current=$(get_current_config)
    
    if [[ "$current" == "none" ]]; then
        echo -e "${YELLOW}No Neovim configuration is currently active${NC}"
    else
        echo -e "${GREEN}Current configuration:${NC} $current"
        
        if [[ -L "${CONFIG_HOME}/nvim" ]]; then
            local target
            target=$(readlink -f "${CONFIG_HOME}/nvim")
            echo -e "${BLUE}Symlink target:${NC} $target"
        fi
    fi
}

# Function to switch configuration
switch_config() {
    local config_name=$1
    local source_dir
    
    # Determine source directory
    if [[ "$config_name" == "nvim" ]]; then
        source_dir="${NVIM_DIR}"
    else
        source_dir="${NVIM_DIR}/${config_name}"
    fi
    
    # Check if configuration exists
    if [[ ! -d "$source_dir" ]]; then
        echo -e "${RED}Error: Configuration '$config_name' not found at $source_dir${NC}"
        exit 1
    fi
    
    # Check if it has an init.lua or init.vim
    if [[ ! -f "${source_dir}/init.lua" && ! -f "${source_dir}/init.vim" ]]; then
        echo -e "${YELLOW}Warning: No init.lua or init.vim found in $config_name${NC}"
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
    
    local target="${CONFIG_HOME}/nvim"
    
    # Backup existing config if it's not a symlink
    if [[ -e "$target" && ! -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backing up existing config to: $backup${NC}"
        mv "$target" "$backup"
    elif [[ -L "$target" ]]; then
        echo -e "${BLUE}Removing existing symlink${NC}"
        rm "$target"
    fi
    
    # Create symlink
    echo -e "${BLUE}Creating symlink: $target -> $source_dir${NC}"
    ln -s "$source_dir" "$target"
    
    echo -e "${GREEN}✓ Successfully switched to '$config_name'${NC}"
    echo -e "${BLUE}You can now launch Neovim with your new configuration${NC}"
}

# Main script logic
main() {
    # If no arguments, show usage
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi
    
    # Parse arguments
    case "$1" in
        -l|--list)
            list_configs
            ;;
        -c|--current)
            show_current
            ;;
        -s|--set)
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}Error: --set requires a configuration name${NC}"
                usage
                exit 1
            fi
            switch_config "$2"
            ;;
        -h|--help)
            usage
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            exit 1
            ;;
        *)
            # Assume it's a config name
            switch_config "$1"
            ;;
    esac
}

main "$@"
