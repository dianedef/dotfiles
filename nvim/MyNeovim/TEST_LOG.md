## 2026-07-12 - Mail Intelligence queue and source opening

- Scope: daily-mail-intake-review-v2
- Environment: local
- Tester: user
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: The review panel displayed 5 pending proposals and opened the first migrated email body correctly.
- Bug pointer: none
- Evidence pointer: none
- Follow-up: test the `a` AI analysis and `h` governed handoff actions

## 2026-07-12 - Mail Intelligence AI analysis after source opening

- Scope: BUG-2026-07-12-002
- Environment: local
- Tester: user
- Source: 107-sg-test
- Status: fail
- Confidence: high
- Result summary: After opening the first source, invoking `a` raised Neovim E95 because the source buffer name already existed.
- Bug pointer: BUG-2026-07-12-002 -> bugs/BUG-2026-07-12-002.md
- Evidence pointer: none
- Follow-up: retest the same `<CR>` then `a` flow

## 2026-07-12 - Mail Intelligence Avante analysis launch

- Scope: BUG-2026-07-12-002
- Environment: local
- Tester: user
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: After the source was already open, `a` opened Avante with the expected analysis pre-prompt and no E95 exception.
- Bug pointer: BUG-2026-07-12-002 -> bugs/BUG-2026-07-12-002.md
- Evidence pointer: none
- Follow-up: test the governed `h` handoff

## 2026-07-12 - Mail Intelligence governed handoff clipboard

- Scope: BUG-2026-07-12-003
- Environment: local
- Tester: user
- Source: 107-sg-test
- Status: fail
- Confidence: high
- Result summary: `h` reported an end-of-copy notification, but the system clipboard remained empty.
- Bug pointer: BUG-2026-07-12-003 -> bugs/BUG-2026-07-12-003.md
- Evidence pointer: none
- Follow-up: restart Neovim and retest `h`

## 2026-07-12 - Mail Intelligence governed handoff clipboard retest

- Scope: BUG-2026-07-12-003
- Environment: local
- Tester: user
- Source: 107-sg-test
- Status: pass
- Confidence: high
- Result summary: `h` copied the governed `#source` handoff with routing metadata and no email body.
- Bug pointer: BUG-2026-07-12-003 -> bugs/BUG-2026-07-12-003.md
- Evidence pointer: none
- Follow-up: continue broader v2 verification; no further manual clipboard step
