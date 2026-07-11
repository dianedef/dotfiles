---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-05-22"
status: draft
source_skill: sf-docs
scope: technical
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: low
docs_impact: yes
evidence:
  - "/home/claude/dotfiles/install.sh"
  - "/home/claude/dotfiles/lib.sh"
  - "/home/claude/dotfiles/config.sh"
  - "/home/claude/dotfiles/bootstrap.sh"
  - "/home/claude/dotfiles/termux.sh"
  - "/home/claude/dotfiles/doppler-setup.sh"
depends_on:
  - "/home/claude/dotfiles/README.md"
  - "/home/claude/dotfiles/CLAUDE.md"
linked_systems:
  - Bash
  - Git
  - CLI
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit AGENT.md
---

# AGENT

## Mission
Maintenir la cohérence opérationnelle du dépôt `/home/claude/dotfiles` en respectant sa structure réelle: un orchestrateur Bash, une bibliothèque d'utilitaires partagée, une stratégie de déploiement multi-plateforme et des configurations versionnées liées par symlink.

## Contrôle initial obligatoire
Avant toute modification de logique, lire en priorité:

- `install.sh` pour l'orchestration d'exécution.
- `lib.sh` pour les helpers (parsing d'options, santé, symlinks, logs, installation).
- `config.sh` pour les paramètres de comportement et de composants.

## Règles de travail

- Préserver le flux de dépendance réel: `install.sh` -> `config.sh` + `lib.sh` -> installation système -> symlinks config -> intégration shell -> auth.
- Ne pas casser les modes `--dry-run`, `--check`, `--uninstall`, `--update`, `--only`, `--parallel`.
- Ne pas retirer les protections de sécurité déjà présentes:
  - fallback sans `.env`
  - `set -uo pipefail`
  - validation d'input simple (`validate_path`)
  - mode local sans sudo (`USER_LOCAL_MODE`)
- Éviter de changer la logique d'identité utilisateur sans suivre `get_user_info` et l'usage de `GITHUB_USERNAME`, `USER_NAME`, `USER_EMAIL`.
- Garder la séparation des cibles par plateforme:
  - installation complète: `install.sh`
  - installation allégée: `termux.sh`
  - bootstrap système: `bootstrap.sh`
  - bootstrap Windows: `windows.ps1` (référencé dans la doc racine).
- Conserver la stratégie de configuration:
  - `install.sh` doit d'abord installer outils + dépendances,
  - puis `setup_configs`,
  - puis `setup_mcp_config`,
  - puis `setup_shell_integration`,
  - puis auth optionnelle.

## Points de contrôle

### Preuves d'architecture à respecter
- `install.sh` source `config.sh` puis `lib.sh` avant le parsing d'options.
- `lib.sh` expose `parse_arguments`, `run_health_check`, `create_symlink`, `parallel_run`, `should_install`.
- `setup_configs` lie les répertoires réels `nvim`, `ranger`, `starship`, `tmux`, `ghostty`, `codex`, `claude`.
- `setup_mcp_config` lit `mcp/mcp-servers.json` et configure plusieurs clients.
- `setup_shell_integration` modifie `.bashrc` avec `starship init`, `zoxide init`, alias et exports.
- `termux.sh` utilise des chemins différents (MyNeovimTermux, `starship-simple.toml`, `~/.local/bin`) et reste limité à l'édition Markdown sur Android.

## Risques connus à surveiller

- Les dépendances de packages changent vite (NPM, GitHub release URLs, API keys). Toujours vérifier la compatibilité OS/arch.
- Le profil Termux ne doit pas réintroduire Node.js, GitHub CLI, Doppler, MCP, Copilot, Claude/Codex/OpenCode, Aider ou agents Neovim.
- Les chemins `.dotfiles-backup/*` peuvent croître si les scripts de symlink sont rejoués souvent.
- La référence à des guides `docs/` dans `README.md` ne correspond pas à un répertoire `docs` présent dans ce snapshot.

## Modèle de contribution recommandé

- Modifier les scripts uniquement pour:
  - fiabiliser les sorties de santé/trace,
  - corriger des régressions d'installation,
  - améliorer la portabilité des chemins.
- Documenter chaque décision de configuration dans `shipglowz_data/technical/context.md`, `shipglowz_data/technical/context-function-tree.md` ou `shipglowz_data/technical/README.md`.
- Éviter d'introduire des dépendances externes non déclarées dans `.env`/`env.example`.
