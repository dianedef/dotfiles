# 📦 Fichiers du Neovim Config Switcher

## Scripts Principaux

### 🔧 `switch-config.sh`

Script principal pour changer de configuration Neovim de manière permanente via symlink.

```bash
./switch-config.sh --list        # Liste les configs
./switch-config.sh nvim11        # Change vers nvim11
./switch-config.sh --current     # Affiche la config active
```

### 🚀 `nvim-multi`

Wrapper simple pour lancer Neovim avec différentes configs.

```bash
./nvim-multi nvim11 fichier.lua  # Lance nvim11 avec fichier.lua
./nvim-multi nvim22              # Lance nvim22
```

## Fichiers de Configuration Shell

### 🔗 `aliases.sh`

Aliases simples à sourcer dans votre shell.

```bash
source /workspaces/dotfiles/nvim/aliases.sh
# Puis : nv11, nv22, nvim-switch, etc.
```

### ⚡ `shell-integration.sh`

Intégration complète avec fonctions et autocomplétion.

```bash
source /workspaces/dotfiles/nvim/shell-integration.sh
# Puis : nvims, nvim-try, etc.
```

## Documentation

### 📖 `SWITCH-README.md`

Documentation complète avec exemples et explications détaillées.

### ⚡ `QUICKSTART.txt`

Guide de démarrage rapide format ASCII art.

### 📋 `FILES.md`

Ce fichier - liste de tous les fichiers du projet.

## Structure de Répertoire

```
nvim/
├── switch-config.sh          # Script principal de changement de config
├── nvim-multi                # Wrapper pour lancer différentes configs
├── aliases.sh                # Aliases shell simples
├── shell-integration.sh      # Intégration shell complète
├── SWITCH-README.md          # Documentation complète
├── QUICKSTART.txt            # Guide de démarrage rapide
├── FILES.md                  # Ce fichier
├── init.lua                  # Config par défaut (nvim)
├── lua/                      # Modules Lua de la config par défaut
├── nvim3/                    # Configuration alternative 3
├── nvim6/                    # Configuration alternative 6
├── nvim11/                   # Configuration alternative 11
└── nvim22/                   # Configuration alternative 22
```

## Installation Recommandée

### Méthode 1 : Intégration complète (recommandé)

```bash
echo 'source /workspaces/dotfiles/nvim/shell-integration.sh' >> ~/.bashrc
source ~/.bashrc
```

### Méthode 2 : Aliases uniquement

```bash
echo 'source /workspaces/dotfiles/nvim/aliases.sh' >> ~/.bashrc
source ~/.bashrc
```

### Méthode 3 : Ajouter au PATH (pour nvim-multi)

```bash
echo 'export PATH="/workspaces/dotfiles/nvim:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Utilisation

### Changement Permanent

```bash
# Avec le script
./switch-config.sh nvim11

# Avec l'alias (après installation)
nvim-switch nvim22
```

### Utilisation Temporaire

```bash
# Avec NVIM_APPNAME
NVIM_APPNAME=nvim11 nvim

# Avec alias (après installation)
nv11

# Avec nvim-multi
./nvim-multi nvim22 fichier.lua
```

### Avec Fonctions Shell (après installation de shell-integration.sh)

```bash
nvims                    # Liste les configs
nvims nvim11            # Change et lance
nvim-try nvim22         # Teste temporairement
```

## Désinstallation

Pour revenir à une installation normale de Neovim :

```bash
rm ~/.config/nvim
# Puis restaurer votre ancienne config ou créer une nouvelle
```

## Notes Techniques

- **Symlink** : `switch-config.sh` crée un lien symbolique vers la config choisie
- **NVIM_APPNAME** : Variable d'environnement Neovim pour charger des configs alternatives
- **Data séparé** : Chaque config a son propre répertoire de données (`~/.local/share/<NVIM_APPNAME>/`)
- **Backup auto** : Les configs existantes sont automatiquement sauvegardées

## Dépannage

### Le script ne trouve pas les configs

Vérifiez les chemins dans `switch-config.sh` :

```bash
DOTFILES_DIR="/workspaces/dotfiles"
NVIM_DIR="${DOTFILES_DIR}/nvim"
```

### Les aliases ne fonctionnent pas

```bash
# Rechargez votre shell
source ~/.bashrc
# ou
source ~/.zshrc
```

### Conflit de configurations

```bash
# Voir la config active
./switch-config.sh --current

# Retour à la config par défaut
./switch-config.sh nvim
```
