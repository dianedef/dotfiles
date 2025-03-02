# My Windows Dotfiles

## Repo Overview

- This repo contains my current Windows dotfiles
- My daily driver is Windows 11 and my editor of choice is Neovim
- My environment is highly customized and adapted to my workflow, using several open source tools including:
  - Neovim for code editing
  - Yazi as terminal file manager
  - PowerShell with Starship prompt
  - FZF, Ripgrep, and Zoxide for navigation
- If you don't understand something in my dotfiles, I probably have a detailed YouTube video explaining it
- Sneak peek of my setup below:

<div align="left">
  <img
    src="./assets/img/setup.png"
    alt="Preview of my Windows setup"
    width="800"
  />
</div>

<!-- toc -->

- [Repo Overview](#repo-overview)
- [Quick Installation](#quick-installation)
- [Technical Details](#technical-details)
  - [Installation Process](#installation-process)
  - [File Locations](#file-locations)
- [What's Inside](#whats-inside)
  - [Neovim Setup](#neovim-setup)
  - [Yazi File Manager](#yazi-file-manager)
- [Maintenance](#maintenance)
- [Follow Me on Social Media](#follow-me-on-social-media)
- [Support My Work](#support-my-work)
- [My Content](#my-content)
- [Notes](#notes)

<!-- tocstop -->

## Quick Installation

1. **Install Required Tools**
   ```powershell
   # Run in PowerShell as administrator
   winget install Git.Git
   winget install Neovim.Neovim
   winget install Starship.Starship
   winget install junegunn.fzf
   winget install sharkdp.fd
   winget install BurntSushi.ripgrep.MSVC
   winget install ajeetdsouza.zoxide
   winget install mpv.mpv
   winget install qBittorrent.qBittorrent --version 4.6.0
   ```

2. **Clone and Install**
   ```powershell
   # Clone repository
   git clone https://github.com/Shadow/dotfiles.git $HOME/dotfiles

   # Run installation script (as administrator)
   Set-ExecutionPolicy Bypass -Scope Process -Force
   $HOME/dotfiles/install.ps1
   ```

## Technical Details

### Installation Process
The `install.ps1` script manages the dotfiles installation through several steps:

1. **Administrator Check**
   ```powershell
   # Requires -RunAsAdministrator
   ```
   The script requires administrator privileges to create symbolic links.

2. **Configuration Mapping**
   ```powershell
   $CONFIG_PATHS = @{
       "nvim" = @{
           "source" = "$HOME\dotfiles\nvim"
           "target" = "$env:LOCALAPPDATA\nvim"
       }
       "yazi" = @{
           "source" = "$HOME\dotfiles\yazi1"
           "target" = "$env:APPDATA\yazi"
       }
   }
   ```
   Defines the source and target paths for each configuration.

3. **Backup Process**
   - Checks if target configuration exists
   - If found, creates a `.backup` copy
   - Example: `$env:LOCALAPPDATA\nvim` → `$env:LOCALAPPDATA\nvim.backup`

4. **Directory Structure**
   - Creates any missing parent directories
   - Uses native PowerShell directory handling
   - Ensures clean installation

5. **Symbolic Links**
   - Creates Windows symbolic links using `New-Item`
   - Links point from system locations to dotfiles repository
   - Example: `$env:APPDATA\yazi` → `$HOME\dotfiles\yazi1`

### File Locations

#### Neovim Configuration
- Source: `$HOME\dotfiles\nvim`
- Target: `$env:LOCALAPPDATA\nvim`
- Contains: init.lua, plugins, keymaps

#### Yazi Configuration
- Source: `$HOME\dotfiles\yazi1`
- Target: `$env:APPDATA\yazi`
- Contains: yazi.toml, keymap.toml, theme settings

## What's Inside

### Neovim Setup
- Full development environment
- Custom keybindings and plugins
- Optimized for Windows

### Yazi File Manager
Modern terminal file manager with:
- Smart directory navigation (zoxide)
- Git status integration
- File previews (including Markdown)
- Archive handling
- Catppuccin Frappé theme

#### Yazi Key Bindings
- Navigation: `u`/`e` (up/down), `U`/`E` (5 lines)
- Files: `o` (create), `d d` (delete), `y y` (copy)
- Tools: `w` (shell), `W` (tasks)

## Maintenance

To update the dotfiles:
```powershell
cd $HOME/dotfiles
git pull
```

To reinstall/update symlinks:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
$HOME/dotfiles/install.ps1
```

## Follow Me on Social Media

- [Twitter](https://twitter.com/Shadow)
- [LinkedIn](https://linkedin.com/in/Shadow)
- [GitHub](https://github.com/Shadow)
- [YouTube](https://youtube.com/@Shadow)

## Support My Work

If you appreciate my work and would like to support me:

- 🌟 Star this repo
- 📺 Subscribe to my YouTube channel
- 💖 Share my content

## My Content

### Latest Videos

<div align="left">
    <a href="https://youtube.com/@Shadow">
        <img
          src="./assets/img/thumbnail1.png"
          alt="Windows Terminal Setup"
          width="400"
        />
    </a>
</div>

## Some of my YouTube videos

[The Power User's 2025 Guide to macOS ricing - Yabai, Simple-bar, SketchyBar, Fastfetch, Btop & More](https://youtu.be/8pqFtkQip4I)

<div align="left">
    <a href=" https://youtu.be/8pqFtkQip4I ">
        <img
          src="./assets/img/imgs/250120-macos-ricing-link.avif"
          alt=" The Power User's 2025 Guide to macOS ricing | Yabai, Simple-bar, SketchyBar, Fastfetch, Btop & More "
          width="400"
        />
    </a>
</div>

---

[How I Recreated (and Improved) My Obsidian Note-Taking Workflow in Neovim](https://youtu.be/k_g8q5JeisY)

<div align="left">
    <a href=" https://youtu.be/k_g8q5JeisY ">
        <img
          src="./assets/img/imgs/250220-thux-neovim-like-obsidian.avif"
          alt=" How I Recreated (and Improved) My Obsidian Note-Taking Workflow in Neovim "
          width="400"
        />
    </a>
</div>

---

[Images in Neovim - Setting up Snacks Image and Comparing it to Image.nvim](https://youtu.be/G27MHyT-u2I)

<div align="left">
    <a href=" https://youtu.be/G27MHyT-u2I ">
        <img
          src="./assets/img/imgs/250218-thux-snacks-image.avif"
          alt=" Images in Neovim | Setting up Snacks Image and Comparing it to Image.nvim "
          width="400"
        />
    </a>
</div>

---
### Featured Articles

- [Complete Guide to Neovim Setup on Windows](https://blog.shadow.com/neovim-windows)
- [Advanced Yazi Customization](https://blog.shadow.com/yazi-customization)

## Notes
- Backup your existing configurations before installing
- Some features require administrator privileges
- Report any Windows-specific issues via GitHub issues