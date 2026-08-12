# WezTerm workflow

WezTerm is the native Windows equivalent of the former tmux workflow. Its
workspaces replace tmux sessions; its tabs replace tmux windows. Pane process
names are supplied by the program itself, while the tab bar automatically adds
the active directory. Use the manual tab-name shortcut when a durable label is
more useful.

| Old tmux action | WezTerm shortcut |
| --- | --- |
| Prefix | `Ctrl+W` |
| Horizontal split | `Ctrl+W`, then `|` or `%` |
| Vertical split | `Ctrl+W`, then `-` or `"` |
| Move between panes | `Ctrl+W`, then `h`/`j`/`k`/`l` |
| Resize pane | `Ctrl+W`, then `Shift+H`/`J`/`K`/`L` |
| New tab at home | `Ctrl+W`, then `c` |
| List/switch workspaces | `Ctrl+W`, then `w` |
| Create or switch workspace | `Ctrl+W`, then `s` |
| Name the current tab | `Ctrl+W`, then `,` |
| Open a fresh Codex pane | `Ctrl+W`, then `Shift+R` |

`Shift+R` deliberately opens Codex in a new pane. It never replaces or closes
the active pane, so an existing conversation remains available if Codex cannot
start.

Yazi preserves the old Ranger `Shift+S` behavior: it opens PowerShell on
Windows or the configured shell on Unix in Yazi's current directory. Exit that
shell to return to Yazi.

On Windows, `y` is also a PATH shortcut for Yazi in ordinary PowerShell and
WezTerm. Open a new terminal after the Dotfiles installation so Windows reads
the updated user PATH.

WezTerm does not use tmux-resurrect files. Workspaces, tabs and panes live in
the active WezTerm multiplexer; keep a WezTerm window open when you need a
long-running workspace to stay available.
