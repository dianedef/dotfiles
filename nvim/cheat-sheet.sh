#!/usr/bin/env bash

# Neovim Config Switcher - Cheat Sheet
# Quick reference for all commands

cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════════════╗
║           NEOVIM CONFIG SWITCHER - CHEAT SHEET                            ║
╚═══════════════════════════════════════════════════════════════════════════╝

📦 INSTALLATION
─────────────────────────────────────────────────────────────────────────────
./nvim/install.sh                    # Installation automatique
source ~/.bashrc                      # Recharger le shell

🔧 COMMANDES PRINCIPALES
─────────────────────────────────────────────────────────────────────────────
./nvim/switch-config.sh --list       # Liste toutes les configurations
./nvim/switch-config.sh --current    # Affiche la config active
./nvim/switch-config.sh nvim11       # Change vers nvim11
./nvim/switch-config.sh --help       # Aide complète

🚀 ALIASES (après installation)
─────────────────────────────────────────────────────────────────────────────
nvim-switch --list                   # Liste les configs
nvim-switch nvim22                   # Change vers nvim22
nv-list                              # Liste les configs (court)
nv-current                           # Config active (court)

⚡ LANCEMENT RAPIDE (temporaire, sans changer)
─────────────────────────────────────────────────────────────────────────────
NVIM_APPNAME=nvim11 nvim             # Utilise nvim11 temporairement
nv11                                 # Alias pour nvim11
nv22 fichier.lua                     # Ouvre fichier.lua avec nvim22
nvim11 ~/.bashrc                     # Alias long pour nvim11

🎯 FONCTIONS SHELL (après installation)
─────────────────────────────────────────────────────────────────────────────
nvims                                # Liste et sélectionne
nvims nvim11                         # Change vers nvim11 et lance
nvim-try nvim22                      # Teste nvim22 temporairement
nvim-try nvim11 fichier.lua          # Teste nvim11 avec un fichier

🔨 WRAPPER MULTI-CONFIG
─────────────────────────────────────────────────────────────────────────────
./nvim/nvim-multi nvim11             # Lance nvim11
./nvim/nvim-multi nvim22 file.lua    # Lance nvim22 avec fichier

📚 DOCUMENTATION
─────────────────────────────────────────────────────────────────────────────
cat nvim/QUICKSTART.txt              # Guide rapide (ASCII art)
cat nvim/SWITCH-README.md            # Documentation complète
cat nvim/FILES.md                    # Liste des fichiers
cat nvim/cheat-sheet.sh              # Cette aide

🎨 CONFIGURATIONS DISPONIBLES
─────────────────────────────────────────────────────────────────────────────
nvim          Default (racine du dossier nvim/)
nvim3         Alternative config 3
nvim6         Alternative config 6
nvim11        Alternative config 11
nvim22        Alternative config 22

💡 EXEMPLES D'USAGE
─────────────────────────────────────────────────────────────────────────────

# Tester rapidement une config
NVIM_APPNAME=nvim11 nvim

# Changer définitivement
./nvim/switch-config.sh nvim11

# Comparer deux configs
NVIM_APPNAME=nvim11 nvim file.lua &
NVIM_APPNAME=nvim22 nvim file.lua &

# Utiliser une config juste pour un fichier
nv22 ~/.config/test.lua

# Lancer avec le wrapper
./nvim/nvim-multi nvim11 project.lua

🔍 VÉRIFICATIONS
─────────────────────────────────────────────────────────────────────────────
./nvim/switch-config.sh --current    # Quelle config est active ?
echo $NVIM_APPNAME                   # Variable d'environnement
ls -la ~/.config/nvim                # Vérifier le symlink
ls ~/.local/share/nvim*              # Voir les data directories

🛠️  PERSONNALISATION
─────────────────────────────────────────────────────────────────────────────
# Éditer les chemins
vim nvim/switch-config.sh

# Ajouter une nouvelle config
mkdir nvim/nvim99
cp nvim/init.lua nvim/nvim99/
./nvim/switch-config.sh nvim99

🐛 DÉPANNAGE
─────────────────────────────────────────────────────────────────────────────
# Retour à la config par défaut
./nvim/switch-config.sh nvim

# Voir où pointe le symlink
ls -la ~/.config/nvim

# Recharger les aliases
source ~/.bashrc

# Réinstaller
./nvim/install.sh

📋 FICHIERS CRÉÉS
─────────────────────────────────────────────────────────────────────────────
nvim/switch-config.sh                Script principal
nvim/nvim-multi                      Wrapper simple
nvim/aliases.sh                      Aliases shell
nvim/shell-integration.sh            Intégration complète
nvim/install.sh                      Script d'installation
nvim/SWITCH-README.md                Documentation complète
nvim/QUICKSTART.txt                  Guide rapide
nvim/FILES.md                        Liste des fichiers
nvim/cheat-sheet.sh                  Cette aide

═══════════════════════════════════════════════════════════════════════════

💬 Pour plus d'infos: ./nvim/switch-config.sh --help

EOF
