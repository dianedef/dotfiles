#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
for f in dotfiles/install.sh dotfiles/bootstrap.sh;do rg -n 'exec.*install-dotfiles\.sh' "$ROOT_DIR/$f" >/dev/null;done
rg -n 'install-dotfiles\.ps1|DryRun' "$ROOT_DIR/dotfiles/windows.ps1" >/dev/null;rg -n 'HOME/\.dotfiles|components\.tsv|journal\.tsv' "$ROOT_DIR/dotfiles/config.sh" >/dev/null
rg -n '^yazi.*windows,linux.*core' "$ROOT_DIR/dotfiles/components.tsv" >/dev/null;rg -n '^ranger-legacy.*linux.*legacy' "$ROOT_DIR/dotfiles/components.tsv" >/dev/null
printf 'Runtime layout contract: OK\n'
