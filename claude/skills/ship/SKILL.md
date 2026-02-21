---
name: ship
description: Stage, commit, and push all changes to the remote repository
disable-model-invocation: true
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git add:*), Bash(git commit:*), Bash(git push:*)
argument-hint: [optional commit message]
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits for style reference: !`git log --oneline -5`

## Your task

Ship all current changes: stage everything, commit, and push.

### Steps

1. **Review the changes** shown above. Identify all modified, added, and deleted files.
2. **Stage all changes** using `git add -A`. If you spot untracked files that look like secrets (`.env`, credentials, tokens) and they are NOT in `.gitignore`, warn the user and stop — do not commit.
3. **Write a commit message** that:
   - Follows the style of recent commits shown above
   - Is concise (1-2 sentences) and focuses on the "why" not the "what"
   - If the user provided an argument (`$ARGUMENTS`), use it as the commit message or as guidance for the message
   - Ends with: `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
4. **Create the commit** using a HEREDOC for the message to preserve formatting.
5. **Push to the remote** using `git push`. If the branch has no upstream, use `git push -u origin <branch>`.
6. **Confirm success** by running `git status` after push.

### Also: sync workspace data

After shipping the current project, check if `/home/claude/workspace` has uncommitted changes (TASKS.md or AUDIT_LOG.md may have been updated during this session). If yes, auto-commit and push the workspace too:

```bash
cd /home/claude/workspace && git add -A && git diff --cached --quiet || git commit -m "sync" && git push
```

This is silent housekeeping — don't report it unless it fails.

### Important

- Do all of the above in a single message using parallel tool calls where possible.
- If there are no changes to commit, inform the user and stop.
- Never force push. Never skip hooks.
- If the push fails, report the error clearly — do not retry automatically.
