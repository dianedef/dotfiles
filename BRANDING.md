---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sf-docs
scope: brand
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: low
docs_impact: yes
brand_voice: "direct, fonctionnel, sans emphase"
trust_posture: "prévisible, vérifiable, orienté reproducibilité"
evidence:
  - "/home/claude/dotfiles/starship/README.md"
  - "/home/claude/dotfiles/nvim/README.md"
  - "/home/claude/dotfiles/README.md"
depends_on:
  - "/home/claude/dotfiles/CLAUDE.md"
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit BRANDING.md
---

# BRANDING.md

## Position visuelle

Ce dépôt privilégie des repères visuels cohérents, lisibles et sobres, avec une identité orientée productivité :

- Clarté fonctionnelle avant ornement.
- Contrastes nets pour améliorer la lisibilité en terminal.
- Cohérence entre prompt, shell, nvim, et outils associés.

## Langage et ton

- Direct, concis, orienté action.
- Documentation en anglais ou français selon le contexte équipe/usage local.
- Éviter les ambiguïtés techniques ; privilégier les étapes concrètes et testables.

## Palette d’interface (conseillée)

- Texte principal : `#E5E7EB`
- Accent fort : `#60A5FA`
- Accent secondaire : `#34D399`
- Surface claire : `#0B1120`
- Alerte : `#FBBF24`

## Typographie recommandée

- Consoles de code : monospace lisible (JetBrains Mono / Fira Code / Victor Mono).
- Titres de docs : famille sobre, claire, contrastée.
- Taille de base en terminal/config :
  - 12–14 px (terminal)
  - 11–13 px (interfaces légères)

## Motion & esthétique terminal

- Effets subtils uniquement quand utiles (chargements, changement de contexte).
- Pas d’animation distrayante par défaut.
- Préférer des séparateurs visuels stables (sections, blocs, icônes de statut).

## Direction continue

Conserver une identité uniforme entre les trois plateformes (Termux/Linux/Windows), en évitant les écarts de thème non documentés.
