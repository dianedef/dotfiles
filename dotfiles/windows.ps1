# Compatibility shim. A bare legacy invocation is preview-only.
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments = $true)][object[]]$RemainingArgs)
$installer = Join-Path (Split-Path -Parent $PSScriptRoot) 'install-dotfiles.ps1'
if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Canonical installer not found: $installer" }
$forward = @($RemainingArgs | ForEach-Object { [string]$_ })
if ($forward.Count -eq 0) { $forward = @('-DryRun') }
& $installer @forward
exit $LASTEXITCODE
