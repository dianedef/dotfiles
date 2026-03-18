# Gemini CLI

Mémo rapide pour utiliser `gemini-cli.nvim`.

## Pourquoi l'utiliser

- Plugin fin et direct autour du **Gemini CLI officiel**.
- Bon choix si vous aimez un workflow agent/terminal dans NeoVim.
- Tres pratique pour ajouter le fichier courant, lancer des slash commands et demander un fix de diagnostic.

## Prerequis

- Avoir le binaire `gemini` installe et accessible dans NeoVim.
- Avoir deja initialise Gemini CLI une premiere fois hors de NeoVim.

Verification rapide :

```bash
which gemini
gemini
```

## Vos raccourcis dans cette config

- `<leader>ag` : ouvrir / fermer Gemini CLI
- `<leader>aa` : ajouter le fichier courant au contexte
- `<leader>ad` : fixer le diagnostic courant
- `<leader>a/` : picker des slash commands

Avec le `leader` par defaut de LazyVim, cela donne en general `Espace a g`, `Espace a a`, `Espace a d`, `Espace a /`.

## Utilisation la plus simple

1. Ouvrir un fichier.
2. Faire `Espace a a` pour l'ajouter au contexte.
3. Faire `Espace a g` pour ouvrir Gemini.
4. Demander quelque chose de concret : `explique ce module`, `propose un refactor minimal`, `ecris les tests`.

## Bon reflexe

- Ajouter d'abord le fichier avec `Espace a a`.
- Utiliser `Espace a d` quand vous voulez partir d'une erreur ou d'un diagnostic LSP.
- Utiliser `Espace a /` pour decouvrir les commandes natives du CLI au lieu de tout memoriser.

## Si ca ne marche pas

- Verifier que `gemini` marche hors de NeoVim
- Verifier que le `PATH` de NeoVim trouve bien le binaire
- Relancer une session Gemini CLI hors NeoVim si l'authentification n'est pas initialisee

## Docs source

- Plugin : <https://github.com/marcinjahn/gemini-cli.nvim>
- CLI officiel : <https://github.com/google-gemini/gemini-cli>
