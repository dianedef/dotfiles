---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: "dotfiles"
created: "2026-07-13"
updated: "2026-08-27"
status: ready
source_skill: 300-sg-docs
scope: avante-codex-acp-operator-guide
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - dotfiles/install.sh
  - dotfiles/lib.sh
  - dotfiles/config.sh
  - nvim/MyNeovim/lua/plugins/avante.lua
  - nvim/MyNeovim/tests/codex-acp-lifecycle.lua
depends_on:
  - shipglows_data/workflow/bugs/BUG-2026-07-13-002.md
supersedes: []
evidence:
  - "The installer pins @zed-industries/codex-acp@0.16.0 and validates its native runtime."
  - "The focused installer and lifecycle regressions pass on Linux ARM64."
  - "Avante resolves the native executable instead of launching the JavaScript wrapper when the native runtime is available."
next_review: "2026-08-13"
next_step: "/103-sg-verify BUG-2026-07-13-002"
---

# Guide sûr : Avante et Codex ACP

## À retenir

Tu n'as normalement rien à lancer ni à arrêter manuellement pour Codex ACP.

- L'installateur des dotfiles installe la version compatible avec Avante.
- Avante démarre Codex ACP quand il en a besoin.
- `Espace a x s`, `:AvanteStop` ou la fermeture normale de Neovim arrêtent le processus.
- Si une vérification échoue, ne supprime aucun dossier et n'exécute pas de commande globale pour tuer Codex. Copie simplement le résultat pour le transmettre à un agent.

## Ce qui a été corrigé

L'ancien démarrage passait par un petit lanceur JavaScript. Avante arrêtait ce lanceur, mais le processus natif pouvait rester actif en arrière-plan.

Le correctif comporte maintenant deux protections :

1. l'installateur vérifie que le vrai programme natif correspondant au système et à l'architecture est présent et exécutable ;
2. Avante lance directement ce programme natif afin de pouvoir l'arrêter proprement.

Le correctif couvre donc le serveur actuel **et** les prochaines installations réalisées avec ces dotfiles.

## Installation normale sur une nouvelle machine

Depuis le dépôt des dotfiles :

```bash
cd ~/.dotfiles
./dotfiles/install.sh
```

Pendant la phase des outils Node, le script :

1. installe `@zed-industries/codex-acp@0.16.0` ;
2. autorise l'installation du paquet natif propre à la machine ;
3. vérifie le lanceur `codex-acp` ;
4. localise le vrai binaire natif ;
5. vérifie que ce binaire répond ;
6. arrête l'installation avec une erreur claire si l'ensemble est incomplet.

L'échec est volontaire : une installation interrompue vaut mieux qu'une installation annoncée comme réussie alors qu'Avante ne pourrait pas fonctionner correctement.

### Windows natif

L'installateur PowerShell installe exactement `@zed-industries/codex-acp@0.16.0` avec `pnpm` ou `npm` deja present. Il exige ensuite le lanceur `codex-acp.cmd` et le binaire optionnel `codex-acp-win32-x64` ou `codex-acp-win32-arm64`, puis verifie ce binaire avec `--help`. Une reussite du gestionnaire Node sans ces postconditions devient une erreur actionnable; aucun store npm/pnpm n'est supprime.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1 -DryRun -Only codex-acp
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1 -Only codex-acp
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install-dotfiles.ps1 -Check -Only codex-acp
```

Avante utilise le script upstream `Build.ps1 -BuildFromSource false` sous Windows. Telescope reste utilisable sans `telescope-fzf-native`: l'extension est desactivee proprement quand CMake et un compilateur compatible sont absents, et elle reste construite sous Linux/macOS quand les prerequis existent.

Avec pnpm 11, le lanceur global peut vivre sous `%LOCALAPPDATA%\pnpm\bin` tandis que le lien du paquet natif vit dans une instance sous `global\v11\<instance>\node_modules\.pnpm\node_modules`. Le resolveur suit ces emplacements deterministes et le lien officiel du paquet; il ne parcourt ni ne supprime le store pnpm. Pendant `-Update`, le code WinGet signifiant qu'aucune mise a niveau applicable n'existe est traite comme un etat deja converge, sans masquer les autres codes d'erreur.

## Vérification sans rien modifier

La vérification générale des dotfiles est :

```bash
cd ~/.dotfiles
./dotfiles/install.sh --check
```

Cherche cette ligne :

```text
✓ Codex ACP native runtime: /chemin/vers/codex-acp
```

Le contrôle général peut aussi signaler d'autres outils facultatifs absents. Pour vérifier uniquement Codex ACP :

```bash
bash -lc 'source "$HOME/.dotfiles/dotfiles/config.sh"; source "$HOME/.dotfiles/dotfiles/lib.sh"; health_check_codex_acp'
```

Cette commande ne réinstalle rien et ne supprime rien.

## Utilisation quotidienne dans Neovim

- `Espace a x t` : ouvrir ou fermer Avante.
- `Espace a x c` : ouvrir le chat Avante.
- `Espace a x q` : poser une question.
- `Espace a x s` : arrêter la génération et Codex ACP.
- `:AvanteStop` : autre manière d'effectuer le même arrêt.

Après un usage normal, il n'est pas nécessaire de rechercher ou tuer des processus.

## Contrôle ponctuel après un crash

Un contrôle est utile seulement après un crash brutal de Neovim, une fermeture forcée du terminal ou un redémarrage incomplet.

```bash
ps -eo pid=,ppid=,etimes=,stat=,comm=,args= | awk '$2 == 1 && $5 == "codex-acp" {print}'
```

- **Aucune sortie** : aucun processus Codex ACP orphelin n'a été trouvé.
- **Une ou plusieurs lignes** : ne les tue pas à l'aveugle. Copie les lignes et demande une vérification.

## En cas d'échec de l'installation

1. Ne supprime pas `~/.local/share/pnpm`, `~/.npm-global`, `~/.codex` ou la configuration Neovim.
2. Ne lance pas `pkill codex`, `pkill -f codex` ou une commande équivalente.
3. Ne remplace pas manuellement le paquet installé.
4. Copie la fin du message d'erreur.
5. Exécute le contrôle ciblé ci-dessus et copie son résultat.
6. Transmets les deux résultats à un agent avec le modèle ci-dessous.

```text
J'ai un problème avec Avante / Codex ACP dans les dotfiles.

Contexte : installation / vérification / usage Neovim
Message d'erreur :
[coller ici]

Résultat de health_check_codex_acp :
[coller ici]

Résultat du contrôle des processus orphelins :
[coller ici, ou écrire « aucune sortie »]

Merci de ne supprimer aucun store PNPM/NPM et de vérifier d'abord l'installateur des dotfiles.
```

Ne copie jamais de jeton, de cookie, de clé API ou de contenu privé dans ce rapport.

## Manipulations à éviter

- Ne pas installer `codex-acp` avec une autre version « pour essayer ».
- Ne pas remplacer manuellement `@zed-industries/codex-acp@0.16.0` par `@agentclientprotocol/codex-acp`.
- Ne pas modifier directement les fichiers installés sous `~/.local/share/pnpm` ou `~/.npm-global`.
- Ne pas supprimer tout le store PNPM pour réparer un seul paquet.
- Ne pas tuer tous les processus contenant le mot `codex`, car cela pourrait interrompre d'autres sessions en cours.

La version `0.16.0` est épinglée volontairement : la configuration Avante actuelle utilise ses arguments `-c`. Le successeur officiel utilise une autre interface de configuration et devra être adopté dans une migration séparée, avec ses propres tests.

## Preuve technique disponible

Les validations automatisées sont destinées aux agents ou aux mainteneurs :

```bash
cd ~/.dotfiles
bash tests/codex-acp-installation.sh
nvim --headless -u NONE -l nvim/MyNeovim/tests/codex-acp-lifecycle.lua
```

La preuve locale actuelle porte sur Linux ARM64. Le résolveur contient aussi les correspondances Linux, macOS et Windows en `x64` ou `arm64`, mais ces autres plateformes doivent être vérifiées sur leurs machines respectives avant d'affirmer une parité complète.

## Maintenance Rule

Mettre à jour ce guide si la version du paquet change, si Avante change son contrat ACP, si les chemins PNPM/NPM changent, ou si les commandes d'arrêt et de vérification évoluent.
