#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

export HOME="$TMP_DIR/home"
export DOTFILES_DRY_RUN=false
export DOTFILES_LOG_FILE="$TMP_DIR/dotfiles.log"
export DOTFILES_LOG_LEVEL=ERROR
mkdir -p "$HOME"

# shellcheck source=/dev/null
source "$ROOT_DIR/config.sh"
# shellcheck source=/dev/null
source "$ROOT_DIR/lib.sh"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

backup_count() {
    local target=$1
    find "$(dirname "$target")" -maxdepth 1 -name "$(basename "$target").backup.*" | wc -l
}

single_backup_for() {
    local target=$1
    find "$(dirname "$target")" -maxdepth 1 -name "$(basename "$target").backup.*" -print -quit
}

assert_link_to() {
    local target=$1
    local source=$2
    [ -L "$target" ] || fail "$target is not a symlink"
    [ "$(readlink -f "$target")" = "$(readlink -f "$source")" ] || fail "$target does not point to $source"
}

mkdir -p "$TMP_DIR/sources" "$HOME/.config"

# Existing real files are backed up, not deleted.
file_source="$TMP_DIR/sources/starship.toml"
file_target="$HOME/.config/starship.toml"
printf 'dotfiles\n' > "$file_source"
printf 'user-local\n' > "$file_target"
create_symlink "$file_source" "$file_target" false >/dev/null
assert_link_to "$file_target" "$file_source"
file_backup="$(single_backup_for "$file_target")"
[ -n "$file_backup" ] || fail "file backup was not created"
[ "$(cat "$file_backup")" = "user-local" ] || fail "file backup did not preserve content"

# Existing real directories are backed up, not recursively removed.
dir_source="$TMP_DIR/sources/nvim"
dir_target="$HOME/.config/nvim"
mkdir -p "$dir_source" "$dir_target"
printf 'user config\n' > "$dir_target/init.lua"
create_symlink "$dir_source" "$dir_target" false >/dev/null
assert_link_to "$dir_target" "$dir_source"
dir_backup="$(single_backup_for "$dir_target")"
[ -n "$dir_backup" ] || fail "directory backup was not created"
[ -f "$dir_backup/init.lua" ] || fail "directory backup did not preserve files"

# Re-running an already-correct symlink is idempotent and creates no extra backup.
before_count="$(backup_count "$dir_target")"
create_symlink "$dir_source" "$dir_target" false >/dev/null
after_count="$(backup_count "$dir_target")"
[ "$before_count" = "$after_count" ] || fail "idempotent symlink run created an extra backup"
assert_link_to "$dir_target" "$dir_source"

# Stale symlinks are replaced as symlinks only; their old source stays intact.
old_source="$TMP_DIR/sources/old-tmux.conf"
new_source="$TMP_DIR/sources/tmux.conf"
target="$HOME/.tmux.conf"
printf 'old\n' > "$old_source"
printf 'new\n' > "$new_source"
ln -s "$old_source" "$target"
create_symlink "$new_source" "$target" false >/dev/null
assert_link_to "$target" "$new_source"
[ -f "$old_source" ] || fail "old symlink source was removed"

echo "symlink safety checks passed"

# Termux keeps a standalone helper, so test that extracted function without
# running the installer body.
termux_functions="$TMP_DIR/termux-symlink-functions.sh"
awk '
    /^next_backup_path\(\) \{/ { capture=1 }
    capture { print }
    /^# Neovim config/ { exit }
' "$ROOT_DIR/termux.sh" > "$termux_functions"

log() {
    :
}

# shellcheck source=/dev/null
source "$termux_functions"

termux_source="$TMP_DIR/sources/termux.properties"
termux_target="$HOME/.termux/termux.properties"
mkdir -p "$(dirname "$termux_target")"
printf 'dotfiles termux\n' > "$termux_source"
printf 'user termux\n' > "$termux_target"
create_symlink "$termux_source" "$termux_target" >/dev/null
assert_link_to "$termux_target" "$termux_source"
termux_backup="$(single_backup_for "$termux_target")"
[ -n "$termux_backup" ] || fail "termux file backup was not created"
[ "$(cat "$termux_backup")" = "user termux" ] || fail "termux backup did not preserve content"

termux_before_count="$(backup_count "$termux_target")"
create_symlink "$termux_source" "$termux_target" >/dev/null
termux_after_count="$(backup_count "$termux_target")"
[ "$termux_before_count" = "$termux_after_count" ] || fail "termux idempotent run created an extra backup"

echo "termux symlink safety checks passed"
