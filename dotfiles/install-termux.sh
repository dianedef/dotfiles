#!/usr/bin/env sh
# Bootstrap Termux dotfiles without a manual git clone.

set -eu

REPO_URL="${DOTFILES_REPO_URL:-https://github.com/dianedef/dotfiles.git}"
BRANCH="${DOTFILES_BRANCH:-master}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BOOTSTRAP_LOG="${TERMUX_DOTFILES_BOOTSTRAP_LOG:-$HOME/termux-bootstrap.log}"
export DEBIAN_FRONTEND=noninteractive

log() {
    printf '%s\n' "$*"
}

run_quiet() {
    "$@" </dev/null >/dev/null 2>&1
}

apt_termux() {
    apt-get \
        -o Dpkg::Options::=--force-confdef \
        -o Dpkg::Options::=--force-confold \
        "$@"
}

run_or_explain() {
    label=$1
    shift

    if "$@" </dev/null >>"$BOOTSTRAP_LOG" 2>&1; then
        return 0
    fi

    log "Échec: $label."
    log "Détails: $BOOTSTRAP_LOG"
    log "Dernières lignes:"
    tail -n 8 "$BOOTSTRAP_LOG" 2>/dev/null || true
    return 1
}

stash_dotfiles_changes() {
    if [ -z "$(git -C "$DOTFILES_DIR" status --porcelain 2>/dev/null)" ]; then
        return 0
    fi

    log "Modifications locales détectées dans $DOTFILES_DIR; sauvegarde temporaire..."
    run_or_explain "sauvegarde des modifications locales dotfiles" env \
        GIT_AUTHOR_NAME="Termux Bootstrap" \
        GIT_AUTHOR_EMAIL="termux-bootstrap@example.invalid" \
        GIT_COMMITTER_NAME="Termux Bootstrap" \
        GIT_COMMITTER_EMAIL="termux-bootstrap@example.invalid" \
        git -C "$DOTFILES_DIR" stash push -u -m "termux-bootstrap backup $(date -u +%Y%m%dT%H%M%SZ)"
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

    run_quiet apt_termux update
    run_quiet dpkg --force-confdef --force-confold --configure -a
    run_quiet apt_termux full-upgrade -y
    run_quiet apt_termux install --reinstall curl openssl libngtcp2 -y || \
        run_quiet apt_termux install curl openssl libngtcp2 -y

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
run_or_explain "mise à jour des paquets Termux" apt_termux update
run_or_explain "réparation de l'état dpkg" dpkg --force-confdef --force-confold --configure -a
run_or_explain "installation de git/curl/bash" apt_termux install -y git curl bash

if [ "$DOTFILES_DIR" != "$HOME/dotfiles" ] && [ -e "$HOME/dotfiles" ]; then
    log "Ancien checkout laissé inchangé: $HOME/dotfiles"
fi

if [ -d "$DOTFILES_DIR/.git" ]; then
    log "Mise à jour du dépôt dotfiles..."
    stash_dotfiles_changes
    run_or_explain "récupération de la dernière version dotfiles" git -C "$DOTFILES_DIR" fetch origin "$BRANCH"
    run_or_explain "sélection de la branche $BRANCH" git -C "$DOTFILES_DIR" checkout "$BRANCH"
    run_or_explain "mise à jour du dépôt dotfiles" git -C "$DOTFILES_DIR" pull --ff-only origin "$BRANCH"
elif [ -e "$DOTFILES_DIR" ]; then
    log "$DOTFILES_DIR existe déjà mais ce n'est pas un dépôt git."
    log "Déplacez-le ou définissez DOTFILES_DIR vers un autre chemin, puis relancez."
    exit 1
else
    log "Téléchargement des dotfiles..."
    run_or_explain "téléchargement des dotfiles" git clone --quiet --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
fi

exec bash "$DOTFILES_DIR/dotfiles/termux.sh"
