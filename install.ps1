# Requires -RunAsAdministrator

# Install applications
Write-Host "Installing applications..." -ForegroundColor Cyan

# Browsers and Development
Write-Host "Installing Vivaldi Browser..." -ForegroundColor Yellow
winget install VivaldiTechnologies.Vivaldi

Write-Host "Installing Firefox Developer Edition..." -ForegroundColor Yellow
winget install Mozilla.Firefox.DeveloperEdition

Write-Host "Installing Cursor IDE..." -ForegroundColor Yellow
winget install Cursor.Cursor

Write-Host "Installing Wezterm..." -ForegroundColor Yellow
winget install wez.wezterm

Write-Host "Installing Git Bash..." -ForegroundColor Yellow
winget install Git.Git

Write-Host "Installing MSYS2..." -ForegroundColor Yellow
winget install MSYS2.MSYS2

Write-Host "Installing GitHub CLI..." -ForegroundColor Yellow
winget install GitHub.cli

Write-Host "Installing Python..." -ForegroundColor Yellow
winget install Python.Python.3.11

Write-Host "Installing Node.js..." -ForegroundColor Yellow
winget install OpenJS.NodeJS.LTS

Write-Host "Installing pnpm..." -ForegroundColor Yellow
winget install pnpm.pnpm

Write-Host "Installing Cloudflared..." -ForegroundColor Yellow
winget install Cloudflare.cloudflared

Write-Host "Installing Aider..." -ForegroundColor Yellow
pip install aider-chat

Write-Host "Installing Pinokio..." -ForegroundColor Yellow
winget install Pinokio.Pinokio

Write-Host "Installing LMStudio..." -ForegroundColor Yellow
winget install LMStudio.LMStudio

Write-Host "Installing Windsurf Editor..." -ForegroundColor Yellow
winget install Windsurf.Editor

Write-Host "Installing Trae Editor..." -ForegroundColor Yellow
winget install Trae.Editor

Write-Host "Installing LazyVim..." -ForegroundColor Yellow
git clone https://github.com/LazyVim/starter $env:LOCALAPPDATA\nvim-lazy
Move-Item -Path "$env:LOCALAPPDATA\nvim-lazy\*" -Destination "$env:LOCALAPPDATA\nvim" -Force
Remove-Item -Path "$env:LOCALAPPDATA\nvim-lazy" -Force -Recurse

Write-Host "Installing Nerd Fonts..." -ForegroundColor Yellow
winget install nerdfonts

# System Utilities
Write-Host "Installing 7-Zip..." -ForegroundColor Yellow
winget install 7zip.7zip

Write-Host "Installing ImageMagick..." -ForegroundColor Yellow
winget install ImageMagick.ImageMagick

Write-Host "Installing Poppler..." -ForegroundColor Yellow
winget install poppler.poppler

Write-Host "Installing Preme for Windows..." -ForegroundColor Yellow
winget install WorkMan.Preme

Write-Host "Installing Wedge..." -ForegroundColor Yellow
winget install Wedge.Wedge

Write-Host "Installing Everything Search..." -ForegroundColor Yellow
winget install voidtools.Everything

Write-Host "Installing SpaceSniffer..." -ForegroundColor Yellow
winget install Uderzo.SpaceSniffer

Write-Host "Installing Preview64..." -ForegroundColor Yellow
winget install JohnMacFarlane.Preview64

# File Management and Utilities
Write-Host "Installing XYPlorer..." -ForegroundColor Yellow
winget install XYplorer.XYplorer

Write-Host "Installing ShareX..." -ForegroundColor Yellow
winget install ShareX.ShareX

Write-Host "Installing IceDrive..." -ForegroundColor Yellow
winget install Icedrive.Icedrive

# Document Viewers and Editors
Write-Host "Installing Sumatra PDF..." -ForegroundColor Yellow
winget install SumatraPDF.SumatraPDF

Write-Host "Installing UPDF..." -ForegroundColor Yellow
winget install Superace.UPDF

Write-Host "Installing Obsidian..." -ForegroundColor Yellow
winget install Obsidian.Obsidian

# Media and Entertainment
Write-Host "Installing PotPlayer..." -ForegroundColor Yellow
winget install Daum.PotPlayer

Write-Host "Installing HandBrake..." -ForegroundColor Yellow
winget install HandBrake.HandBrake

Write-Host "Installing Foobar2000..." -ForegroundColor Yellow
winget install PeterPawlowski.foobar2000

Write-Host "Installing Deezer..." -ForegroundColor Yellow
winget install Deezer.Deezer

Write-Host "Installing Audacity..." -ForegroundColor Yellow
winget install Audacity.Audacity

# Download and Torrents
Write-Host "Installing qBittorrent 4.6.0..." -ForegroundColor Yellow
winget install qBittorrent.qBittorrent --version 4.6.0

# Configuration paths
$CONFIG_PATHS = @{
    "nvim" = @{
        "source" = "$HOME\dotfiles\nvim"
        "target" = "$env:LOCALAPPDATA\nvim"
    }
    "yazi" = @{
        "source" = "$HOME\dotfiles\yazi1"
        "target" = "$env:APPDATA\yazi"
    }
    # Add more configurations here as needed
}

# Function to create symbolic link
function Create-SymLink {
    param (
        [string]$Source,
        [string]$Target
    )
    
    # Remove existing target if it exists
    if (Test-Path $Target) {
        Write-Host "Backing up existing $Target to ${Target}.backup"
        Move-Item -Path $Target -Destination "${Target}.backup" -Force
    }

    # Create parent directory if it doesn't exist
    $ParentDir = Split-Path -Parent $Target
    if (-not (Test-Path $ParentDir)) {
        New-Item -ItemType Directory -Path $ParentDir -Force
    }

    # Create symbolic link
    Write-Host "Creating symlink: $Target -> $Source"
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force
}

# Main installation
Write-Host "Starting dotfiles installation..." -ForegroundColor Green

foreach ($config in $CONFIG_PATHS.GetEnumerator()) {
    Write-Host "`nInstalling $($config.Key) configuration..." -ForegroundColor Cyan
    Create-SymLink -Source $config.Value.source -Target $config.Value.target
}

Write-Host "`nInstallation complete!" -ForegroundColor Green 