# 🚀 Zoxide - Navigation Intelligente

Zoxide est un **remplacement intelligent de `cd`** qui apprend vos habitudes de navigation.

## 🎯 Concept Principal

**PAS de TUI, juste de l'intelligence !** 🧠

Zoxide se souvient automatiquement des dossiers que vous visitez et vous permet d'y retourner avec juste quelques lettres.

## 📚 Comment ça marche

### 1. Visitez des dossiers normalement
```bash
cd ~/dotfiles/nvim/lua/plugins/
cd ~/dotfiles/yazi/
cd /tmp/test/
cd ~/projects/myapp/src/
```

### 2. Zoxide mémorise automatiquement
Aucune action requise ! Zoxide enregistre en arrière-plan.

### 3. Utilisez `z` pour sauter rapidement
```bash
z plugins    # → ~/dotfiles/nvim/lua/plugins/
z yazi       # → ~/dotfiles/yazi/
z dot        # → ~/dotfiles/
z myapp      # → ~/projects/myapp/src/
```

## 🎓 Commandes Essentielles

### Navigation de base
```bash
z <mot-clé>              # Saute au dossier le plus probable
z <mot1> <mot2>          # Affine la recherche (ex: z dot nvim)
```

### Recherche avancée
```bash
zoxide query <mot>       # Voir où "z mot" sauterait (sans y aller)
zoxide query -l          # Liste TOUS les dossiers mémorisés
zoxide query -l | grep nvim   # Filtrer les résultats
```

### Gestion de la base de données
```bash
zoxide remove <chemin>   # Oublier un dossier spécifique
zoxide remove /tmp       # Exemple: supprimer /tmp
```

## 💡 Exemples Pratiques

### Navigation rapide dans les dotfiles
```bash
# Au lieu de :
cd ~/dotfiles/nvim/lua/plugins/ui/

# Tapez juste :
z ui         # Zoxide trouve le bon chemin !
```

### Affiner une recherche ambiguë
```bash
# Si plusieurs dossiers contiennent "config" :
z config         # → Celui le plus fréquemment visité
z config nvim    # → Spécifiquement nvim/config
z config yazi    # → Spécifiquement yazi/config
```

### Naviguer entre projets
```bash
z dot       # → ~/dotfiles/
z nvim      # → ~/dotfiles/nvim/
z plugins   # → ~/dotfiles/nvim/lua/plugins/
z yazi      # → ~/dotfiles/yazi/
```

## 🔍 Comprendre la Sélection

Zoxide utilise un **algorithme de scoring** basé sur :
- **Fréquence** : Combien de fois vous avez visité le dossier
- **Récence** : Quand vous l'avez visité la dernière fois
- **Pertinence** : Correspondance du mot-clé

Plus vous utilisez un dossier, plus il est prioritaire !

## 🆚 Zoxide vs cd

| Commande | cd traditionnel | Zoxide |
|----------|----------------|--------|
| Navigation | `cd ~/dotfiles/nvim/lua/plugins/` | `z plugins` |
| Retour | `cd -` | `z -` |
| Parent | `cd ..` | `cd ..` (utilisez cd) |

**Conseil** : Gardez `cd` pour la navigation relative (`cd ..`, `cd ./folder`), utilisez `z` pour les sauts longs !

## ⚙️ Configuration (Déjà fait !)

Zoxide est déjà configuré dans votre `~/.bashrc` :
```bash
eval "$(zoxide init bash)"
```

Ceci active automatiquement :
- La commande `z`
- L'enregistrement des dossiers visités
- L'algorithme de scoring

## 🐛 Dépannage

### `z` ne trouve pas un dossier
**Solution** : Visitez-le d'abord avec `cd`, puis zoxide le mémorisera.
```bash
cd ~/dotfiles/nvim/lua/plugins/
# Maintenant "z plugins" fonctionnera
```

### Zoxide pointe vers le mauvais dossier
**Solution** : Soyez plus précis ou supprimez l'entrée incorrecte.
```bash
z dot nvim           # Plus précis
zoxide remove /tmp   # Supprimer une entrée
```

### Voir ce qui est mémorisé
```bash
zoxide query -l | less    # Parcourir la liste
zoxide query -l | wc -l   # Compter les entrées
```

## 🎯 Astuces Pro

### 1. Combiner avec d'autres commandes
```bash
# Sauter ET lister
z plugins && ls

# Sauter ET éditer un fichier
z nvim && nvim init.lua
```

### 2. Créer des aliases personnalisés
Ajoutez dans `~/.bashrc` :
```bash
alias zp='z plugins'
alias zn='z nvim'
alias zd='z dotfiles'
```

### 3. Utiliser avec des patterns
```bash
z lua      # Trouve le dossier lua le plus visité
z .config  # Trouve dans ~/.config/...
```

## 📊 Statistiques

Voir vos dossiers les plus visités :
```bash
zoxide query -l --score | head -20
```

## 🔗 Ressources

- [Documentation officielle](https://github.com/ajeetdsouza/zoxide)
- Installation automatique via `install.sh` de ce repo
- Fonctionne sur : Linux, macOS, Windows, Termux

## ✨ Résumé

1. **Visitez** des dossiers avec `cd` (comme d'habitude)
2. **Zoxide mémorise** automatiquement
3. **Utilisez `z <mot>`** pour y retourner instantanément
4. **Gagnez du temps** sur SSH/Termux ! 🚀

**C'est tout !** Pas de TUI, pas de configuration compliquée, juste une navigation intelligente. 🎉
