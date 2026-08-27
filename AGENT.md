# Agent context

Read `CLAUDE.md`, `docs/INDEX.md`, and the active spec before changing installer behavior. Keep Windows and Linux aligned through `dotfiles/components.tsv`, using native PowerShell and Bash engines.

Do not conflate installed runtime (`~/.dotfiles`) and editable clone (`~/ShipGlows/dotfiles`). Preserve user data, reject ambiguous ownership, and leave Termux untouched unless explicitly scoped.
