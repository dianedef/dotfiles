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

- `<leader>agt` : ouvrir / fermer Gemini CLI
- `<leader>aga` : ajouter le fichier courant au contexte
- `<leader>agd` : fixer les diagnostics du buffer courant
- `<leader>ag/` : picker des slash commands

Avec le `leader` par defaut de LazyVim, cela donne en general `Espace a g t`, `Espace a g a`, `Espace a g d`, `Espace a g /`.

## Utilisation la plus simple

1. Ouvrir un fichier.
2. Faire `Espace a g a` pour l'ajouter au contexte.
3. Faire `Espace a g t` pour ouvrir Gemini.
4. Demander quelque chose de concret : `explique ce module`, `propose un refactor minimal`, `ecris les tests`.

## Bon reflexe

- Ajouter d'abord le fichier avec `Espace a g a`.
- Utiliser `Espace a g d` quand vous voulez partir d'une erreur ou d'un diagnostic LSP.
- Utiliser `Espace a g /` pour decouvrir les commandes natives du CLI au lieu de tout memoriser.

## Si ca ne marche pas

- Verifier que `gemini` marche hors de NeoVim
- Verifier que le `PATH` de NeoVim trouve bien le binaire
- Si le terminal Gemini affiche `code 127`, installer le CLI avec `npm install -g @google/gemini-cli`, puis redemarrer NeoVim
- `No diagnostics found in the current buffer` signifie qu'aucun diagnostic LSP n'est present dans le buffer courant
- `No valid file in current buffer` signifie que le buffer courant n'a pas de chemin de fichier reel
- Relancer une session Gemini CLI hors NeoVim si l'authentification n'est pas initialisee

## Docs source

- Plugin : <https://github.com/marcinjahn/gemini-cli.nvim>
- CLI officiel : <https://github.com/google-gemini/gemini-cli>
