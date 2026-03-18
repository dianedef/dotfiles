# AI Plugins

Résumé court des plugins IA activés dans cette config.

## Choix rapide

- **Copilot Chat** : le plus intégré a NeoVim pour discuter avec le code, demander une review, expliquer ou corriger.
- **Gemini CLI** : le plus proche d'un agent/terminal Gemini officiel dans NeoVim.
- **Claude Code** : reste pertinent si vous voulez un agent tres autonome dans un terminal/diff.

## Raccourcis utiles

Si votre `leader` est celui par défaut de LazyVim, `<leader>` correspond en général a `Espace`.

### Copilot Chat

- `Espace a p` : ouvrir / fermer Copilot Chat
- `Espace a e` : expliquer le buffer ou la sélection
- `Espace a r` : review du buffer ou de la sélection
- `Espace a f` : aider a corriger le buffer ou la sélection

### Gemini CLI

- `Espace a g` : ouvrir / fermer Gemini CLI
- `Espace a a` : ajouter le fichier courant au contexte Gemini
- `Espace a d` : demander un fix du diagnostic courant
- `Espace a /` : ouvrir le picker des slash commands Gemini

## Comment choisir

- Prenez **Copilot Chat** si vous voulez une intégration NeoVim plus poussée et une UX plus opinionated.
- Prenez **Gemini CLI** si vous voulez un mode agent plus direct, proche du CLI officiel.
- Gardez **Claude Code** pour les sessions plus longues ou les diffs plus ambitieux.
