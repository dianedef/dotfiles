#!/bin/bash

# Starship-inspired status line for Claude Code
# Based on /root/.config/starship.toml
# Reads JSON from stdin (Claude Code statusLine protocol)

input=$(cat)
output=""

# Environment indicator (codespace/SSH/docker/local)
if [ "$CODESPACES" = "true" ]; then
    env_icon="☁️"
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    env_icon="🌐"
elif [ -f /.dockerenv ]; then
    env_icon="🐳"
else
    env_icon="💻"
fi
output+=$(printf "\033[01;34m%s\033[00m " "$env_icon")

# Codespace name (if in codespace)
if [ -n "$CODESPACE_NAME" ] && [ "$CODESPACES" = "true" ]; then
    if [ -f ~/.codespace_displayname ]; then
        cs_name=$(cat ~/.codespace_displayname)
    else
        cs_name="$CODESPACE_NAME"
    fi
    output+=$(printf "\033[01;36m%s\033[00m " "$cs_name")
fi

# Username@hostname (conditional based on Starship rules)
user=$(whoami)
hostname=$(hostname -s | cut -d'-' -f1)  # Truncate to first part (e.g., "ubuntu")

# Show username if root or in special environment
if [ "$user" = "root" ]; then
    output+=$(printf "\033[01;37m%s\033[00m@" "$user")
elif [ "$CODESPACES" = "true" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    output+=$(printf "\033[01;32m%s\033[00m@" "$user")
fi

# Show hostname if in SSH or codespace
if [ "$CODESPACES" = "true" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    output+=$(printf "\033[02;37m%s\033[00m " "$hostname")
fi

# Directory - use cwd from JSON input (Claude Code provides this), fall back to pwd
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$cwd" ] && cwd=$(pwd)
# cd into the session's cwd so git commands and file checks work correctly
[ -d "$cwd" ] && cd "$cwd" 2>/dev/null

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    repo_name=$(basename "$repo_root")
    relative_path="${cwd#$repo_root}"
    if [ "$relative_path" = "" ]; then
        relative_path="/"
    fi
    # Truncate long paths
    if [ "${#relative_path}" -gt 40 ]; then
        relative_path="…${relative_path: -37}"
    fi
    output+=$(printf "\033[01;36m%s%s\033[00m " "$repo_name" "$relative_path")
else
    # Non-repo path - truncate if too long
    if [ "${#cwd}" -gt 50 ]; then
        cwd="…${cwd: -47}"
    fi
    output+=$(printf "\033[01;36m%s\033[00m " "$cwd")
fi

# Git branch
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        # Truncate long branch names
        if [ "${#branch}" -gt 15 ]; then
            branch="${branch:0:12}…"
        fi
        output+=$(printf "\033[01;35m %s\033[00m " "$branch")
    fi

    # Git status (simplified version without optional locks)
    git_status=$(git -c core.fileMode=false status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
        status_info="["

        # Count status types
        untracked=$(echo "$git_status" | grep -c "^??")
        modified=$(echo "$git_status" | grep -c "^ M")
        staged=$(echo "$git_status" | grep -c "^M")
        deleted=$(echo "$git_status" | grep -c "^ D")

        # Build status string
        [ "$staged" -gt 0 ] && status_info+="🚀${staged} "
        [ "$modified" -gt 0 ] && status_info+="📝${modified} "
        [ "$untracked" -gt 0 ] && status_info+="⚠️${untracked} "
        [ "$deleted" -gt 0 ] && status_info+="🧹${deleted} "

        status_info="${status_info% }]"
        if [ "$status_info" != "[]" ]; then
            output+=$(printf "\033[01;33m%s\033[00m " "$status_info")
        fi
    fi
fi

# Python version (if in project with Python files)
if command -v python3 >/dev/null 2>&1 && { [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/setup.py" ]; }; then
    py_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
    output+=$(printf "\033[33m🐍 %s\033[00m " "$py_version")
fi

# Node.js version (if in project with package.json)
if command -v node >/dev/null 2>&1 && [ -f "$cwd/package.json" ]; then
    node_version=$(node --version | sed 's/v//')
    output+=$(printf "\033[32m⬢ %s\033[00m " "$node_version")
fi

# Print the status line (remove trailing space)
printf "%s" "${output% }"
