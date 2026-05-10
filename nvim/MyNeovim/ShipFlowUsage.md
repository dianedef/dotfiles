# ShipFlow Plugin for NeoVim

ShipFlow is a NeoVim helper module that allows users to navigate between different levels of Markdown headers and control the shared explorer panel width with customizable shortcuts.

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

It also exposes explorer width commands for the shared Snacks/Neo-tree panel:

- **Set explorer width to 20**: `:ShipFlowExplorerWidth20` or `<leader>e2`
- **Set explorer width to 35**: `:ShipFlowExplorerWidth35` or `<leader>e3`
- **Set explorer width to full screen**: `:ShipFlowExplorerWidthFull` or `<leader>eF`

## Configuration

You can customize the shortcuts by modifying `lua/shipflow/init.lua`.

For example:

```lua
vim.api.nvim_set_keymap("n", "<leader>h1", ":lua require'shipflow'.search_header(1)<CR>", { noremap = true, silent = true })
```
