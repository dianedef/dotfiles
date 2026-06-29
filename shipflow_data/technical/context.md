---
artifact: technical_context
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-06-20"
status: draft
source_skill: sf-docs
scope: technique
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: medium
docs_impact: yes
evidence:
  - "/home/claude/dotfiles/README.md"
  - "/home/claude/dotfiles/CLAUDE.md"
  - "/home/claude/dotfiles/install.sh"
  - "/home/claude/dotfiles/lib.sh"
  - "/home/claude/dotfiles/config.sh"
  - "/home/claude/dotfiles/bootstrap.sh"
  - "/home/claude/dotfiles/termux.sh"
depends_on:
  - "/home/claude/dotfiles/AGENT.md"
  - "/home/claude/dotfiles/install.sh"
  - "/home/claude/dotfiles/lib.sh"
  - "/home/claude/dotfiles/config.sh"
next_step: /sf-docs audit shipflow_data/technical/context.md
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit CONTEXT.md
---

# CONTEXT

## Contexte métier
Ce dépôt regroupe un ensemble de configurations locales (terminal, éditeur, file managers, prompts, MCP, assistants IA) avec un pipeline d'installation automatisé. L'objectif est de reconstituer un poste de travail homogène sur Linux/Codespaces et Windows, avec un profil Termux volontairement réduit à l'édition Markdown et aux petits fichiers texte.

## Architecture réelle observée

- Couche installation:
  - `bootstrap.sh` installe prérequis, clone/actualise le dépôt puis délègue à `install.sh`.
  - `install-termux.sh` fournit l'entrée réseau Termux en une commande, clone ou met à jour `~/dotfiles`, puis délègue à `termux.sh`.
  - `install.sh` est le point d'entrée principal et pilote toutes les phases.
  - `lib.sh` contient le socle utilitaire: parsing d'options, installation, santé, symlinks, auth, menu, logs.
  - `config.sh` concentre les constantes runtime: versions, chemins, flags, listes de composants.
- Couche configuration:
  - Répertoires de configs versionnés: `nvim/`, `ranger/`, `starship/`, `ghostty/`.
  - Fichiers dédiés: `.tmux.conf`, `.env.example`, `cheat/conf.yml`, `mcp/mcp-servers.json`, `codex/config.toml`, `lazygit/config.yml`, `cursor/settings.json`, `ranger/...`.
- Couche secrets/AI:
  - `doppler-setup.sh` gère la configuration d'accès pour Linux/Codespaces.
  - Termux ne configure plus de secrets, agents IA, MCP, GitHub CLI ou stack web.
  - `.env.example` et `env.example` décrivent les variables supportées.
  - `mcp/mcp-servers.json` est la source principale des serveurs MCP.
- Couche intégration shell:
  - `nvim/shell-integration.sh`, alias (`alias dot='~/dotfiles/install.sh'`), `append_to_bashrc` dans `lib.sh`.
  - `setup_shell_integration` (dans `install.sh`) injecte `starship init`, `zoxide init` et éditeurs.

## Contraintes techniques

- Multi-plateforme: la logique diffère selon OS détecté et architecture (`Linux`/`Darwin`/`Windows`/Termux via script dédié).
- Modes de fonctionnement:
  - plein, interactif, `--dry-run`, `--check`, `--only`, `--update`, `--parallel`, `--uninstall`.
- Gestion des droits:
  - mode local sans sudo (`USER_LOCAL_MODE`) vers `~/.local/bin`, `~/.local/share/pnpm` et `~/.npm-global` quand nécessaire.
- Gestion des configurations:
  - la logique privilégie les symlinks vers le dépôt pour garder un source of truth unique.
  - Sur Termux, `termux/termux.properties` ne force pas le plein écran: `fullscreen` et `use-fullscreen-workaround` restent désactivés pour éviter les zones noires ou marges mortes au-dessus du clavier Android.
  - La barre `extra-keys` Termux est désactivée avec `extra-keys = []`; ne pas utiliser `[[]]`, qui peut conserver une ligne vide.
- Dépendances externes: GitHub releases, Starship install script, curl, npm/node, Doppler, gh, npx, outils système selon composants. Sur Termux, le périmètre est limité à `pkg`, Neovim, outils de recherche/navigation, Starship/Zoxide/Ranger et font Nerd Font.
- ESLint est un outil Node global de la station, désormais installé via `pnpm` dans `PNPM_HOME` quand disponible, avec compatibilité `~/.npm-global` pour les anciennes stations. Il sert de bibliothèque au serveur ESLint installé par Mason pour Neovim. Le serveur ne s'attache qu'aux arborescences déclarant une configuration ESLint afin de ne pas appliquer de règles implicites à des fichiers arbitraires.

## État documenté et preuves

- Entrée principale install:
  - `/home/claude/dotfiles/install.sh`
- Bibliothèque d'exécution:
  - `/home/claude/dotfiles/lib.sh`
- Paramètres centralisés:
  - `/home/claude/dotfiles/config.sh`
- Démarrage multi-plateforme:
  - `/home/claude/dotfiles/bootstrap.sh`
  - `/home/claude/dotfiles/install-termux.sh`
  - `/home/claude/dotfiles/termux.sh`
  - `/home/claude/dotfiles/windows.ps1`
- Documentation de produit:
  - `/home/claude/dotfiles/README.md`
  - `/home/claude/dotfiles/CLAUDE.md`
  - `/home/claude/dotfiles/starship/README.md`

## Dépendances documentaires

- Sources internes obligatoires:
  - `README.md` (installation, objectifs, liste d'inclus).
  - `CLAUDE.md` (invariants d'agent + commandes clé).
  - `.env.example` / `env.example` (variables observables de comportement).
  - `starship/README.md`, `nvim/README.md`, `ranger/rc.conf`, `mcp/mcp-servers.json`.
- Sources d'exécution:
  - `install.sh`, `lib.sh`, `config.sh`.
- Sources externes recommandées (non incluses en snapshot):
  - docs officielles de Starship, Neovim, Ranger, MCP, Doppler, GitHub CLI.

## Gaps et points d'attention

- Le `README.md` référence un ensemble de guides `docs/...` absents dans ce répertoire racine au moment de la génération.
- La base de configuration peut évoluer vite (MCP/AI tools), maintenir la cohérence entre `config.sh` et `install.sh` lors de tout ajout.
- Le profil Termux ne doit pas réintroduire Node.js, GitHub CLI, Doppler, MCP, Copilot, Claude/Codex/OpenCode, Aider ou agents Neovim; il cible Markdown seulement.
- Les dépendances de santé (`run_health_check`) doivent rester alignées avec les composants réellement installés via `DOTFILES_ONLY`.
- Le panneau explorateur Neovim partage sa largeur via `nvim/MyNeovim/lua/config/explorer-panel.lua`; `shipflow` expose `ShipFlowExplorerWidth20`, `ShipFlowExplorerWidth35` et `ShipFlowExplorerWidthFull` avec les mappings `<leader>e2`, `<leader>e3`, `<leader>eF` pour Snacks et Neo-tree.
