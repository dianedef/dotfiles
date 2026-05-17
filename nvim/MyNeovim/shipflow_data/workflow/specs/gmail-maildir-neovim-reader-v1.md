---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "MyNeovim"
created: "2026-05-17"
created_at: "2026-05-17 14:35:01 UTC"
updated: "2026-05-17"
updated_at: "2026-05-17 14:35:01 UTC"
status: draft
source_skill: sf-spec
source_model: "GPT-5 Codex"
scope: "read-only Gmail-to-Maildir-to-Neovim competitor email reader"
owner: "dianedef"
user_story: "En tant qu'utilisatrice de Neovim qui surveille des emails concurrents recus sur plusieurs comptes Gmail personnels, je veux lister, rechercher, ouvrir et copier le contenu texte des emails depuis Neovim, afin de les envoyer manuellement a mes agents IA pour analyse."
risk_level: "medium"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Gmail personal accounts"
  - "IMAP"
  - "mbsync/isync"
  - "Maildir"
  - "notmuch"
  - "Neovim"
  - "LazyVim"
  - "Claude Code"
  - "Gemini CLI"
  - "Copilot Chat"
depends_on:
  - artifact: "explorations/2026-05-17-neovim-plugin-mcp-idea.md"
    artifact_version: "1.0.0"
    required_status: "draft"
  - artifact: "Google Gmail Help: Add Gmail to another email client"
    artifact_version: "accessed-2026-05-17"
    required_status: "current"
  - artifact: "Google Account Help: Sign in with app passwords"
    artifact_version: "accessed-2026-05-17"
    required_status: "current"
supersedes: []
evidence:
  - "User wants read-only access to competitor emails from Gmail personal accounts for AI analysis."
  - "User prefers Gmail -> local Maildir option and does not need to write emails."
  - "lua/shipflow/init.lua already hosts local Neovim commands and mappings."
  - "lua/plugins/claudecode.lua and lua/plugins/gemini-cli.lua already expose AI agent surfaces inside Neovim."
  - "AI Plugins.md documents current AI plugin choices."
  - "Official Gmail Help says personal Gmail IMAP access is always on from January 2025 and recommends Sign in with Google over sharing account passwords."
  - "Official Google Account Help says app passwords require 2-Step Verification and are not always available."
next_step: "/sf-ready gmail maildir neovim reader v1"
---

# Title

Gmail Maildir Neovim Reader V1

## Status

Draft spec for a first read-only implementation.

## User Story

En tant qu'utilisatrice de Neovim qui surveille des emails concurrents recus sur plusieurs comptes Gmail personnels, je veux lister, rechercher, ouvrir et copier le contenu texte des emails depuis Neovim, afin de les envoyer manuellement a mes agents IA pour analyse.

## Minimal Behavior Contract

The system reads locally synchronized Gmail messages from a Maildir tree, indexes or queries them through `notmuch`, and exposes a small read-only Neovim interface for listing, searching, opening, and copying selected emails as clean Markdown. It must never send, delete, archive, move, mark, tag, or mutate remote Gmail messages in v1. When local mail sync, indexing, or provider credentials are missing, commands fail with a clear local setup error and do not attempt network auth from Neovim. The easy-to-miss edge case is HTML-only email: v1 must produce readable plain text when possible and clearly mark when extraction is incomplete.

## Success Behavior

- A configured Gmail account can be synchronized locally into Maildir outside Neovim.
- `notmuch` can index the local Maildir and search by folder, sender, subject, date, and free text.
- Neovim provides user commands to list recent competitor emails, search emails, open one email in a scratch Markdown buffer, and copy the opened email as Markdown.
- Email buffers include metadata and body text in a stable structure suitable for pasting into Claude Code, Gemini CLI, Copilot Chat, Avante, or another agent.
- All AI handoff is manual in v1: the user explicitly copies or invokes an existing agent command with the selected email content.

## Error Behavior

- If `notmuch` is unavailable, Neovim reports that the local index dependency is missing.
- If no Maildir path is configured, commands report the expected config key and do nothing else.
- If a query returns no messages, Neovim opens no email and reports an empty result.
- If an email cannot be parsed, the UI shows the raw headers/body fallback in a scratch buffer with a warning.
- If sync credentials fail, that failure is handled by `mbsync` or the sync command, not by the Neovim plugin.

## Problem

The user has multiple personal Gmail accounts used for businesses and receives competitor/newsletter emails there. The current AI tools inside Neovim can analyze pasted text, but there is no clean local bridge from inbox content to Neovim/AI context. A full email client or MCP server is unnecessary for v1 and would increase setup, security, and maintenance risk.

## Solution

Build a read-only local pipeline: Gmail personal account syncs to Maildir with `mbsync/isync`; `notmuch` indexes the local mail; a small CLI wrapper exposes stable list/search/show/export operations; a local Neovim module calls the CLI and displays/copies Markdown.

## Scope In

- One Gmail personal account as the pilot account.
- Local Maildir storage under a configurable root such as `~/Mail/competitors/<account>/`.
- `mbsync/isync` configuration guidance for read-focused Gmail sync.
- `notmuch` setup and indexing for the local Maildir.
- A local CLI, tentatively `mail-intel`, with read-only commands:
  - `accounts`
  - `folders`
  - `list`
  - `search`
  - `show`
  - `export --markdown`
- A local Neovim module under `lua/shipflow/` or adjacent namespace with commands:
  - `:CompetitorMailInbox`
  - `:CompetitorMailSearch`
  - `:CompetitorMailOpen`
  - `:CompetitorMailCopyMarkdown`
- Scratch buffers for opened emails.
- Documentation for setup, security boundaries, and troubleshooting.

## Scope Out

- Sending, replying, forwarding, drafting, deleting, archiving, moving, tagging, or marking emails.
- Full email client behavior.
- Direct Gmail API implementation.
- MCP server.
- Automatic AI ingestion of a whole inbox.
- Automatic competitor classification or summarization.
- Multi-account UX beyond config structure and one-account pilot validation.
- Attachment download or attachment parsing.
- Background daemon or scheduled sync management inside Neovim.

## Constraints

- Keep v1 read-only from the Neovim and CLI perspective.
- Do not store Gmail passwords, app passwords, OAuth tokens, or cookies in the repository.
- Do not persist email contents in ShipFlow specs, docs, logs, or examples.
- Prefer local files and CLI calls over embedding Gmail auth in Neovim.
- Preserve existing LazyVim conventions and local module style.
- Do not break existing AI plugin mappings documented in `AI Plugins.md`.
- Gmail auth must follow current Google guidance: modern Sign in with Google/OAuth is preferred; app passwords are only an optional fallback when available.

## Dependencies

- `mbsync/isync` for IMAP-to-Maildir synchronization.
- `notmuch` for local mail indexing and search.
- Neovim/LazyVim local config.
- Existing `lua/shipflow/init.lua` command registration pattern.
- Official Google Gmail Help, accessed 2026-05-17:
  - `https://support.google.com/mail/answer/7126229`
  - Relevant rule: personal Gmail IMAP access is always on from January 2025, and Gmail recommends Sign in with Google instead of sharing Google username/password with third-party clients.
- Official Google Account Help, accessed 2026-05-17:
  - `https://support.google.com/accounts/answer/185833`
  - Relevant rule: app passwords require 2-Step Verification, are not recommended in most cases, and may be unavailable for some account configurations.
- Fresh docs verdict: `fresh-docs checked`.

## Invariants

- A Neovim command cannot mutate Gmail or local Maildir state in v1 except creating temporary scratch buffers and copying selected output.
- All email-to-agent transfer requires an explicit user action on selected content.
- The CLI output format consumed by Neovim must be stable and machine-readable for list/search/show operations.
- The Markdown export format must remain readable when pasted outside Neovim.
- Missing optional providers degrade gracefully instead of failing Neovim startup.

## Links & Consequences

- `lua/plugins/claudecode.lua`: possible manual destination for copied email context.
- `lua/plugins/gemini-cli.lua`: possible manual destination for copied email context.
- `AI Plugins.md`: should document the new email-to-AI workflow after implementation.
- `lua/shipflow/init.lua`: likely host for local commands or setup delegation.
- Local mail storage can contain sensitive business and personal data; backup, logging, and repo hygiene matter.
- Gmail account security choices affect setup friction and must be documented explicitly.

## Documentation Coherence

- Add a new doc such as `Mail Intel.md` or update `AI Plugins.md` with:
  - v1 purpose
  - read-only boundary
  - setup dependencies
  - Gmail auth caveats
  - basic commands
  - troubleshooting for no index, no Maildir, and parse failure
- Do not include real email contents, account addresses, tokens, or competitor-specific private examples.

## Edge Cases

- HTML-only emails with no `text/plain` part.
- Multipart emails with quoted-printable or base64 encodings.
- Gmail labels represented as IMAP folders or Maildir paths.
- Duplicate messages across Gmail labels.
- Multiple Gmail accounts with similar sender/subject values.
- Very large newsletters that should not freeze Neovim.
- Emails with tracking pixels or remote images; v1 must not fetch remote assets.
- Non-UTF-8 or malformed message bodies.
- Queries returning many results; v1 must enforce default limits.

## Implementation Tasks

- [ ] Task 1: Add project-local mail-intel configuration contract
  - File: `lua/shipflow/mail_config.lua`
  - Action: Define account names, Maildir root, default account, default folders, result limit, and CLI command names without secrets.
  - User story link: Establishes where competitor emails are read from.
  - Depends on: none
  - Validate with: `nvim --headless "+lua require('shipflow.mail_config')" +qa`
  - Notes: Keep account addresses optional or allow aliases to avoid exposing private details in repo.

- [ ] Task 2: Add read-only CLI wrapper
  - File: `scripts/mail-intel`
  - Action: Implement `accounts`, `folders`, `list`, `search`, `show`, and `export --markdown` using `notmuch` and local Maildir paths.
  - User story link: Provides the reusable local bridge from indexed email to text/Markdown.
  - Depends on: Task 1
  - Validate with: `scripts/mail-intel --help` and a no-Maildir failure check.
  - Notes: Prefer JSON output for machine consumption and Markdown only for export/open/copy.

- [ ] Task 3: Add email parsing/export logic
  - File: `scripts/mail-intel`
  - Action: Parse `notmuch show --format=json` output, extract From/To/Date/Subject/Account/Folder, prefer `text/plain`, and produce a Markdown export.
  - User story link: Converts raw email into agent-friendly text.
  - Depends on: Task 2
  - Validate with: fixture-based parser checks or sanitized sample email files.
  - Notes: Do not fetch remote images or links; list links that already appear in the message body.

- [ ] Task 4: Add Neovim mail module
  - File: `lua/shipflow/mail.lua`
  - Action: Call the CLI with `vim.system`, handle errors, render scratch buffers, and expose Lua functions for inbox/search/open/copy.
  - User story link: Makes the workflow usable from Neovim.
  - Depends on: Tasks 1-3
  - Validate with: `nvim --headless "+lua require('shipflow.mail')" +qa`
  - Notes: Commands should fail gracefully if `scripts/mail-intel` or `notmuch` is missing.

- [ ] Task 5: Register Neovim commands and mappings
  - File: `lua/shipflow/init.lua`
  - Action: Register `CompetitorMailInbox`, `CompetitorMailSearch`, `CompetitorMailOpen`, and `CompetitorMailCopyMarkdown`; add optional leader mappings under an existing or new AI/mail group.
  - User story link: Gives the user direct commands for reading and copying selected emails.
  - Depends on: Task 4
  - Validate with: `nvim --headless "+lua require('shipflow').setup()" +qa`
  - Notes: Avoid colliding with existing mappings in `lua/config/keymaps.lua`.

- [ ] Task 6: Document setup and v1 boundary
  - File: `Mail Intel.md`
  - Action: Document installing `mbsync/isync` and `notmuch`, syncing one Gmail pilot account, indexing, command examples, and the read-only/security boundary.
  - User story link: Makes the first version reproducible without rereading chat history.
  - Depends on: Tasks 1-5
  - Validate with: Read-through plus command names matching implementation.
  - Notes: Link to official Google help pages instead of copying sensitive setup details.

## Acceptance Criteria

- Running Neovim headless with the new modules loaded exits without Lua errors.
- With no Maildir configured, `:CompetitorMailInbox` reports a clear setup error and does not crash.
- With `notmuch` missing, CLI and Neovim commands report the missing dependency.
- With a configured local test Maildir and notmuch index, the CLI can list recent messages with a result limit.
- Opening an email creates a scratch Markdown buffer with stable metadata and body sections.
- Copying an opened email places only the selected/current email Markdown on the clipboard or configured copy mechanism.
- No command sends, deletes, archives, moves, tags, marks, or syncs emails.
- Documentation states that Gmail credentials/tokens must not be committed.
- Documentation states that AI ingestion is manual and user-selected in v1.

## Test Strategy

- Static Lua load checks:
  - `nvim --headless "+lua require('shipflow.mail_config')" +qa`
  - `nvim --headless "+lua require('shipflow.mail')" +qa`
  - `nvim --headless "+lua require('shipflow').setup()" +qa`
- CLI smoke checks:
  - `scripts/mail-intel --help`
  - `scripts/mail-intel accounts`
  - `scripts/mail-intel list <account> INBOX --limit 5`
  - `scripts/mail-intel export <account> <message-id> --markdown`
- Failure checks:
  - Missing Maildir root.
  - Missing `notmuch`.
  - Empty query result.
  - Malformed/sanitized email fixture.
- Manual Neovim checks:
  - Run `:CompetitorMailInbox`.
  - Open one message.
  - Copy Markdown.
  - Paste into an existing AI agent buffer or terminal manually.

## Risks

- Gmail auth setup may be the longest part because Google recommends modern Sign in with Google and app passwords are conditional.
- A local Maildir may contain sensitive email data; accidental repo inclusion must be prevented.
- HTML email extraction can be messy; v1 should prefer readable text over perfect rendering.
- `notmuch` indexing/tagging conventions can differ by account and Maildir layout.
- Multiple accounts can create duplicate messages through Gmail labels.

## Execution Notes

- Start with one Gmail personal account and one folder/label before expanding.
- Treat `mbsync` as an external setup step. The Neovim plugin should not own sync scheduling.
- Keep `mail-intel` read-only: it may call `notmuch search/show`, but not tag or mutate mail state in v1.
- Consider adding ignore patterns for local mail directories if they are inside or near the dotfiles tree; preferred storage is outside the repo.
- Fresh docs checked against official Google Help on 2026-05-17:
  - Gmail IMAP for personal accounts is always on from January 2025.
  - Google recommends Sign in with Google instead of sharing Google account credentials.
  - App passwords require 2-Step Verification and may be unavailable depending on account security settings.

## Open Questions

- None blocking for the v1 spec. Implementation should choose one pilot Gmail account locally during setup and keep secrets outside the repository.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-17 14:35:01 UTC | sf-spec | GPT-5 Codex | Created first v1 spec for read-only Gmail/Maildir/Neovim email reader | Draft spec written with security and freshness gates | /sf-ready gmail maildir neovim reader v1 |

## Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sf-spec | done | First draft spec created. |
| sf-ready | next | Validate readiness and resolve any setup/auth concerns before implementation. |
| sf-start | pending | Implement only after readiness validation. |
| sf-verify | pending | Verify CLI, Neovim load, and manual read-only behavior. |
| sf-end | pending | Close with documentation and remaining risks. |
| sf-ship | pending | Optional, only if the user wants commit/push workflow. |
