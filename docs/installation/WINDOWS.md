# Windows installation

Run the canonical script without loading a PowerShell profile:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1 -DryRun
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1
```

Modes are `-DryRun`, `-Check`, `-Update`, and `-Uninstall`; they are mutually constrained. `-Only neovim,yazi` selects components. `-SkipTools` applies configuration without WinGet packages. `-ConfigureWezTerm` adds WezTerm. `-InstallYaziPlugins` is the only path that runs `ya pkg install`.

The checkout must have expected origin, branch, and clean worktree. Updates fetch and merge `--ff-only`; the installer never resets, stashes, or recreates a branch. WinGet failures explain the missing prerequisite. PATH reconstruction merges current process, user, and machine values.

No PowerShell profile, execution policy, credential, secret, agent, skill, MCP client, or Doppler setting is modified.
