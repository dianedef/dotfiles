---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sf-docs
scope: business
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: low
docs_impact: yes
target_audience: "développeurs solo et équipes techniques qui réinstallent souvent un environnement"
value_proposition: "réduire le coût de setup machine grâce à une configuration automatisée et reproductible"
business_model: "dépôt d’ingénierie personnelle de référence, réutilisable et évolutif"
market: "utilisateurs techniques, équipes lean, workflows d’onboarding infra"
evidence:
  - "/home/claude/dotfiles/CLAUDE.md"
  - "/home/claude/dotfiles/README.md"
  - "/home/claude/dotfiles/install.sh"
depends_on:
  - "/home/claude/dotfiles/CLAUDE.md"
  - "/home/claude/dotfiles/install.sh"
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit BUSINESS.md
---

# BUSINESS.md

## Mission

Faire du dépôt dotfiles un référentiel propre, reproductible et maintenable pour un workflow cohérent entre Termux, Linux/Codespaces et Windows, avec la même expérience de développement et de productivité.

## Utilisateurs cibles

- Propriétaire du dépôt (développeur principal), qui doit reconfigurer une machine en quelques minutes.
- Outils automatisés (scripts d’installation, bootstrap et synchronisation).
- Environnements cibles : Linux/Codespaces, Android/Termux, Windows.

## Valeur métier

- Réduction du temps de setup machine.
- Uniformisation des habitudes de travail (shell, éditeurs, outils, MCP).
- Prévisibilité d’installation et réduction des erreurs humaines.
- Documentation claire pour la reprise après incident/migration de poste.

## Hypothèses de valeur

- Les outils standards (Git, nvim, shell utils, prompt) restent stables au cycle semestriel.
- Les identifiants sensibles restent externalisés (Doppler, `.env` non versionné).
- Les changements d’environnement sont mieux gérés par scripts idempotents.

## Risques business

- Fragmentation entre plateformes si un installateur diverge.
- Régressions de productivity lors des migrations MCP/shell.
- Fuite accidentelle d’environnement ou de tokens.

## Indicateurs de succès

- Installation réussie sur machine fraîche en < 20 minutes.
- Taux de scripts passés sans erreur après chaque run > 95 %.
- Réduction des interventions manuelles répétitives.
- Aucune fuite de secret détectée.

## Prochaine action

Mettre à jour ce document quand une dépendance critique change (nvim core, gestionnaire de plugin, nouveau workflow Windows/Termux).
