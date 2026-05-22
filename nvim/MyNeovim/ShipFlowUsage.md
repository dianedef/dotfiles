# ShipFlow Plugin for NeoVim

ShipFlow is a NeoVim helper module that allows users to navigate between Markdown headings and control the shared explorer panel width with compact shortcuts.

## Installation

The module lives in this config at:

```text
lua/shipflow/init.lua
```

It is loaded from `lua/config/keymaps.lua` with `require("shipflow").setup()`.

## Usage

Once loaded, ShipFlow provides the following default shortcuts for navigating between headers:

- **Navigate to the next heading (H2/H3)**: `n`
- **Navigate to the previous heading (H2/H3)**: `p`
- Legacy suffix shortcuts are still available: `]h`, `[h`
- **Navigate to the next heading (any level)**: `zh` (markdown only)
- These commands work in:
  - `]h`, `[h`, `zh` in `Normal` and `Visual`.
  - `n`, `p` in `Visual` only (single-letter navigation inside a selection mode), with numeric prefixes (`2n`, `3n`, `2p`, `3p`).
- Numeric prefixes work too: `2n`, `3n`, `2p`, `3p` to jump multiple headings at once.

## Folding In Markdown

- **Toggle fold all except H1 / unfold all**: `q`
- **Toggle fold for current section heading (any level, full fold/unfold)**: `r`
- These commands are available in `Visual` mode only (markdown-local), to avoid overriding normal-mode defaults.

It also exposes explorer width commands for the shared Snacks/Neo-tree panel:

- **Set explorer width to 20**: `:ShipFlowExplorerWidth20` or `<leader>e2`
- **Set explorer width to 35**: `:ShipFlowExplorerWidth35` or `<leader>e3`
- **Set explorer width to full screen**: `:ShipFlowExplorerWidthFull` or `<leader>eF`

## Configuration

You can customize the shortcuts by modifying `lua/shipflow/init.lua`.
