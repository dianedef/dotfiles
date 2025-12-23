# Neovim Configuration Switcher Aliases
# Source this file in your ~/.bashrc or ~/.zshrc
# Example: source $(dirname "${BASH_SOURCE[0]}")/aliases.sh

# Get the directory of this script dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main switcher alias
alias nvim-switch="$SCRIPT_DIR/switch-config.sh"
alias nv-switch="$SCRIPT_DIR/switch-config.sh"

# Quick access to different configs using NVIM_APPNAME
alias nv="nvim"
alias nv3="NVIM_APPNAME=nvim3 nvim"
alias nv6="NVIM_APPNAME=nvim6 nvim"
alias nv11="NVIM_APPNAME=nvim11 nvim"
alias nv22="NVIM_APPNAME=nvim22 nvim"

# Alternative names for those who prefer full names
alias nvim3="NVIM_APPNAME=nvim3 nvim"
alias nvim6="NVIM_APPNAME=nvim6 nvim"
alias nvim11="NVIM_APPNAME=nvim11 nvim"
alias nvim22="NVIM_APPNAME=nvim22 nvim"

# Useful shortcuts
alias nv-list="nvim-switch --list"
alias nv-current="nvim-switch --current"

# Silent load - no messages

# pnpm cache clearing alias
alias pnpm-clear="pnpm store prune"
