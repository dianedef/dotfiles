# ✨ Starship Configuration

Configuration minimaliste et élégante de Starship pour Termux/Codespaces.

## 📦 Installation

```bash
# Installer Starship
curl -sS https://starship.rs/install.sh | sh

# Lier la config
ln -sf /workspaces/dotfiles/starship/starship-simple.toml ~/.config/starship.toml

# Ajouter à ~/.bashrc
eval "$(starship init bash)"
```

## 🎨 Fonctionnalités

### Prompt
- 📁 Dossier actuel avec chemin compact
- 🌿 Branche Git avec icône
- Emojis pour le status Git :
  - ✅ À jour avec origin
  - ⚠️ Fichiers non trackés
  - 📝 Fichiers modifiés
  - 🚀 Fichiers staged
  - 🧹 Fichiers supprimés
  - ⏳ Changements stashed
  - 📬 Commits en retard (behind)
  - ⇡ Commits en avance (ahead)

### Langages supportés
- 🐍 Python
- ⬢ Node.js
- 🦀 Rust
- 🐹 Go
- ☕ Java
- 🐳 Docker

### Optimisations
- Ligne vide avant chaque prompt
- Timeout rapide (500ms) pour SSH
- Affichage de la durée si commande > 2s

## 🛠️ Outils complémentaires installés

### bat - Better cat
```bash
cat fichier.txt    # Coloration syntaxe automatique
bat fichier.txt    # Alias explicite
```

### lsd - Better ls
```bash
ls                 # Liste avec icônes et couleurs
ll                 # Liste détaillée (-lh)
la                 # Liste tout + cachés (-lAh)
lt                 # Tree view (2 niveaux)
```

### trash-cli - Corbeille sécurisée
```bash
tp fichier         # Mettre à la corbeille (trash-put)
tl                 # Voir la corbeille (trash-list)
tr                 # Restaurer (trash-restore)
te                 # Vider la corbeille (trash-empty)
rm                 # ⚠️ Bloqué - utiliser tp ou /bin/rm
```

### Navigation rapide
```bash
..                 # cd ..
...                # cd ../..
....               # cd ../../..
```

### Git shortcuts
```bash
gs                 # git status
ga                 # git add
gc                 # git commit
gp                 # git push
gl                 # git pull
gd                 # git diff
glog               # git log --oneline --graph
```

### Autres
```bash
reload             # source ~/.bashrc
cls                # clear
h                  # history
```

## 📝 Fichiers

- `starship-simple.toml` - Config active (émojis + optimisée)
- `starship.toml` - Config originale avec lignes vertes

## 🎯 Philosophie

Configuration pensée pour :
- Termux/Android (écran petit)
- SSH/Codespaces (latence réseau)
- Lisibilité maximale
- Informations essentielles uniquement
