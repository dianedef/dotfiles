# ShipFlow Plugin for NeoVim

ShipFlow is a NeoVim helper module that allows users to navigate between different levels of Markdown headers using customizable shortcuts.

## Installation

The module lives in this config at:

```text
lua/shipflow/init.lua
```

It is loaded from `lua/config/keymaps.lua` with `require("shipflow").setup()`.

## Usage

Once loaded, ShipFlow provides the following default shortcuts for navigating between headers:

- **Navigate to the next H1 header**: `<leader>h1`
- **Navigate to the next H2 header**: `<leader>h2`
- **Navigate to the next H3 header**: `<leader>h3`

## Configuration

You can customize the shortcuts by modifying `lua/shipflow/init.lua`.

For example:

```lua
vim.api.nvim_set_keymap("n", "<leader>h1", ":lua require'shipflow'.search_header(1)<CR>", { noremap = true, silent = true })
```
