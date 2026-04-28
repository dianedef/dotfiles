---
artifact: gtm_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "dotfiles"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sf-docs
scope: gtm
owner: "dianedef"
confidence: medium
risk_level: low
security_impact: medium
docs_impact: high
evidence:
  - "README.md: message d’entrée clair avec liens rapides par plateforme"
  - "install.sh: options de commande qui répondent aux profils techniques (full, ciblé, dry-run, check, uninstall)"
  - "termux.sh and windows.ps1: parcours spécialisés qui réduisent la friction d’entrée"
  - "bootstrap.sh: réduction du seuil d’entrée pour une mise en place Ubuntu/Codespace"
depends_on:
  - "BUSINESS.md@0.1.0"
  - "PRODUCT.md@0.1.0"
target_segment: "développeurs techniques qui déploient rapidement des postes de travail"
offer: "pack de configuration automatisée multi-plateforme"
channels:
  - "README GitHub"
  - "copy/paste scripts (install.sh/termux.sh/windows.ps1/bootstrap.sh)"
  - "communautés techniques / échanges"
proof_points:
  - "modes d’exécution dédiés (check, dry-run, uninstall, update, only)"
  - "couverture multi-plateforme stable via install.sh, termux.sh, windows.ps1"
  - "intégration de secrets et outils IA via `doppler-setup` et config scripts"
supersedes: []
next_review: "2026-07-26"
next_step: /sf-docs audit GTM.md
---

# GTM Context

## Segment cible

- développeurs solo et indépendants,
- équipes techniques légères qui déploient souvent sur plusieurs postes,
- utilisateurs cherchant une configuration terminal reproductible avec AI assistance.

## Proposition de valeur

Un dépôt de dotfiles qui transforme une installation manuelle fastidieuse en flux automatisé, prévisible et réplicable.

- entrée réduite grâce aux scripts dédiés par contexte,
- standardisation des outils essentiels,
- réduction du temps entre « machine neuve » et « travail réel ».

## Positionnement

- **Ce que l’on vend:** la fiabilité de l’activation d’un environnement dev.
- **Ce que l’on n’est pas:** une couche SaaS commerciale ni un framework de produit logiciel général.
- **Positionnement utile:** repositorie de configuration opérationnelle, orientée reprise, automatisation, et cohérence multi-plateforme.

## Canaux

- README GitHub comme surface d’entrée principale,
- pages/captures d’exemples de commandes dans des profils communautaires,
- liens directs d’installation (`bootstrap`, `install`, `termux`, `windows`) partagés dans des conversations techniques.

## Parcours de conversion

1. **Attention:** page README avec promesse et liens rapides.
2. **Activation:** copie du repo et exécution d’un script correspondant à la plateforme.
3. **Expérience de réussite:** prompt/terminal/editeur opérationnels + outils AI et MCP branchés.
4. **Adoption continue:** relance de `./install.sh --check` et `--update` pour garder une configuration stable.

## Points de preuve

- modes non destructifs (dry-run, check) qui facilitent la confiance,
- installation adaptative (interactif/ciblé/full),
- scripts explicites pour la gestion des secrets et de la configuration,
- logs et chemins d’erreur cohérents pour diagnostiquer vite.

## Objections

- "Trop complexe pour un setup simple"
- "Je ne veux pas dépendre d’un repo tiers"
- "Ce n’est pas assez adapté à ma machine"
- "Mes clés et secrets ne seront pas sûrs"

## Objectif conversion

Le succès conversionnel principal n’est pas la vente, mais le passage de l’intention à la récurrence:

- utilisateurs qui testent le bootstrap,
- utilisateurs qui terminent une première installation complète sans intervention manuelle majeure,
- équipes qui réutilisent le dépôt lors de migrations futures au lieu d’inventer une stack maison.

## KPI initiaux

- taux de clone → run d’installation réussi,
- taux d’installation complète sans erreur bloquante,
- temps moyen entre l’installation et la première session de travail productive,
- fréquence d’utilisation de `./install.sh --check` après modifications.
