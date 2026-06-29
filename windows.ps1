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

Write-Host "Installing Rio Terminal..." -ForegroundColor Yellow
winget install raphaelamorim.rio

Write-Host "Installing Git Bash..." -ForegroundColor Yellow
winget install Git.Git

Write-Host "Installing MSYS2..." -ForegroundColor Yellow
winget install MSYS2.MSYS2

Write-Host "Installing GitHub CLI..." -ForegroundColor Yellow
winget install GitHub.cli

Write-Host "Installing fzf..." -ForegroundColor Yellow
winget install junegunn.fzf

Write-Host "Installing Python..." -ForegroundColor Yellow
winget install Python.Python.3.11

Write-Host "Installing Node.js..." -ForegroundColor Yellow
winget install OpenJS.NodeJS.LTS

Write-Host "Installing pnpm..." -ForegroundColor Yellow
winget install pnpm.pnpm

# Wait for pnpm/npm to be available after Node.js installation
Write-Host "Waiting for pnpm/npm to be available..." -ForegroundColor Yellow
Start-Sleep -Seconds 5
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verify pnpm is installed
if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    Write-Host "Installing CLI tools via pnpm..." -ForegroundColor Yellow
    
    Write-Host "Installing GitHub Copilot CLI..." -ForegroundColor Yellow
    pnpm add -g @github/copilot
    
    Write-Host "Installing OpenCode AI..." -ForegroundColor Yellow
    pnpm add -g opencode-ai
    
    Write-Host "CLI tools installed via pnpm (update with: pnpm update -g)" -ForegroundColor Green
} else {
    Write-Host "pnpm not found, skipping CLI tools installation" -ForegroundColor Red
}

Write-Host "Installing Cloudflared..." -ForegroundColor Yellow
winget install Cloudflare.cloudflared

Write-Host "Installing Doppler CLI..." -ForegroundColor Yellow
winget install doppler

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
    "starship" = @{
        "source" = "$HOME\dotfiles\starship\starship.toml"
        "target" = "$HOME\.config\starship.toml"
    }
    "wezterm" = @{
        "source" = "$HOME\dotfiles\wezterm"
        "target" = "$HOME\.config\wezterm"
    }
    "rio" = @{
        "source" = "$HOME\dotfiles\rio\config.toml"
        "target" = "$env:APPDATA\rio\config.toml"
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

# Add aliases to PowerShell profile
Write-Host "`nConfiguring PowerShell aliases..." -ForegroundColor Cyan

$ProfilePath = $PROFILE.CurrentUserAllHosts
$ProfileDir = Split-Path -Parent $ProfilePath

# Create profile directory if it doesn't exist
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
}

# Create or append to profile
if (-not (Test-Path $ProfilePath)) {
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
}

# Add aliases if not already present
$aliasContent = @"

# Installation shortcuts
Set-Alias -Name i -Value "$HOME\dotfiles\windows.ps1"
function ds { & "$HOME\dotfiles\doppler-setup.sh" }

# File manager aliases
Set-Alias -Name r -Value ranger
"@

if (-not (Get-Content $ProfilePath -ErrorAction SilentlyContinue | Select-String "File manager aliases")) {
    Add-Content -Path $ProfilePath -Value $aliasContent
    Write-Host "Added file manager aliases to PowerShell profile" -ForegroundColor Green
} else {
    Write-Host "File manager aliases already exist in PowerShell profile" -ForegroundColor Yellow
}

# --- GitHub CLI Authentication (with Doppler fallback) ---
Write-Host "`n🔐 Setting up GitHub CLI..." -ForegroundColor Cyan

# Try 1: Doppler token (automated)
$ghAuthenticated = $false
if (Get-Command doppler -ErrorAction SilentlyContinue) {
    try {
        $null = doppler me 2>&1
        $dopplerWorking = $?
        
        if ($dopplerWorking) {
            $ghToken = doppler secrets get GH_TOKEN --plain 2>$null
            if (-not $ghToken) {
                $ghToken = doppler secrets get GITHUB_TOKEN --plain 2>$null
            }
            
            if ($ghToken) {
                Write-Host "Authenticating with Doppler token..." -ForegroundColor Yellow
                echo $ghToken | gh auth login --with-token 2>&1 | Out-Null
                
                $null = gh auth status 2>&1
                if ($?) {
                    Write-Host "✅ GitHub authenticated via Doppler" -ForegroundColor Green
                    $ghAuthenticated = $true
                }
                else {
                    Write-Host "⚠️ Doppler token failed" -ForegroundColor Yellow
                }
            }
        }
    }
    catch {
        # Doppler not configured, skip
    }
}

# Try 2: Already authenticated
if (-not $ghAuthenticated) {
    $null = gh auth status 2>&1
    if ($?) {
        Write-Host "✅ GitHub already authenticated" -ForegroundColor Green
        $ghAuthenticated = $true
    }
}

# Try 3: Manual login (interactive fallback)
if (-not $ghAuthenticated) {
    Write-Host "⚠️ GitHub not authenticated" -ForegroundColor Yellow
    Write-Host "📝 Setup Doppler with GH_TOKEN or run: gh auth login" -ForegroundColor Cyan
    
    $authNow = Read-Host "Authenticate now? (y/N)"
    if ($authNow -eq "y" -or $authNow -eq "Y") {
        gh auth login
    }
}

Write-Host "`n🎊 Installation complete!" -ForegroundColor Green
