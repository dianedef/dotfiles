#!/usr/bin/env sh
# Bootstrap Termux dotfiles without a manual git clone.

set -eu

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/dianedef/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-master}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log() {
    printf '%s\n' "$*"
}

if ! command -v pkg >/dev/null 2>&1; then
    log "This installer must run inside Termux (pkg command not found)."
    exit 1
fi

log "Installing bootstrap dependencies..."
pkg update -y >/dev/null 2>&1
pkg install -y git curl bash >/dev/null 2>&1

if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Updating existing dotfiles repository: $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" fetch origin "$BRANCH"
    git -C "$DOTFILES_DIR" checkout "$BRANCH"
    git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH"
elif [ -e "$DOTFILES_DIR" ]; then
    log "$DOTFILES_DIR already exists but is not a git repository."
    log "Move it away or set DOTFILES_DIR to another path, then retry."
    exit 1
else
    log "Cloning dotfiles into $DOTFILES_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
fi

chmod +x "$DOTFILES_DIR/termux.sh"
exec bash "$DOTFILES_DIR/termux.sh"
