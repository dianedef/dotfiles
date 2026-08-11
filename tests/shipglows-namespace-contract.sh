#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
OBSOLETE_NAMESPACE="shipglow""z"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

if git -C "$ROOT_DIR" grep -I -n -i "$OBSOLETE_NAMESPACE"; then
  fail 'tracked content still contains the obsolete namespace'
fi

if find "$ROOT_DIR" -path "$ROOT_DIR/.git" -prune -o -iname "*$OBSOLETE_NAMESPACE*" -print | grep -q .; then
  fail 'a tracked workspace path still uses the obsolete namespace'
fi

rg -n 'SHIPGLOWS_PRIVATE_DIR=.*\.shipglows/private' "$ROOT_DIR/dotfiles/config.sh" >/dev/null
rg -n 'lua/shipglows|require\("shipglows' "$ROOT_DIR/nvim/MyNeovim" >/dev/null
rg -n 'shipglows_data/technical' "$ROOT_DIR/AGENT.md" >/dev/null

printf 'ShipGlows namespace contract: OK\n'
