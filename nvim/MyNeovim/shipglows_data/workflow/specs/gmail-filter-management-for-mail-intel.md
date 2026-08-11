---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "MyNeovim"
created: "2026-07-08"
created_at: "2026-07-08 00:00:00 UTC"
updated: "2026-07-08"
updated_at: "2026-07-08 00:00:00 UTC"
status: ready
source_skill: 100-sf-spec
source_model: "GPT-5 Codex"
scope: "Gmail filter and label management integrated with the Mail Intel email-management system"
owner: "dianedef"
user_story: "En tant qu'utilisatrice qui n'a parfois qu'un telephone, je veux que notre systeme de gestion email puisse creer et maintenir des filtres Gmail via l'API officielle, afin que mes labels et mes boites amont soient prets avant la revue locale Maildir dans Neovim."
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Mail Intel"
  - "daily-mail-intake-review-v2"
  - "Gmail API"
  - "OAuth desktop/local auth"
  - "mbsync/isync"
  - "Maildir"
  - "Neovim"
depends_on:
  - artifact: "shipglows_data/workflow/specs/gmail-maildir-neovim-reader-v1.md"
    artifact_version: "0.1.0"
    required_status: "active"
  - artifact: "shipglows_data/workflow/specs/daily-mail-intake-review-v2.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "The current Mail Intel and daily intake specs intentionally keep raw mail access read-only and local, so Gmail filter creation is not yet covered by the existing contract."
  - "The operator wants Gmail filters created from the managed system because mobile Gmail does not reliably expose native filter creation."
  - "Gmail exposes official API endpoints for labels and filters, making a first-party integration preferable to a third-party MCP for this admin capability."
next_step: "/102-sg-start gmail filter management for mail intel"
---

# Title

Gmail Filter Management For Mail Intel

## Status

Ready. This capability is a sibling of Mail Intel and daily intake, not an ad hoc standalone script, because it changes upstream inbox shaping and introduces remote Gmail settings mutation.

## User Story

En tant qu'utilisatrice qui n'a parfois qu'un telephone, je veux que notre systeme de gestion email puisse creer et maintenir des filtres Gmail via l'API officielle, afin que mes labels et mes boites amont soient prets avant la revue locale Maildir dans Neovim.

## Minimal Behavior Contract

The system provides an explicit operator-invoked Gmail admin path that can create and list Gmail labels and filters through the official Gmail API using local OAuth credentials. The feature stays separate from the read-only Maildir reading path: remote Gmail mutation is allowed for labels and filters and may send matching incoming mail to Gmail Trash immediately, but it must not read message bodies through Gmail API, send mail, or blur the local Maildir review boundary. Filter rules are stored in a local versioned declarative registry under `~/.shipglows/private/data/mail-admin/registry.json`, and the canonical dry-run normalization output must be stable across repeated runs. The easy-to-miss edge case is drift between declared rules and live Gmail settings: the tool must detect duplicate or conflicting filters rather than blindly creating more rules on each run.

The exact Gmail OAuth scope set is pinned to:
- `https://www.googleapis.com/auth/gmail.labels`
- `https://www.googleapis.com/auth/gmail.settings.basic`

## Success Behavior

- A local command can authenticate to Gmail with the minimum viable official scopes for labels and filter settings.
- The system can list existing Gmail labels and filters for the configured account.
- The operator can define a filter rule locally with sender/domain/query conditions, target label behavior, and optional immediate trash behavior.
- Applying a rule can create the label if missing, then create the Gmail filter idempotently.
- The operator can choose dry-run versus apply mode.
- The Mail Intel docs and workflow explain that Gmail filters shape upstream intake before `mbsync` and `notmuch`.

## Error Behavior

- If OAuth credentials are missing, the command fails with a clear setup error and does not prompt from inside Neovim unexpectedly.
- If the token lacks the needed Gmail settings scope, the command reports the missing permission explicitly.
- If the requested label already exists with incompatible settings, the command surfaces the conflict instead of silently changing it.
- If a logically equivalent Gmail filter already exists, the command reports it as already satisfied.
- If a remote API call fails, no local state claims success.

## Problem

The current Mail Intel system starts after Gmail has already delivered and organized mail. That works for local reading and daily review, but it leaves an upstream gap: when the operator only has a phone, native Gmail filter creation is impractical, so folder and label shaping cannot be maintained from the same managed workflow.

## Solution

Add an official Gmail API admin capability adjacent to Mail Intel. This capability owns declarative Gmail label/filter definitions and applies them explicitly before the existing Maildir sync and daily intake flow. The remote admin surface must remain narrow and intentional, while local reading and classification continue to use Maildir/notmuch.

## Scope In

- Gmail OAuth setup guidance for one or more personal/business accounts.
- Local commands to:
  - list Gmail labels
  - create Gmail labels
  - list Gmail filters
  - create Gmail filters from declarative local definitions
  - dry-run planned changes
- Storage of non-secret filter definitions in `~/.shipglows/private/data/mail-admin/registry.json`, intended to be versioned and backed up.
- Integration notes showing how upstream filters improve the Maildir/daily intake workflow.

## Scope Out

- Sending, replying, or reading message bodies through the Gmail API.
- Automatic background syncing from Gmail API into Neovim buffers.
- Broad mailbox administration beyond labels and filters.
- Third-party MCP dependency as the primary implementation path.

## Constraints

- Use the official Gmail API, not Gmail web scraping.
- Keep secrets and OAuth tokens outside `~/.shipglows/private/data/` and outside the repository.
- Keep remote mutation explicit and operator-invoked, not part of every read-only inbox command.
- Separate Gmail admin code from the local Maildir reading path so the safety boundary remains understandable.
- Prefer declarative, diffable rule definitions over one-off imperative commands when possible.
- Use a sibling CLI entrypoint `scripts/mail-admin`, not a hidden extension of the read-only `scripts/mail-intel` path.
- Treat "delete" in operator language as "move to Gmail Trash immediately" unless a later spec explicitly adds a stronger destructive path.

## Test Contract

- The filter-management CLI must support dry-run without mutating Gmail.
- Local normalization logic must prove idempotency for repeated apply runs against the same declared rule set.
- Label/filter payload generation must be testable without network access.
- Missing-scope and missing-credential failures must be covered by explicit error-path tests.

## Dependencies

- Existing Mail Intel v1 implementation:
  - `scripts/mail-intel`
  - `lua/shipglows/mail/`
  - `Mail Intel.md`
- Existing daily review spec:
  - `shipglows_data/workflow/specs/daily-mail-intake-review-v2.md`
- Gmail API official endpoints for:
  - labels
  - filters
- Local OAuth client credentials and token storage outside Git

## Invariants

- Raw email reading for Neovim review still flows through Maildir/notmuch.
- Gmail API access for this subsystem is limited to labels and filter settings, not general mail read/write unless a later spec explicitly changes that contract.
- The system never stores OAuth secrets, refresh tokens, or real account addresses in `~/.shipglows/private/data/`, repository docs, or fixtures.
- Reapplying the same declarative rules does not create duplicate filters.
- The local registry is the source of truth for desired rules; Gmail is the applied remote state.
- Rule normalization must sort accounts and rules deterministically, reject duplicate ids, and reject logically equivalent rules that target the same account, label, trash behavior, and normalized match expression.

## Links & Consequences

- This capability lives as a sibling CLI `scripts/mail-admin` separate from the current read-only `scripts/mail-intel`.
- `daily-mail-intake-review-v2` should treat Gmail filters as optional upstream shaping, not as a replacement for local review classification.
- Documentation must explain the boundary clearly: Gmail admin mutates remote settings; Mail Intel reading remains local-first.
- The durable local registry path is `~/.shipglows/private/data/mail-admin/registry.json`; short-retention review state may also be versioned in the same private repo under a separate subtree such as `~/.shipglows/private/data/mail-intake/`.

## Documentation Coherence

- Update `Mail Intel.md` with an explicit section on upstream Gmail filter management.
- Update `Cheat Sheet.md` with safe commands for filter dry-run/apply once implemented.
- Do not document real sender addresses, credentials, or live Gmail filter examples.
- Document the required OAuth scopes and registry normalization rules.

## Edge Cases

- The same sender should route differently depending on subject keywords.
- One Gmail message can match multiple labels and create duplicate Maildir placement downstream.
- Existing manual Gmail filters may conflict with declared rules.
- Different Gmail accounts may need different label naming conventions.
- The operator may want `label only` versus `label + immediate trash` behavior.
- A filter may move mail to Gmail Trash immediately, and the operator relies on Gmail Trash as the short recovery window.

## Implementation Tasks

- [ ] Task 1: Define the declarative rule contract
  - Files: new spec, future config location
  - Action: Freeze the local shape for sender/domain/query matching, label target, immediate trash behavior, and account selection.
  - User story link: Gives the operator a stable way to manage Gmail routing from the same system.
  - Depends on: none
  - Validate with: spec review and fixture payload examples.

- [ ] Task 2: Choose storage and command surface
  - Files: `scripts/` entrypoint, optional config file path, docs
  - Action: Implement the decided shape: declarative registry rooted at `~/.shipglows/private/data/mail-admin/` plus sibling CLI `scripts/mail-admin`.
  - User story link: Ensures the feature integrates with the existing email-management system instead of becoming a stray script.
  - Depends on: Task 1
  - Validate with: implementation layout review.

- [ ] Task 3: Add Gmail OAuth/bootstrap flow
  - Files: new script/module plus docs
  - Action: Implement token bootstrap and secure local token loading for the Gmail settings scope.
  - User story link: Makes remote filter creation possible from the managed system.
  - Depends on: Tasks 1-2
  - Validate with: auth bootstrap smoke check and secure path review.

- [ ] Task 4: Add label/filter list and apply commands
  - Files: new script/module
  - Action: Implement list/create/apply/dry-run flows with duplicate detection and minimal mutation semantics, including immediate-trash filter actions where declared.
  - User story link: Actually creates and maintains Gmail filters.
  - Depends on: Task 3
  - Validate with: local unit checks for normalization plus live proof against a pilot account.

- [ ] Task 5: Link upstream admin with daily intake docs
  - Files: `Mail Intel.md`, `Cheat Sheet.md`, `daily-mail-intake-review-v2.md`
  - Action: Document how Gmail filters shape the upstream inbox before local Maildir intake and when to use this admin path.
  - User story link: Keeps the whole email workflow coherent end to end.
  - Depends on: Task 4
  - Validate with: doc command/path consistency review.

## Acceptance Criteria

- The system exposes a coherent, documented Gmail admin capability as part of the Mail Intel ecosystem.
- Filter creation uses the official Gmail API with explicit operator action.
- Reapplying the same rules is idempotent.
- Rules can declare immediate Gmail Trash behavior for matching incoming mail.
- The feature does not weaken the read-only boundary of local Maildir review commands.
- Docs make the upstream versus local boundary obvious.

## Risks

- OAuth setup may be the hardest part for the operator compared with the code itself.
- Mixing remote Gmail admin too tightly into `mail-intel` could blur the safety boundary.
- Poor duplicate detection could create filter sprawl in Gmail.

## Open Questions

None. This spec is ready on the following decisions: rules live in `~/.shipglows/private/data/mail-admin/`, the command surface is `scripts/mail-admin`, and the supported destructive shortcut is immediate Gmail Trash rather than archive-by-default.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-08 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Added a sibling spec for Gmail filter management integrated with the Mail Intel ecosystem | Draft spec written; readiness still depends on storage, command surface, and OAuth decisions | /101-sf-ready gmail filter management for mail intel |
| 2026-07-08 00:00:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed Gmail filter management readiness after operator decisions on local registry, command surface, and immediate-trash behavior | ready: operator-facing decisions are now explicit, scope is bounded, and the proof contract is sufficient for implementation | /102-sg-start gmail filter management for mail intel |
| 2026-07-09 00:00:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the first Mail Admin slice with a versioned registry, local validation/planning, Gmail OAuth bootstrap hooks, and Gmail label/filter apply logic | partial: command surface and local registry are implemented, but live Gmail proof and installer/bootstrap follow-through remain pending | /103-sg-verify gmail filter management for mail intel |

## Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sf-spec | done | New sibling spec defines Gmail admin integration as part of the email-management system. |
| sf-ready | done | Registry path `~/.shipglows/private/data/mail-admin/`, `scripts/mail-admin`, and immediate-trash behavior are fixed in the spec. |
| sf-start | partial | `scripts/mail-admin` exists, private data roots are created, and docs now describe the Gmail admin boundary. |
| sf-verify | pending | Local CLI checks remain to run, and live Gmail API proof is still pending. |
| sf-end | pending | Closure depends on implementation and verification. |
| sf-ship | pending | Optional, only if the user wants commit/push workflow. |
