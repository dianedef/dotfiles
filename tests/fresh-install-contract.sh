#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALLER="$ROOT_DIR/dotfiles/install.sh"

grep -Fq 'load_nvm_runtime' "$INSTALLER"
grep -Fq 'curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$DOTFILES_NVM_VERSION/install.sh"' "$INSTALLER"
grep -Fq 'command -v node >/dev/null 2>&1 || return 1' "$INSTALLER"
grep -Fq 'sh -s -- -y -b "$DOTFILES_BIN_DIR"' "$INSTALLER"
grep -Fq 'GIT_TERMINAL_PROMPT=0' "$INSTALLER"
grep -Fq 'BatchMode=yes' "$INSTALLER"

echo "Fresh install contract passed"
