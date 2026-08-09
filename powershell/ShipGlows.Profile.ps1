# Loaded by WezTerm with ExecutionPolicy Bypass. This deliberately avoids the
# system PowerShell profile so it also works on managed hosts such as Shadow.

$starship = Get-Command starship.exe -CommandType Application -ErrorAction SilentlyContinue
if ($starship) {
    $env:STARSHIP_CONFIG = Join-Path $env:USERPROFILE '.config\starship.toml'
    Invoke-Expression (& $starship.Source init powershell)
}

$zoxide = Get-Command zoxide.exe -CommandType Application -ErrorAction SilentlyContinue
if ($zoxide) { Invoke-Expression (& $zoxide.Source init powershell) }

function n { & nvim.exe @args }
function r { & yazi.exe @args }
function re { . $PSCommandPath }
function ch {
    Clear-Host
    Clear-History -ErrorAction SilentlyContinue
}
