---
artifact: competitive_intelligence
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "dotfiles"
created: "2026-05-11"
updated: "2026-05-11"
status: reviewed
source_skill: sf-veille
scope: "project-competitors-and-inspirations"
owner: "Diane"
confidence: low
risk_level: low
security_impact: none
docs_impact: yes
evidence:
  - "Initial inspiration triage captured in legacy root concurrent.md."
  - "Dotfiles primarily hosts reusable environment, editor, scripts, and agent workflow configuration."
depends_on:
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes:
  - "concurrent.md"
next_review: "2026-06-11"
next_step: "/sf-docs audit shipglows_data/business/project-competitors-and-inspirations.md"
target_projects:
  - dotfiles
reference_categories:
  - tool_inspiration
  - workflow_inspiration
source_policy: "Track public sources only; do not copy private positioning, paid assets, credentials, or non-public customer data."
---

# Concurrents et inspirations — dotfiles

## Lecture projet

`dotfiles` porte surtout la configuration réutilisable, les skills, les scripts et l'environnement de travail. Les liens fournis ne contiennent pas de concurrent direct de dotfiles, mais plusieurs inspirations peuvent améliorer l'outillage agentique.

## Inspirations retenues

| Lien | Type | Score | Usage concret |
|---|---:|:---:|---|
| [Spec27](https://betalist.com/startups/spec27) | Inspiration validation | 6/10 | S'inspirer de la validation spec-driven pour tester skills, prompts et workflows CLI. |
| [MemoryPlugin](https://betalist.com/startups/memoryplugin) | Inspiration mémoire | 5/10 | Réfléchir à une mémoire persistante maîtrisée pour agents et sessions. |
| [DiffHook](https://betalist.com/startups/diffhook) | Inspiration veille | 5/10 | Surveiller changements de docs/outils qui impactent les scripts et skills. |
| [frp](https://github.com/fatedier/frp) | Inspiration réseau | 4/10 | Référence de tunnel à connaître, mais plutôt côté ShipGlows que dotfiles. |

## Statut

Pas de concurrent direct identifié dans la liste actuelle.
