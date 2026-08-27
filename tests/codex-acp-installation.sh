#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
P="$ROOT_DIR/install-dotfiles.ps1"; M="$ROOT_DIR/dotfiles/components.tsv"
A="$ROOT_DIR/nvim/MyNeovim/lua/plugins/avante.lua"; T="$ROOT_DIR/nvim/MyNeovim/lua/plugins/telescope.lua"; L="$ROOT_DIR/nvim/MyNeovim/lazy-lock.json"; G="$ROOT_DIR/.gitattributes"
awk -F '\t' 'NR==1{if($20!="node_package")exit 1}$1=="codex-acp"{found=1;if($3!="windows"||$4!="core"||$20!="@zed-industries/codex-acp@0.16.0")exit 1}END{if(!found)exit 1}' "$M"
rg -n "@zed-industries/codex-acp@0\.16\.0|codex-acp-win32-\$architecture" "$P" >/dev/null
rg -n 'pnpm\.cmd|npm\.cmd|--config\.optional=true|--include=optional' "$P" >/dev/null
rg -n 'Find-CodexAcpNativeBinary|Test-CodexAcpRuntime|Optional dependencies must remain enabled' "$P" >/dev/null
rg -n 'Get-NodeGlobalBin|Find-CodexAcpWrapper|pnpm\\global|instanceRoot.*node_modules' "$P" >/dev/null
rg -n 'version = "v0\.2\.3"|Build\.ps1 -BuildFromSource false' "$A" >/dev/null
rg -n '"avante\.nvim": \{ "branch": "main", "commit": "a0a1d12c51d5336167074215bc22ff7127ac240c" \}' "$L" >/dev/null
if rg -n 'version[[:space:]]*=[[:space:]]*false' "$A"; then printf 'FAIL: Avante must stay pinned to a release with Windows assets\n' >&2; exit 1; fi
rg -Fx 'nvim/MyNeovim/lazy-lock.json text eol=lf' "$G" >/dev/null
if LC_ALL=C grep -q $'\r' "$L"; then printf 'FAIL: lazy-lock.json must use LF to avoid false dirty checkouts\n' >&2; exit 1; fi
rg -n 'Build\.ps1 -BuildFromSource false|APPDATA.*codex-acp\.cmd|codex-acp-win32' "$A" >/dev/null
rg -n 'telescope_fzf_native_build|enabled = fzf_native_build ~= nil|has_cmake and has_compiler' "$T" >/dev/null
printf 'Codex ACP Windows installation contracts: OK\n'
