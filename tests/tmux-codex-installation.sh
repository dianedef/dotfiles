#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

helper="$ROOT_DIR/bin/tmux-codex-fresh"

bash -n "$helper"
grep -q 'PNPM_HOME:-\$HOME/.local/share/pnpm' "$helper" \
  || fail "tmux Codex helper does not resolve the portable PNPM home"
if grep -q '/home/claude' "$helper"; then
  fail "tmux Codex helper contains a VM-specific home path"
fi
grep -q 'bind R run-shell.*tmux-codex-fresh.*#{pane_id}' "$ROOT_DIR/.tmux.conf" \
  || fail "tmux configuration does not use the safe Codex handoff"
if grep -q 'bind R respawn-pane' "$ROOT_DIR/.tmux.conf"; then
  fail "tmux configuration still destroys the pane before Codex starts"
fi
grep -q 'DOTFILES_PNPM_PACKAGES=.*@openai/codex' "$ROOT_DIR/dotfiles/config.sh" \
  || fail "dotfiles does not install the Codex CLI through PNPM"

export HOME="$TEST_DIR/home"
export DOTFILES_NO_GUM=true
export SKIP_SHIPGLOWS=true
export DOTFILES_REPORT_DIR="$TEST_DIR/reports"
mkdir -p "$HOME/.tmux/plugins/tpm"
touch "$HOME/.bashrc"

"$ROOT_DIR/dotfiles/install.sh" --only=configs > "$TEST_DIR/install.out"

[[ "$(readlink -f "$HOME/.tmux.conf")" == "$ROOT_DIR/.tmux.conf" ]] \
  || fail "installer did not link the tmux configuration"
[[ "$(readlink -f "$HOME/.local/bin/tmux-codex-fresh")" == "$helper" ]] \
  || fail "installer did not link the tmux Codex helper"
[[ -x "$HOME/.local/bin/tmux-codex-fresh" ]] \
  || fail "installed tmux Codex helper is not executable"

echo "Tmux Codex installation checks passed"
