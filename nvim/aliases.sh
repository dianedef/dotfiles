# Neovim Configuration Switcher Aliases
# Source this file in your ~/.bashrc or ~/.zshrc
# Example: source /workspaces/dotfiles/nvim/aliases.sh

# Main switcher alias
alias nvim-switch="/workspaces/dotfiles/nvim/switch-config.sh"
alias nv-switch="/workspaces/dotfiles/nvim/switch-config.sh"

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

echo "✓ Neovim config switcher aliases loaded"
echo "  Usage: nv11, nv22, etc. or 'nvim-switch --list' to see all configs"
