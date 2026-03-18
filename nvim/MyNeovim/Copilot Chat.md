# Copilot Chat

Mémo rapide pour utiliser `CopilotChat.nvim`.

## Pourquoi l'utiliser

- Integration NeoVim poussee : chat, contexte, prompts, diffs et workflow de review.
- Bon choix si vous voulez un plugin **opinionated** avec une vraie interface de travail.
- Par defaut, cette config vise `claude-sonnet-4` via GitHub Copilot.

## Prerequis

- Avoir GitHub Copilot actif.
- Avoir lance `:Copilot auth` si besoin.
- Avoir active la partie chat cote GitHub Copilot.

## Vos raccourcis dans cette config

- `<leader>ap` : ouvrir / fermer Copilot Chat
- `<leader>ae` : expliquer le buffer ou la selection
- `<leader>ar` : review du buffer ou de la selection
- `<leader>af` : corriger le buffer ou la selection

Avec le `leader` par defaut de LazyVim, cela donne en general `Espace a p`, `Espace a e`, `Espace a r`, `Espace a f`.

## Utilisation la plus simple

1. Ouvrir un fichier.
2. Faire `Espace a p` pour ouvrir le chat.
3. Ecrire une demande simple : `explique ce module`, `propose un refactor minimal`, `ecris les tests manquants`.
4. Si vous voulez cibler un bloc, passez en mode visuel puis utilisez `Espace a e`, `Espace a r` ou `Espace a f`.

## Bon reflexe

- `Explain` pour comprendre un morceau de code.
- `Review` pour chercher bugs, regressions et risques.
- `Fix` pour demander un patch minimal et sur.

## Modeles

Ce plugin peut utiliser plusieurs bons modeles via Copilot. Dans le chat, vous pouvez aussi orienter le modele avec la syntaxe du plugin, par exemple :

```text
$claude-sonnet-4
Review this file
```

Autres pistes si disponibles dans votre offre Copilot : `gemini-2.5-pro`, `gpt-4.1`.

## Si ca ne marche pas

- Verifier `:Copilot auth`
- Verifier que Copilot fonctionne deja dans l'edition
- Si le modele par defaut n'est pas disponible, essayer un autre modele pris en charge par votre abonnement

## Docs source

- README : <https://github.com/CopilotC-Nvim/CopilotChat.nvim>
