# Codespace Management Aliases
# Add these aliases to your ~/.bashrc or shell configuration file

# Rename current codespace - usage: csrename "new-name"
# Also caches the display name for starship prompt
csrename() {
    if [ -z "$1" ]; then
        echo "Usage: csrename \"new-name\""
        return 1
    fi
    gh codespace edit -c "$CODESPACE_NAME" -d "$1" && \
    echo "$1" > ~/.codespace_displayname && \
    echo "Renamed to: $1 (cached for prompt)"
}

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
csrenamehere() {
    csrename "$(basename "$(pwd)")"
}

# Enhanced codespace creation for any repository
alias cscreate-repo='gh codespace create -r'
alias cscreate-branch='gh codespace create -r'
alias cscreate-machine='gh codespace create -r -m'

# Interactive repo creation via URL
alias csurl='echo "https://codespaces.new/" && read -p "Repo URL (format: OWNER/REPO): " repo && echo "Opening: https://codespaces.new/$repo"'

# Get the directory of this script dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fuzzy documentation access (with absolute paths and bat fallback)
if command -v bat &> /dev/null; then
    alias cheat='bat $SCRIPT_DIR/docs/reference/COMPREHENSIVE-CHEATSHEET.md'
    alias cheat-nvim='bat $SCRIPT_DIR/nvim/cheat-sheet.sh'
    DOCS_PREVIEW="bat --color=always"
else
    alias cheat='cat $SCRIPT_DIR/docs/reference/COMPREHENSIVE-CHEATSHEET.md'
    alias cheat-nvim='cat $SCRIPT_DIR/nvim/cheat-sheet.sh'
    DOCS_PREVIEW="cat"
fi

alias docs="fzf --preview=\"$DOCS_PREVIEW $SCRIPT_DIR/docs/{}\" < <(find $SCRIPT_DIR/docs -name \"*.md\" | sort)"
alias dotfind="find $SCRIPT_DIR -name \"*.md\" | fzf --preview=\"$DOCS_PREVIEW {}\""
alias cheats='cat $SCRIPT_DIR/codespace-aliases.sh | grep "^alias" | fzf --preview="echo {} | cut -d= -f2-"'

# Tool-specific cheats
alias cheat-git='cat $SCRIPT_DIR/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 50 "## 🔧 6. Development Workflow"'
alias cheat-codespace='cat $SCRIPT_DIR/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 30 "## 🔄 1. Codespaces"'

# Quick access to specific sections
alias cheat-keys='cat $SCRIPT_DIR/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 100 "## ⌨️ 5. Tool-Specific Hotkeys"'
alias cheat-bmad='cat $SCRIPT_DIR/docs/reference/COMPREHENSIVE-CHEATSHEET.md | rg -A 20 "## 🎯 7. BMAD Agents Workflow"'

# Starship configuration management
if [ -f "$SCRIPT_DIR/starship/starship-switch.sh" ]; then
    alias starship='$SCRIPT_DIR/starship/starship-switch.sh'
    alias ss='$SCRIPT_DIR/starship/starship-switch.sh'
    alias starship-status='starship status'
    alias starship-local='starship local'
    alias starship-smart='starship smart'
    alias starship-codespace='starship codespace'
    alias starship-reload='starship auto && source ~/.bashrc'
fi