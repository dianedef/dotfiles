# Neovim Configuration Switcher

Ce répertoire contient plusieurs configurations Neovim que vous pouvez facilement échanger.

## 🚀 Installation

Le script d'installation fait TOUT automatiquement :

```bash
./install.sh
```

C'est tout ! Le script :

- ✅ Installe Neovim 0.10.2+
- ✅ Configure tous les liens symboliques
- ✅ Ajoute automatiquement l'intégration shell à `~/.bashrc`
- ✅ Active les commandes pour la session actuelle
- ✅ Installe tous les plugins

Après l'installation, ouvrez un nouveau terminal ou lancez `source ~/.bashrc`.

## 📦 Utilisation - Méthodes disponibles

### Méthode 1 : Aliases (Recommandée)

Les aliases sont automatiquement disponibles après l'installation :

```bash
nv              # ou nvim     → Lance config par défaut
nv11            # ou nvim11   → Lance nvim11
nv22            # ou nvim22   → Lance nvim22
nv3             # ou nvim3    → Lance nvim3
nv6             # ou nvim6    → Lance nvim6
```

### Méthode 2 : Fonction interactive

```bash
nvims           # Affiche fzf pour choisir la config
nvim-try nvim11 # Teste une config sans la rendre permanente
```

### Méthode 3 : Script direct

```bash
./switch-config.sh --list      # Lister les configurations
./switch-config.sh nvim11      # Changer vers nvim11
./switch-config.sh --current   # Voir la config actuelle
```

### Méthode 4 : Variable d'environnement

```bash
# Utiliser temporairement une config différente
NVIM_APPNAME=nvim11 nvim

# Ou l'exporter pour la session
export NVIM_APPNAME=nvim22
nvim
```

## 📂 Configurations Disponibles

- **nvim** - Configuration par défaut (racine du dossier)
- **nvim3** - Configuration alternative 3
- **nvim6** - Configuration alternative 6
- **nvim11** - Configuration alternative 11
- **nvim22** - Configuration alternative 22

> 💡 Vous pouvez ajouter de nouvelles configurations simplement en créant un dossier nommé `nvim*` (ex: `nvim-custom`, `nvim-lazy`). Le script les détectera automatiquement.

## 🔄 Comment ça marche

### Avec symlink (legacy)

Le script ancien créait un lien symbolique de la configuration choisie vers `~/.config/nvim`.

### Avec NVIM_APPNAME (recommandé)

Neovim détecte automatiquement la variable `NVIM_APPNAME` et charge la config depuis `~/.config/$NVIM_APPNAME` au lieu de `~/.config/nvim`.

## 🔄 Créer un alias

Ajoutez ceci à votre `~/.bashrc` ou `~/.zshrc` :

```bash
alias nvim-switch="/workspaces/dotfiles/nvim/switch-config.sh"

# Ou pour des accès rapides à des configs spécifiques
alias nvim11="NVIM_APPNAME=nvim11 nvim"
alias nvim22="NVIM_APPNAME=nvim22 nvim"
```

## 📋 Exemples d'utilisation

```bash
# Lister toutes les configurations
nvim-switch --list

# Passer à nvim11
nvim-switch nvim11

# Vérifier quelle config est active
nvim-switch --current

# Utiliser temporairement nvim22 sans changer de config par défaut
NVIM_APPNAME=nvim22 nvim mon-fichier.lua
```

## ⚙️ Configuration

Le script utilise les chemins suivants :

- **DOTFILES_DIR**: `/workspaces/dotfiles`
- **NVIM_DIR**: `/workspaces/dotfiles/nvim`
- **CONFIG_HOME**: `${XDG_CONFIG_HOME:-$HOME/.config}`

Vous pouvez modifier ces valeurs dans le script si nécessaire.

## 🛟 Aide

```bash
./switch-config.sh --help
```

---

## Requirements

### System config

OS: ArchLinux x86_64

WM: [hyprland](https://hyprland.org/) (Wayland compositor so you'd need a Wayland clipboard utility like [bugaevc/wl-clipboard](https://github.com/bugaevc/wl-clipboard))

Terminal: [kitty](https://github.com/kovidgoyal/kitty)

### Dependecies

`pip3 install pynvim`

#### Languages

`pacman -Syu nodejs ruby perl`

#### Tools

`pacman -Syu cmake fd ripgrep`

Open Neovim and run `:Mason` to install the LSP servers you need.
