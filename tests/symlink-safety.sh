#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)";TMP="$(mktemp -d)";trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home" DOTFILES_STATE_DIR="$TMP/state" DOTFILES_JOURNAL="$TMP/state/journal.tsv" DOTFILES_DRY_RUN=false
mkdir -p "$HOME/.config" "$TMP/source/config";printf 'user\n' > "$HOME/.config/tool";printf 'managed\n' > "$TMP/source/config/file"
source "$ROOT_DIR/dotfiles/lib.sh"
create_managed_link test "$TMP/source/config" "$HOME/.config/tool";[ -L "$HOME/.config/tool" ];backup="$(awk -F '\t' 'NR==2{print $6}' "$DOTFILES_JOURNAL")";[ -f "$backup" ]
count="$(wc -l < "$DOTFILES_JOURNAL")";create_managed_link test "$TMP/source/config" "$HOME/.config/tool";[ "$(wc -l < "$DOTFILES_JOURNAL")" = "$count" ]
run_uninstall;[ -f "$HOME/.config/tool" ];[ "$(cat "$HOME/.config/tool")" = user ];printf 'Symlink safety contracts: OK\n'
