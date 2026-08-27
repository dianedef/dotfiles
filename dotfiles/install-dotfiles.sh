#!/usr/bin/env bash
set -euo pipefail
IMPL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"; REPO_ROOT="$(cd "$IMPL_DIR/.." && pwd -P)"
source "$IMPL_DIR/config.sh"
if [ ! -e "$DOTFILES_DIR" ] && [ -e "$REPO_ROOT/.git" ]; then DOTFILES_DIR="$REPO_ROOT";DOTFILES_MANIFEST="$REPO_ROOT/dotfiles/components.tsv";fi
source "$IMPL_DIR/lib.sh"
parse_arguments "$@";require_linux_host
if [ "$DOTFILES_UNINSTALL" = true ];then run_uninstall;exit 0;fi
sync_checkout;DOTFILES_MANIFEST="$DOTFILES_DIR/dotfiles/components.tsv";validate_manifest;select_components
if [ "$DOTFILES_CHECK" = true ];then check_installation;exit 0;fi
install_packages;install_artifacts
if [ "$DOTFILES_DRY_RUN" = true ];then info 'dry-run completed without mutation';else info 'Linux Dotfiles installation completed';fi
