#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"; P="$ROOT_DIR/install-dotfiles.ps1"
[ -f "$P" ]; rg -n '\[switch\]\$DryRun|\[switch\]\$Check|\[switch\]\$Update|\[switch\]\$Uninstall|\[string\[\]\]\$Only' "$P" >/dev/null
rg -n 'status.*--porcelain|remote.*get-url.*origin|--ff-only|never resets or stashes|not a Git checkout' "$P" >/dev/null
rg -n 'journal\.tsv|backups|REFUSED changed target|Packages were intentionally left installed' "$P" >/dev/null
rg -n 'Import-Csv.*Delimiter|components\.tsv|Unknown or unsupported Windows component' "$P" >/dev/null
rg -n 'Update-ProcessPath|GetEnvironmentVariable.*Path.*User|GetEnvironmentVariable.*Path.*Machine' "$P" >/dev/null
rg -n 'InstallYaziPlugins|ya\.exe|pkg install' "$P" >/dev/null
rg -n "@zed-industries/codex-acp@0\.16\.0|codex-acp-win32-\$architecture|pnpm\.cmd|npm\.cmd|--include=optional|--config\.optional=true" "$P" >/dev/null
rg -n 'Find-CodexAcpNativeBinary|Test-CodexAcpRuntime|Node reported success.*native' "$P" >/dev/null
rg -n 'Build\.ps1 -BuildFromSource false' "$ROOT_DIR/nvim/MyNeovim/lua/plugins/avante.lua" >/dev/null
rg -n 'telescope_fzf_native_build|enabled = fzf_native_build ~= nil|executable\("cmake"\)|executable\("cl"\)' "$ROOT_DIR/nvim/MyNeovim/lua/plugins/telescope.lua" >/dev/null
if rg -n 'checkout.*-B|Set-ExecutionPolicy|\$PROFILE|doppler secrets|gh auth|curl.*\|.*(sh|bash)|Remove-Item.*-Recurse' "$P";then printf 'FAIL: forbidden behavior\n' >&2;exit 1;fi
rg -n 'install-dotfiles\.ps1|DryRun' "$ROOT_DIR/dotfiles/windows.ps1" >/dev/null
printf 'Windows bootstrap static contract: OK\n'
