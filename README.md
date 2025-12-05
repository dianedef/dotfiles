# My Dotfiles

- Neovim for code editing
- Yazi as terminal file manager
- PowerShell with Starship prompt
- FZF, Ripgrep, and Zoxide for navigation

<!-- toc -->

- [Windows Installation](#quick-installation)
- [Technical Details](#technical-details)
  - [Installation Process](#installation-process)
  - [File Locations](#file-locations)
- [Neovim Setup](#neovim-setup)
- [Yazi File Manager](#yazi-file-manager)
- [Maintenance](#maintenance)
- [Credits](#credits)

<!-- tocstop -->

## Windows Installation

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
   git clone https://github.com/dianedef/dotfiles.git $HOME/dotfiles

   # Run installation script (as administrator)
   Set-ExecutionPolicy Bypass -Scope Process -Force
   $HOME/dotfiles/install.ps1
   ```

### Installation Process Details

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

## Neovim Setup

- Full development environment
- Custom keybindings and plugins
- Optimized for Windows

## Yazi File Manager

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

## Credits

[The Youtube Inspiration behind this repo](https://youtu.be/G27MHyT-u2I)

<div align="left">
    <a href=" https://youtu.be/G27MHyT-u2I ">
        <img
          src="./assets/img/imgs/250218-thux-snacks-image.avif"
          alt=" Images in Neovim | Setting up Snacks Image and Comparing it to Image.nvim "
          width="400"
        />
    </a>
</div>