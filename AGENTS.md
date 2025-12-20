# AGENTS.md - Dotfiles Repository

## Build/Install Commands
- `./install.sh` - Linux/Codespaces installation (runs automatically on Codespace creation)
- `./termux.sh` - Termux (Android) lightweight installation
- `nvim --headless "+Lazy! sync" +qa` - Sync Neovim plugins

## Code Style

### Shell Scripts (Bash)
- Use `set -euo pipefail` for error handling; functions: `snake_case()`
- Variables: `UPPER_SNAKE_CASE` (constants), `lower_snake_case` (local)
- Format with `shfmt` (2-space indent); quote variables: `"$VAR"`

### Lua (Neovim/Yazi)
- Format with StyLua: 2-space indent, 120 column width
- Use return table pattern for modules; lazy.nvim spec format for plugins
- Globals allowed: `vim`, `vim.g`, `vim.opt`, etc.

### JavaScript/TypeScript (yazi/rules)
- Format with Prettier: tabs, no semicolons, double quotes, 120 print width

## Key Conventions
- Configs are symlinked to `~/.config/`, not copied
- Multi-platform: test in Codespaces first, then Termux if Android-specific
- Keep configs lightweight for SSH latency; prefer built-in tools over npm/pip
- See `.github/copilot-instructions.md` for full context and gotchas
