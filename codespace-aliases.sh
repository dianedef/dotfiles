# Codespace Management Aliases
# Add these aliases to your ~/.bashrc or shell configuration file

# Rename current codespace - usage: csrename "new-name"
alias csrename='gh codespace edit -c $CODESPACE_NAME -d'

# Stop current codespace - usage: csstop
alias csstop='gh codespace stop -c $CODESPACE_NAME'

# SSH into any codespace (interactive selector) - usage: cs
alias cs='gh cs ssh'

# List all codespaces - usage: cslist
alias cslist='gh codespace list'

# View current codespace details - usage: csinfo
alias csinfo='gh codespace view -c $CODESPACE_NAME'

# SSH into current codespace (from local) - usage: cssh
alias cssh='gh codespace ssh -c $CODESPACE_NAME'

# Create new codespace for current repo - usage: cscreate
alias cscreate='gh codespace create'

# Delete current codespace - usage: csdelete
alias csdelete='gh codespace delete -c $CODESPACE_NAME'

# Quick rename with current directory name as suggestion
alias csrenamehere='csrename "$(basename $(pwd))"'

# Enhanced codespace creation for any repository
alias cscreate-repo='gh codespace create -r'
alias cscreate-branch='gh codespace create -r'
alias cscreate-machine='gh codespace create -r -m'

# Interactive repo creation via URL
alias csurl='echo "https://codespaces.new/" && read -p "Repo URL (format: OWNER/REPO): " repo && echo "Opening: https://codespaces.new/$repo"'

# Fuzzy documentation access (with absolute paths and bat fallback)
if command -v bat &> /dev/null; then
    alias cheat='bat /workspaces/dotfiles/docs/reference/COMPREHENSIVE-CHEATSHEET.md'
    alias cheat-nvim='bat /workspaces/dotfiles/nvim/cheat-sheet.sh'
    DOCS_PREVIEW="bat --color=always"
else
    alias cheat='cat /workspaces/dotfiles/docs/reference/COMPREHENSIVE-CHEATSHEET.md'
    alias cheat-nvim='cat /workspaces/dotfiles/nvim/cheat-sheet.sh'
    DOCS_PREVIEW="cat"
fi

alias docs="fzf --preview=\"$DOCS_PREVIEW /workspaces/dotfiles/docs/{}\" < <(find /workspaces/dotfiles/docs -name \"*.md\" | sort)"
alias dotfind="find /workspaces/dotfiles -name \"*.md\" | fzf --preview=\"$DOCS_PREVIEW {}\""
alias cheats='cat /workspaces/dotfiles/codespace-aliases.sh | grep "^alias" | fzf --preview="echo {} | cut -d= -f2-"'

# Tool-specific cheats
alias cheat-git='cat /workspaces/dotfiles/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 50 "## 🔧 6. Development Workflow"'
alias cheat-codespace='cat /workspaces/dotfiles/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 30 "## 🔄 1. Codespaces"'

# Quick access to specific sections
alias cheat-keys='cat ~/dotfiles/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 100 "## ⌨️ 5. Tool-Specific Hotkeys"'
alias cheat-bmad='cat ~/dotfiles/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 20 "## 🎯 7. BMAD Agents Workflow"'

# Starship configuration management
if [ -f "/workspaces/dotfiles/starship/starship-switch.sh" ]; then
    alias starship='/workspaces/dotfiles/starship/starship-switch.sh'
    alias ss='/workspaces/dotfiles/starship/starship-switch.sh'
    alias starship-status='starship status'
    alias starship-local='starship local'
    alias starship-smart='starship smart'
    alias starship-codespace='starship codespace'
    alias starship-reload='starship auto && source ~/.bashrc'
fi