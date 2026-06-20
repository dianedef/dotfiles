<h1 align="center">Welcome to my Neovim IDE Layer 👋</h1>
<p>
</p>

![screenshot](https://user-images.githubusercontent.com/57322459/216741256-de0ac4fc-bda9-44fa-aac4-83413baaae7e.png)

The template is from ~~[LunarVim/Neovim-from-scratch](https://github.com/LunarVim/Neovim-from-scratch)~~ [nvim-starter-kit](https://github.com/bcampolo/nvim-starter-kit). Structure updated for [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

### System config

OS: ArchLinux x86_64

WM: [hyprland](https://hyprland.org/) (Wayland compositor so you'd need a Wayland clipboard utility like [bugaevc/wl-clipboard](https://github.com/bugaevc/wl-clipboard))

Terminal: [kitty](https://github.com/kovidgoyal/kitty)

### Dependecies

`pip3 install pynvim`

#### Languages

`pacman -Syu nodejs ruby perl`

#### Tools

`pacman -Syu cmake fd ripgrep`

Open Neovim and run `:Mason` to install the LSP servers you need.

## Git review

`Neogit` stays the staging and unstaging control surface.

`DiffFlowz` opens a single-column Difftastic review of the repo changes:
use `:DiffFlowz` or `<leader>gT` for working-tree changes, `:DiffFlowzStaged`
for staged changes, and `:DiffFlowzClose` to close the view. The diff is
rendered inline, so you review one combined output instead of two panes.

`:Difftastic` and `<leader>gt` remain a syntax-aware preview for the current
file. It is still a terminal renderer, so it is not the editable source of
truth for the diff view.
