# Quick start

Use an editable clone for development and `~/.dotfiles` for the installed runtime. Preview first.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1 -DryRun
```

```bash
git clone https://github.com/commandglows/dotfiles.git "$HOME/.dotfiles"
"$HOME/.dotfiles/dotfiles/install-dotfiles.sh" --dry-run
```

Remove dry-run only after reviewing the plan. Use `Only`/`--only` for comma-separated manifest IDs. Yazi is default; Ranger requires `--only ranger-legacy` on Linux.

Existing targets move into the platform state directory before replacement. Uninstall restores backups only when the current artifact still matches its ownership proof. Packages remain installed.
