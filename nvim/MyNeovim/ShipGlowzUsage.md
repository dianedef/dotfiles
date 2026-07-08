# ShipGlowz Plugin for NeoVim

ShipGlowz is a NeoVim helper module that allows users to navigate between Markdown headings and control the shared explorer panel width with compact shortcuts.

## Installation

The module lives in this config at:

```text
lua/shipglowz/init.lua
```

It is loaded from `lua/config/keymaps.lua` with `require("shipglowz").setup()`.

## Usage

Once loaded, ShipGlowz provides the following default shortcuts for navigating between headers:

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

It also exposes panel size presets for the current panel:

- **Panel size 1**: `:ShipGlowzPanel1` or `<leader>w1`
- **Panel size 2**: `:ShipGlowzPanel2` or `<leader>w2`
- **Panel size 3**: `:ShipGlowzPanel3` or `<leader>w3`
- **Panel full size**: `:ShipGlowzPanelFull` or `<leader>wF`

The panel commands detect the current context: explorer panels keep the shared
explorer widths, Avante keeps its vertical/horizontal presets, and other windows
resize by width or height depending on their layout.

## Configuration

You can customize the shortcuts by modifying `lua/shipglowz/init.lua`.
