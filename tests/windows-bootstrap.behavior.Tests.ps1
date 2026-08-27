$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $root 'install-dotfiles.ps1'
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('dotfiles-windows-' + [Guid]::NewGuid().ToString('N'))
$checkout = Join-Path $fixture '.dotfiles'; $state = Join-Path $fixture 'state'
$originalUserProfile = $env:USERPROFILE
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
try {
    & $installer -DryRun -Only neovim -DotfilesDir $checkout -StateDir $state
    if (Test-Path $checkout) { throw 'dry-run created checkout' }; if (Test-Path $state) { throw 'dry-run created state' }
    $codexPlan = @(& $installer -DryRun -Only codex-acp -DotfilesDir $checkout -StateDir $state 6>&1 | Out-String)
    if ($codexPlan -notmatch '@zed-industries/codex-acp@0\.16\.0') { throw 'Codex ACP dry-run does not expose the pinned Node package' }
    if ($codexPlan -notmatch 'codex-acp-win32-(x64|arm64)') { throw 'Codex ACP dry-run does not expose the required native Windows runtime' }
    if (Test-Path $state) { throw 'Codex ACP dry-run created state' }
    $failed=$false;try{& $installer -DryRun -Only invalid-component -DotfilesDir $checkout -StateDir $state}catch{$failed=$true};if(-not $failed){throw 'invalid component accepted'}
    $failed=$false;try{& $installer -DryRun -Check -DotfilesDir $checkout -StateDir $state}catch{$failed=$true};if(-not $failed){throw 'incompatible modes accepted'}
    $env:USERPROFILE = $fixture
    $starshipTarget = Join-Path $fixture '.config\starship.toml'
    New-Item -ItemType Directory -Path (Split-Path -Parent $starshipTarget) -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot '..\starship\starship.toml') -Destination $starshipTarget
    $plan = @(& $installer -DryRun -Only starship -DotfilesDir $checkout -StateDir $state 6>&1 | Out-String)
    if ($plan -match 'would install starship') { throw 'dry-run planned an already-converged copy' }
    'Windows behavior contracts: OK'
} finally { $env:USERPROFILE = $originalUserProfile; Remove-Item -LiteralPath $fixture -Recurse -Force -ErrorAction SilentlyContinue }
