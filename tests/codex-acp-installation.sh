#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

export HOME="$TMP_DIR/home"
export DOTFILES_NPM_DIR="$HOME/.npm-global"
export DOTFILES_PNPM_HOME="$HOME/.local/share/pnpm"
export DOTFILES_LOG_FILE="$TMP_DIR/dotfiles.log"
export DOTFILES_LOG_LEVEL=ERROR
mkdir -p "$HOME"

# shellcheck source=/dev/null
source "$ROOT_DIR/dotfiles/config.sh"
# shellcheck source=/dev/null
source "$ROOT_DIR/dotfiles/lib.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[ "$DOTFILES_CODEX_ACP_PACKAGE" = "@zed-industries/codex-acp@0.16.0" ] \
  || fail "Codex ACP installer package is not pinned to the Avante-compatible release"
[[ " $DOTFILES_NPM_PACKAGES " == *" $DOTFILES_CODEX_ACP_PACKAGE "* ]] \
  || fail "Codex ACP package is absent from DOTFILES_NPM_PACKAGES"

declare -F resolve_codex_acp_native_binary >/dev/null \
  || fail "native Codex ACP resolver is missing"
declare -F verify_codex_acp_installation >/dev/null \
  || fail "Codex ACP installation verifier is missing"

platform_package="$(codex_acp_platform_package)"
binary_name="codex-acp"
case "$platform_package" in
  *-win32-*) binary_name="codex-acp.exe" ;;
esac

wrapper="$DOTFILES_PNPM_HOME/codex-acp"
native="$DOTFILES_PNPM_HOME/global/v11/install-instance/node_modules/.pnpm/node_modules/@zed-industries/$platform_package/bin/$binary_name"
mkdir -p "$(dirname "$native")"
printf '#!/usr/bin/env sh\nexit 0\n' > "$wrapper"
printf '#!/usr/bin/env sh\nexit 0\n' > "$native"
chmod +x "$wrapper" "$native"
export PATH="$DOTFILES_PNPM_HOME:$PATH"

[ "$(resolve_codex_acp_native_binary)" = "$native" ] \
  || fail "native Codex ACP resolver did not select the pnpm runtime"
verify_codex_acp_installation \
  || fail "Codex ACP installation verifier rejected a complete install"

avante_command="$(
  nvim --headless -u NONE --cmd \
    "lua local spec=dofile('$ROOT_DIR/nvim/MyNeovim/lua/plugins/avante.lua'); print(spec.opts.acp_providers.codex.command)" \
    +qa 2>&1 | tr -d '\r'
)"
[ "$avante_command" = "$native" ] \
  || fail "Avante did not select the native runtime installed by pnpm"

rm -f "$native"
if verify_codex_acp_installation; then
  fail "Codex ACP installation verifier accepted a missing native runtime"
fi

grep -q 'verify_codex_acp_installation' "$ROOT_DIR/dotfiles/install.sh" \
  || fail "installer does not validate Codex ACP after installing Node tools"
grep -q 'if ! install_npm_tools' "$ROOT_DIR/dotfiles/install.sh" \
  || fail "installer does not stop after an incomplete Codex ACP installation"

echo "codex-acp installation checks passed"
