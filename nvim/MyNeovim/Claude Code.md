# Claude Code

Mémo rapide pour utiliser `coder/claudecode.nvim` sans relire toute la doc.

## Prérequis

- Avoir le CLI `claude` installé et accessible dans Neovim.
- Vérifier au besoin :

```bash
which claude
claude doctor
```

- Dans cette config, `claudecode.nvim` suppose que la commande `claude` est déjà trouvable dans le `PATH`.

## Vos raccourcis dans cette config

- `<leader>ac` : ouvrir / basculer le terminal Claude Code
- `<leader>as` : envoyer du contexte a Claude Code

Raccourci a retenir :

- `Claude Code` utilise les touches en minuscules
- `Codex` utilise les touches en majuscules : `<leader>aC`, `<leader>aF`, `<leader>aN`, `<leader>aR`

Si votre `<leader>` est celui par défaut de LazyVim, cela correspond généralement a `Espace a c` et `Espace a s`.

## Utilisation la plus rapide

1. Ouvrir le projet et le fichier sur lequel vous travaillez.
2. Lancer Claude avec `<leader>ac` ou `:ClaudeCode`.
3. Sélectionner un bloc en mode visuel puis faire `<leader>as` ou `:ClaudeCodeSend`.
4. Laisser Claude proposer des changements.
5. Quand un diff s'ouvre :
   - `:w` pour accepter
   - `:q` pour refuser

## Commandes utiles

- `:ClaudeCode` : ouvre / ferme la fenêtre Claude
- `:ClaudeCodeFocus` : focus intelligent sur la fenêtre Claude
- `:ClaudeCodeSend` : envoie la sélection courante
- `:ClaudeCodeAdd %` : ajoute le fichier courant au contexte
- `:ClaudeCodeAdd % 10 40` : ajoute seulement les lignes 10 a 40
- `:ClaudeCodeSelectModel` : choisir le modèle Claude
- `:ClaudeCode --resume` : reprendre la session précédente
- `:ClaudeCode --continue` : continuer avec l'historique
- `:ClaudeCodeDiffAccept` : accepter un diff
- `:ClaudeCodeDiffDeny` : refuser un diff

## Ce que votre setup fait deja

- La fenêtre Claude s'ouvre en split a droite.
- Largeur du split : `50%`.
- Aucun autre raccourci local n'est défini ici pour `Focus`, `Resume`, `DiffAccept`, `DiffDeny`, etc. : ils restent disponibles via les commandes `:`.

## Bon reflexe

- Lancez Claude depuis Neovim avec `:ClaudeCode`, pas seulement depuis un terminal séparé.
- Le plugin branche automatiquement Claude a votre session Neovim, vos fichiers ouverts, vos sélections et les diffs.

## Si ca ne marche pas

- Vérifier que `claude` fonctionne hors de Neovim.
- Vérifier `which claude` depuis le meme environnement shell.
- Si vous utilisez une installation locale ou binaire non standard, il faut renseigner `terminal_cmd` dans la config du plugin avec le chemin exact du binaire.

## Docs source

- README : <https://github.com/coder/claudecode.nvim/blob/main/README.md>
- PROTOCOL : <https://github.com/coder/claudecode.nvim/blob/main/PROTOCOL.md>
