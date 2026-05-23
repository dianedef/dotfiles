#!/usr/bin/env sh
# Bootstrap Termux dotfiles without a manual git clone.

set -eu

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/dianedef/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-master}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

log() {
    printf '%s\n' "$*"
}

run_quiet() {
    "$@" </dev/null >/dev/null 2>&1
}

curl_works() {
    command -v curl >/dev/null 2>&1 && curl --version >/dev/null 2>&1
}

repair_termux_curl() {
    if curl_works; then
        return 0
    fi

    log "curl est cassé ou manquant; réparation des paquets Termux..."

    if ! command -v apt >/dev/null 2>&1; then
        log "apt est indisponible, réparation automatique impossible."
        return 1
    fi

    run_quiet apt update
    run_quiet apt full-upgrade -y
    run_quiet apt install --reinstall curl openssl libngtcp2 -y || \
        run_quiet apt install curl openssl libngtcp2 -y

    if ! curl_works; then
        log "curl ne fonctionne toujours pas après réparation automatique."
        return 1
    fi
}

if ! command -v pkg >/dev/null 2>&1; then
    log "Ce script doit être lancé dans Termux (commande pkg introuvable)."
    exit 1
fi

repair_termux_curl

log "Préparation de l'installation Termux..."
# Keep subprocesses off stdin because this installer is commonly run as curl | sh.
pkg update -y </dev/null >/dev/null 2>&1
pkg install -y git curl bash </dev/null >/dev/null 2>&1

if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Mise à jour du dépôt dotfiles..."
    git -C "$DOTFILES_DIR" fetch origin "$BRANCH" </dev/null >/dev/null 2>&1
    git -C "$DOTFILES_DIR" checkout "$BRANCH" </dev/null >/dev/null 2>&1
    git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH" </dev/null >/dev/null 2>&1
elif [ -e "$DOTFILES_DIR" ]; then
    log "$DOTFILES_DIR existe déjà mais ce n'est pas un dépôt git."
    log "Déplacez-le ou définissez DOTFILES_DIR vers un autre chemin, puis relancez."
    exit 1
else
    log "Téléchargement des dotfiles..."
    git clone --quiet --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR" </dev/null
fi

chmod +x "$DOTFILES_DIR/termux.sh"
exec bash "$DOTFILES_DIR/termux.sh"
