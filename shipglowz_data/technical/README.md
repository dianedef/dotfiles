---
artifact: architecture_context
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-07-12"
status: draft
source_skill: sf-docs
scope: architecture
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: medium
docs_impact: yes
evidence:
  - "/home/claude/dotfiles/dotfiles/install.sh"
  - "/home/claude/dotfiles/dotfiles/lib.sh"
  - "/home/claude/dotfiles/dotfiles/config.sh"
  - "/home/claude/dotfiles/dotfiles/bootstrap.sh"
  - "/home/claude/dotfiles/dotfiles/termux.sh"
  - "/home/claude/dotfiles/dotfiles/doppler-setup.sh"
  - "/home/claude/dotfiles/mcp/mcp-servers.json"
depends_on:
  - "/home/claude/dotfiles/README.md"
  - "/home/claude/dotfiles/CLAUDE.md"
  - "/home/claude/dotfiles/shipglowz_data/technical/context.md"
  - "/home/claude/dotfiles/shipglowz_data/technical/context-function-tree.md"
linked_systems:
  - Bash
  - Neovim
  - Starship
  - MCP
  - Doppler
  - Termux
external_dependencies:
  - GitHub releases
  - Node.js/npm
  - CLI binaries (curl/jq/npm/git)
invariants:
  - install.sh remains orchestrator for setup flows.
  - config.sh and lib.sh must stay in sync for component behavior.
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit shipglowz_data/technical/README.md
---

# ARCHITECTURE

## Vue d'ensemble

Le dépôt fonctionne comme une plateforme de bootstrap de workstation:

- une couche d'installation scriptée,
- une couche de bibliothèques partagées,
- une couche de configurations déclaratives par application,
- une couche de secrets et d'intégrations d'outils IA pour Linux/Codespaces.

## Diagramme logique

```text
Entrée d'installation
├─ dotfiles/bootstrap.sh (one-click ubuntu) -> dotfiles/install.sh
├─ dotfiles/termux.sh (workflow Android allégé Markdown-only)
└─ dotfiles/windows.ps1 (workflow Windows référencé)

dotfiles/install.sh (orchestrateur)
├─ dotfiles/config.sh (paramètres)
├─ dotfiles/lib.sh (moteur utilitaire)
├─ install system/tools
├─ create symlink configs
├─ configure MCP
└─ setup shell integration
```

## Couche 1 — Orchestration

Entrée `install.sh`:

- parse options avant toute action (`--dry-run`, `--check`, `--uninstall`, `--update`, `--only`, `--parallel`),
- charge `.env` si présent,
- initialise logs, gestion d'erreurs, détection OS+arch+sudo,
- exécute des modes spéciaux (`check`, `uninstall`, `update`) avec sortie courte,
- en mode standard, exécute un pipeline:
  1) configuration utilisateur locale,
  2) outils système,
  3) Node.js + outils npm,
  4) shell tools,
  5) AI tools,
  6) liaison config,
  7) MCP,
  8) intégration shell,
  9) plugins et auth.

Le point de contrôle final est le calcul d'état d'installation de composants (`capture_final_component_state`) puis la synchronisation des artefacts utilisateurs (`sync_component_artifacts`) pour garantir la cohérence:

- seuls les aliases/commandes cibles installées à la fin du run sont conservés,
- les aliases obsolètes sont supprimés,
- les symlinks de config (`~/.config/ranger`) ne sont gardés que quand l’outil correspondant est effectivement disponible.
- ce mécanisme s’applique aussi en mode `--only=<component>`, évitant les artefacts fantômes.

Contrainte: la même orchestration est réutilisable en mode non-interactif (CI) ou interactif (menu `gum`).

## Couche 2 — Bibliothèque partagée `lib.sh`

`lib.sh` externalise les services d'infrastructure:

- gestion d'exécution (`is_installed`, `run_action`, `run_privileged`, `parallel_run`),
- téléversement et vérification (`download_file`, `download_verified`),
- santé système (`run_health_check`, `health_check_tool`, `health_check_symlink`, `health_check_bashrc`),
- gestion des alias et intégration (`append_to_bashrc`, `source_if_exists`, `run_single_component`),
- mécanismes de parsing et d'affichage d'aide (`parse_arguments`, `show_help`),
- configuration de sécurité légère (`validate_path`, `run_uninstall`, `setup_error_traps`).

## Couche 3 — Modules d'exécution et d'installation

### Modules principaux (Linux/Codespaces)

- `Neovim`
  - install binaire/URL release, lien binaire, symlink config vers `nvim/MyNeovim`.
- `Starship`
  - installation via script officiel ou cargo fallback, initialisation shell dans `.bashrc`.
- `Zoxide`, `Doppler`, `FZF`, `GH CLI`, `lsd`, `bat`.
- Outils Node globaux via `pnpm` quand disponible:
  - `@apify/mcpc`, `@zed-industries/codex-acp`, `tldr`, `eslint`, plus outils listés dans `DOTFILES_ALL_COMPONENTS`.
  - `claude`, `codex`, les skills ShipGlowz, et les configs runtime `~/.claude` / `~/.codex` sont exclus de ce périmètre et appartiennent à ShipGlowz.

### Modules spécifiques Termux

- `termux.sh` active une variante légère:
  - outils de base via `pkg` pour Markdown et petits fichiers,
  - `Neovim`,
  - `Starship` binaire local,
  - gestion `ranger` prioritaire,
  - configs simplifiées (`starship-simple.toml`) et config Nvim Termux.
  - exclusions explicites: Node.js, GitHub CLI, Doppler, MCP, Copilot, Claude/Codex/OpenCode, Aider et agents Neovim.

## Couche 4 — Config-as-code

- Gestion de configuration utilisateur via symlink:
  - `nvim` -> `~/.config/nvim`
  - `ranger` -> `~/.config/ranger`
  - `starship` -> `~/.config/starship.toml`
  - `tmux` -> `~/.tmux.conf`
  - `ghostty/config` -> `~/.config/ghostty/config`
  - `.config/mcp/servers.json` -> `mcp/mcp-servers.json`
  - liaisons de `TASKS.md` et `AUDIT_LOG.md` depuis `~/shipglowz` quand disponible.

## Données et flux de secrets

- Le dépôt prévoit le flux secret manager `Doppler` pour l'installation/usage standard Linux/Codespaces.
- Termux ne configure plus de secrets locaux; les anciens flux de secrets Android sont retirés du profil.
- Les variables d'environnement sont lues depuis `.env` (template `.env.example`), avec valeurs par défaut définies dans `config.sh`.
- Certains flux MCP utilisent des clés optionnelles (`FIRECRAWL`, `DEEPL`, `DFS`) injectées dynamiquement.

## Dépendances documentaires

### Documentation interne

- `/home/claude/dotfiles/README.md`
- `/home/claude/dotfiles/CLAUDE.md`
- `/home/claude/dotfiles/.env.example`
- `/home/claude/dotfiles/env.example`
- `/home/claude/dotfiles/dotfiles/config.sh`
- `/home/claude/dotfiles/dotfiles/lib.sh`
- `/home/claude/dotfiles/dotfiles/install.sh`
- `/home/claude/dotfiles/dotfiles/termux.sh`
- `/home/claude/dotfiles/mcp/mcp-servers.json`
- `/home/claude/dotfiles/starship/README.md`
- `/home/claude/dotfiles/nvim/README.md`

### Documentation externe utilisée en appui

- Starship docs (installation + prompt init).
- Neovim / LazyVim docs.
- Ranger docs.
- MCP protocol docs.
- Doppler docs.
- GitHub CLI docs.
- `gh` et `npm` tool docs.

## Preuves d'architecture (sélection)

- `install.sh` orchestre explicitement les phases (initialisation, install, config, MCP, shell integration, auth).
- `lib.sh` contient la matrice complète des composants et le parseur d'options.
- `config.sh` contient versioning, chemins, flags et liste `DOTFILES_ALL_COMPONENTS`.
- `mcp/mcp-servers.json` regroupe la vérité des serveurs MCP.
- `termux.sh` exprime un flux différent et volontairement réduit: config Markdown Android, pas station de développement web/agentique.

## Répartition des responsabilités

- Script owner (contrat): bootstrap, installation, santé, uninstall.
- Config owner: répertoires module (`nvim`, `ranger`, `starship`, `ghostty`, `lazygit`, `mpv`).
- Secret owner: `.env` templates + scripts Doppler pour Linux/Codespaces.
- MCP owner: `mcp/mcp-servers.json` + logique d'injection multi-client.

## Points de vigilance

- Maintenir la compatibilité des modes `--only` avec `run_health_check`.
- Garder la cohérence entre nom des répertoires cibles et `dotfiles-switch`/scripts externes.
- Vérifier les chemins absolus attendus sur Windows/macOS avant élargissement de fonctionnalités.
- Contrôler la rotation/charge des plugins AI et l'impact réseau.


## Standards techniques

- Bash :
  - `set -euo pipefail`
  - guillemets sur toutes les expansions de variables
  - fonctions nommées en `snake_case`
- Lua :
  - formatage via Stylua, 2 espaces, largeur 120
  - préférer modules renvoyant des tables (`return { ... }`)
- JS/TS :
  - style cohérent, lint localement respecté
  - priorité lisibilité/simplicité sur cleverness

### Conventions de sécurité

- Aucun secret en clair dans les fichiers versionnés.
- Variables sensibles dans `.env` ou Doppler seulement.
- Vérifier les droits d’exécution uniquement quand nécessaire.
- Journaliser sans afficher de tokens / mots de passe dans les logs.

### Ordre de travail recommandé

1. Modifier le script ciblé en mode minimal.
2. Ajuster la doc associée dans le bloc correspondant.
3. Mettre à jour les fichiers d’inventaire/guide s’il y a un comportement utilisateur visible.
4. Documenter les cas de migration (plateforme, rollback).

### Gouvernance

- Priorité : stabilité de la chaîne d’installation, puis confort d’usage.
- Décisions importantes validées par essai sur Linux/Codespaces, puis sur Termux/Windows si impact.
