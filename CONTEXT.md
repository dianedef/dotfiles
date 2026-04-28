---
artifact: technical_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
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
  - "/home/claude/dotfiles/ARCHITECTURE.md"
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit CONTEXT.md
---

# CONTEXT

## Contexte métier
Ce dépôt regroupe un ensemble de configurations locales (terminal, éditeur, file managers, prompts, MCP, assistants IA) avec un pipeline d'installation automatisé. L'objectif est de reconstituer un poste de travail homogène sur Linux/Codespaces, Termux et Windows.

## Architecture réelle observée

- Couche installation:
  - `bootstrap.sh` installe prérequis, clone/actualise le dépôt puis délègue à `install.sh`.
  - `install.sh` est le point d'entrée principal et pilote toutes les phases.
  - `lib.sh` contient le socle utilitaire: parsing d'options, installation, santé, symlinks, auth, menu, logs.
  - `config.sh` concentre les constantes runtime: versions, chemins, flags, listes de composants.
- Couche configuration:
  - Répertoires de configs versionnés: `nvim/`, `yazi/`, `ranger/`, `starship/`, `ghostty/`.
  - Fichiers dédiés: `.tmux.conf`, `.env.example`, `cheat/conf.yml`, `mcp/mcp-servers.json`, `codex/config.toml`, `lazygit/config.yml`, `cursor/settings.json`, `ranger/...`.
- Couche secrets/AI:
  - `doppler-setup.sh` et `doppler-setup-termux.sh` gèrent la configuration d'accès.
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
  - mode local sans sudo (`USER_LOCAL_MODE`) vers `~/.local/bin` et `~/.npm-global` quand nécessaire.
- Gestion des configurations:
  - la logique privilégie les symlinks vers le dépôt pour garder un source of truth unique.
- Dépendances externes: GitHub releases, Starship install script, curl, npm/node, Doppler, gh, npx, outils système selon composants.

## État documenté et preuves

- Entrée principale install:
  - `/home/claude/dotfiles/install.sh`
- Bibliothèque d'exécution:
  - `/home/claude/dotfiles/lib.sh`
- Paramètres centralisés:
  - `/home/claude/dotfiles/config.sh`
- Démarrage multi-plateforme:
  - `/home/claude/dotfiles/bootstrap.sh`
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
  - `starship/README.md`, `nvim/README.md`, `ranger/rc.conf`, `yazi/yazi.toml`, `mcp/mcp-servers.json`.
- Sources d'exécution:
  - `install.sh`, `lib.sh`, `config.sh`.
- Sources externes recommandées (non incluses en snapshot):
  - docs officielles de Starship, Yazi, Neovim, Ranger, MCP, Doppler, GitHub CLI.

## Gaps et points d'attention

- Le `README.md` référence un ensemble de guides `docs/...` absents dans ce répertoire racine au moment de la génération.
- La base de configuration peut évoluer vite (MCP/AI tools), maintenir la cohérence entre `config.sh` et `install.sh` lors de tout ajout.
- Les dépendances de santé (`run_health_check`) doivent rester alignées avec les composants réellement installés via `DOTFILES_ONLY`.
