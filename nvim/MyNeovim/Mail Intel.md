# Mail Intel

Mail Intel est une passerelle locale en lecture seule pour lire des emails Gmail synchronisés en Maildir, les ouvrir dans Neovim, puis copier leur contenu en Markdown pour un agent IA.

## Mail Intelligence review

La revue interactive se lance avec `:MailIntake` ou `<leader>mi`. Elle ouvre une liste buffer-driven des propositions en attente, puis un panneau voisin en lecture seule avec l'email source. Depuis la liste :

- `<CR>` ouvre l'email source.
- `a` ouvre l'email et demande à Avante de proposer projet, angle, owner skill, risques et action.
- `h` copie un handoff `#source` gouverné pour la skill suivante.
- `y` accepte, `e` marque comme édité, `x` rejette et `i` ignore.

`:MailIntakeScan` crée les fiches metadata-only dans `~/.shipglowz/private/data/mail-intake/inbox/`. `:MailIntakeScan!` effectue un dry-run. Les corps bruts restent dans le Maildir et ne sont jamais écrits dans la queue privée.

L'administration amont des labels et filtres Gmail vit maintenant a cote, via `scripts/mail-admin`, avec un registre local versionne sous `~/.shipglowz/private/data/mail-admin/`.

## Architecture

```text
Gmail personnel
  -> scripts/mail-admin
  -> labels/filtres Gmail
  -> mbsync/isync
  -> ~/Mail/competitors/<account>/
  -> notmuch
  -> scripts/mail-intel
  -> lua/shipglowz/mail/
  -> Neovim
```

`scripts/mail-intel` ne sait pas envoyer, supprimer, archiver, deplacer, taguer ou marquer des emails. Il lit uniquement un Maildir local deja synchronise.

`scripts/mail-intake` est le voisin review-first : il crée une queue privée idempotente et déplace les décisions terminées vers `mail-intake/done/`. Il ne modifie pas le Maildir ni Gmail.

`scripts/mail-admin` est le seul chemin de mutation Gmail de ce systeme. Il gere les labels et filtres Gmail via l'API officielle, avec un `dry-run` possible avant application.

## Prérequis

- `mbsync` ou `isync` pour synchroniser Gmail vers Maildir.
- `notmuch` pour indexer et rechercher les emails locaux.
- Un dossier local hors dépôt, par exemple `~/Mail/competitors`.

Ne committez jamais de mot de passe Gmail, app password, token OAuth, cookie ou contenu réel d'email dans ce dépôt.

Sur Ubuntu/Debian :

```bash
sudo apt-get update
sudo apt-get install -y notmuch isync
```

## Configuration

Variables utiles:

```bash
export MAIL_INTEL_ROOT="$HOME/Mail/competitors"
export MAIL_INTEL_ACCOUNT="business-a"
export MAIL_INTEL_FOLDER="INBOX"
export MAIL_INTEL_LIMIT="30"
```

Structure attendue:

```text
~/Mail/competitors/
  business-a/
    INBOX/
      cur/
      new/
      tmp/
```

## CLI

```bash
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" accounts
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" folders business-a
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" --format json list business-a INBOX --limit 10
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" --format json search business-a "pricing" --limit 10
scripts/mail-intel export <message-or-thread-id> --markdown
```

`list`, `search`, `show` et `export` utilisent `notmuch`. Si `notmuch` n'est pas installé ou si le Maildir n'est pas encore indexé, la commande renvoie une erreur explicite.

## Gmail Admin

Le registre declaratif non secret vit sous :

```text
~/.shipglowz/private/data/mail-admin/
  registry.json
  registry.example.json
```

Les secrets OAuth restent hors Git, par exemple :

```text
~/.config/mail-admin/oauth/<account>/credentials.json
~/.config/mail-admin/oauth/<account>/token.json
```

Commandes principales :

```bash
scripts/mail-admin init-registry
scripts/mail-admin validate
scripts/mail-admin list-rules
scripts/mail-admin plan
scripts/mail-admin plan --live
scripts/mail-admin apply --dry-run
scripts/mail-admin apply
scripts/mail-admin bootstrap-auth <account>
scripts/mail-admin list-labels <account>
scripts/mail-admin list-filters <account>
```

`plan` sans `--live` reste purement local. `plan --live` et `apply` comparent le registre local a Gmail et evitent de recreer des filtres equivalents. En cas de meme requete distante avec une action differente, la commande signale un conflit au lieu d'empiler des doublons.

Quand une regle declare `"trash": true`, `mail-admin` applique le label cible et ajoute aussi `TRASH` au filtre Gmail. Cela correspond a la suppression immediate voulue, avec recuperation possible via la corbeille Gmail.

Dependances Python distantes a installer avant les commandes Gmail API :

```bash
python3 -m pip install --user google-api-python-client google-auth-oauthlib google-auth-httplib2
```

Scopes utilises :

- `https://www.googleapis.com/auth/gmail.labels`
- `https://www.googleapis.com/auth/gmail.settings.basic`

## Commandes Neovim

```vim
:CompetitorMailAccounts
:CompetitorMailInbox
:CompetitorMailInbox business-a
:CompetitorMailSearch pricing
:CompetitorMailOpen <message-or-thread-id>
:CompetitorMailCopyMarkdown
```

`CompetitorMailInbox` et `CompetitorMailSearch` ouvrent une sélection via `vim.ui.select`. L'email choisi est rendu dans un buffer Markdown temporaire. `CompetitorMailCopyMarkdown` copie le contenu courant dans le presse-papiers et le registre par défaut.

## Gmail

Pour les comptes Gmail personnels, consultez la documentation officielle Google avant de configurer la synchronisation:

- Gmail avec un autre client email: `https://support.google.com/mail/answer/7126229`
- App passwords: `https://support.google.com/accounts/answer/185833`

Google recommande les connexions modernes avec Sign in with Google. Les app passwords demandent la validation en deux étapes et ne sont pas toujours disponibles.

## Connexion d'un compte Gmail pilote

Le plus simple pour une v1 locale est de commencer avec un seul compte Gmail et un alias local, par exemple `business-a`.

1. Installer les dépendances:

```bash
sudo apt-get update
sudo apt-get install -y notmuch isync
```

2. Préparer les dossiers locaux:

```bash
mkdir -p "$HOME/Mail/competitors/business-a/INBOX"
```

3. Créer un secret local hors dépôt:

```bash
mkdir -p "$HOME/.config/mail-intel"
chmod 700 "$HOME/.config/mail-intel"
nvim "$HOME/.config/mail-intel/business-a-password"
chmod 600 "$HOME/.config/mail-intel/business-a-password"
```

Le fichier `business-a-password` doit contenir uniquement le mot de passe d'application Gmail si votre compte le permet. Sinon, il faudra passer par une configuration OAuth plus avancée.

4. Créer `~/.mbsyncrc`:

```conf
IMAPAccount business-a
Host imap.gmail.com
User votre-adresse@gmail.com
PassCmd "cat ~/.config/mail-intel/business-a-password"
SSLType IMAPS
AuthMechs LOGIN

IMAPStore business-a-remote
Account business-a

MaildirStore business-a-local
SubFolders Verbatim
Path ~/Mail/competitors/business-a/
Inbox ~/Mail/competitors/business-a/INBOX

Channel business-a-inbox
Far :business-a-remote:
Near :business-a-local:
Patterns "INBOX"
Create Near
Sync Pull
Expunge None
CopyArrivalDate yes
```

Cette configuration est volontairement orientée lecture: `Sync Pull` récupère depuis Gmail vers le local, et `Expunge None` évite de propager des suppressions.

5. Synchroniser:

```bash
mbsync business-a-inbox
```

6. Initialiser `notmuch`:

```bash
notmuch setup
```

Quand `notmuch setup` demande le dossier mail, indiquez:

```text
~/Mail/competitors
```

Puis indexez:

```bash
notmuch new
```

7. Exporter les variables pour Neovim:

```bash
export MAIL_INTEL_ROOT="$HOME/Mail/competitors"
export MAIL_INTEL_ACCOUNT="business-a"
export MAIL_INTEL_FOLDER="INBOX"
```

Pour les rendre permanentes, ajoutez-les à votre shell (`~/.bashrc`, `~/.zshrc`, ou le fichier équivalent utilisé par votre dotfiles).

8. Tester:

```bash
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" accounts
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" folders business-a
scripts/mail-intel --maildir-root "$HOME/Mail/competitors" --format json list business-a INBOX --limit 10
```

Ensuite dans Neovim:

```vim
:CompetitorMailInbox
```
