#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
mkdir -p "$HOME"

printf 'dotfiles: Dry-run preview without local checkout.\n'
export DOTFILES_DIR="$HOME/.dotfiles"
if "$ROOT_DIR/install-dotfiles.sh" --dry-run >"$TMP/dry.out" 2>&1; then
  if ! rg -q 'DRY-RUN: would clone' "$TMP/dry.out" || [ -e "$DOTFILES_DIR" ]; then
    echo "Expected a pure dry-run plan for missing checkout." >&2
    cat "$TMP/dry.out" >&2
    exit 1
  fi
else
  cat "$TMP/dry.out" >&2
  exit 1
fi

printf 'dotfiles: Fresh local checkout delegate preview.\n'
rm -rf "$DOTFILES_DIR"
git clone --depth 1 --branch master "$ROOT_DIR" "$DOTFILES_DIR" >/dev/null
before="$(find "$TMP" -mindepth 1 -print | sort)"
"$ROOT_DIR/install-dotfiles.sh" --dry-run --only neovim >"$TMP/delegated-dry.out" 2>&1
after="$(find "$TMP" -mindepth 1 ! -name dry.out ! -name delegated-dry.out -print | sort)"
if [ "$before" != "$after" ] || rg -q 'DRY-RUN: would clone' "$TMP/delegated-dry.out"; then
  echo "Expected delegated dry-run on existing valid checkout without filesystem mutation." >&2
  echo "before:" >&2; printf '%s\n' "$before" >&2
  echo "after:" >&2; printf '%s\n' "$after" >&2
  cat "$TMP/delegated-dry.out" >&2
  exit 1
fi

printf 'dotfiles: Non-git checkout guard.\n'
rm -rf "$DOTFILES_DIR"
mkdir -p "$HOME"
cat <<'EOF' > "$DOTFILES_DIR"
collision target
EOF
if "$ROOT_DIR/install-dotfiles.sh" --check >"$TMP/non-git.out" 2>&1; then
  echo "Expected failure on non-git checkout target." >&2
  exit 1
fi
if ! rg -q 'not a Git checkout' "$TMP/non-git.out"; then
  cat "$TMP/non-git.out" >&2
  exit 1
fi

printf 'Linux bootstrap contract: OK\n'
