---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sf-docs
scope: technical
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: high
docs_impact: yes
evidence:
  - "/home/claude/dotfiles/.env.example"
  - "/home/claude/dotfiles/doppler-setup.sh"
  - "/home/claude/dotfiles/install.sh"
depends_on:
  - "/home/claude/dotfiles/CLAUDE.md"
  - "/home/claude/dotfiles/CONTEXT.md"
linked_systems:
  - Bash
  - Git
  - MCP
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit GUIDELINES.md
---

# GUIDELINES.md

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

## Conventions de sécurité

- Aucun secret en clair dans les fichiers versionnés.
- Variables sensibles dans `.env` ou Doppler seulement.
- Vérifier les droits d’exécution uniquement quand nécessaire.
- Journaliser sans afficher de tokens / mots de passe dans les logs.

## Ordre de travail recommandé

1. Modifier le script ciblé en mode minimal.
2. Ajuster la doc associée dans le bloc correspondant.
3. Mettre à jour les fichiers d’inventaire/guide s’il y a un comportement utilisateur visible.
4. Documenter les cas de migration (platforme, rollback).

## Qualité documentaire

- Les changements fonctionnels majeurs doivent être reflétés ici ou dans `CLAUDE.md`.
- Chaque mise à jour technique significative doit inclure date + note d’impact.
- Maintenir une documentation “recoverable” (copier-coller exécutable quand possible).

## Gouvernance

- Priorité : stabilité de la chaîne d’installation, puis confort d’usage.
- Décisions importantes validées par essai sur Linux/Codespaces, puis sur Termux/Windows si impact.
