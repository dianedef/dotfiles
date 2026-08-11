---
artifact: product_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
status: reviewed
source_skill: manual
scope: product
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: medium
docs_impact: high
evidence:
  - "README.md: onboarding multi-plateforme (Windows, Linux/Codespaces, Termux)"
  - "install.sh: orchestration complète avec modes --dry-run, --check, --update, --only, --uninstall"
  - "bootstrap.sh: bootstrap one-click pour serveurs Ubuntu avec prérequis + clonage + exécution de install.sh"
  - "termux.sh and windows.ps1: parcours d’installation dédiés par plateforme"
  - "config.sh and lib.sh: fonctions réutilisables, logs, détection OS, idempotence et traçabilité"
depends_on:
  - artifact: "BUSINESS.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "BRANDING.md"
    artifact_version: "1.0.0"
    required_status: active
target_user: "développeurs solo et équipes techniques qui réinstallent fréquemment des environnements"
user_problem: "Les setups manuels sont longs, hétérogènes et source d’erreurs entre plateformes."
desired_outcomes:
  - "activer rapidement une machine en état de travail standard"
  - "réduire les écarts de configuration entre postes"
  - "centraliser une base de dotfiles versionnée"
non_goals:
  - "ne remplace pas la gestion métier d’applications métier"
  - "ne garantit pas une compatibilité absolue de tous les outils tiers"
  - "ne vise pas une expérience produit grand public"
supersedes: []
next_review: "2026-07-26"
next_step: "/sf-docs audit PRODUCT.md"
---

# Product Context

## Cible utilisateur

- Développeurs qui réinstallent souvent des machines (Linux/Codespaces, Termux, Windows).
- Développeurs qui veulent une expérience terminal cohérente avec peu de réglages manuels.
- Opérateurs techniques qui veulent des scripts idempotents pour gagner du temps de onboarding.

## Problème produit

Le principal coût opérationnel est la reconfiguration machine à machine :

- installation incohérente selon la plateforme,
- configuration manuelle répétitive,
- scripts d’outillage difficiles à orchestrer,
- onboarding long entre une machine neuve et un environnement productif.

Le dépôt doit réduire ce coût en offrant une source unique, versionnée et automatisable.

## Résultats attendus

- réduire le temps d’activation d’un nouvel environnement,
- réduire les erreurs de setup entre Linux, Termux et Windows,
- uniformiser les outils de base (shell, prompt, file manager, éditeurs, AI CLIs),
- accélérer la récurrence de collaboration avec la même base de scripts.

## Offre produit

- **Objectif central:** fournir une infrastructure terminal prête à l’emploi via des scripts d’installation auditables.
- **Mécanique principale:** scripts modulaires (`install.sh`, `termux.sh`, `windows.ps1`, `bootstrap.sh`) orchestrés avec modes santé/sécurité (check, dry-run, mode sélection).
- **Valeur immédiate:** passage rapide d’un système neuf à un environnement cohérent.
- **Valeur business opérationnelle:** moins d’heures perdues en setup, plus de temps en travail utile.

## Non-objectifs

- Développer une nouvelle application produit indépendante des configurations existantes.
- Promettre une compatibilité parfaite sur tous les matériels sans maintenance dédiée.
- Remplacer le jugement humain sur les réglages de chaque outil.
- Remettre en cause l’architecture logicielle générale au-delà du cadre terminal/dev-environment.

## Conversion logicielle et valeur

Le dépôt convertit l’action utilisateur en valeur par un chemin simple :

1. découvrir le repo,
2. exécuter un script d’installation adapté,
3. obtenir une machine configurée (shell + éditeurs + utilitaires + MCP/AI) sans configuration manuelle extensive,
4. répliquer la configuration après migration ou réinitialisation via le même flux.

## Mesures de succès

- temps moyen de mise en service (clone → shell productif) réduit,
- taux de scripts exécutés sans intervention manuale critique,
- baisse du nombre d’écarts de config entre plateformes,
- réduction des incidents de secrets/dépendances non configurés,
- couverture documentaire claire pour les parcours de réinstallation.

## Risques

- divergence entre scripts selon plateformes,
- dépendances externes qui cassent des chaînes d’installation,
- scripts trop permissifs qui masquent des erreurs silencieuses,
- attente de « setup universel » irréaliste si l’environnement est hautement custom.
