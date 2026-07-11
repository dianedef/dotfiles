---
artifact: repurpose_pack
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-11"
updated: "2026-07-11"
status: active
source_skill: "202-sg-repurpose"
scope: "mail-admin-recovery-playbook"
owner: Diane
confidence: high
risk_level: low
security_impact: low
docs_impact: yes
source_type: conversation
source_ref: "current thread: mail-admin smoke test, sudo/venv blocker, VM migration"
linked_systems:
  - "/home/claude/dotfiles/nvim/MyNeovim/scripts/mail-admin"
  - "/home/claude/dotfiles/nvim/MyNeovim/Mail Intel.md"
  - "/home/claude/dotfiles/nvim/MyNeovim/Cheat Sheet.md"
  - "/home/claude/dotfiles/nvim/MyNeovim/shipglowz_data/workflow/specs/gmail-filter-management-for-mail-intel.md"
  - "/home/claude/dotfiles/nvim/MyNeovim/shipglowz_data/workflow/specs/daily-mail-intake-review-v2.md"
next_step: "Use this note as the handoff checklist when resuming on a new VM."
---

## Recovery Playbook

### What Is Already Confirmed

- `scripts/mail-admin` exists and is a real Python CLI, not a shell wrapper.
- The command surface is present: `init-registry`, `validate`, `list-rules`, `plan`, `apply`, `bootstrap-auth`, `list-labels`, `list-filters`.
- The local registry path resolves to `~/.shipglowz/private/data/mail-admin/registry.json`.
- `validate` passed on the current machine with an empty registry.
- `list-rules` returned `[]`.
- `plan` returned `[]`.
- The docs in `Mail Intel.md` and `Cheat Sheet.md` already mention `mail-admin` and the registry path.
- The specs for `gmail-filter-management-for-mail-intel` and `daily-mail-intake-review-v2` were aligned around the sibling CLI model and the `mail-admin` registry contract.

### What Is Still Missing

- Live Gmail proof is not done.
- Google Python dependencies are not installed in a usable isolated environment on the current server.
- `python3 -m pip install --user ...` is blocked by the system Python policy.
- `python3 -m venv` is blocked here because `python3-venv` is missing.
- `sudo` is not usable from this session, so the missing package cannot be installed here.
- No commit or push was made.

### Safe Restart Sequence On The New VM

1. Confirm the repo root.

```bash
cd /home/claude/dotfiles/nvim/MyNeovim
```

2. Re-run the non-destructive checks.

```bash
scripts/mail-admin validate
scripts/mail-admin list-rules
scripts/mail-admin plan
```

3. Create an isolated Python environment.

```bash
python3 -m venv .venv-mail-admin
source .venv-mail-admin/bin/activate
python -m pip install --upgrade pip
python -m pip install google-api-python-client google-auth-oauthlib google-auth-httplib2
```

4. Prepare a pilot account in the registry.

- Add one account entry in `~/.shipglowz/private/data/mail-admin/registry.json`.
- Point it at local OAuth files under `~/.config/mail-admin/oauth/<account>/`.
- Keep the registry declarative and non-secret.

5. Bootstrap OAuth with a test account only.

```bash
scripts/mail-admin bootstrap-auth <account>
```

6. Verify against live Gmail without mutating first.

```bash
scripts/mail-admin plan --live
scripts/mail-admin list-labels <account>
scripts/mail-admin list-filters <account>
```

7. Only after the dry checks pass, run the dry application path.

```bash
scripts/mail-admin apply --dry-run
```

8. Run real `apply` only if the pilot account and filter diff are correct.

```bash
scripts/mail-admin apply
```

### Safety Notes

- Do not install Python packages system-wide on the new VM if a venv is available.
- Do not reuse a production Gmail account for the first live smoke test.
- Do not assume `plan --live` is safe to apply without checking the diff.
- Keep OAuth secrets outside Git.

### Handy Proof Lines

- The CLI already validated successfully on the old machine.
- The remaining blocker was environmental, not logical.
- The exact missing system piece was `python3-venv`.
- The exact missing runtime proof was a live Gmail run with OAuth and Google client packages inside an isolated environment.

