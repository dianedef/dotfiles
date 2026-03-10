#!/bin/bash

# Starship-inspired status line for Claude Code
# Reads JSON from stdin (Claude Code statusLine protocol)

input=$(cat)

# ── HELPERS ───────────────────────────────────────────────────────────────────

# Terminal width via Python (most reliable: tries stdout, stdin, stderr, /dev/tty)
TERM_WIDTH=$(python3 -c "import shutil; w=shutil.get_terminal_size((0,0)).columns; print(w if w>0 else 120)" 2>/dev/null)
[[ ! "$TERM_WIDTH" =~ ^[0-9]+$ ]] && TERM_WIDTH=120

# Strip ANSI escape codes and return visible character count
visible_width() {
    local stripped
    stripped=$(printf "%s" "$1" | sed $'s/\033\[[^m]*m//g')
    printf "%d" "${#stripped}"
}

# Distribute non-empty parts evenly across terminal width (space-between)
space_between() {
    local -a parts=()
    local p
    for p in "$@"; do [ -n "$p" ] && parts+=("$p"); done
    local n=${#parts[@]}
    [ "$n" -eq 0 ] && return
    [ "$n" -eq 1 ] && printf "%s" "${parts[0]}" && return

    local total_vis=0 w
    for p in "${parts[@]}"; do
        w=$(visible_width "$p")
        total_vis=$(( total_vis + w ))
    done

    local space=$(( (${TERM_WIDTH:-120} - total_vis) / (n - 1) ))
    [ "$space" -lt 3 ]  && space=3
    [ "$space" -gt 60 ] && space=60
    local pad
    pad=$(printf "%${space}s" "")

    local result="" i
    for ((i=0; i<n; i++)); do
        result+="${parts[$i]}"
        [ "$i" -lt $((n-1)) ] && result+="$pad"
    done
    printf "%s" "$result"
}

# ── LINE 1 SEGMENTS ───────────────────────────────────────────────────────────

# Environment icon + codespace + user@hostname
if [ "$CODESPACES" = "true" ]; then
    env_icon="☁️"
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    env_icon="🌐"
elif [ -f /.dockerenv ]; then
    env_icon="🐳"
else
    env_icon="💻"
fi
seg1_loc=$(printf "\033[01;34m%s\033[00m" "$env_icon")

if [ -n "$CODESPACE_NAME" ] && [ "$CODESPACES" = "true" ]; then
    cs_name="${CODESPACE_NAME}"
    [ -f ~/.codespace_displayname ] && cs_name=$(cat ~/.codespace_displayname)
    seg1_loc+=$(printf " \033[01;36m%s\033[00m" "$cs_name")
fi

user=$(whoami)
hostname=$(hostname -s | cut -d'-' -f1)
if [ "$user" = "root" ]; then
    seg1_loc+=$(printf " \033[01;37m%s\033[00m@" "$user")
elif [ "$CODESPACES" = "true" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    seg1_loc+=$(printf " \033[01;32m%s\033[00m@" "$user")
fi
if [ "$CODESPACES" = "true" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    seg1_loc+=$(printf "\033[02;37m%s\033[00m" "$hostname")
fi

# Directory
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$cwd" ] && cwd=$(pwd)
[ -d "$cwd" ] && cd "$cwd" 2>/dev/null

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    repo_name=$(basename "$repo_root")
    relative_path="${cwd#$repo_root}"
    [ "$relative_path" = "" ] && relative_path="/"
    [ "${#relative_path}" -gt 40 ] && relative_path="…${relative_path: -37}"
    seg1_dir=$(printf "\033[01;36m%s%s\033[00m" "$repo_name" "$relative_path")
else
    [ "${#cwd}" -gt 50 ] && cwd="…${cwd: -47}"
    seg1_dir=$(printf "\033[01;36m%s\033[00m" "$cwd")
fi

# Git branch + status
seg1_git=""
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        [ "${#branch}" -gt 15 ] && branch="${branch:0:12}…"
        seg1_git=$(printf "\033[01;35m %s\033[00m" "$branch")
    fi

    git_status=$(git -c core.fileMode=false status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
        status_info="["
        untracked=$(echo "$git_status" | grep -c "^??")
        modified=$(echo "$git_status" | grep -c "^ M")
        staged=$(echo "$git_status" | grep -c "^M")
        deleted=$(echo "$git_status" | grep -c "^ D")
        [ "$staged" -gt 0 ]    && status_info+="🚀${staged} "
        [ "$modified" -gt 0 ]  && status_info+="📝${modified} "
        [ "$untracked" -gt 0 ] && status_info+="⚠️${untracked} "
        [ "$deleted" -gt 0 ]   && status_info+="🧹${deleted} "
        status_info="${status_info% }]"
        [ "$status_info" != "[]" ] && seg1_git+=$(printf " \033[01;33m%s\033[00m" "$status_info")
    fi
fi

# Runtime hints
seg1_runtime=""
if command -v python3 >/dev/null 2>&1 && { [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/setup.py" ]; }; then
    py_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
    seg1_runtime+=$(printf "\033[33m🐍 %s\033[00m" "$py_version")
fi
if command -v node >/dev/null 2>&1 && [ -f "$cwd/package.json" ]; then
    node_version=$(node --version | sed 's/v//')
    seg1_runtime+=$(printf "\033[32m⬢ %s\033[00m" "$node_version")
fi

# ── LINE 2 SEGMENTS ───────────────────────────────────────────────────────────

# Model
seg2_model=""
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)
[ -n "$model" ] && seg2_model=$(printf "\033[01;36m%s\033[00m" "$model")

# Context window
seg2_context=""
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
    used_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "$used_pct")
    remaining_int=$((100 - used_int))
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))

    if [ "$used_int" -lt 50 ]; then
        ctx_color="\033[01;32m"
    elif [ "$used_int" -lt 80 ]; then
        ctx_color="\033[01;33m"
    else
        ctx_color="\033[01;31m"
    fi

    spent_bar=""
    remaining_bar=""
    for ((i=0; i<filled; i++)); do spent_bar+="░"; done
    for ((i=0; i<empty; i++));  do remaining_bar+="█"; done

    seg2_context=$(printf "${ctx_color}%s\033[02;37m%s\033[00m ${ctx_color}%d%% context left\033[00m" "$remaining_bar" "$spent_bar" "$remaining_int")
fi

# Cost
seg2_cost=""
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
if [ -n "$cost" ] && [ "$cost" != "null" ] && [ "$cost" != "0" ]; then
    cost_fmt=$(printf "%.3f" "$cost" 2>/dev/null)
    seg2_cost=$(printf "\033[02;37m\$%s\033[00m" "$cost_fmt")
fi

# Session name
seg2_session=""
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$session_id" ]; then
    note_file="$HOME/.claude/session_notes/${session_id}"
    if [ -f "$note_file" ]; then
        session_name=$(cat "$note_file")
        seg2_session=$(printf "\033[01;33m📌 %s\033[00m" "$session_name")
    fi
fi

# ── OUTPUT ────────────────────────────────────────────────────────────────────

line1=$(space_between "$seg1_loc" "$seg1_dir" "$seg1_git" "$seg1_runtime")
line2=$(space_between "$seg2_model" "$seg2_context" "$seg2_cost" "$seg2_session")

if [ -n "$line2" ]; then
    printf "%s\n%s" "$line1" "$line2"
else
    printf "%s" "$line1"
fi
