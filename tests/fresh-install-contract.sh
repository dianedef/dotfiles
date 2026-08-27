#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)";I="$ROOT_DIR/dotfiles/install-dotfiles.sh";L="$ROOT_DIR/dotfiles/lib.sh"
rg -n 'set -euo pipefail|require_linux_host|validate_manifest|select_components' "$I" >/dev/null
rg -n 'apt-get|dnf|pacman|zypper|brew' "$L" >/dev/null;rg -n 'id -u.*-eq 0|command -v sudo|root or sudo' "$L" >/dev/null
rg -n 'origin mismatch|status --porcelain|merge --ff-only|never resets or stashes' "$L" >/dev/null
if rg -n 'curl[^#]*\|[^#]*(sh|bash)|checkout[^#]*-B|reset --hard|rm -rf.*DOTFILES' "$I" "$L";then exit 1;fi
printf 'Fresh install contract: OK\n'
