# NeoVim Cheat Sheet

Cheat sheet courte pour les fonctions que tu utilises vraiment.

## Comment trouver un raccourci que tu ne connais pas

### L'aide intégrée

Quand tu cherches un raccourci, la première option c'est l'aide native :

```
:help <sujet>
```

Par exemple `:help moving` ou `:help usr_04` pour les bases de l'édition.

Pour voir tous tes mappings actifs selon le mode :

```
:nmap          " tous les mappings en mode Normal
:imap          " mode Insert
:vmap          " mode Visual
:nmap <leader> " tous ceux avec ton leader key
```

### which-key : la vraie solution

`which-key.nvim` répond exactement à ce besoin. Quand tu commences une séquence de touches, une popup apparaît automatiquement avec toutes les options disponibles.

- Tu tapes `<leader>` et tu vois toutes les possibilités s'afficher
- Tu peux aussi appeler `:WhichKey` pour ouvrir la cheatsheet complète

Pour vérifier si c'est actif dans ton setup :

```
:checkhealth which-key
```

### Déplacer une ligne vers le haut

Un exemple concret — faire remonter la ligne courante :

- **En mode normal** : `ddkP` (`dd` = couper la ligne, `k` = monter d'une ligne, `P` = coller au-dessus)
- **Avec une commande** : `:m .-2`
- **En mode visuel** (pour un bloc) : `:m '<-2`

---

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

### Spell (orthographe)

- `zg` / `Zg` : ajouter le mot sous le curseur au dictionnaire personnel
- `zug` / `Zug` : supprimer le mot du dictionnaire personnel
- `zw` / `Zw` : marquer le mot comme incorrect
- `z=` : proposer des corrections
- `]s` / `[s` : aller à l'erreur d’orthographe suivante / précédente

### Raccourcis très rentables sur mobile

- `s` : saut rapide visible avec `flash.nvim`
- `zz` : recentrer souvent pour garder le contexte
- `{` / `}` : naviguer de paragraphe en paragraphe
- `diw` : supprimer proprement un mot
- `dd` : supprimer vite une ligne

## Explorer

### NeoTree

Trois portes d'entrée — attention, « root » ici n'est ni le root système (`/`) ni le project root LazyVim, c'est juste `$HOME`.

| Mapping | Ancré sur | Résolution chez toi |
|---|---|---|
| `<leader>er` (root) | `$HOME` (figé dans la config) | `/home/ubuntu` |
| `<leader>ec` (cwd) | dossier où `nvim` a été lancé | figé au démarrage |
| `<leader>ee` (git) | dossier git courant, vue git_status | ouvert auto au lancement |
| `<leader>e2` | largeur panneau | 20 colonnes |
| `<leader>e3` | largeur panneau | 35 colonnes |
| `<leader>eF` | largeur panneau | largeur totale écran |

Ce qu'il faut retenir :

- les dossiers avec `*` contiennent du travail Git en cours
- les dossiers avec `?` contiennent au moins un fichier non tracké
- tu n'as plus besoin d'ouvrir chaque dossier pour savoir où il y a du travail
- `l` ouvre un dossier ou un fichier
- `h` referme un dossier

### Changer la racine de l'explorateur

Tu peux choisir n'importe quel dossier dans l'arborescence et le définir comme nouvelle racine, pour ne plus voir que son contenu.

**NeoTree** (curseur sur le dossier) :

- `.` : définir le dossier sous le curseur comme nouvelle racine (`set_root`)
- `<BS>` : remonter d'un niveau (`navigate_up`)
- `<` / `>` : naviguer entre les sources (filesystem / buffers / git)
- `H` : toggle fichiers cachés

**Snacks Explorer** (curseur sur le dossier) :

- `.` : focus sur le dossier courant et le définir comme cwd (`explorer_focus`)
- `<BS>` : remonter d'un niveau (`explorer_up`)
- `<C-c>` : changer le cwd du tab vers le dossier courant (`tcd`)
- `Z` : refermer tous les dossiers ouverts
- `H` / `I` : toggle fichiers cachés / ignorés (gitignore)

À retenir : `.` est le même raccourci dans les deux. Pour revenir en arrière, `<BS>` partout.

### Chercher dans un dossier précis

Quand tu es positionné sur un dossier dans l'explorateur, tu peux limiter une recherche à ce dossier.

**Snacks Explorer** (curseur sur le dossier) :

- `<C-f>` : grep (live grep) limité à ce dossier
- `<C-t>` : find files limité à ce dossier
- `<C-w>` : words / symbols limité à ce dossier
- `?` dans l'explorateur : liste complète des mappings actifs (la source de vérité)

**NeoTree** : pas de mapping intégré pour ça. Deux solutions :

1. Yank + picker : positionner sur le dossier, `Y` pour copier le chemin, puis `<leader>sg` ou `<leader>ff` et coller le chemin dans le champ « cwd ».
2. Ajouter un mapping custom dans `window.mappings` de `lua/plugins/neo-tree.lua` qui appelle Snacks/Telescope sur `state.tree:get_node().path`.

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

- `Snacks picker` : `<leader>gd` ouvre la liste des fichiers/hunks modifiés avec preview
- `Diffview` : `<leader>gv` ouvre la revue Git en plein écran avec fichiers en haut et diff en bas
- `gitsigns` : actif par défaut, montre les changements dans la gouttière du buffer courant
- `[h` / `]h` : hunk précédent / suivant
- `<leader>ghp` : aperçu inline du hunk courant
- `<leader>ghd` : ouvrir un vrai mode diff sur le fichier courant
- `<leader>ghD` : diff contre `~`

- `Codex` (`agentic.nvim`) : montre un diff visuel pour les changements proposés par l'agent avant validation
- `Claude Code` : ouvre aussi des diffs visuels quand Claude propose des modifications

### Neogit — agir sur Git sans taper de commandes

Interface type magit pour stage/commit/push au clavier.

Raccourcis globaux :

- `<leader>gn` : ouvrir Neogit
- `<leader>gc` : commit
- `<leader>gp` : push
- `<leader>gl` : pull

Dans le buffer Neogit (mode normal) :

- `s` : stage le fichier ou le hunk sous le curseur
- `S` : stage tout
- `u` : unstage
- `U` : unstage tout
- `x` : discard (annule les changements)
- `<Tab>` : déplier / replier un fichier pour voir le diff
- `<Enter>` : ouvrir le fichier
- `d` : ouvrir le diff dans Diffview

Commits :

- `cc` : commit (ouvre le buffer message, `:wq` pour valider)
- `ca` : commit --amend (réécrit le dernier commit)
- `ce` : extend (ajoute au dernier commit sans changer le message)
- `cf` : fixup
- `cw` : reword (changer juste le message)

Push / pull / fetch :

- `Pp` : push vers l'upstream
- `Pf` : push --force-with-lease
- `Pu` : push et set upstream
- `Fa` : fetch all
- `pp` : pull

Branches / log :

- `bb` : checkout branche
- `bc` : créer une branche
- `ll` : log de la branche
- `q` : fermer Neogit

### Diffview — relire les diffs en plein écran

Raccourcis globaux :

- `<leader>gv` : ouvrir Diffview (changements locaux)
- `<leader>gV` : diff vs `origin/main` (ce que la PR contiendra)
- `<leader>gq` : fermer Diffview
- `<leader>gF` : historique du fichier courant

Dans le panneau de fichiers (en haut) :

- `j` / `k` : fichier suivant / précédent (le diff s'ouvre en bas)
- `<Enter>` : ouvrir le fichier sélectionné
- `-` : toggle stage / unstage du fichier
- `s` : stage
- `u` : unstage
- `X` : discard
- `R` : refresh
- `<Tab>` / `<S-Tab>` : sauter au fichier suivant / précédent

Dans la vue diff :

- `]c` / `[c` : hunk suivant / précédent (natif Vim diff)
- `do` : appliquer le hunk depuis l'autre côté (obtain)
- `dp` : pousser le hunk vers l'autre côté (put)
- `g?` : afficher l'aide complète des keymaps de Diffview

Workflow type :

- `neo-tree` = voir où ça a bougé
- `Diffview` (`<leader>gv`) = lire ce qui a changé
- `Neogit` (`<leader>gn`) = stage + commit + push

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

- `<leader>akt` : ouvre / ferme Codex
- `<leader>akf` : ajoute le fichier courant ou la sélection au contexte
- `<leader>akn` : nouvelle session
- `<leader>akr` : restaurer une session
- `<leader>akl` : ajouter le diagnostic de la ligne
- `<leader>akb` : ajouter tous les diagnostics du buffer

Ce qu'il faut retenir :

- le panneau Codex est horizontal, en bas, pratique sur mobile
- tu peux travailler en regardant tes vrais fichiers dans NeoVim
- tu vois les modifications proposées avec un diff visuel avant validation

Workflow utile :

1. Ouvrir un fichier ou un article
2. `<leader>akt`
3. `<leader>akf`
4. demander une réécriture, une amélioration ou une correction
5. relire le diff avant d'accepter

## Codex / Claude

### Sortir proprement d'une interface agent

Si tu vois `Prompt | <C-s>: submit`, tu es dans le panneau Codex, pas dans Claude Code.

- `<leader>akt` : masquer / réafficher le panneau Codex
- `q` : fermer le panneau Codex quand tu es en mode normal
- `<C-s>` : envoyer le prompt

Si tu es dans un vrai terminal Claude :

- `<leader>ac` : ouvrir / fermer Claude Code
- `<C-\><C-n>` : quitter le mode terminal sans envoyer `Esc` au process
- ensuite `<C-h>` / `<C-l>` : revenir à la fenêtre de code ou changer de split

À retenir :

- `Esc` peut avoir un effet indésirable dans certains outils agents
- pour sortir sans casser la session, préfère `<leader>akt` dans le panneau Codex
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

Avante est activé dans ce setup.

Flux de base :

1. `<leader>axt` : basculer la sidebar (vertical par défaut).
2. `<leader>axv` : ouvrir verticalement (droite).
3. `<leader>axb` : ouvrir horizontalement (bas).
2. `:AvanteChat` (ou `<leader>axc`) : lancer une conversation avec le contexte courant.
3. Envoie ton prompt, puis regarde les propositions dans la sidebar Avante.
4. `a` applique le changement sous le curseur, `A` applique tous les changements proposés.

Raccourcis actifs :

- `<leader>axt` : basculer la sidebar (vertical par défaut).
- `<leader>axv` : ouvrir verticalement (droite).
- `<leader>axb` : ouvrir horizontalement (bas).
- `:AvanteChat` / `<leader>axc` : chat.
- `:AvanteAsk` / `<leader>axq` : question rapide.
- `:AvanteEdit` / `<leader>axe` : édition basée sélection/contexte.
- `:AvanteFocus` / `<leader>axf` : focus fenêtre Avante.
- `:AvanteHistory` / `<leader>axh` : historique des échanges.
- `:AvanteModels` / `<leader>axm` : choisir un modèle.
- `:AvanteChatNew` / `<leader>axn` : nouvelle session.
- `:AvanteSwitchProvider` / `<leader>axp` : changer le provider.
- `:AvanteRefresh` / `<leader>axu` : rafraîchir la vue.
- `:AvanteStop` / `<leader>axs` : arrêter une génération.
- `:AvanteBuild` / `:AvanteClear` / `:AvanteShowRepoMap` : commandes utiles selon le cas.

Ce que tu dois comparer avec le workflow Codex/Copilot Chat :

- la lisibilité des diffs,
- la qualité des suggestions,
- la fluidité d'application depuis la sidebar.

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
