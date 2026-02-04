# MyNeovim Commands Reference

## scope.nvim - Scoped Buffers per Tab

Scopes buffers to tabs - each tab has its own buffer list instead of sharing all buffers globally.

### Commands

| Command | Description |
|---------|-------------|
| `:Telescope scope buffers` | Browse buffers in current tab |
| `:ScopeMoveBuf` | Move current buffer to another tab |
| `:ScopeSaveState` | Save scope state to session |
| `:ScopeLoadState` | Load scope state from session |

### How it works

- Open buffers in Tab 1 → only visible in Tab 1
- Open buffers in Tab 2 → only visible in Tab 2
- Bufferline will only show buffers for the current tab

Useful when working with multiple tabs to keep buffers organized per-project/context.
