---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "MyNeovim"
created: "2026-07-01"
created_at: "2026-07-01 08:01:48 UTC"
updated: "2026-07-08"
updated_at: "2026-07-08 00:00:00 UTC"
status: ready
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
  - "ShipGlows source-intake classification"
  - "ShipGlows private memory store"
  - "Gmail filter management for Mail Intel"
depends_on:
  - artifact: "shipglows_data/workflow/specs/gmail-maildir-neovim-reader-v1.md"
    artifact_version: "0.1.0"
    required_status: "ready"
  - artifact: "shipglows_data/workflow/specs/gmail-filter-management-for-mail-intel.md"
    artifact_version: "0.1.0"
    required_status: "ready"
  - artifact: "Mail Intel.md"
    artifact_version: "unknown"
    required_status: "active"
  - artifact: "/home/claude/.shipglows/source/skills/references/source-intake-classification.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "/home/claude/.shipglows/source/skills/references/private-memory-store.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "/home/claude/.shipglows/source/shipglows_data/business/portfolio-project-pitch-links.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "MyNeovim already contains a read-only Mail Intel pipeline: Maildir -> notmuch -> scripts/mail-intel -> lua/shipglows/mail/."
  - "Mail Intel currently supports listing, searching, opening, and copying emails, but not daily classification or a review queue."
  - "The operator wants daily automation that classifies emails by probable project, useful angle, and next action before downstream skill use."
  - "The operator plans to review email-derived proposals inside Neovim, so the review surface should live close to the existing Mail Intel workflow."
  - "Gmail filter management is now a sibling ready spec and should be treated as upstream inbox shaping, not as part of the daily review queue implementation."
next_step: "/100-sf-spec daily mail intake review v2"
---

# Title

Daily Mail Intake Review V2

## Status

Ready for implementation. The operator chose a buffer-driven Neovim review surface inspired by lazygit/neogit, with bounded model assistance from the existing Avante surface. Classification is interactive and explicit: the system never silently routes an email or creates downstream content.

## User Story

En tant qu'utilisatrice de Neovim qui lit des emails synchronises localement, je veux qu'un classifieur quotidien transforme les emails utiles en propositions de projet, d'angle et d'action, afin que je valide rapidement ce qui doit alimenter mes business et mes skills.

## Minimal Behavior Contract

The system reads a bounded set of fresh local emails from the existing Maildir/notmuch pipeline, classifies each candidate into a probable project, useful angle, owner skill, and suggested next action, then writes only review records into a private queue inside the private data repository. The queue is short-retention working state, not a durable archive: each candidate is stored as one editable file, pending items live in `inbox/`, recently routed items may live briefly in `done/`, and processed items are expected to age out quickly even though the state is versioned for operator recovery. Neovim exposes commands to inspect the pending queue, open the source email, accept/edit/reject a proposal, and copy a governed prompt or handoff. The system must not send mail, mutate remote inbox state, or persist raw private email bodies into the public repository. The easy-to-miss edge case is rerun drift: the daily classifier must be idempotent and must not create duplicate pending records for the same message unless the source changed or the operator explicitly requeues it.

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

Add a `v2` intake layer around the existing Mail Intel pipeline. A local daily classifier will sync and index mail, select candidate messages, classify them using the ShipGlows source-intake and portfolio contracts, write queue records into the private memory store, and expose Neovim commands for review and downstream routing.

## Queue Storage Contract

- The private queue root is `~/.shipglows/private/data/mail-intake/` by default.
- The approved local raw-mail source may live under `~/.shipglows/private/data/mail-source/`; raw source files are excluded from the private Git working tree and are not queue records.
- Storage is `one file per queue item`, using a human-editable text format with YAML frontmatter and Markdown body.
- The queue is short-retention operational state, not a durable email archive, but it is still versioned in the private repo for operator recovery.
- Pending items live in `~/.shipglows/private/data/mail-intake/inbox/`.
- Reviewed and routed items may be moved to `~/.shipglows/private/data/mail-intake/done/` for short retention only.
- Optional `rejected/` retention is allowed, but it is not required for v2.
- Queue filenames must use a stable key derived from the source message identifier so reruns can detect existing items.
- Once an item is accepted and routed, the queue file is no longer the canonical business artifact; the canonical artifact becomes the downstream output or a minimal private note if one is explicitly created.
- Automatic cleanup may purge `done/` items after a short retention window such as `7` or `14` days.
- The storage contract must optimize for direct operator review and manual correction inside Neovim before optimizing for analytics or long-term history.
- Durable reference state such as declarative Gmail filter rules and short-retention working state such as the review queue may both live under `~/.shipglows/private/data/`, but they must remain in clearly separated subtrees with distinct cleanup expectations.

## Scope In

- Daily or on-demand orchestration command for:
  - optional `mbsync`
  - `notmuch new`
  - bounded candidate selection
  - classification
  - private queue update
- Private queue storage under a dedicated path such as `~/.shipglows/private/data/mail-intake/`.
- Structured queue record schema for proposal review.
- Extensions to `scripts/mail-intel` or a sibling local CLI dedicated to review queue operations.
- Neovim commands for:
  - viewing the pending queue
  - opening the source email from a queue item
  - accepting a proposal
  - editing key routing fields
  - rejecting or ignoring a proposal
  - copying a governed downstream prompt
- Routing logic aligned with ShipGlows `#source`, portfolio index, and private-memory rules.
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
- Keep all private email-derived records outside the public `MyNeovim` repository; versioning inside the separate private data repository is allowed and expected for both durable rule state and short-retention queue state.
- Use the ShipGlows private-memory contract and source-intake classification contract as the routing/storage source of truth.
- Default to storing compact summaries and structured fields, not full raw bodies.
- Treat processed queue items as disposable working state with short retention, not permanent records.
- Maintain idempotency across repeated daily runs.
- Reuse the centralized `lua/shipglows/mail/` module pattern rather than scattering logic through unrelated config files.
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
  - `lua/shipglows/mail/config.lua`
  - `lua/shipglows/mail/init.lua`
  - `Mail Intel.md`
- Local mail tools:
  - `mbsync/isync`
  - `notmuch`
- Existing Neovim runtime with `vim.system`, `vim.ui.select`, and current AI plugin surfaces.
- ShipGlows governance inputs:
  - `/home/claude/.shipglows/source/skills/references/source-intake-classification.md`
  - `/home/claude/.shipglows/source/skills/references/private-memory-store.md`
  - `/home/claude/.shipglows/source/shipglows_data/business/portfolio-project-pitch-links.md`
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
- `lua/shipglows/mail/init.lua` already owns Mail Intel commands and is the right review surface owner for queue actions.
- `lua/shipglows/mail/config.lua` should grow only with queue root, default review filters, and bounded execution settings, not secrets.
- `Mail Intel.md` and `Cheat Sheet.md` must be updated so the review queue becomes the default daily workflow, not a hidden extra.
- The private queue and the durable email-management registry will operationally depend on `~/.shipglows/private/data/`, so local setup, private-repo sync, and bounded cleanup matter.
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
  - File: `shipglows_data/workflow/specs/daily-mail-intake-review-v2.md`
  - Action: Freeze the fields, statuses, dedupe key, and allowed persisted content for mail-intake queue records.
  - User story link: Gives the operator a stable object to review instead of free-form AI output.
  - Depends on: none
  - Validate with: spec review and fixture examples in dry-run notes.
  - Notes: Fixed as one-file-per-item, short-retention queue storage under `~/.shipglows/private/data/mail-intake/` with `inbox/` and short-retention `done/`, plus compact metadata and summaries instead of full email bodies.

- [x] Task 2: Add private storage configuration
  - Files: `lua/shipglows/mail/config.lua`, queue storage helper path
  - Action: Add configurable private queue root, default queue file naming, and bounded limits.
  - User story link: Makes durable review state available between runs.
  - Depends on: Task 1
  - Validate with: headless config load and a no-root error check.
  - Notes: The default root should align with `~/.shipglows/private/data/mail-intake/`.

- [x] Task 3: Add candidate selection and classification CLI
  - Files: `scripts/mail-intel` or `scripts/mail-intake`
  - Action: Implement bounded candidate selection from notmuch plus `classify`, `queue-list`, `queue-show`, `queue-update`, and `queue-requeue` style operations.
  - User story link: Produces the daily proposal queue from fresh local emails.
  - Depends on: Tasks 1-2
  - Validate with: CLI help, dry-run output, deterministic fixture run, and missing-dependency failures.
  - Notes: Keep raw mail read-only; queue updates change only local private review records.

- [ ] Task 4: Add classification adapter
  - Files: local classifier module or script helpers
  - Action: Map source emails into `project`, `angle`, `owner skill`, `suggested action`, `confidence`, and `risks` using the ShipGlows source-intake and portfolio contracts.
  - User story link: Replaces manual first-pass routing.
  - Depends on: Task 3
  - Validate with: fixture-based classification comparisons and explicit unknown/ambiguous cases.
  - Notes: Separate observed facts from inference in persisted records.

- [x] Task 5: Add Neovim queue review commands
  - File: `lua/shipglows/mail/init.lua`
  - Action: Add commands and mappings for queue listing, queue item open, accept/edit/reject, and governed prompt copy.
  - User story link: Lets the operator validate proposals without leaving Neovim.
  - Depends on: Tasks 2-4
  - Validate with: headless command registration and manual queue-fixture review checks.
  - Notes: The v2 review commands remain active alongside the restored v1 reader. Shared configuration lives in `lua/shipglows/mail/config.lua`; `<leader>mm` and `<leader>ms` remain owned by v2.

- [x] Task 6: Add downstream prompt/handoff generation
  - File: `lua/shipglows/mail/init.lua` and CLI helpers as needed
  - Action: Replace the current monolithic `$sf-content` prompt path with queue-aware governed handoffs aligned to `#source` and the selected owner skill.
  - User story link: Makes accepted proposals immediately usable by downstream skills.
  - Depends on: Task 5
  - Validate with: prompt generation checks for `emailing`, repurpose, research, and docs-oriented cases.
  - Notes: Do not hardcode every case into one giant prompt string.

- [x] Task 7: Add scheduling path
  - Files: local docs, optional user-systemd unit samples, optional helper script
  - Action: Provide and document a user-level timer/service that runs `mbsync`, `notmuch new`, and the bounded intake scan twice daily after the manual command is proven reliable.
  - User story link: Removes the need to remember the intake pass every day.
  - Depends on: Tasks 3-6
  - Validate with: `systemd-analyze verify`, active timer inspection, one manual service run, and successful sync/index/scan exit statuses.
  - Notes: Active units are `~/.config/systemd/user/shipglows-mail-intake.{service,timer}`; the timer runs at 07:00 and 14:00 Europe/Paris and does not invoke Avante or send mail.

- [x] Task 8: Update docs
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
- Neovim can open a full-screen review layout with the pending list above and the first linked source email already open below.
- Neovim can request a factual 1-to-5 sentence summary before the operator decides how to route a long source.
- The operator can accept, edit, reject, or ignore a queue item from Neovim.
- After a queue decision, the next pending source becomes active automatically, with the previous item as fallback at the end of the list.
- Accepted records can generate a downstream prompt or handoff that includes project, angle, owner skill, risks, and suggested next action.
- Ambiguous records remain reviewable without false precision.
- Docs clearly explain that raw email content is private and must not be committed.

## Test Strategy

- Static/load checks:
  - `nvim --headless "+lua require('shipglows.mail.config')" +qa`
  - `nvim --headless "+lua require('shipglows.mail')" +qa`
  - `nvim --headless "+lua require('shipglows').setup()" +qa`
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

## Resolved Decisions

- Classifier mode: bounded model-assisted classification initiated by the operator from the open source buffer. Queue creation stores metadata only and leaves project, angle, owner skill, and action as review fields until the operator or AI fills them.
- Primary Neovim review surface: a persistent buffer-driven review panel with a pending list, adjacent read-only source buffer, explicit decision mappings, and an Avante analysis action. `vim.ui.select` may be used only for secondary choices.
- Provider boundary: Mail Intelligence owns a provider-neutral analysis contract. The first adapter routes through Avante, with the selected model provider configurable (including Gemini), while project routing context is loaded from the approved private project cache under `~/.shipglows/private/data/projects/`.
- Project context: the classifier receives the reviewed private project fiches as routing context, but must keep raw email bodies and cached pitch contents out of public repositories and must leave ambiguous matches as `unknown`.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-01 08:01:48 UTC | sf-spec | GPT-5 Codex | Created a v2 spec for daily mail intake classification and Neovim review queue on top of Mail Intel v1 | Draft spec written with private storage, review-state, idempotency, and downstream routing constraints | /101-sf-ready daily mail intake review v2 |
| 2026-07-01 22:13:06 UTC | 101-sf-ready | GPT-5 Codex | Reviewed readiness for daily mail intake review v2 | not ready: queue storage contract, classifier mode, and Neovim review surface remain materially undecided | /100-sf-spec daily mail intake review v2 |
| 2026-07-08 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Resolved the queue storage blocker by fixing one-file-per-item queue storage under the private root | Storage shape, lifecycle, retention, and canonical-output boundary are now explicit; classifier mode and review-surface blockers remain | /100-sf-spec daily mail intake review v2 |
| 2026-07-09 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Updated the queue storage contract so short-retention review state is also versioned in the private data repository | Queue recovery/versioning now lives under `~/.shipglows/private/data/mail-intake/` while retention stays intentionally short | /101-sf-ready daily mail intake review v2 |
| 2026-07-08 00:00:00 UTC | 703-sg-review | GPT-5 Codex | Migrated spec references from shipglows to shipglows namespace | Spec paths and headless test commands now match the current repo naming; implementation gaps remain | /100-sf-spec daily mail intake review v2 |
| 2026-07-08 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Linked the daily intake spec to a new sibling Gmail filter-management spec | Upstream Gmail routing is now modeled as part of the broader email-management system without weakening the local review queue boundary | /101-sf-ready gmail filter management for mail intel |
| 2026-07-11 00:00:00 UTC | 100-sf-spec | GPT-5 Codex | Resolved classifier and review-surface decisions from operator request | Ready: buffer-driven review panel with explicit Avante-assisted classification and no silent downstream action | /102-sf-start daily mail intake review v2 |
| 2026-07-12 00:00:00 UTC | 001-sg-build | inherited current model | Restored the Mail Intelligence v1 Neovim reader from commit `8860949`, integrated it with v2, and validated both command surfaces headlessly | implemented and locally verified for the reader/review integration, including the v2 LuaJIT unpack compatibility fix; overall v2 remains partial because Task 4 classification adapter and Task 7 scheduling are pending | Implement Task 4 classification adapter |
| 2026-07-12 15:34:33 UTC | 103-sg-verify | inherited current model (applied) | Independently verified Mail Intelligence v1 reader restoration and v2 review coexistence with evidence-first local probes only | not verified: v1 commands, mappings, CLI construction, help surfaces, security boundary, and wrapper removal pass, but the v2 Avante action passes `ask` while the installed API requires `question`, and the checked Task 6 handoff does not include the queue project, angle, owner skill, risks, or suggested action; Tasks 4 and 7 also remain pending | /106-sg-fix repair the v2 Avante option and queue-aware handoff, then rerun /103-sg-verify |
| 2026-07-12 15:49:49 UTC | 106-sg-fix | inherited current model (delegated sequential) | Applied the bounded v2 Avante and queue-aware handoff repair under BUG-2026-07-12-001 | fix-attempted; local headless/static retest pending, with real Avante provider and notmuch/Maildir interaction explicitly out of scope | /103-sg-verify daily mail intake review v2 |
| 2026-07-12 15:53:15 UTC | 103-sg-verify | GPT-5 Codex | Re-ran the bounded post-fix verification with a sanitized queue fixture | partial: all 10 commands, both review mappings, metadata-only handoff fields, body redaction, Avante `question` contract, unavailable-Avante fallback, CLI help, diff hygiene, duplicate-wrapper removal, and docs/security boundary checks pass; real Avante provider/notmuch/Maildir proof remains out of scope and Tasks 4 and 7 remain pending | /104-sg-end only for the bounded fix record, while the v2 chantier remains partial and Task 4 classification adapter remains next |
| 2026-07-12 21:10:43 UTC | 107-sg-test | GPT-5 Codex | Ran the first guided manual scenario against the migrated private Maildir source | pass: the Neovim review panel displayed 5 pending proposals and opened the first real email body; AI analysis and governed handoff remain to be tested | Continue /107-sg-test with `a` and `h` |
| 2026-07-12 21:43:58 UTC | 107-sg-test | GPT-5 Codex | Retested the source-buffer lifecycle after BUG-2026-07-12-002 | pass: opening a source, returning to the list, and invoking `a` opened Avante with its pre-prompt without E95; governed handoff remains to be tested | Continue /107-sg-test with `h` |
| 2026-07-12 22:42:46 UTC | 107-sg-test | GPT-5 Codex | Retested the governed handoff clipboard after BUG-2026-07-12-003 | pass: `h` copied the expected `#source` metadata and did not include the email body | Continue broader v2 verification |
| 2026-07-12 22:44:54 UTC | 300-sg-docs | GPT-5 Codex | Aligned Mail Intelligence docs with the private raw-mail source, dedicated notmuch config, OSC 52 clipboard fallback, and Which-Key registration | docs aligned; runtime behavior and QA evidence remain tracked separately | Continue broader v2 verification |
| 2026-07-12 22:50:53 UTC | 102-sg-start | GPT-5 Codex | Activated the twice-daily user systemd sync/index/intake schedule after the manual flow passed | Task 7 implemented; `mbsync`, `notmuch new`, and `mail-intake scan` completed successfully in one manual service run | Continue Task 4 classification adapter and broader v2 verification |
| 2026-07-12 | 102-sg-start | GPT-5 Codex | Added a focused Avante summary action for long review sources | `r` requests a factual summary of 1 to 5 sentences without replacing the separate classification action | Manually test `r` on a long email |
| 2026-07-12 | 102-sg-start | GPT-5 Codex | Reworked the review layout and primary mapping after operator UX feedback | `<leader>mm` now opens a full-screen two-pane view with the list above and the first source already open below; source panes are reused | Manually retest the new layout and `r` action |
| 2026-07-12 | 102-sg-start | GPT-5 Codex | Added next-item progression after review decisions | `y`, `E`, `x`, `i`, and `d` reopen the queue on the next pending email, falling back to the previous item at the end | Manually retest a decision transition |
| 2026-07-13 | 001-sg-build | GPT-5 Codex | Added the first provider-neutral Mail Intelligence analysis boundary and injected the approved private project cache into Avante prompts | `lua/shipglows/mail/ai.lua` loads `~/.shipglows/private/data/projects/`, supports the configured Avante/Gemini provider route, and preserves the human review boundary; structured provider response persistence remains pending | Implement structured classification result parsing and queue persistence |
| 2026-07-13 | 706-continue | GPT-5 Codex | Added the structured classification contract, tolerant JSON parsing, private queue persistence, and direct Avante stream capture for action `a` | Classification now writes summary, project, angle, owner skill, suggested action, confidence, risks, and pending status without persisting raw email bodies; real provider credentials and live Neovim run remain to be proven | Run one live `a` classification against a migrated email, then verify and close the bounded unit |
| 2026-07-13 | 107-sg-test | GPT-5 Codex | Tested action `a` with the configured Avante ACP `codex` provider and replaced body embedding with a private Maildir path fallback | The source reached Avante; the ACP session still ended with `-32603 Internal error`, so live classification persistence is not proven | Retest `a` after the path-based fallback |
| 2026-07-13 11:07:11 UTC | 106-sg-fix | GPT-5 Codex | Diagnosed BUG-2026-07-13-001 and pinned the Avante Codex ACP subprocess to `gpt-5.4-mini` with `medium` reasoning | fix-attempted: ACP default and environment-override arguments pass headlessly and the CLI accepts them; a live `a` retest after Neovim restart remains required | /107-sg-test --retest BUG-2026-07-13-001 |
| 2026-07-13 20:46:24 UTC | 106-sg-fix | GPT-5 Codex | Prevented Mail Intelligence from restoring ACP sessions created under an obsolete model by forcing a new Avante chat per analysis | regression and sanitized live ACP proof pass with `gpt-5.4-mini`; one real Mail Intelligence UI retest remains before closure | /107-sg-test --retest BUG-2026-07-13-001 in Mail Intelligence |

## Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sf-spec | done | New v2 chantier drafted on top of the existing Mail Intel v1 pipeline. |
| sf-ready | done | Operator selected interactive Avante-assisted classification and a persistent buffer-driven review panel. |
| sf-start | partial | Private queue review, restored v1 reader, twice-daily timer, provider-neutral project context, structured Task 4 classification persistence, fixed Avante ACP model override, and fresh-session guard are integrated; real Mail Intelligence UI proof and final verification remain. |
| sf-verify | partial | The original v1/v2 defects, scheduled sync/index/intake path, and sanitized live ACP model selection have proof. One real Mail Intelligence analysis and broader v2 verification remain. |
| sf-end | pending | Closure depends on implementation and verification. |
| sf-ship | pending | Optional, only if the user wants commit/push workflow. |
