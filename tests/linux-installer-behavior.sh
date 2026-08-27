#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)";TMP="$(mktemp -d)";trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home" XDG_STATE_HOME="$TMP/state" DOTFILES_DIR="$ROOT_DIR";export XDG_CONFIG_HOME="$HOME/.config";mkdir -p "$HOME"
before="$(find "$TMP" -mindepth 1 -print|sort)";"$ROOT_DIR/dotfiles/install-dotfiles.sh" --dry-run --only neovim,starship > "$TMP/dry.out"
after="$(find "$TMP" -mindepth 1 ! -name dry.out -print|sort)";[ "$before" = "$after" ]||{ printf 'dry-run mutated fixture\n' >&2;exit 1;}
if "$ROOT_DIR/dotfiles/install-dotfiles.sh" --dry-run --only invalid-component >/dev/null 2>&1;then exit 1;fi
if "$ROOT_DIR/dotfiles/install-dotfiles.sh" --dry-run --check >/dev/null 2>&1;then exit 1;fi
rg -n 'DRY-RUN.*neovim|DRY-RUN.*starship' "$TMP/dry.out" >/dev/null;printf 'Linux behavior contracts: OK\n'
