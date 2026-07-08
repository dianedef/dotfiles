---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "MyNeovim"
created: "2026-07-01"
created_at: "2026-07-01 08:01:48 UTC"
updated: "2026-07-08"
updated_at: "2026-07-08 00:00:00 UTC"
status: reviewed
source_skill: 100-sf-spec
source_model: "GPT-5 Codex"
scope: "daily Maildir intake classification and Neovim review queue"
owner: "dianedef"
user_story: "En tant qu'utilisatrice de Neovim qui lit des emails synchronises localement, je veux qu'un classifieur quotidien transforme les emails utiles en propositions de projet, d'angle et d'action, afin que je valide rapidement ce qui doit alimenter mes business et mes skills."
confidence: "medium"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "Mail Intel"
  - "mbsync/isync"
  - "Maildir"
  - "notmuch"
  - "Neovim"
  - "Avante"
  - "ShipGlowz source-intake classification"
  - "ShipGlowz private memory store"
  - "Gmail filter management for Mail Intel"
depends_on:
  - artifact: "shipglowz_data/workflow/specs/gmail-maildir-neovim-reader-v1.md"
    artifact_version: "0.1.0"
    required_status: "ready"
  - artifact: "shipglowz_data/workflow/specs/gmail-filter-management-for-mail-intel.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "Mail Intel.md"
    artifact_version: "unknown"
    required_status: "active"
  - artifact: "/home/claude/shipglowz/skills/references/source-intake-classification.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "/home/claude/shipglowz/skills/references/private-memory-store.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "/home/claude/shipglowz/shipglowz_data/business/portfolio-project-pitch-links.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "MyNeovim already contains a read-only Mail Intel pipeline: Maildir -> notmuch -> scripts/mail-intel -> lua/shipglowz/mail/."
  - "Mail Intel currently supports listing, searching, opening, and copying emails, but not daily classification or a review queue."
  - "The operator wants daily automation that classifies emails by probable project, useful angle, and next action before downstream skill use."
  - "The operator plans to review email-derived proposals inside Neovim, so the review surface should live close to the existing Mail Intel workflow."
next_step: "/100-sf-spec daily mail intake review v2"
---

# Title

Daily Mail Intake Review V2

## Status

Reviewed but not ready. The v2 direction is sound, and the queue storage contract is now fixed, but implementation-critical decisions remain open around classifier mode and the primary review surface inside Neovim.

## User Story

En tant qu'utilisatrice de Neovim qui lit des emails synchronises localement, je veux qu'un classifieur quotidien transforme les emails utiles en propositions de projet, d'angle et d'action, afin que je valide rapidement ce qui doit alimenter mes business et mes skills.

## Minimal Behavior Contract

The system reads a bounded set of fresh local emails from the existing Maildir/notmuch pipeline, classifies each candidate into a probable project, useful angle, owner skill, and suggested next action, then writes only review records into a private queue outside the repository. The queue is an operator-local ephemeral work queue, not a durable archive: each candidate is stored as one editable file, pending items live in `inbox/`, recently routed items may live briefly in `done/`, and processed items are expected to age out quickly. Neovim exposes commands to inspect the pending queue, open the source email, accept/edit/reject a proposal, and copy a governed prompt or handoff. The system must not send mail, mutate remote inbox state, or persist raw private email bodies into the public repository. The easy-to-miss edge case is rerun drift: the daily classifier must be idempotent and must not create duplicate pending records for the same message unless the source changed or the operator explicitly requeues it.

## Success Behavior

- A local command can run `mbsync`, `notmuch new`, and a bounded classification pass in sequence.
- The classifier can query only fresh or unreviewed emails from configured accounts/folders.
- Each queued proposal includes a stable source identifier, a compact source summary, probable project, useful angle, owner skill, confidence, risks, and review state.
- Queue records are stored under a private root outside Git, not in the `MyNeovim` repository.
- Queue records use one-file-per-item storage and remain easy to inspect, edit, move, and purge from Neovim.
- Neovim can list pending proposals, open the linked source email through the existing Mail Intel module, and update the review state.
- Accepted proposals can generate a governed prompt or structured handoff for downstream use.
- Rejected or ignored proposals do not reappear on every run unless explicitly requeued.

## Error Behavior

- If `mbsync` is unavailable, the sync step fails clearly and classification does not pretend to be fresh.
- If `notmuch` is unavailable or the index is stale/missing, the classifier stops with an explicit local dependency error.
- If the private queue root is missing or unwritable, the run fails without falling back to public repository storage.
- If project classification is ambiguous, the record remains `pending` with `project=unknown` or `portfolio scan needed` instead of forcing a wrong route.
- If the model/classifier cannot parse a message safely, the record is created with an explicit failure reason or skipped with a log entry, depending on the configured mode.
- If a proposal update conflicts with a locally edited review file, the system preserves the operator-edited record and reports the conflict.
- If `done/` retention cleanup fails, the system reports the failure but does not treat already reviewed items as pending again.

## Problem

Mail Intel v1 gives read-only email access inside Neovim, but it still assumes a manual workflow: the user searches, opens, reads, and manually forwards one email at a time to an AI tool. That is too slow for daily scanning when the goal is to turn inbox material into project ideas, content angles, or reusable marketing patterns. The missing capability is operational triage, not email reading.

## Solution

Add a `v2` intake layer around the existing Mail Intel pipeline. A local daily classifier will sync and index mail, select candidate messages, classify them using the ShipGlowz source-intake and portfolio contracts, write queue records into the private memory store, and expose Neovim commands for review and downstream routing.

## Queue Storage Contract

- The private queue root is `~/.shipglowz/private/mail-intake/` by default and stays separate from durable versioned data under `~/.shipglowz/private/data/`.
- Storage is `one file per queue item`, using a human-editable text format with YAML frontmatter and Markdown body.
- The queue is ephemeral operational state, not a durable email archive.
- Pending items live in `~/.shipglowz/private/mail-intake/inbox/`.
- Reviewed and routed items may be moved to `~/.shipglowz/private/mail-intake/done/` for short retention only.
- Optional `rejected/` retention is allowed, but it is not required for v2.
- Queue filenames must use a stable key derived from the source message identifier so reruns can detect existing items.
- Once an item is accepted and routed, the queue file is no longer the canonical business artifact; the canonical artifact becomes the downstream output or a minimal private note if one is explicitly created.
- Automatic cleanup may purge `done/` items after a short retention window such as `7` or `14` days.
- The storage contract must optimize for direct operator review and manual correction inside Neovim before optimizing for analytics or long-term history.
- Durable, versioned email-management memory such as declarative Gmail filter rules belongs under `~/.shipglowz/private/data/`, not in the ephemeral review queue.

## Scope In

- Daily or on-demand orchestration command for:
  - optional `mbsync`
  - `notmuch new`
  - bounded candidate selection
  - classification
  - private queue update
- Private queue storage under a dedicated path such as `~/.shipglowz/private/mail-intake/`.
- Structured queue record schema for proposal review.
- Extensions to `scripts/mail-intel` or a sibling local CLI dedicated to review queue operations.
- Neovim commands for:
  - viewing the pending queue
  - opening the source email from a queue item
  - accepting a proposal
  - editing key routing fields
  - rejecting or ignoring a proposal
  - copying a governed downstream prompt
- Routing logic aligned with ShipGlowz `#source`, portfolio index, and private-memory rules.
- Dedupe and rerun-state tracking keyed by stable message/thread identifiers.
- Docs for setup, security boundary, queue storage, and review workflow.

## Scope Out

- Sending, replying, archiving, deleting, tagging, or modifying remote email state.
- Full inbox management UI.
- Public repository storage of email bodies or private queue records.
- Automatic content publication, automatic spec creation, or automatic email-sequence drafting without review.
- Attachment parsing beyond lightweight metadata references.
- Multi-user review queue sync.
- A daemon owned by Neovim itself; scheduling may use systemd user timers but not background Neovim sessions.

## Constraints

- Preserve the existing read-only Mail Intel safety boundary for raw mail access.
- Keep all durable private email-derived records outside Git and outside the `MyNeovim` repository.
- Use the ShipGlowz private-memory contract and source-intake classification contract as the routing/storage source of truth.
- Default to storing compact summaries and structured fields, not full raw bodies.
- Treat processed queue items as disposable working state with short retention, not permanent records.
- Maintain idempotency across repeated daily runs.
- Reuse the centralized `lua/shipglowz/mail/` module pattern rather than scattering logic through unrelated config files.
- The operator must remain the approval gate before downstream skills act on a proposal.
- Any AI/model usage must degrade safely when unavailable and must not silently invent project truth or unsupported claims.

## Test Contract

- The classifier must be runnable in a dry-run mode that writes no queue files.
- A deterministic sample of indexed emails must produce stable queue records across repeated runs.
- Queue state transitions (`pending`, `accepted`, `edited`, `rejected`, `ignored`) must be testable without touching remote mail.
- The Neovim review commands must work against local queue fixtures and a local Mail Intel source without network access.
- Sensitive data rules must be testable by verifying that queue records do not contain forbidden raw fields by default.
- Queue retention and cleanup behavior must be testable without deleting the source Maildir message.

## Dependencies

- Existing Mail Intel v1 implementation:
  - `scripts/mail-intel`
  - `lua/shipglowz/mail/config.lua`
  - `lua/shipglowz/mail/init.lua`
  - `Mail Intel.md`
- Local mail tools:
  - `mbsync/isync`
  - `notmuch`
- Existing Neovim runtime with `vim.system`, `vim.ui.select`, and current AI plugin surfaces.
- ShipGlowz governance inputs:
  - `/home/claude/shipglowz/skills/references/source-intake-classification.md`
  - `/home/claude/shipglowz/skills/references/private-memory-store.md`
  - `/home/claude/shipglowz/shipglowz_data/business/portfolio-project-pitch-links.md`
- Fresh docs verdict: `fresh-docs not needed` for this spec pass because the design builds on local Maildir/notmuch behavior already present in the environment and does not introduce a new external provider contract.

## Invariants

- Queue storage never falls back to public repository paths.
- A queue record is keyed by a stable source identifier and must remain traceable back to the local message.
- The review workflow must remain explicit; downstream action is opt-in, not automatic.
- Classification output must separate inferred fields from observed source facts.
- Proposal text must not claim project truths that are not supported by the portfolio index or governed project docs.
- Raw mail access continues to flow through local Maildir/notmuch only; no direct Gmail API or remote inbox mutation is added.

## Links & Consequences

- `scripts/mail-intel` is the current logical entrypoint and may need a subcommand expansion or a sibling script if the responsibilities become too broad.
- Upstream Gmail filter administration now has its own sibling spec and should remain a separate operator-invoked surface, even if it lives in the same Mail Intel ecosystem.
- `lua/shipglowz/mail/init.lua` already owns Mail Intel commands and is the right review surface owner for queue actions.
- `lua/shipglowz/mail/config.lua` should grow only with queue root, default review filters, and bounded execution settings, not secrets.
- `Mail Intel.md` and `Cheat Sheet.md` must be updated so the review queue becomes the default daily workflow, not a hidden extra.
- The private queue will operationally depend on `~/.shipglowz/private/`, while durable versioned email-management data may live under `~/.shipglowz/private/data/`, so local setup and backups matter.
- Wrong classification can create operator drag, so confidence and review state are first-class fields, not optional metadata.

## Documentation Coherence

- Update `Mail Intel.md` with:
  - daily intake concept
  - private queue path
  - review commands
  - read-only versus review-state boundary
- Update `Cheat Sheet.md` with the new keymaps/commands and the recommended daily flow.
- Document the queue record schema and safe storage rules in a dedicated local doc if `Mail Intel.md` becomes too dense.
- Do not include real email excerpts, addresses, credentials, or private queue examples in repository docs.

## Edge Cases

- One email matches several projects with similar vocabulary.
- Several Gmail labels create near-duplicate Maildir entries for the same message.
- A source email is useful for more than one downstream angle.
- The classifier sees newsletters, transactional emails, and personal mail in the same folder.
- An HTML-heavy email has weak plain-text extraction but still needs a review record.
- The operator edits a pending queue record while a daily run happens.
- The queue grows too large and needs a limit, archive, or aging strategy.
- A message was already accepted months ago and resurfaces because the folder was reindexed.

## Implementation Tasks

- [x] Task 1: Define the queue record contract
  - File: `shipglowz_data/workflow/specs/daily-mail-intake-review-v2.md`
  - Action: Freeze the fields, statuses, dedupe key, and allowed persisted content for mail-intake queue records.
  - User story link: Gives the operator a stable object to review instead of free-form AI output.
  - Depends on: none
  - Validate with: spec review and fixture examples in dry-run notes.
  - Notes: Fixed as one-file-per-item, ephemeral queue storage under `inbox/` and short-retention `done/`, with compact metadata and summaries instead of full email bodies.

- [ ] Task 2: Add private storage configuration
  - Files: `lua/shipglowz/mail/config.lua`, queue storage helper path
  - Action: Add configurable private queue root, default queue file naming, and bounded limits.
  - User story link: Makes durable review state available between runs.
  - Depends on: Task 1
  - Validate with: headless config load and a no-root error check.
  - Notes: The default root should align with `~/.shipglowz/private/mail-intake/`.

- [ ] Task 3: Add candidate selection and classification CLI
  - Files: `scripts/mail-intel` or `scripts/mail-intake`
  - Action: Implement bounded candidate selection from notmuch plus `classify`, `queue-list`, `queue-show`, `queue-update`, and `queue-requeue` style operations.
  - User story link: Produces the daily proposal queue from fresh local emails.
  - Depends on: Tasks 1-2
  - Validate with: CLI help, dry-run output, deterministic fixture run, and missing-dependency failures.
  - Notes: Keep raw mail read-only; queue updates change only local private review records.

- [ ] Task 4: Add classification adapter
  - Files: local classifier module or script helpers
  - Action: Map source emails into `project`, `angle`, `owner skill`, `suggested action`, `confidence`, and `risks` using the ShipGlowz source-intake and portfolio contracts.
  - User story link: Replaces manual first-pass routing.
  - Depends on: Task 3
  - Validate with: fixture-based classification comparisons and explicit unknown/ambiguous cases.
  - Notes: Separate observed facts from inference in persisted records.

- [ ] Task 5: Add Neovim queue review commands
  - File: `lua/shipglowz/mail/init.lua`
  - Action: Add commands and mappings for queue listing, queue item open, accept/edit/reject, and governed prompt copy.
  - User story link: Lets the operator validate proposals without leaving Neovim.
  - Depends on: Tasks 2-4
  - Validate with: headless command registration and manual queue-fixture review checks.
  - Notes: Reuse the existing Mail Intel UX patterns where they are good enough.

- [ ] Task 6: Add downstream prompt/handoff generation
  - File: `lua/shipglowz/mail/init.lua` and CLI helpers as needed
  - Action: Replace the current monolithic `$sf-content` prompt path with queue-aware governed handoffs aligned to `#source` and the selected owner skill.
  - User story link: Makes accepted proposals immediately usable by downstream skills.
  - Depends on: Task 5
  - Validate with: prompt generation checks for `emailing`, repurpose, research, and docs-oriented cases.
  - Notes: Do not hardcode every case into one giant prompt string.

- [ ] Task 7: Add scheduling path
  - Files: local docs, optional user-systemd unit samples, optional helper script
  - Action: Document and, if justified, provide a user-level timer/service pattern for daily runs after the manual command is proven reliable.
  - User story link: Removes the need to remember the intake pass every day.
  - Depends on: Tasks 3-6
  - Validate with: `systemctl --user` dry-run or sample-unit review plus idempotent rerun proof.
  - Notes: Scheduling is last, not first.

- [ ] Task 8: Update docs
  - Files: `Mail Intel.md`, `Cheat Sheet.md`, optional dedicated queue doc
  - Action: Document setup, review workflow, queue states, and storage boundaries.
  - User story link: Makes the v2 workflow repeatable without chat history.
  - Depends on: Tasks 5-7
  - Validate with: command/doc name matching and security redaction review.
  - Notes: Show examples with sanitized placeholders only.

## Acceptance Criteria

- A local daily intake command can run without modifying remote mail state.
- Running the intake command twice without new mail does not create duplicate pending records.
- Queue records are written only under the configured private root and not in the repository.
- Queue records are stored as one editable file per item and can be purged after routing without breaking the source Maildir state.
- A pending record can be opened in Neovim and linked back to its source email.
- The operator can accept, edit, reject, or ignore a queue item from Neovim.
- Accepted records can generate a downstream prompt or handoff that includes project, angle, owner skill, risks, and suggested next action.
- Ambiguous records remain reviewable without false precision.
- Docs clearly explain that raw email content is private and must not be committed.

## Test Strategy

- Static/load checks:
  - `nvim --headless "+lua require('shipglowz.mail.config')" +qa`
  - `nvim --headless "+lua require('shipglowz.mail')" +qa`
  - `nvim --headless "+lua require('shipglowz').setup()" +qa`
- CLI smoke checks:
  - `scripts/mail-intel --help` or new intake CLI help
  - dry-run intake command
  - queue list/show/update command checks
- Determinism checks:
  - same source set -> same queue records
  - rerun after acceptance/rejection preserves state correctly
- Failure checks:
  - missing `mbsync`
  - missing `notmuch`
  - missing private root
  - malformed or HTML-heavy source
  - ambiguous project routing
- Manual Neovim checks:
  - open queue
  - open linked email
  - change status
  - generate downstream prompt

## Risks

- The classifier can easily overfit to weak wording and produce noisy project matches.
- Daily automation can create review fatigue if candidate selection is too broad.
- Even compact queue records can leak more source text than intended if the schema is not disciplined.
- Mixing queue review logic into `mail-intel` without clear boundaries could bloat the current read-only CLI.
- Scheduling before the manual command is solid would lock in fragile behavior.

## Execution Notes

- Keep the current Mail Intel read-only contract intact and layer queue operations on top of it.
- Treat Gmail filter creation as optional upstream inbox shaping owned by the sibling Gmail admin spec, not by the local review queue runtime itself.
- Prefer a sibling `mail-intake` CLI if `scripts/mail-intel` becomes semantically overloaded.
- Start with one account and one or two folders before generalizing the classifier.
- Keep queue files machine-readable and easy to diff locally.
- Treat the private queue as operator-local working state, not as a collaborative artifact or archive.

## Open Questions

The spec is still blocked on two implementation-shaping decisions:

- Classifier mode: local heuristics only versus bounded model-assisted classification.
- Primary Neovim review surface: `vim.ui.select`-style picker versus a richer buffer-driven review workflow.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-01 08:01:48 UTC | sf-spec | GPT-5 Codex | Created a v2 spec for daily mail intake classification and Neovim review queue on top of Mail Intel v1 | Draft spec written with private storage, review-state, idempotency, and downstream routing constraints | /101-sf-ready daily mail intake review v2 |
| 2026-07-01 22:13:06 UTC | 101-sf-ready | GPT-5 Codex | Reviewed readiness for daily mail intake review v2 | not ready: queue storage contract, classifier mode, and Neovim review surface remain materially undecided | /100-sf-spec daily mail intake review v2 |
| 2026-07-08 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Resolved the queue storage blocker by fixing ephemeral one-file-per-item queue storage under the private root | Storage shape, lifecycle, retention, and canonical-output boundary are now explicit; classifier mode and review-surface blockers remain | /100-sf-spec daily mail intake review v2 |
| 2026-07-08 00:00:00 UTC | 703-sg-review | GPT-5 Codex | Migrated spec references from shipflow to shipglowz namespace | Spec paths and headless test commands now match the current repo naming; implementation gaps remain | /100-sf-spec daily mail intake review v2 |
| 2026-07-08 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Linked the daily intake spec to a new sibling Gmail filter-management spec | Upstream Gmail routing is now modeled as part of the broader email-management system without weakening the local review queue boundary | /101-sf-ready gmail filter management for mail intel |

## Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sf-spec | done | New v2 chantier drafted on top of the existing Mail Intel v1 pipeline. |
| sf-ready | not ready | Storage contract is fixed; classifier strategy and review-surface choice still change implementation and proof paths. |
| sf-start | pending | Implementation has not started. |
| sf-verify | pending | No implementation proof yet. |
| sf-end | pending | Closure depends on implementation and verification. |
| sf-ship | pending | Optional, only if the user wants commit/push workflow. |
