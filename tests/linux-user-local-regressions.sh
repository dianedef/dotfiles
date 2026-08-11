#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# A non-interactive fresh shell has no PROMPT_COMMAND. The sourced integration
# must remain compatible with the installer's `set -u` contract.
(
  set -u
  unset PROMPT_COMMAND
  SCRIPT_DIR=/installer/root
  # shellcheck source=/dev/null
  source "$ROOT_DIR/nvim/shell-integration.sh"
  [[ "${PROMPT_COMMAND:-}" == *"_git_auto_fetch"* ]]
  [[ "$SCRIPT_DIR" == /installer/root ]]
) || fail "shell integration is not safe with an unset PROMPT_COMMAND"

export HOME="$TEST_DIR/home"
export DOTFILES_PNPM_HOME="$HOME/.local/share/pnpm"
export DOTFILES_LOG_FILE="$TEST_DIR/dotfiles.log"
export DOTFILES_LOG_LEVEL=ERROR
mkdir -p "$HOME/.local/bin" "$DOTFILES_PNPM_HOME" "$HOME/.config/mcp" "$TEST_DIR/targets"

make_stub() {
  local path="$1"
  mkdir -p "$(dirname "$path")"
  printf '#!/usr/bin/env sh\nprintf "stub 1.0\\n"\n' > "$path"
  chmod +x "$path"
}

for command_name in nvim node npm fzf starship zoxide rg fd bat lsd tmux mosh git; do
  make_stub "$HOME/.local/bin/$command_name"
done

cat > "$HOME/.local/bin/gh" <<'EOF'
#!/usr/bin/env sh
if [ "${1:-}" = auth ]; then
  exit 1
fi
printf 'gh stub 1.0\n'
EOF
chmod +x "$HOME/.local/bin/gh"

cat > "$HOME/.local/bin/doppler" <<'EOF'
#!/usr/bin/env sh
if [ "${1:-}" = me ]; then
  exit 1
fi
printf 'doppler stub 1.0\n'
EOF
chmod +x "$HOME/.local/bin/doppler"

make_stub "$DOTFILES_PNPM_HOME/mcpc"
make_stub "$DOTFILES_PNPM_HOME/codex-acp"

case "$(uname -m)" in
  x86_64|amd64) platform_package="codex-acp-linux-x64" ;;
  arm64|aarch64) platform_package="codex-acp-linux-arm64" ;;
  *) fail "unsupported test architecture: $(uname -m)" ;;
esac
native="$DOTFILES_PNPM_HOME/global/v11/install-instance/node_modules/.pnpm/node_modules/@zed-industries/$platform_package/bin/codex-acp"
make_stub "$native"

printf 'target\n' > "$TEST_DIR/targets/nvim"
printf 'target\n' > "$TEST_DIR/targets/tmux"
printf 'target\n' > "$TEST_DIR/targets/mcp"
ln -s "$TEST_DIR/targets/nvim" "$HOME/.config/nvim"
ln -s "$TEST_DIR/targets/tmux" "$HOME/.tmux.conf"
ln -s "$TEST_DIR/targets/mcp" "$HOME/.config/mcp/servers.json"
printf 'format = "$directory$character"\n' > "$HOME/.config/starship.toml"

cat > "$HOME/.bashrc" <<'EOF'
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$HOME/.local/bin:$PNPM_HOME:$PATH"
eval "$(starship init bash)"
eval "$(zoxide init bash)"
source /tmp/dotfiles/nvim/shell-integration.sh
EOF

# Keep the caller PATH intentionally free of the fixture binaries. The health
# check must evaluate the user-local paths it promises to validate.
PATH=/usr/bin:/bin
export PATH

# shellcheck source=/dev/null
source "$ROOT_DIR/dotfiles/config.sh"
# shellcheck source=/dev/null
source "$ROOT_DIR/dotfiles/lib.sh"

# If a system Corepack cannot create a usable shim, pnpm must fall back to an
# npm install under ~/.local instead of silently skipping required CLI tools.
fallback_bin="$TEST_DIR/pnpm-fallback-bin"
mkdir -p "$fallback_bin"
cat > "$fallback_bin/corepack" <<'EOF'
#!/usr/bin/env sh
exit 1
EOF
cat > "$HOME/.local/bin/npm" <<'EOF'
#!/usr/bin/env sh
if [ "${1:-}" != install ]; then
  printf 'npm stub 1.0\n'
  exit 0
fi
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/pnpm" <<'PNPM'
#!/usr/bin/env sh
case "${1:-}" in
  --version) printf '10.0.0\n' ;;
  config) exit 0 ;;
esac
PNPM
chmod +x "$HOME/.local/bin/pnpm"
EOF
chmod +x "$fallback_bin/corepack" "$HOME/.local/bin/npm"
PATH="$fallback_bin:/usr/bin:/bin"
export PATH
ensure_pnpm_global_env || fail "npm fallback did not provide user-local pnpm"
[[ "$(command -v pnpm)" == "$HOME/.local/bin/pnpm" ]] \
  || fail "pnpm fallback is not resolved from ~/.local/bin"

health_output="$TEST_DIR/health.out"
run_health_check > "$health_output" || {
  cat "$health_output" >&2
  fail "user-local health check rejected a complete installation"
}

grep -q 'PATH (pnpm).*configured' "$health_output" \
  || fail "health check does not validate PNPM_HOME"
grep -q 'GitHub CLI: not authenticated (optional)' "$health_output" \
  || fail "optional GitHub authentication is reported as required"
if grep -q 'npm-global' "$health_output"; then
  fail "health check still requires the retired npm-global path"
fi

grep -q 'managed separately by the official ShipGlows installer' "$ROOT_DIR/dotfiles/install.sh" \
  || fail "installer does not delegate ShipGlows to the official installer"
if grep -q 'commandglows/shipglows\.git' "$ROOT_DIR/dotfiles/install.sh"; then
  fail "installer still clones a local ShipGlows source tree"
fi

echo "Linux user-local regression checks passed"
