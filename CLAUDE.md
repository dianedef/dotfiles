# Repository guidance

This repository owns personal terminal dotfiles and terminal-tool installation on native Windows and Linux. ShipGlows owns AI agents, skills, MCP runtime/client configuration, Doppler, and broader developer provisioning. Do not add those concerns back to Dotfiles installers.

Canonical engines are `install-dotfiles.ps1` and `dotfiles/install-dotfiles.sh`; both consume `dotfiles/components.tsv`. Compatibility entrypoints remain thin shims. Keep Termux independent and unchanged unless explicitly scoped.

Safety invariants: dry-run makes no changes, check is read-only, checkout updates are clean-origin-verified fast-forwards, conflicts are backed up centrally, and uninstall acts only on journal-proven artifacts. Never reset/stash user work, pipe downloads into a shell, modify execution policy or PowerShell profiles, expose secrets, or remove packages during uninstall.
