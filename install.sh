#!/bin/bash
#
## Le script sera exécuté par Codespaces dans votre répertoire ~/dotfiles.
#
## --- 1. Installation des Dépendances Linux (Applications) ---
#echo "Installing required Linux applications..."
#
## Mettre à jour et installer les outils de base (Codespace a déjà beaucoup de choses)
#sudo apt-get update
#sudo apt-get install -y \
#  git \
#    curl \
#      wget \
#        unzip \
#          build-essential \
#            python3-pip \
#              xclip  # Essentiel pour le presse-papiers dans VS Code/Codespace
#
#              # Installer Node.js et pnpm via nvm ou une autre méthode standard Linux
#              # Ici, nous utilisons la méthode NodeSource pour une installation propre
#              # curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
#              # sudo apt-get install -y nodejs
#              # npm install -g pnpm
#
#              # --- Installation de LazyVim pour Neovim (Équivalent de votre section Windows) ---
#              echo "Setting up LazyVim..."
#
#              NVIM_CONFIG_DIR="$HOME/.config/nvim"
#
#              if [ -d "$NVIM_CONFIG_DIR" ]; then
#                  echo "Backing up existing Neovim config to ${NVIM_CONFIG_DIR}.backup"
#                      mv "$NVIM_CONFIG_DIR" "${NVIM_CONFIG_DIR}.backup"
#                      fi
#
#                      # Cloner le starter de LazyVim
#                      git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
#
#                      # Suppression du répertoire .git (car nous ne voulons pas que la configuration soit un repo)
#                      rm -rf "$NVIM_CONFIG_DIR/.git"
#
#                      # --- 2. Configuration des Dotfiles (Liens Symboliques) ---
#                      echo "Starting dotfiles symlinking..."
#
#                      # Définir le répertoire source de configuration (là où le repo dotfiles est cloné)
#                      SOURCE_DIR="$HOME/dotfiles"
#
#                      # Tableau associatif des configurations à lier (source -> cible)
#                      declare -A CONFIG_PATHS=(
#                          ["nvim"]="$SOURCE_DIR/nvim:$HOME/.config/nvim"
#                              ["yazi"]="$SOURCE_DIR/yazi:$HOME/.config/yazi"
#                                  # Ajoutez ici d'autres configurations comme zshrc, bashrc, etc.
#                                      # ["bashrc"]="$SOURCE_DIR/.bashrc:$HOME/.bashrc"
#                                      )
#
#                                      # Fonction pour créer le lien symbolique (très similaire à votre fonction PowerShell)
#                                      create_symlink() {
#                                          local SOURCE=$1
#                                              local TARGET=$2
#                                                  
#                                                      # Supprimer l'ancienne cible (ou lien)
#                                                          if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
#                                                                  echo "Removing existing $TARGET..."
#                                                                          rm -rf "$TARGET"
#                                                                              fi
#
#                                                                                  # Créer le répertoire parent si absent
#                                                                                      mkdir -p "$(dirname "$TARGET")"
#
#                                                                                          # Créer le lien symbolique
#                                                                                              echo "Creating symlink: $TARGET -> $SOURCE"
#                                                                                                  ln -s "$SOURCE" "$TARGET"
#                                                                                                  }
#
#                                                                                                  for KEY in "${!CONFIG_PATHS[@]}"; do
#                                                                                                      IFS=':' read -r SOURCE TARGET <<< "${CONFIG_PATHS[$KEY]}"
#                                                                                                          echo -e "\nInstalling $KEY configuration..."
#                                                                                                              create_symlink "$SOURCE" "$TARGET"
#                                                                                                              done
#
#                                                                                                              # --- 3. Synchronisation et finalisation Neovim ---
#
#                                                                                                              # Exécuter Neovim en mode headless pour installer les plugins LazyVim/Neovim
#                                                                                                              echo "Running Neovim to install plugins and complete setup (LazyVim)..."
#
#                                                                                                              # Cette commande lance nvim, exécute la commande de synchronisation des plugins, et quitte.
#                                                                                                              nvim --headless -c 'Lazy sync' -c 'qa!'
#
#                                                                                                              echo -e "\nInstallation complete!"
#
