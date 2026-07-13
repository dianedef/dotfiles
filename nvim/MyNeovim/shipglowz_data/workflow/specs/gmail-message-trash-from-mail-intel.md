---
artifact: workflow_spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "MyNeovim Mail Intelligence"
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 102-sg-start
scope: "explicit Gmail Trash action from the Neovim Mail Intelligence review queue"
owner: "Diane"
confidence: "high"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems: ["Mail Intel", "mbsync", "Gmail IMAP", "mail-intake"]
depends_on: ["daily-mail-intake-review-v2"]
supersedes: []
evidence: ["Operator explicitly requested direct Trash behavior without confirmation and manual retest of the review queue"]
next_step: "/103-sg-verify gmail message trash from mail intel"
---

# Gmail Message Trash From Mail Intel

## User Story

As the operator reviewing a Mail Intelligence proposal, I want `d` to move the linked Gmail message directly to Gmail Trash without a confirmation prompt, so irrelevant or already-processed messages leave the working inbox quickly while remaining recoverable from Gmail Trash.

## Contract

- `x` rejects only the local review proposal and keeps the source message.
- `d` resolves the queue `source_id` to the selected IMAP folder, copies the message to the Gmail Trash mailbox, removes it from the current folder, and marks the queue record `deleted`.
- The action is explicit and has no interactive confirmation by operator decision.
- The command must never send, permanently purge, or mutate an unrelated message.
- If lookup, authentication, mailbox selection, or Trash copy fails, the queue record remains pending and the error is shown.
- OAuth tokens and IMAP passwords remain outside the repository.

## Implementation

- `scripts/mail-delete` performs the IMAP lookup and Trash move.
- `lua/shipglowz/mail/review.lua` exposes `d` in the queue list.
- `scripts/mail-intake update` accepts `deleted` and moves the record to `done/`.
- The account and password are resolved from the existing `~/.mbsyncrc` and local password file, with environment overrides.

## Validation

- CLI help and Python compilation pass.
- `--dry-run` must locate the target message without mutating Gmail.
- Manual `d` proof must show the message in Gmail Trash and the queue item moved to `mail-intake/done/` with `status: deleted`.
- A failed lookup must leave the queue item in `inbox/`.
- Restoration remains an operator action in Gmail; the local queue does not auto-restore labels.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-12 | 102-sg-start | GPT-5 Codex | Added the direct Trash command and queue action after explicit operator request | implementation added; real deletion proof pending | `/103-sg-verify gmail message trash from mail intel` |

## Current Chantier Flow

| Step | Status | Notes |
|------|--------|-------|
| sf-spec | draft | Contract records direct Gmail Trash behavior without confirmation. |
| sf-start | partial | CLI and Neovim action implemented; live Trash proof pending. |
| sf-verify | pending | Requires dry-run and one operator-approved real deletion/recovery check. |
| sf-end | pending | Depends on verification. |
