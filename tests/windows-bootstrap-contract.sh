#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
INSTALLER="$ROOT_DIR/install-dotfiles.ps1"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[ -f "$INSTALLER" ] || fail 'native Windows bootstrap is missing'
rg -n '^\[CmdletBinding\(\)\]|Set-StrictMode -Version Latest' "$INSTALLER" >/dev/null
rg -n "RepoUrl = 'https://github.com/dianedef/dotfiles.git'|Branch = 'master'" "$INSTALLER" >/dev/null
rg -n "Git\.Git|wez\.wezterm|--accept-package-agreements|--accept-source-agreements" "$INSTALLER" >/dev/null
rg -n 'status --porcelain|Local changes were found|--ff-only|already exists and is not a Git checkout' "$INSTALLER" >/dev/null
rg -n 'Non-interactive run: WezTerm setup skipped|ConfigureWezTerm|SkipWezTerm' "$INSTALLER" >/dev/null
rg -n 'dotfiles-backup-|Get-FileHash|Copy-Item -LiteralPath \$source' "$INSTALLER" >/dev/null

if rg -n 'Set-ExecutionPolicy|\$PROFILE|Add-Content.*Profile|windows\.ps1' "$INSTALLER"; then
  fail 'native Windows bootstrap must not alter execution policy, profiles, or invoke the legacy full-machine script'
fi

printf 'Windows Dotfiles bootstrap static contract: OK\n'
