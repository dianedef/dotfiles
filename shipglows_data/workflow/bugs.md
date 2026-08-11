# Bugs

| ID | Status | Severity | Title | Last tested | Next step |
|---|---|---|---|---|---|
| BUG-2026-05-03-001 | fixed | medium | Neovim AI agents ask for confirmations despite autonomous user config | 2026-05-03 | Shipped fix |
| BUG-2026-05-03-002 | fixed-pending-verify | high | Installer symlink replacement can delete existing user config targets | 2026-05-03 | Optional real-device Termux retest |
| BUG-2026-05-04-001 | fix-attempted | medium | Avante crashes on invalid buffer after plugin reload | 2026-05-04 | `/sf-test --retest BUG-2026-05-04-001` |
| BUG-2026-05-23-001 | fixed-pending-verify | medium | Termux leaves a black unused area above the keyboard | 2026-05-23 | Real-device Termux retest after rerunning bootstrap |
| BUG-2026-05-23-002 | fixed-pending-verify | medium | Termux bootstrap fails when local dotfiles files are dirty | 2026-05-23 | Real-device Termux retest after rerunning bootstrap |
| BUG-2026-07-13-001 | fixed-pending-verify | medium | Mail Intelligence restores an ACP session with a stale Codex model | 2026-07-13 | `/107-sg-test --retest BUG-2026-07-13-001 in Mail Intelligence` |
| BUG-2026-07-13-002 | fixed-pending-verify | high | Avante leaves native Codex ACP processes orphaned after stopping its Node wrapper | 2026-07-13 | `/103-sg-verify BUG-2026-07-13-002` |
| BUG-2026-08-09-001 | closed | high | Fresh user-local install aborts in shell integration and misreports installed tools | 2026-08-09 | Shipped fix |
