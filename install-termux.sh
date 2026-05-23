#!/usr/bin/env sh
# Bootstrap Termux dotfiles without a manual git clone.

set -eu

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/dianedef/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-master}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log() {
    printf '%s\n' "$*"
}

curl_works() {
    command -v curl >/dev/null 2>&1 && curl --version >/dev/null 2>&1
}

repair_termux_curl() {
    if curl_works; then
        return 0
    fi

    log "curl is broken or missing; repairing Termux TLS packages..."

    if ! command -v apt >/dev/null 2>&1; then
        log "apt is not available, cannot repair curl automatically."
        return 1
    fi

    apt update </dev/null
    apt full-upgrade -y </dev/null
    apt install --reinstall curl openssl libngtcp2 -y </dev/null || \
        apt install curl openssl libngtcp2 -y </dev/null

    if ! curl_works; then
        log "curl is still not working after automatic repair."
        return 1
    fi
}

if ! command -v pkg >/dev/null 2>&1; then
    log "This installer must run inside Termux (pkg command not found)."
    exit 1
fi

repair_termux_curl

log "Installing bootstrap dependencies..."
# Keep subprocesses off stdin because this installer is commonly run as curl | sh.
pkg update -y </dev/null >/dev/null 2>&1
pkg install -y git curl bash </dev/null >/dev/null 2>&1

if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Updating existing dotfiles repository: $DOTFILES_DIR"
    git -C "$DOTFILES_DIR" fetch origin "$BRANCH" </dev/null
    git -C "$DOTFILES_DIR" checkout "$BRANCH" </dev/null
    git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH" </dev/null
elif [ -e "$DOTFILES_DIR" ]; then
    log "$DOTFILES_DIR already exists but is not a git repository."
    log "Move it away or set DOTFILES_DIR to another path, then retry."
    exit 1
else
    log "Cloning dotfiles into $DOTFILES_DIR..."
    git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR" </dev/null
fi

chmod +x "$DOTFILES_DIR/termux.sh"
exec bash "$DOTFILES_DIR/termux.sh"
