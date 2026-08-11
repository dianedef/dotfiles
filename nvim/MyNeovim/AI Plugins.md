# AI Plugins

Résumé court des plugins IA activés dans cette config.

## Choix rapide

- **Copilot Chat** : le plus intégré a NeoVim pour discuter avec le code, demander une review, expliquer ou corriger.
- **Avante Codex** : interface Avante branchee sur Codex ACP avec l'auth ChatGPT/Codex, sans cle API OpenAI transmise au provider.
- **Gemini CLI** : le plus proche d'un agent/terminal Gemini officiel dans NeoVim.
- **Claude Code** : reste pertinent si vous voulez un agent tres autonome dans un terminal/diff.

## Raccourcis utiles

Si votre `leader` est celui par défaut de LazyVim, `<leader>` correspond en général a `Espace`.

### Copilot Chat

- `Espace a p` : ouvrir / fermer Copilot Chat
- `Espace a e` : expliquer le buffer ou la sélection
- `Espace a r` : review du buffer ou de la sélection
- `Espace a f` : aider a corriger le buffer ou la sélection

### Avante Codex

- `Espace a x t` : ouvrir / fermer Avante
- `Espace a x c` : ouvrir le chat Avante
- `Espace a x q` : poser une question
- `Espace a x e` : editer avec Avante
- `Espace a x p` : changer de provider Avante
- `Espace a x m` : choisir le modele Avante
- `Espace a x s` : arrêter la génération et son processus ACP

Avante lance directement le binaire natif `codex-acp`, afin que `:AvanteStop` et la fermeture normale de Neovim puissent arrêter le processus qu'ils possèdent. Il n'est donc pas nécessaire de fermer manuellement Codex ACP après chaque analyse. Après un crash brutal ou un arrêt forcé de la machine, un contrôle ponctuel des processus orphelins reste recommandé.

L'installateur dotfiles conserve `@zed-industries/codex-acp@0.16.0`, la version compatible avec les arguments `-c` configurés ici, et refuse de considérer l'installation complète si le runtime natif OS/architecture manque. Le successeur officiel `@agentclientprotocol/codex-acp` utilise une autre interface de configuration et doit faire l'objet d'une migration dédiée avant remplacement.

Pour l'installation, les vérifications sûres, les erreurs à éviter et la procédure de dépannage, lire le [guide opérateur Avante et Codex ACP](../../shipglows_data/technical/operator-guides/avante-codex-acp.md).

### Gemini CLI

- `Espace a g t` : ouvrir / fermer Gemini CLI
- `Espace a g a` : ajouter le fichier courant au contexte Gemini
- `Espace a g d` : demander un fix des diagnostics du buffer courant
- `Espace a g /` : ouvrir le picker des slash commands Gemini

## Comment choisir

- Prenez **Copilot Chat** si vous voulez une intégration NeoVim plus poussée et une UX plus opinionated.
- Prenez **Avante Codex** si vous voulez utiliser Codex dans Avante via votre abonnement ChatGPT/Codex plutot que la facturation API OpenAI.
- Prenez **Gemini CLI** si vous voulez un mode agent plus direct, proche du CLI officiel.
- Gardez **Claude Code** pour les sessions plus longues ou les diffs plus ambitieux.
