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
rg -n "USERPROFILE '.dotfiles'|Set-InstalledRootHidden|FileAttributes.*Hidden|installed runtime ready" "$INSTALLER" >/dev/null
rg -n "ShipGlows\\dotfiles|Legacy checkout left unchanged" "$INSTALLER" >/dev/null
rg -n "Git\.Git|wez\.wezterm|--accept-package-agreements|--accept-source-agreements" "$INSTALLER" >/dev/null
rg -n 'status --porcelain|Local changes were found|--ff-only|already exists and is not a Git checkout' "$INSTALLER" >/dev/null
rg -n "fetch'.*'origin'.*\$Branch|checkout'.*'-B'.*\$Branch.*'FETCH_HEAD'|Switching the installed runtime" "$INSTALLER" >/dev/null
rg -n 'Non-interactive run: WezTerm setup skipped|ConfigureWezTerm|SkipWezTerm' "$INSTALLER" >/dev/null
rg -n 'ConfigureTools|SkipTools|Neovim\.Neovim|Starship\.Starship|ajeetdsouza\.zoxide|sxyazi\.yazi' "$INSTALLER" >/dev/null
rg -n 'junegunn\.fzf|BurntSushi\.ripgrep\.MSVC|sharkdp\.fd|sharkdp\.bat' "$INSTALLER" >/dev/null
rg -n 'BrechtSanders\.WinLibs\.POSIX\.UCRT|WinLibs GCC|gcc\.exe' "$INSTALLER" >/dev/null
rg -n 'ShipGlows\.Profile\.ps1|Install-YaziConfig|APPDATA.*yazi\\config|ya\.exe|pkg install|Neovim, Starship, PowerShell, and Yazi terminal configuration installed' "$INSTALLER" >/dev/null
rg -n "Install-NeovimConfig|nvim\\\\MyNeovim|LOCALAPPDATA.*'nvim'|Install-DirectoryJunction|ItemType Junction" "$INSTALLER" >/dev/null
rg -n '^Install-TerminalConfigs$|if \(\$installWezTerm\).*Install-WezTermConfig' "$INSTALLER" >/dev/null
rg -n 'Remove-Item Function:r|function y.*yazi\.exe' "$ROOT_DIR/powershell/ShipGlows.Profile.ps1" >/dev/null
rg -n 'require\("git"\):setup' "$ROOT_DIR/yazi/init.lua" >/dev/null
rg -n 'prepend_fetchers|run.*=.*"git"|group.*=.*"git"' "$ROOT_DIR/yazi/yazi.toml" >/dev/null
rg -n 'yazi-rs/plugins:git' "$ROOT_DIR/yazi/package.toml" >/dev/null
rg -n -- '--disable-interactivity.*Out-Null' "$INSTALLER" >/dev/null
if rg -n 'Write-Warning|winget.*install.*Out-Host' "$INSTALLER"; then
  fail 'native Windows bootstrap must keep controlled output in English'
fi
rg -n 'dotfiles-backup-|ReadAllText.*Replace|Copy-Item -LiteralPath \$source' "$INSTALLER" >/dev/null

if rg -n 'Set-ExecutionPolicy|\$PROFILE|Add-Content.*Profile|windows\.ps1' "$INSTALLER"; then
  fail 'native Windows bootstrap must not alter execution policy, profiles, or invoke the legacy full-machine script'
fi
if rg -n 'build.*Copilot auth' "$ROOT_DIR/nvim/MyNeovim/lua/plugins/copilot.lua"; then
  fail 'Copilot authentication must not run as a non-interactive plugin build step'
fi

printf 'Windows Dotfiles bootstrap static contract: OK\n'
