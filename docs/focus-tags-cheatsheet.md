# Focus Tags Cheatsheet

Cheatsheet publique pour qualifier rapidement le type d'attention qu'une tache demande. Utilise un seul tag principal, puis ajoute un tag secondaire seulement si cela change vraiment la priorite ou le mode de travail.

## Tags principaux

| Tag | Quand l'utiliser | Signal de sortie |
|---|---|---|
| `#fix` | Corriger un bug, une regression ou un comportement casse. | Le cas casse est reproduit, corrige et reteste. |
| `#ship` | Finaliser une livraison, une PR, un deploy ou une release. | Les checks utiles sont verts et le changement est publiable. |
| `#audit` | Inspecter un produit, du code, du SEO, du contenu ou une UX. | Les risques sont classes et les actions suivantes sont explicites. |
| `#build` | Creer une fonctionnalite, un ecran, un script ou une integration. | Le comportement attendu existe et a ete verifie. |
| `#docs` | Ecrire ou maintenir de la documentation durable. | Le lecteur peut agir sans contexte oral supplementaire. |
| `#content` | Produire, adapter ou ameliorer un contenu public. | Le contenu est coherent avec l'audience et l'objectif. |
| `#research` | Chercher, comparer ou sourcer des informations. | Les sources et conclusions sont citees ou tracables. |
| `#ops` | Gerer installation, configuration, environnement ou incident. | L'etat operationnel est clair et reproductible. |
| `#design` | Travailler l'interface, l'experience ou le systeme visuel. | Les choix UX/UI sont visibles, coherents et testables. |
| `#strategy` | Arbitrer priorites, scope, positionnement ou plan d'action. | La decision, les compromis et la prochaine action sont nets. |

## Tags secondaires

| Tag | Sens |
|---|---|
| `#quick` | Tache courte, faible risque, resolution directe. |
| `#deep` | Demande une analyse poussee ou plusieurs passes. |
| `#blocked` | Bloque par un acces, une decision, une donnee ou un etat externe. |
| `#followup` | Suite logique d'un travail deja commence. |
| `#cleanup` | Nettoyage, simplification ou reduction de dette. |
| `#verify` | Verification, retest, preuve ou controle qualite. |
| `#public` | Sortie visible publiquement: site, docs, marketing, support. |
| `#private` | Usage interne, notes personnelles ou configuration locale. |

## Combinaisons utiles

| Combinaison | Exemple |
|---|---|
| `#fix #verify` | Corriger une regression et confirmer le cas en navigateur ou test. |
| `#docs #public` | Rediger une page lisible par des utilisateurs externes. |
| `#audit #deep` | Audit complet avec risques, preuves et priorisation. |
| `#build #ship` | Implementer puis preparer la livraison. |
| `#ops #blocked` | Incident ou configuration en attente d'un secret, acces ou service. |
| `#strategy #followup` | Reprendre une decision produit apres premiers retours. |

## Regles rapides

- Choisir le tag qui decrit le travail principal, pas le fichier touche.
- Preferer `#fix` a `#build` si le comportement existe deja mais est casse.
- Preferer `#audit` a `#research` si l'objectif est de juger un etat existant.
- Ajouter `#public` des qu'un lecteur externe verra le resultat.
- Ajouter `#verify` quand la preuve de bon fonctionnement est le coeur de la demande.
- Ne pas empiler plus de trois tags sauf pour une synthese ou un backlog.

## Format recommande

```text
#tag-principal #tag-secondaire - action concrete
```

Exemples:

```text
#fix #verify - retester le login mobile apres correction du callback OAuth
#docs #public - publier la cheatsheet focus-tags dans docs/
#audit #deep - classer les risques de performance du dashboard
```
