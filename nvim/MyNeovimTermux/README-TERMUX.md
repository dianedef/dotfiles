# MyNeovim for Termux

Configuration Neovim légère pour Android/Termux, alignée avec le script racine `termux.sh`.

## Installation

Depuis Termux:

```bash
cd ~/dotfiles
bash termux.sh
source ~/.bashrc
```

Le script doit être lancé dans Termux, car il dépend de `pkg`.

## Ce que `termux.sh` installe

- Paquets Termux: `git`, `curl`, `wget`, `neovim`, `ripgrep`, `fd`, `fzf`, `python`, `nodejs-lts`, `gh`, `ranger`, `tree`, `termux-api`.
- Prompt et navigation: Starship dans `~/.local/bin`, Zoxide via `pkg`.
- Secrets optionnels: Doppler si compatible, sinon fichier local `~/.dotfiles-secrets.env`.
- Configs symlinkées: `nvim/MyNeovimTermux`, `termux/termux.properties`, `ranger`, `starship-simple.toml`.
- Agents CLI légers: Shell-GPT (`sgpt`) et LLM CLI (`llm`) avec plugins Gemini/Anthropic.
- Font: JetBrainsMono Nerd Font dans `~/.termux/font.ttf` si absente.

## Agents disponibles

### Shell-GPT

Commande rapide pour les prompts OpenAI:

```bash
gpt "explique cette erreur bash"
sgpt "résume ce fichier"
```

La clé OpenAI est écrite dans `~/.config/shell_gpt/.sgptrc` avec permissions `0600`.

### LLM CLI

Interface multi-provider:

```bash
ai "question"
llm -m gemini-2.0-flash "question"
llm -m claude-3-haiku "question"
chat
```

Les clés sont récupérées depuis Doppler si disponible, sinon depuis `~/.dotfiles-secrets.env`.

## Secrets locaux

Pour configurer les clés sans Doppler:

```bash
bash ~/dotfiles/doppler-setup-termux.sh
```

Le fichier généré est `~/.dotfiles-secrets.env`, avec permissions `0600`.

## Keybindings Neovim

La config Termux garde LazyVim léger. Les intégrations lourdes ne sont pas installées par défaut.

| Key | Action |
|-----|--------|
| `<leader>ai` | Aider si installé manuellement |
| `<leader>ax` | Codex-Termux si installé manuellement |
| `<leader>as` | Sheikh si installé manuellement |
| `<leader>ao` | OpenCode si installé manuellement |

Ces mappings peuvent exister côté config, mais les binaires correspondants ne sont pas installés par `termux.sh`.

## Choix volontairement exclus

- GitHub Copilot CLI.
- Aider auto-installé.
- OpenCode auto-installé.
- Neovim compilé depuis source.
- Plugins LSP lourds.

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

### Shell-GPT sans clé API

```bash
bash ~/dotfiles/doppler-setup-termux.sh
source ~/.dotfiles-secrets.env
```

### LLM CLI sans provider

```bash
llm keys set openai
llm keys set gemini
llm keys set anthropic
```

### GitHub CLI non authentifié

```bash
gh auth login
```

ou:

```bash
bash ~/dotfiles/doppler-setup-termux.sh
```
