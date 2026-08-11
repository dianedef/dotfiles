#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"

for file in \
  "$ROOT_DIR/dotfiles/config.sh" \
  "$ROOT_DIR/dotfiles/install-dotfiles.sh" \
  "$ROOT_DIR/dotfiles/install-termux.sh" \
  "$ROOT_DIR/dotfiles/bootstrap.sh"; do
  rg -n 'HOME/\.dotfiles' "$file" >/dev/null
done

rg -n "alias dot='~/\.dotfiles/dotfiles/install\.sh'" "$ROOT_DIR/dotfiles/install.sh" >/dev/null
rg -n "alias dot='~/\.dotfiles/dotfiles/termux\.sh'" "$ROOT_DIR/dotfiles/termux.sh" >/dev/null
rg -n 'HOME/\.dotfiles/nvim/shell-integration\.sh' "$ROOT_DIR/dotfiles/termux.sh" "$ROOT_DIR/nvim/shell-integration.sh" >/dev/null
rg -n 'ShipGlows/dotfiles|ShipGlows\\dotfiles' "$ROOT_DIR/README.md" >/dev/null

if rg -n 'rm -rf "\$DOTFILES_DIR"' "$ROOT_DIR/dotfiles/bootstrap.sh"; then
  printf 'FAIL: bootstrap must never recursively delete DOTFILES_DIR\n' >&2
  exit 1
fi

if rg -n 'DOTFILES_DIR=.*HOME/dotfiles|script_dir=.*HOME/dotfiles|alias (i|dot|dotfiles)=.*~/dotfiles|source .*HOME/dotfiles' \
  "$ROOT_DIR/dotfiles/config.sh" \
  "$ROOT_DIR/dotfiles/install.sh" \
  "$ROOT_DIR/dotfiles/lib.sh" \
  "$ROOT_DIR/dotfiles/termux.sh" \
  "$ROOT_DIR/nvim/shell-integration.sh"; then
  printf 'FAIL: active runtime code still targets the visible legacy checkout\n' >&2
  exit 1
fi

printf 'Dotfiles runtime layout contract: OK\n'
