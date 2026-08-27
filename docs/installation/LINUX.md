# Linux installation

Clone explicitly, then invoke the in-repository Bash engine:

```bash
git clone https://github.com/dianedef/dotfiles.git "$HOME/.dotfiles"
"$HOME/.dotfiles/dotfiles/install-dotfiles.sh" --dry-run
"$HOME/.dotfiles/dotfiles/install-dotfiles.sh"
```

Modes are `--dry-run`, `--check`, `--update`, `--uninstall`, and `--only id,id`. Windows/MSYS is refused with a PowerShell handoff; Termux is refused with its dedicated installer named. Package installation explicitly supports apt, dnf, pacman, zypper, and Homebrew. Root runs commands directly; non-root needs `sudo`. Unmapped packages are reported and never replaced by implicit remote-script execution.

The installer changes user config plus explicitly selected packages. It does not provision servers, users, services, agents, MCP clients, Doppler, or secrets. Shell integration is a marked Bash block with journal ownership. Uninstall removes only proven links, copies, and blocks, restores backups, and leaves packages installed.
