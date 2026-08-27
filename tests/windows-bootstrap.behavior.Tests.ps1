$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $root 'install-dotfiles.ps1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('dotfiles-windows-' + [Guid]::NewGuid().ToString('N'))
$checkout = Join-Path $fixture '.dotfiles'; $state = Join-Path $fixture 'state'
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
try {
    & $installer -DryRun -Only neovim -DotfilesDir $checkout -StateDir $state
    if (Test-Path $checkout) { throw 'dry-run created checkout' }; if (Test-Path $state) { throw 'dry-run created state' }
    $failed=$false;try{& $installer -DryRun -Only invalid-component -DotfilesDir $checkout -StateDir $state}catch{$failed=$true};if(-not $failed){throw 'invalid component accepted'}
    $failed=$false;try{& $installer -DryRun -Check -DotfilesDir $checkout -StateDir $state}catch{$failed=$true};if(-not $failed){throw 'incompatible modes accepted'}
    'Windows behavior contracts: OK'
} finally { Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue }
