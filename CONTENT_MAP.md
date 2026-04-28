---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
status: reviewed
source_skill: manual
scope: content-map
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: low
docs_impact: high
evidence:
  - "README.md: point d’entrée principal avec liens d’installation"
  - "install.sh, termux.sh, windows.ps1, bootstrap.sh: surfaces d’action pour l’onboarding"
  - "config.sh and lib.sh: cœur réutilisable de l’automatisation"
  - "zoxide/README.md, starship/README.md, nvim/*, mpv/README.md: documentation locale des composants"
depends_on:
  - artifact: "README.md"
    required_status: active
  - artifact: "PRODUCT.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
next_review: "2026-07-26"
next_step: "/sf-repurpose"
content_surfaces:
  - "README.md | entrée officielle: onboarding, liens rapides, aperçu des composants"
  - "PRODUCT.md | contrat produit (objectif, problème, portée, risques)"
  - "GTM.md | message public, canaux, objections, preuves"
  - "BUSINESS.md | mission cible, valeur métier, indicateurs"
  - "BRANDING.md | ton, style, repères visuels et éditoriaux"
  - "CLAUDE.md | conventions opérationnelles pour l’agent"
  - "install.sh | canal principal d’activation: installation/rejeu/update/health/uninstall"
  - "termux.sh | canal dédié Android/Termux"
  - "windows.ps1 | canal dédié Windows"
  - "bootstrap.sh | canal d’entrée Ubuntu one-click"
  - "config.sh + lib.sh | support technique pour les scripts d’orchestration"
  - "sous-README par outil (zoxide, starship, nvim, mpv, ranger) | support ciblé par composant"
---

# Content Map

## But

`CONTENT_MAP.md` décrit où se trouvent les preuves produit et les contenus opérationnels du dépôt pour éviter que chaque tâche ne réexplique la structure.

## Surfaces de contenu

| Surface | Rôle | Type | Source | Déclencheur de mise à jour |
|---|---|---|---|---|
| `README.md` | Onboarding principal multi-plateforme | Markdown | Équipe / mainteneur du dépôt | Changement des commandes d’installation, ajout de plateforme |
| `PRODUCT.md` | Contrat produit | Markdown | Mainteneur | Changement de la promesse de valeur ou de la portée |
| `GTM.md` | Message d’acquisition et preuve | Markdown | Mainteneur / product docs | Nouvelle stratégie de diffusion ou de conversion |
| `BUSINESS.md` | Contexte métier | Markdown | Mainteneur | Changement de cible d’usage ou d’hypothèses business |
| `BRANDING.md` | Ton + repères visuels | Markdown | Mainteneur | Changement de la ligne éditoriale |
| `CLAUDE.md` | Règles d’exécution agent | Markdown | Mainteneur | Ajout de scripts, conventions de contribution |
| `install.sh` | Contrat d’exécution | Script | Mainteneur | Ajout de modes ou de nouvelles dépendances |
| `termux.sh` / `windows.ps1` / `bootstrap.sh` | Points d’entrée par plateforme | Scripts | Mainteneur | Adaptation d’UX d’installation |
| `config.sh` + `lib.sh` | Infrastructure de scripts | Scripts | Mainteneur | Changement de logique d’orchestration |
| README composants | Documentation locale | Markdown | Propriétaire de chaque composant | Nouvelle config ou breaking change locale |

## Règles de repurposing

- Pour toute amélioration de onboarding ou réduction de friction, prioriser `README.md` et ce `CONTENT_MAP.md`.
- Pour clarifier la promesse d’ensemble, écrire dans `PRODUCT.md` et `GTM.md` puis refléter la change dans le `README.md`.
- Pour la migration/installation, maintenir la source de vérité dans `install.sh`, `termux.sh`, `windows.ps1`, `bootstrap.sh`.
- Pour la documentation composant, lister les nouveaux points dans le README de dossier concerné.

## Liens de mise à jour

- `install.sh` change: mettre à jour la section "Quick Installation" du README et `PRODUCT.md` si la valeur (vitesse/fiabilité) change.
- `BUSINESS.md` / `PRODUCT.md` change: vérifier cohérence de `GTM.md` et de `BRANDING.md`.
- Ajout d’un nouveau `--only` dans install.sh: mettre à jour README (commandes), `CONTENT_MAP.md` (liste de composants), éventuellement `AGENT` docs.

## Gaps ouverts

- le README référence encore des chemins de docs absents (`docs/*`), à corriger ou à créer.
- ajouter une page de release notes pour suivre les versions de scripts d’installation.
