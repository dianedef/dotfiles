# NeoVim Cheat Sheet

Cheat sheet courte pour les fonctions que tu utilises vraiment.

## Édition de texte

### Mouvements indispensables

- `j` / `k` : descendre / monter d'une ligne
- `3j` / `3k` : descendre / monter de 3 lignes
- `w` : mot suivant
- `b` : mot précédent
- `e` : fin du mot
- `0` : début de ligne
- `^` : premier caractère non vide de la ligne
- `$` : fin de ligne
- `gg` : début du fichier
- `G` : fin du fichier
- `H` : haut de l'écran
- `M` : milieu de l'écran
- `L` : bas de l'écran
- `zz` : recentrer l'écran sur le curseur

### Paragraphes et texte long

- `{` : paragraphe précédent
- `}` : paragraphe suivant
- `(` / `)` : phrase précédente / suivante
- `/mot` : chercher un mot ou une expression
- `n` : résultat suivant
- `N` : résultat précédent

Pour les articles, `}` et `{` sont parmi les touches les plus utiles.

### Folds

- `za` : ouvrir / fermer le fold courant
- `zo` : ouvrir le fold courant
- `zc` : fermer le fold courant
- `zR` : tout ouvrir
- `zM` : tout fermer
- `zr` : ouvrir un peu plus les folds
- `zm` : fermer un peu plus les folds
- `zj` : fold suivant
- `zk` : fold précédent

Pour un paragraphe ou un bloc courant :

- `vip` puis `zf` : créer un fold manuel sur le paragraphe courant
- `zd` : supprimer le fold sous le curseur

Si on active un bon plugin de fold Markdown, le plus utile sera surtout :

- `za`
- `zR`
- `zM`
- `zr`
- `zm`
- `K` : aperçu du fold courant si tu es sur une section repliée

### Suppressions utiles

- `x` : supprimer un caractère
- `dw` : supprimer jusqu'au mot suivant
- `diw` : supprimer le mot sous le curseur
- `dd` : supprimer la ligne
- `D` : supprimer jusqu'à la fin de la ligne
- `d$` : idem, jusqu'à la fin de ligne
- `d0` : supprimer jusqu'au début de ligne
- `3dd` : supprimer 3 lignes

### Édition utile

- `i` : insérer avant le curseur
- `a` : insérer après le curseur
- `o` : nouvelle ligne en dessous
- `O` : nouvelle ligne au-dessus
- `u` : annuler
- `<C-r>` : refaire
- `yy` : copier une ligne
- `p` : coller après
- `P` : coller avant

### Raccourcis très rentables sur mobile

- `s` : saut rapide visible avec `flash.nvim`
- `zz` : recentrer souvent pour garder le contexte
- `{` / `}` : naviguer de paragraphe en paragraphe
- `diw` : supprimer proprement un mot
- `dd` : supprimer vite une ligne

## Explorer

### NeoTree

- `<leader>e` : ouvre l'arborescence du projet courant
- `<leader>E` : ouvre l'arborescence du `cwd`
- `<leader>ge` : ouvre la vue Git de `neo-tree`

Ce qu'il faut retenir :

- les dossiers avec `*` contiennent du travail Git en cours
- les dossiers avec `?` contiennent au moins un fichier non tracké
- tu n'as plus besoin d'ouvrir chaque dossier pour savoir où il y a du travail
- `l` ouvre un dossier ou un fichier
- `h` referme un dossier

## Git

### Lecture rapide

- `neo-tree` sert à voir où ça a bougé
- la vue Git de `neo-tree` sert à voir uniquement les fichiers Git concernés
- `lualine` affiche déjà la branche Git et le nombre de fichiers modifiés

Important :

- `neo-tree` et `Git status` ne montrent pas le diff ligne par ligne
- ils montrent surtout quels fichiers ou dossiers sont modifiés, ajoutés ou non trackés
- pour voir le vrai contenu des changements, il faut un plugin de diff ou une commande Git

### Plugins qui montrent un vrai diff visuel

- `gitsigns` : actif par défaut, montre les changements dans la gouttière du buffer courant
- `[h` / `]h` : hunk précédent / suivant
- `<leader>ghp` : aperçu inline du hunk courant
- `<leader>ghd` : ouvrir un vrai mode diff sur le fichier courant
- `<leader>ghD` : diff contre `~`

- `Codex` (`agentic.nvim`) : montre un diff visuel pour les changements proposés par l'agent avant validation
- `Claude Code` : ouvre aussi des diffs visuels quand Claude propose des modifications

### Plugins présents mais désactivés

- `Neogit` : interface Git complète
- `Diffview` : très bon pour relire des diffs complets
- `CodeDiff` : utile pour comparer deux blocs ou deux versions de code

Donc, dans ton setup actuel :

- pour savoir *où* ça a changé : `neo-tree` ou Git status
- pour voir *ce qui* a changé dans un fichier : `gitsigns`
- pour relire un diff proposé par une IA : `Codex` ou `Claude Code`

### Plus tard : Neogit

`Neogit` sert à agir sur Git depuis NeoVim :

- stage / unstage
- commit
- push / pull
- review des changements

Idée simple :

- `neo-tree` = voir
- `neogit` = agir

## Recherche et navigation

### Chercher un fichier ou un texte

- `<leader>e` : explorer le projet
- `<leader>ge` : vue Git du projet
- `<leader>sg` : chercher du texte dans le projet
- `<leader>sw` : chercher le mot courant ou la sélection
- `<leader>sb` : chercher dans le buffer courant
- `<leader>su` : historique d'undo
- `<leader>bb` : revenir au buffer précédent
- `<leader>bd` : fermer le buffer courant

### Aller vite à l'endroit voulu

- `s` : `flash.nvim`, saut rapide à l'endroit voulu
- `S` : saut Treesitter, utile en code
- `<leader>e` puis `l` / `h` : ouvrir / fermer les dossiers

## Codex dans NeoVim

Ici, `Codex` correspond au plugin `agentic.nvim` branché sur `codex-acp`.
Si tu cherches "Agentic", c'est cette section.

### Panneau Codex

- `<leader>aC` : ouvre / ferme Codex
- `<leader>aF` : ajoute le fichier courant ou la sélection au contexte
- `<leader>aN` : nouvelle session
- `<leader>aR` : restaurer une session
- `<leader>aL` : ajouter le diagnostic de la ligne
- `<leader>aB` : ajouter tous les diagnostics du buffer

Ce qu'il faut retenir :

- le panneau Codex est horizontal, en bas, pratique sur mobile
- Codex utilise les raccourcis en majuscules pour ne pas entrer en collision avec Claude Code et Copilot Chat
- tu peux travailler en regardant tes vrais fichiers dans NeoVim
- tu vois les modifications proposées avec un diff visuel avant validation

Workflow utile :

1. Ouvrir un fichier ou un article
2. `<leader>aC`
3. `<leader>aF`
4. demander une réécriture, une amélioration ou une correction
5. relire le diff avant d'accepter

## Codex / Claude

### Sortir proprement d'une interface agent

Si tu vois `Prompt | <C-s>: submit`, tu es dans le panneau Codex, pas dans Claude Code.

- `<leader>aC` : masquer / réafficher le panneau Codex
- `q` : fermer le panneau Codex quand tu es en mode normal
- `<C-s>` : envoyer le prompt

Si tu es dans un vrai terminal Claude :

- `<leader>ac` : ouvrir / fermer Claude Code
- `<C-\><C-n>` : quitter le mode terminal sans envoyer `Esc` au process
- ensuite `<C-h>` / `<C-l>` : revenir à la fenêtre de code ou changer de split

À retenir :

- `Codex` = majuscules
- `Claude Code` = minuscules
- `Esc` peut avoir un effet indésirable dans certains outils agents
- pour sortir sans casser la session, préfère `<leader>aC` dans le panneau Codex
- pour un terminal, préfère toujours `<C-\><C-n>`

## Copilot

### Copilot suggestions

Copilot est déjà actif dans ton setup.

Ce qu'il faut tester :

- est-ce que les suggestions inline t'aident vraiment à écrire plus vite
- est-ce qu'elles sont utiles aussi en Markdown et en rédaction, pas seulement en code
- est-ce que l'acceptation avec `<Tab>` te paraît naturelle ou pénible

Raccourcis utiles :

- `<Tab>` en insertion : accepte la suggestion affichée
- `<M-[>` : suggestion précédente
- `<M-]>` : suggestion suivante

Ce qu'il faut retenir :

- Copilot est surtout un outil d'autocomplétion intelligente
- il est bien pour accélérer une phrase, une fonction ou une structure répétitive
- il est moins adapté qu'un vrai agent quand tu veux une réécriture réfléchie ou un diff contrôlé

### Copilot Chat

Ce qu'il faut tester :

- demander une explication rapide d'un fichier
- demander une review d'un buffer
- demander un fix minimal sur une sélection

Raccourcis utiles :

- `<leader>ap` : ouvrir / fermer Copilot Chat
- `<leader>ae` : expliquer le buffer ou la sélection
- `<leader>ar` : review du buffer ou de la sélection
- `<leader>af` : proposer un fix minimal

Question simple à te poser :

- est-ce que tu préfères ce mode "chat contextuel rapide" à Codex pour certaines tâches courtes ?

## Avante

Avante est présent dans ton setup, mais désactivé pour l'instant.

Ce qu'il faut tester plus tard si on l'active :

- la sidebar conversationnelle
- les propositions de modifications avec diff
- l'application des changements depuis la sidebar
- le confort général par rapport à Codex et Copilot Chat

Ce qu'il faut surtout comparer :

- est-ce que l'interface est plus agréable que Codex pour travailler longtemps
- est-ce que les diffs sont plus faciles à relire
- est-ce que l'application des changements est plus fluide

Raccourcis / idées à retenir si on l'active :

- `a` : appliquer le changement sous le curseur dans la sidebar
- `A` : tout appliquer
- `;x` / `,x` : naviguer entre les changements

Question simple à te poser :

- est-ce que tu veux un agent "éditeur intégré" orienté UI, ou est-ce que Codex te suffit déjà ?

## Plugins à connaître

Ceux que tu devrais connaître d'abord :

- `neo-tree` : arborescence du projet + indicateurs Git
- `flash.nvim` : navigation ultra rapide dans le texte
- `Codex` : réécriture et modifications avec diff visuel
- `Copilot` : autocomplétion rapide
- `Copilot Chat` : explication / review / fix rapide d'un buffer
- `vim-pencil` : confort d'écriture en Markdown et texte

Ceux qui valent le coup plus tard pour la rédaction :

- `nvim-ufo` : folds sur les headings Markdown
- `nvim-spider` : mouvements plus intelligents par mots
- `md-outline` : vue d'ensemble de la structure d'un article
- `follow-md-links` : suivre les liens Markdown facilement

### Ce que je te conseille pour les folds

- `nvim-ufo` est activé dans ton setup
- pour du Markdown, il peut plier les sections par headings
- pour toi, c'est probablement l'activation la plus rentable après `neo-tree` et Codex
- `zR` ouvre tout
- `zM` ferme tout
- `zr` ouvre un peu plus
- `zm` ferme un peu plus
- `K` permet de prévisualiser le contenu d'un fold

Autres pistes si un jour tu veux comparer :

- `preservim/vim-markdown` : option classique, très orientée Markdown, avec folding par headings
- `md-outline` : pas un plugin de fold, mais très utile en complément pour voir la structure

### À quoi sert MD Outline

`md-outline` ne replie pas directement le texte.

Il sert à afficher la structure d'un document Markdown à partir des headings :

- H1
- H2
- H3
- etc.

Donc son rôle, c'est :

- voir le plan d'un article
- repérer rapidement la section que tu veux relire
- naviguer dans un long texte sans scroller partout

Différence simple :

- `ufo` = plier / déplier les sections
- `md-outline` = voir le sommaire / plan du document

Dans ton setup :

- `md-outline` est activé
- `<leader>mo` : ouvrir l'outline Markdown
- `<leader>mc` : fermer l'outline Markdown
- `:MdoOpen` : ouvrir l'outline
- `:MdoClose` : fermer l'outline

Quand l'utiliser :

- quand tu veux voir le squelette d'un article
- quand tu veux passer vite d'un heading à un autre
- quand tu veux relire la structure avant de réécrire le contenu

## Raccourcis à apprendre d'abord

Si tu ne dois retenir que quelques touches :

- `<leader>e` : explorer le projet
- `<leader>ge` : voir l'état Git
- `<leader>sg` : chercher dans le projet
- `s` : sauter vite à un endroit visible
- `{` / `}` : sauter de paragraphe en paragraphe
- `diw` : supprimer un mot
- `dd` : supprimer une ligne
- `za` : ouvrir / fermer la section courante
- `zM` / `zR` : tout fermer / tout ouvrir
- `<leader>aC` : ouvrir Codex
- `<leader>aF` : envoyer un fichier ou une sélection à Codex
- `h` / `l` dans l'arborescence : fermer / ouvrir

## Lecture des indicateurs

- `*` sur un dossier : il y a des fichiers modifiés quelque part dedans
- `?` sur un dossier : il y a au moins un fichier non tracké dedans
- Git visible sur un fichier : ce fichier a changé

## Philosophie simple

Pour toi, l'usage important maintenant est :

- regarder l'arborescence
- repérer les zones sales du repo
- naviguer vite dans un article
- supprimer / corriger du texte sans lenteur
- envoyer un fichier ou une sélection à Codex
- juger les changements dans le diff

Le reste peut attendre.
