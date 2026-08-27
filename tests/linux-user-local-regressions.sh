#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
rg -n 'assert_user_target|refusing target outside HOME' "$ROOT_DIR/dotfiles/lib.sh" >/dev/null;rg -n 'root or sudo|id -u.*-eq 0' "$ROOT_DIR/dotfiles/lib.sh" >/dev/null
rg -n 'ShipGlows.*agents.*skills.*MCP|Doppler' "$ROOT_DIR/dotfiles/lib.sh" "$ROOT_DIR/README.md" >/dev/null
if rg -n '(claude|codex|opencode|mcp|doppler).*(install|auth|secrets)' "$ROOT_DIR/dotfiles/install-dotfiles.sh" "$ROOT_DIR/dotfiles/lib.sh";then exit 1;fi
printf 'Linux user-local regressions: OK\n'
