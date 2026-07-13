---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-07-13"
updated: "2026-07-13"
status: draft
source_skill: 300-sg-docs
scope: code-docs-map
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglowz_data/technical/README.md
  - shipglowz_data/technical/context.md
  - shipglowz_data/technical/context-function-tree.md
  - shipglowz_data/technical/operator-guides/
depends_on: []
supersedes: []
evidence:
  - "Repository inventory and the existing technical context corpus."
  - "Codex ACP installer and Avante lifecycle documentation update on 2026-07-13."
next_review: "2026-08-13"
next_step: "/300-sg-docs technical audit"
---

# Code Docs Map

## Purpose

Cette carte indique quelle documentation lire et mettre à jour lorsqu'un fichier technique des dotfiles change. Elle évite de chercher dans tout le dépôt ou de documenter un correctif dans le mauvais projet.

## Owned Files

| Chemin | Rôle | Règle de modification |
| --- | --- | --- |
| `shipglowz_data/technical/code-docs-map.md` | Carte canonique code vers documentation | Modifier après ajout, déplacement ou changement de responsabilité d'un sous-système |
| `shipglowz_data/technical/README.md` | Vue d'architecture | Garder cohérente avec l'installateur réel |
| `shipglowz_data/technical/context.md` | Orientation technique | Décrire les entrées et contraintes observées |
| `shipglowz_data/technical/context-function-tree.md` | Arbre des scripts | Mettre à jour quand le flux ou les helpers importants changent |
| `shipglowz_data/technical/operator-guides/**` | Procédures destinées à l'opératrice | Utiliser un langage sûr, concret et non destructif |

## Entrypoints

- `dotfiles/install.sh` : installation complète, modes ciblés et contrôle général.
- `dotfiles/bootstrap.sh` : bootstrap Linux avant délégation à l'installateur.
- `dotfiles/install-termux.sh` : bootstrap du profil Android limité.
- `nvim/MyNeovim/init.lua` : chargement de la configuration Neovim principale.

## Invariants

- La documentation propre aux dotfiles reste dans `dotfiles/shipglowz_data`.
- Le corpus `shipglowz_data` intentionnel du plugin Neovim n'est pas déplacé vers ShipGlowz.
- Une modification visible ou risquée de l'installateur met à jour sa documentation dans le même chantier.
- Les preuves et guides ne contiennent aucun secret.

## Map

| Chemins | Sous-système | Documentation principale | Documentation secondaire | Validation attendue | Déclencheur documentaire |
| --- | --- | --- | --- | --- | --- |
| `dotfiles/install.sh`, `dotfiles/lib.sh`, `dotfiles/config.sh` | Installation Linux/Codespaces | `shipglowz_data/technical/README.md` | `shipglowz_data/technical/context-function-tree.md`, guide opérateur concerné | `bash -n`; dry-run ou test ciblé du composant | Phase, option, paquet, chemin, contrôle de santé ou comportement d'échec modifié |
| `dotfiles/bootstrap.sh` | Bootstrap Linux | `shipglowz_data/technical/context.md` | `README.md`, `shipglowz_data/technical/README.md` | `bash -n`; revue du chemin clone/install | Prérequis, dépôt, branche ou délégation vers l'installateur modifiés |
| `dotfiles/install-termux.sh`, `dotfiles/termux.sh`, `nvim/MyNeovimTermux/**` | Profil Termux | `shipglowz_data/technical/context.md` | `shipglowz_data/technical/context-function-tree.md`, `README.md` | `bash -n`; vérification sur Termux quand le comportement change | Périmètre Markdown, paquet, chemin ou configuration Android modifiés |
| `nvim/MyNeovim/lua/plugins/avante.lua` | Avante / Codex ACP | `shipglowz_data/technical/operator-guides/avante-codex-acp.md` | `nvim/MyNeovim/AI Plugins.md`, `shipglowz_data/technical/README.md` | test d'installation ACP et test de cycle de vie headless | Commande ACP, arguments, modèle, authentification, arrêt ou résolution du binaire modifiés |
| `nvim/MyNeovim/shipglowz_data/**` | Corpus intentionnel du plugin Neovim | documentation locale du plugin concerné | carte technique racine seulement si l'intégration dotfiles change | lint metadata et validation fonctionnelle du plugin | Contrat, workflow ou comportement propre au plugin modifié ; ne pas migrer automatiquement ce corpus |
| `nvim/MyNeovim/**` hors Avante | Neovim principal | `nvim/README.md` | `shipglowz_data/technical/context.md` | charge headless, test ou contrôle ciblé selon le plugin | Raccourci, plugin, configuration visible ou dépendance modifiés |
| `mcp/**`, `dotfiles/doppler-setup.sh` | MCP et secrets | `shipglowz_data/technical/context.md` | `README.md`, modèles d'environnement | syntaxe JSON/Bash et contrôle sans exposition de secret | Serveur, variable, injection, authentification ou périmètre secret modifiés |
| `tests/**`, `nvim/MyNeovim/tests/**` | Régressions dotfiles | documentation du sous-système testé | bug ou spec lié | exécution du test ciblé | Contrat vérifié, prérequis ou commande de preuve modifiés |
| `shipglowz_data/workflow/bugs/**` | Historique des bugs | dossier de bug concerné | guide opérateur ou contexte technique lié | lint metadata et cohérence des liens | Diagnostic, correctif, retest ou statut modifié |
| Configurations comme `starship/**`, `ranger/**`, `ghostty/**`, `lazygit/**` | Configurations utilisateur | README local quand il existe | `shipglowz_data/technical/context.md` | validation native de l'outil quand disponible | Comportement utilisateur, chemin de symlink ou prérequis modifié |

## Documentation Update Plan

Pour tout changement de code, relever :

- le chemin modifié ;
- le sous-système ;
- le document principal ;
- les documents secondaires ;
- l'action `none`, `review`, `update` ou `create` ;
- la validation réalisée ;
- la raison si aucune mise à jour documentaire n'est nécessaire.

## Reader Checklist

- Changement dans l'installateur -> lire d'abord la ligne installation de la carte.
- Changement Avante ou Codex ACP -> lire d'abord le guide opérateur dédié.
- Changement Termux -> préserver son périmètre volontairement limité.
- Changement impliquant des secrets -> ne jamais copier leur valeur dans la documentation ou les preuves.
- Nouveau sous-système important -> ajouter une ligne à cette carte et désigner son document principal.

## Validation

```bash
python3 /home/claude/shipglowz/tools/shipglowz_metadata_lint.py shipglowz_data/technical
git diff --check
```

## Maintenance Rule

Mettre à jour cette carte lorsqu'un grand répertoire, un point d'entrée, un document principal, une validation ou un déclencheur documentaire change.
