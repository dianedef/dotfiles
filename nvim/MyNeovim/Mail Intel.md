# Mail Intel

Mail Intel est une passerelle locale en lecture seule pour lire des emails Gmail synchronisés en Maildir, les ouvrir dans Neovim, puis copier leur contenu en Markdown pour un agent IA.

## Architecture

```text
Gmail personnel
  -> mbsync/isync
  -> ~/Mail/competitors/<account>/
  -> notmuch
  -> scripts/mail-intel
  -> lua/shipflow/mail/
  -> Neovim
```

La v1 ne sait pas envoyer, supprimer, archiver, déplacer, taguer ou marquer des emails. Elle lit uniquement un Maildir local déjà synchronisé.

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
