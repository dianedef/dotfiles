# Dotfiles

Cross-platform terminal configuration for native Windows and Linux. The installed runtime defaults to `~/.dotfiles`; an editable development clone may live at `~/ShipGlows/dotfiles`.

Dotfiles owns terminal tools/configuration: Neovim, Starship, Zoxide, fzf, ripgrep, fd, bat, Yazi, and selected terminals. ShipGlows separately owns developer provisioning, AI agents, skills, MCP client runtime/configuration, Doppler, and project toolchains. Termux retains its dedicated unchanged workflow.

Start with a preview:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1 -DryRun
```

```bash
./install-dotfiles.sh --dry-run
```

Both engines read `dotfiles/components.tsv`. They validate selections, preserve conflicts in central backups, and journal managed artifacts. Check is read-only; update accepts only a clean matching checkout and fast-forward; uninstall removes only journal-proven artifacts, restores backups, and never removes packages.

Yazi is modern/default on Windows and Linux. Ranger is available only as explicit Linux component `ranger-legacy`. See [documentation](docs/INDEX.md).
