# MyNeovim for Termux

Configuration Neovim légère pour Android/Termux, alignée avec le script racine `termux.sh`.

Objectif: édition de fichiers Markdown et de petits fichiers texte. Cette config n'est pas une station de développement web et n'installe pas d'agents IA.

## Installation

Depuis Termux:

```bash
curl -fsSL https://winflowz.com/termux-script | sh
source ~/.bashrc
```

Équivalent manuel:

```bash
git clone https://github.com/dianedef/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash termux.sh
source ~/.bashrc
```

Après cette première activation, utiliser `re` pour recharger `.bashrc`.

Le script tente de réparer automatiquement une pile Termux `curl`/OpenSSL cassée. Si `curl` ne peut même pas télécharger le script, réparer d'abord les paquets Termux:

```bash
apt update && apt full-upgrade -y
apt install --reinstall curl openssl libngtcp2 -y
```

Le bootstrap distant clone ou met à jour `~/dotfiles`, puis lance `termux.sh`. Le script doit être lancé dans Termux, car il dépend de `pkg`.

## Ce que `termux.sh` installe

- Paquets Termux: `git`, `curl`, `wget`, `neovim`, `ripgrep`, `fd`, `fzf`, `openssh`, `autossh`, `mosh`, `tmux`, `lsof`, `netcat-openbsd`, `tar`, `unzip`, `ranger`, `tree`, `termux-api`.
- Prompt et navigation: Starship dans `~/.local/bin`, Zoxide via `pkg`.
- Thèmes Termux: `termux-theme` depuis `dianedef/termux-theme`, avec alias `thermux`.
- Tunnels locaux ShipFlow: clone ou mise à jour de `~/shipflow`, puis installation des alias `urls` et `tunnel`.
- Configs symlinkées: `nvim/MyNeovimTermux`, `termux/termux.properties`, `ranger`, `starship-simple.toml`.
- Font: JetBrainsMono Nerd Font dans `~/.termux/font.ttf` si absente.

## Keybindings Neovim

La config Termux utilise `lazy.nvim` avec une whitelist courte: `snacks.nvim`, `vim-pencil`, `nvim-surround`, `gitsigns.nvim`, `markdown.nvim`. Elle n'importe pas LazyVim complet: pas de Mason, pas de LSP, pas d'installation automatique d'outils Python/Node.

Au premier lancement de `nvim`, seuls ces plugins légers peuvent être téléchargés. Les anciens dossiers LazyVim/Mason sont nettoyés par `termux.sh`.

| Key | Action |
|-----|--------|
| `<leader>H` | Ouvrir/fermer cette aide Termux |
| `<leader>es` / `<leader>eS` | Explorer Snacks cwd / root |
| `<leader>bf` | Chercher les buffers |
| `<leader>w-` / `<leader>w|` | Split horizontal / vertical |
| `<leader>th` / `<leader>tv` | Terminal horizontal / vertical |
| `zF` | Plier/déplier le front matter Markdown |
| `z2`..`z5` | Régler le niveau de fold Markdown |
| `zh` | Sauter au prochain titre Markdown |
| Visual `n` / `p` | Titre H2/H3 suivant / précédent |

## Thèmes Termux

Le script installe `termux-theme`:

```bash
thermux
thermux sim
termux-theme
```

`thermux` est un alias vers `termux-theme`.

## Choix volontairement exclus

- Stack web / Node.js.
- MCP.
- Agents IA Neovim et CLI.
- GitHub Copilot CLI.
- Claude, Codex, Aider, OpenCode.
- Neovim compilé depuis source.
- Plugins LSP lourds.
- Plugins avec build natif ou dépendances web.
- Installateurs automatiques d'outils externes type Mason.
- Plugins hors whitelist Termux.

Objectif: garder une installation utilisable sur Android, avec peu de RAM et de stockage.

## Icônes

Après installation de `~/.termux/font.ttf`, il faut redémarrer complètement Termux:

1. Forcer l'arrêt de l'app Termux dans Android.
2. Rouvrir Termux.
3. Lancer `nvim`.

Si les icônes ne s'affichent pas, utiliser l'app officielle `Termux:Styling` depuis F-Droid.

## Troubleshooting

### `pkg` introuvable

Le script n'est pas lancé dans Termux. Utiliser `install.sh` pour Linux/Codespaces.

### Besoin d'outils de dev, agents ou GitHub CLI

Utiliser la config principale sur Linux/Codespaces avec `bash install.sh`.
