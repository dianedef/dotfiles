---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-06-19"
created_at: "2026-06-19 22:07:26 UTC"
updated: "2026-06-19"
updated_at: "2026-06-19 22:17:00 UTC"
status: partial
source_skill: 100-sf-spec
source_model: "GPT-5 Codex"
scope: feature
owner: "dianedef"
user_story: "En tant que developpeuse, je veux examiner tous les fichiers modifies dans une vue Git unique et modifier directement mon cote du diff, afin de valider puis corriger mes changements sans naviguer fichier par fichier."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - Neovim
  - lazy.nvim
  - Neogit
  - Git
  - difftastic
depends_on:
  - artifact: "shipflow_data/technical/context.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "shipflow_data/editorial/content-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "nvim/MyNeovim/lua/neogit/integrations/codediff.lua now shadows Neogit's codediff backend with a local Difftastic snapshot renderer."
  - "nvim/MyNeovim/lua/diffflowz/init.lua validates Git context and opens the inline review for working-tree or staged changes."
  - "difftastic 0.69.0 is installed as difft and renders a single-column terminal diff, not an editable diff-buffer engine."
next_step: "/101-sf-ready shipflow_data/workflow/specs/diffflowz-editable-git-review.md"
---

# Spec: DiffFlowz Editable Git Review

## Title

DiffFlowz Editable Git Review

## Status

partial

## User Story

En tant que developpeuse, je veux examiner tous les fichiers modifies dans une vue Git unique et modifier directement mon cote du diff, afin de valider puis corriger mes changements sans naviguer fichier par fichier.

## Minimal Behavior Contract

Depuis Neovim, DiffFlowz valide le depot Git courant puis ouvre une revue inline Difftastic des fichiers modifies, soit pour le working tree, soit pour les changements indexes sur demande. La vue reste en un seul rendu vertical, sans side-by-side, et la selection des fichiers reste cote Neogit pour le staging/unstaging. Si le buffer courant n'est pas dans un depot Git, ou si Git ne peut pas fournir un diff, DiffFlowz affiche une erreur explicite sans creer de vue partielle.

## Success Behavior

- Preconditions: Neovim est ouvert dans un depot Git avec au moins un fichier modifie ou indexe.
- Trigger: l'utilisatrice lance `:DiffFlowz` ou le mapping `<leader>gT`.
- User/operator result: une vue inline Difftastic s'ouvre en un seul panneau; on peut parcourir tous les fichiers modifies sans passer par un split original/actuel.
- System effect: aucune ecriture Git n'est effectuee par DiffFlowz; Neogit conserve la main pour le staging/unstaging et l'edition se fait dans les buffers fichiers normaux.
- Success proof: commande Neovim headless chargeable et test manuel d'ouverture, navigation, fermeture et retour au buffer fichier dans un depot temporaire.
- Silent success: not allowed; la vue et les erreurs passent par `vim.notify`.

## Error Behavior

- Expected failures: buffer hors depot Git, executable `git` absent, depot sans changements, ou appel a la vue staged sans changements indexes.
- User/operator response: notification claire indiquant la cause et le mode concerne.
- System effect: aucune mutation de fichier ni de l'index Git; aucune session partielle ne doit rester ouverte apres un echec de preparation.
- Must never happen: ecrasement du fichier de travail par le cote historique, ajout/commit/stage implicite, ou shell interpolation d'un chemin Git.
- Silent failure: not allowed; les erreurs de preparation sont notifiees et le code retourne sans side effect.

## Problem

Le mapping Difftastic actuel est une vue terminale d'un seul fichier, non editable et sans liste de fichiers. Le prototype qui forçait Diffview imposait un double rendu origine/actuel, ce qui contredisait le besoin de revue inline unique. La bonne integration doit donc rester dans Neogit et produire un rendu unifié, pas un viewer a deux panes.

## Solution

Creer un module local `diffflowz` qui valide le contexte Git puis delegue l'ouverture inline a un backend local `neogit.integrations.codediff` shadowant le viewer upstream. Ce backend materialise des snapshots temporaires des fichiers compares et lance `difft --display=inline` pour garder un rendu unique. Conserver `:Difftastic` comme preview ponctuelle, sans le faire passer pour un buffer editable.

## Scope In

- Commandes `:DiffFlowz`, `:DiffFlowzStaged` et `:DiffFlowzClose`.
- Mappings Git dedies a DiffFlowz, sans collision avec les mappings Neogit ou LazyGit existants.
- Ouverture d'une session inline Difftastic pour les changements working tree, staged ou de plage.
- Validation robuste du depot et des changements avant ouverture.
- Shadow local de `neogit.integrations.codediff` pour reutiliser les popups Neogit avec le meme backend inline.
- Documentation courte dans `nvim/README.md`.

## Scope Out

- Reimplementation du moteur d'alignement syntaxique de Difftastic dans les buffers Neovim.
- Edition directe du texte rendu par Difftastic comme source de verite.
- Fork ou PR Neogit dans cette premiere version.
- Staging, commit, conflits de merge ou remplacement du buffer fichier par le diff rendu.
- Support Termux; le profil reste volontairement minimal.

## Constraints

- Reutiliser `difft` comme renderer unique pour la review inline.
- Ne pas modifier `install.sh`, `lib.sh`, `config.sh` ni ajouter de dependance d'installation.
- Les commandes Git doivent utiliser `vim.system`/argv, sans concatener de chemins shell.
- Les snapshots temporaires doivent etre nettoyes a la fermeture de la vue.

## Dependencies

- Runtime: `git`, Neovim 0.10+, `sindrets/diffview.nvim`; `difft` reste optionnel pour la commande de rendu existante.
- Document contracts: `shipflow_data/technical/context.md` 0.1.0 et `shipflow_data/editorial/content-map.md` 1.0.0.
- Metadata gaps: `context.md` est draft, mais il couvre la configuration Neovim et ne bloque pas ce chantier local.
- Fresh external docs: fresh-docs not needed; la premiere version compose des interfaces locales deja presentes et n'actualise aucune API externe.

## Invariants

- DiffFlowz garde un rendu inline unique, jamais un split origine/actuel.
- L'edition reste celle des buffers fichiers normaux, jamais une sortie ANSI de Difftastic.
- Aucun appel n'indexe, ne commit ou ne remplace un fichier sans action Git explicite de l'utilisatrice.
- Les commandes ne doivent pas ouvrir de session apres un echec de precondition.

## Links & Consequences

- Upstream systems: LazyVim charge les specs depuis `nvim/MyNeovim/lua/plugins`; Neogit et Diffview consomment Git.
- Downstream systems: les buffers Diffview et les sauvegardes Neovim modifient le working tree selon le comportement standard de Neovim.
- Cross-cutting checks: compatibilite lazy.nvim, absence de monkey patch Neogit, mapping discoverable, aucune regression des mappings Diffview existants.

## Documentation Coherence

- Mettre a jour `nvim/README.md` avec les commandes et l'explication courte: DiffFlowz est la vue inline multi-fichiers; Difftastic reste une vue syntaxique ponctuelle.
- Aucun README racine, FAQ, pricing, contenu public ou onboarding d'installation n'est impacte.

## Edge Cases

- Depot Git sans changements: notifier et ne pas ouvrir la vue.
- Depot avec seulement changements indexes: `DiffFlowzStaged` ouvre la vue staged inline.
- Fichier nouveau, supprime ou renomme: le backend inline reste source de verite de presentation et n'ecrase aucun contenu.
- Appel depuis un buffer sans fichier ou hors depot: notifier et retourner.
- `difft` absent: DiffFlowz s'arrete avec une erreur explicite.

## Implementation Tasks

- [x] Task 1: Retirer le prototype qui force Difftastic dans Neogit.
  - File: `nvim/MyNeovim/lua/plugins/neogit.lua`
  - Action: supprimer les hooks `package.preload` et `get_diff_viewer`; conserver la configuration Neogit existante.
  - User story link: evite de casser la surface Git principale en essayant de remplacer son renderer.
  - Depends on: None.
  - Validate with: `nvim --headless '+Lazy! load neogit' '+lua require("neogit")' +qa`.
  - Notes: supprimer aussi les modules locaux devenus orphelins.

- [x] Task 2: Creer le module DiffFlowz et ses commandes.
  - File: `nvim/MyNeovim/lua/diffflowz/init.lua`
  - Action: detecter le root Git avec `vim.fs.root`, verifier les changements par `vim.system`, puis lancer `DiffviewOpen` ou `DiffviewOpen --staged`; exposer `open`, `open_staged` et `close`.
  - User story link: fournit l'entree unique vers la revue multi-fichiers.
  - Depends on: Task 1.
  - Validate with: `nvim --headless '+lua require("diffflowz")' +qa`.
  - Notes: argv only for Git; `vim.cmd` est limite aux commandes Diffview constantes.

- [x] Task 3: Declarer DiffFlowz dans la configuration Diffview et les mappings.
  - File: `nvim/MyNeovim/lua/plugins/diffview.lua`
  - Action: charger le module au demarrage, creer les commandes et ajouter `<leader>gT`.
  - User story link: rend le flux utilisable en une action depuis Neovim.
  - Depends on: Task 2.
  - Validate with: `nvim --headless '+lua assert(vim.fn.exists(":DiffFlowz") == 2)' +qa`.
  - Notes: ne pas ecraser `<leader>gf`, `<leader>gF`, `<leader>gv`, `<leader>gV` ni `<leader>gq`, deja utilises par LazyGit ou Diffview.

- [x] Task 4: Nettoyer le raccourci Difftastic mono-fichier et documenter les roles.
  - File: `nvim/MyNeovim/lua/config/keymaps.lua`
  - Action: conserver `:Difftastic` comme vue de rendu ponctuelle mais retirer son mapping si DiffFlowz devient le point d'entree Git principal.
  - User story link: reduit les actions et la confusion entre preview ANSI et edition.
  - Depends on: Task 3.
  - Validate with: `nvim --headless '+lua assert(vim.fn.exists(":Difftastic") == 2)' +qa`.
  - Notes: `:Difftastic` reste disponible pour inspection syntaxique d'un fichier.

- [x] Task 5: Documenter et verifier le flux par les commandes Neovim headless et la checklist interactive.
  - File: `nvim/README.md`
  - Action: ajouter une section DiffFlowz avec les commandes, comportements editables et limites Difftastic.
  - User story link: rend le workflow reproductible sans retour a la conversation.
  - Depends on: Tasks 1-4.
  - Validate with: headless command checks plus manuel: creer un fichier modifie, lancer DiffFlowz, naviguer, modifier le working tree, sauvegarder et fermer.
  - Notes: evidence-first; l'UI Neovim terminal ne possede pas de test automatise existant.

## Acceptance Criteria

- [ ] AC 1: Given un depot avec plusieurs fichiers modifies, when `:DiffFlowz` est execute, then la vue inline s'ouvre avec tous les fichiers combines dans un seul rendu.
- [ ] AC 2: Given un depot avec des changements indexes, when `:DiffFlowzStaged` est execute, then la vue staged inline s'ouvre.
- [ ] AC 3: Given un depot sans changement, when `:DiffFlowz` est execute, then une notification explique qu'il n'y a rien a comparer et aucune nouvelle vue ne s'ouvre.
- [ ] AC 4: Given Neogit charge apres DiffFlowz, when le popup diff Neogit est utilise, then il utilise le backend local inline sans erreur de viewer inconnu.
- [ ] AC 5: Given `difft` absent, when `:DiffFlowz` est execute dans un depot modifie, then une erreur explicite est affichee et aucune vue n'est ouverte.

## Test Strategy

- Unit: aucune infrastructure de test Lua locale; les preconditions Git sont verifiees par commandes Neovim headless ciblees.
- Integration: verifier le chargement lazy.nvim, les commandes et les imports; tester dans un depot Git temporaire avec working tree, index et range compare.
- Manual: ouvrir DiffFlowz dans Neovim interactif, parcourir la revue inline, fermer la vue, puis revenir au buffer fichier pour l'edition.

## Test Contract

### Surface

- Stack/surface: Neovim Lua plugin configuration.
- Primary proof mode: mixed.
- Proof order (if applicable): automated headless -> Git integration -> manual Neovim terminal.

### Manual checklist

- Needed: yes.
- Checklist path: `shipflow_data/workflow/test-checklists/diffflowz-editable-git-review.md`.
- Required scenario coverage: `DF-01 multi-file working tree`, `DF-02 buffer edit outside diff`, `DF-03 no changes`, `DF-04 staged`, `DF-05 Neogit regression`.
- Exception with proof: Difftastic's terminal UI has no local automated visual harness; commands/imports and a reproducible manual checklist provide alternate evidence.

### Required evidence stack

- Automated / unit / integration checks: `nvim --headless` command/import checks; `stylua --check` when available.
- Agent-run browser proof: not applicable.
- Auth/session proof (`sf-auth-debug`): not applicable.
- Contract/integration proof: temporary Git repository checks for working-tree, staged and empty states.
- Provider evidence: not applicable.
- Device-native proof: not applicable.

## Risks

- Security impact: none, because DiffFlowz is local-only, does not execute repository-provided code and invokes Git through fixed argv.
- Product/data/performance risk: large repositories can make initial snapshot generation slower; the plugin delegates file filtering to Git and only snapshots the compared paths.

## Execution Notes

- Read first: `nvim/MyNeovim/lua/plugins/neogit.lua`, `nvim/MyNeovim/lua/diffflowz/init.lua`, `nvim/MyNeovim/lua/config/keymaps.lua`, `nvim/MyNeovim/lua/neogit/integrations/codediff.lua`.
- Approach: add the inline Difftastic backend -> route DiffFlowz into it -> configure Neogit to use the same backend -> preserve `:Difftastic` as optional single-file preview -> document -> run headless plus temporary-repository proof.
- Validate with: `nvim --headless '+Lazy! sync' +qa`, command existence/import assertions, `stylua --check nvim/MyNeovim/lua/diffflowz nvim/MyNeovim/lua/neogit/integrations/codediff.lua`, and the manual checklist.
- Stop conditions: Difftastic command unavailable after lazy load, a mapping collision that changes existing behavior, or the backend cannot snapshot the compared paths.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-19 22:07:26 UTC | 100-sf-spec | GPT-5 Codex | Created spec for DiffFlowz editable Git review | draft | /101-sf-ready shipflow_data/workflow/specs/diffflowz-editable-git-review.md |
| 2026-06-19 22:10:00 UTC | 101-sf-ready | GPT-5 Codex | Reviewed behavior, scope, error states, proof contract and Neogit boundary | ready | /102-sf-start shipflow_data/workflow/specs/diffflowz-editable-git-review.md |
| 2026-06-19 22:14:00 UTC | 102-sf-start | GPT-5 Codex | Removed the Neogit renderer patch; added DiffFlowz commands, Diffview mapping, documentation and manual checklist | implemented | /103-sf-verify shipflow_data/workflow/specs/diffflowz-editable-git-review.md |
| 2026-06-19 22:17:00 UTC | 103-sf-verify | GPT-5 Codex | Verified formatting, imports, commands, Diffview lazy loading and Neogit loading; interactive scenarios remain unrun | partial | /107-sf-test shipflow_data/workflow/test-checklists/diffflowz-editable-git-review.md |

## Current Chantier Flow

- `100-sf-spec`: done, draft spec created.
- `101-sf-ready`: ready; adversarial review passed. The only renderer/edition boundary is explicit: Difftastic output is never an editable buffer.
- `102-sf-start`: implemented; headless command, import, lazy-load, formatting and diff-whitespace checks passed.
- `103-sf-verify`: partial; headless proof passed, but DF-01 through DF-05 require interactive Neovim proof.
- `104-sf-end`: not launched.
- `005-sf-ship`: not launched.

Next step: `/107-sf-test shipflow_data/workflow/test-checklists/diffflowz-editable-git-review.md`
