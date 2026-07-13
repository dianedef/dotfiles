---
artifact: technical_context
metadata_schema_version: "1.0"
artifact_version: "0.1.2"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-07-13"
status: draft
source_skill: sf-docs
scope: function_tree
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: low
docs_impact: yes
evidence:
  - "/home/claude/dotfiles/dotfiles/install.sh"
  - "/home/claude/dotfiles/dotfiles/lib.sh"
  - "/home/claude/dotfiles/dotfiles/config.sh"
  - "/home/claude/dotfiles/dotfiles/termux.sh"
  - "/home/claude/dotfiles/dotfiles/doppler-setup.sh"
depends_on:
  - "/home/claude/dotfiles/AGENT.md"
  - "/home/claude/dotfiles/shipglowz_data/technical/context.md"
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit shipglowz_data/technical/context-function-tree.md
---

# CONTEXT-FUNCTION-TREE

## Entrée principale

- `bootstrap.sh` (entrée réseau one-click) appelle `install.sh`.
- `install.sh` est l'orchestrateur machine-agnostique.
- `install-termux.sh` est le bootstrap réseau Termux: il installe `git`, `curl`, `bash`, clone ou met à jour `~/dotfiles`, puis délègue à `termux.sh`.
- `termux.sh` est une alternative légère pour Android, centrée Markdown, sans Node.js, GitHub CLI, Doppler, MCP, Copilot, Claude/Codex/OpenCode, Aider ou agents Neovim.

## Arbre fonctionnel (`install.sh`)

### Initialisation

- `install.sh` charge `SCRIPT_DIR`.
- `install.sh` source `config.sh`.
- `install.sh` source `lib.sh`.
- `parse_arguments` (lib) lit `--dry-run`, `--check`, `--only`, `--update`, `--uninstall`, `--parallel`, `--help`.
- Chargement de `.env` si présent.
- `init_logging`, `setup_error_traps`, `detect_system`.

### Modes spéciaux (early exits)

- `run_health_check` (lib) si `DOTFILES_CHECK_MODE=true`.
- `run_uninstall` (lib) si `DOTFILES_UNINSTALL_MODE=true`.
- `run_interactive_update` (lib) si `DOTFILES_UPDATE_MODE=true`.

### Installation des composants (flow séquentiel)

- Préparation:
  - `setup_user_local_mode` si mode local.
  - `get_user_info` puis config git utilisateur.
- Groupe Outils:
  - `install_neovim`
  - `install_fzf`
  - `install_nerd_fonts`
  - `install_gh`
  - `install_lsd`
  - `install_bat`
- Groupe Runtime:
  - `install_node`
  - `install_npm_tools`
    - installe les paquets globaux avec `install_node_global_package`
    - valide Codex ACP avec `verify_codex_acp_installation`
    - interrompt l'installation si le lanceur ou le runtime natif manque
- Groupe Shell:
  - `install_starship`
  - `install_zoxide`
  - `install_doppler`
- Groupe IA:
  - `install_ai_tools` (inclut Claude CLI, Codex, NPM tools)
- Intégration:
  - `setup_configs`
  - `setup_mcp_config`
  - `setup_shell_integration`
- Plugins optionnels:
  - `Lazy! sync` si `AUTO_INSTALL_NVIM_PLUGINS=true`.
- Auth:
  - phase GitHub + Doppler selon disponibilité et flags.

### Concurrence

- `parallel_run` (lib) peut exécuter en parallèle certains blocs.
- `parallel_wait` clôture une vague de tâches.
- `should_install` (lib) filtre via `--only`.

### Sorties et vérification

- `run_health_check` :
  - vérifie `Neovim`, `Starship`, `Doppler`, `mcpc`, Codex ACP, alias/symlinks, `.bashrc`.

## Arbre fonctionnel (`lib.sh`)

- `log`, `success`, `warn`, `error`, `info`.
- `init_logging`, `setup_error_traps`, `error_trap_handler`.
- `detect_system`, `get_install_path`, `is_installed`.
- `create_symlink`, `append_to_bashrc`, `health_check_tool`, `health_check_symlink`.
- Helpers Codex ACP:
  - `codex_acp_platform_package` choisit le paquet natif OS/architecture.
  - `resolve_codex_acp_native_binary` couvre les implantations globales npm et PNPM.
  - `verify_codex_acp_installation` exige le lanceur et un runtime natif exécutable.
  - `health_check_codex_acp` expose le résultat dans `--check`.
  - `install_node_global_package` conserve les dépendances optionnelles pour Codex ACP.
- `parse_arguments`, `show_help`.
- `install_system_packages`, `install_gum`, `install_neovim` (legacy fallback), `install_ai_tools_legacy` via `run_single_component`.
- `run_health_check`, `run_uninstall`, `run_interactive_update`.
- Helpers de maintenance:
  - `run_update`, `refresh_cache`, `invalidate_cache`, `download_file`, `download_verified`.
- Helpers shell:
  - `setup_shell_integration` fonctions appelées par l'orchestrateur.

## Arbre fonctionnel par script de configuration

- `config.sh`:
  - variables runtime (`DOTFILES_DIR`, `DOTFILES_BIN_DIR`, flags SKIP*, versions),
  - liste composants `DOTFILES_ALL_COMPONENTS`,
  - configuration d'outils.
- `termux.sh`:
  - installation allégée pour Markdown et petits fichiers,
  - cible appelée par `install-termux.sh` pour l'installation en une commande,
  - installation `starship`, `zoxide`, `ranger`,
  - symlink config vers `nvim/MyNeovimTermux`, `ranger`, `starship-simple.toml`,
  - exclusion explicite agents IA, MCP et tooling web.
- `doppler-setup.sh`:
  - setup projet Doppler, vérification clés, auto-auth GitHub.

## Modules de configuration liés

- `nvim/`:
  - `MyNeovim` (configs principales), `MyNeovimTermux` (variant Android), `shell-integration.sh`.
- `starship/`:
  - `starship.toml`, `starship-simple.toml`, `starship-switch.sh`.
- `ranger/`:
  - `rc.conf`, `rifle.conf`, `commands.py`, `commands_full.py`, plugin `devicons.py`.
- `mcp/`:
  - `mcp-servers.json`.
- `codex/`:
  - `config.toml`.
- `lazygit/`, `ghostty/`, `tmux`, `cheat`, `mpv` : actifs selon disponibilité.

## Preuves liées

- `install.sh` contient explicitement l'ordre: dépendances -> outils -> node -> shell tools -> shell integration -> MCP -> auth.
- `setup_configs` enchaîne les symlinks `nvim`, `ranger`, `starship`, `tmux`, `ghostty`.
- `setup_mcp_config` publie seulement le registre MCP partagé sous `~/.config/mcp/servers.json`; les fichiers runtime Claude/Codex sont gérés par ShipGlowz.
- `termux.sh` montre clairement la voie Android Markdown-only.
