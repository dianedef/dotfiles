---
name: shipflow-tasks
description: Update TASKS.md with completed items, add remaining tasks, and suggest next steps
disable-model-invocation: false
argument-hint: [optional focus area or task type]
---

## Context

- Current directory: !`pwd`
- **Master TASKS.md** (multi-project dashboard): !`cat /home/claude/TASKS.md 2>/dev/null || echo "No master TASKS.md"`
- Local TASKS.md (if exists): !`cat TASKS.md 2>/dev/null || echo "No local TASKS.md"`
- Recent git status: !`git status --short 2>/dev/null || echo "Not a git repository"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "N/A"`
- Project CLAUDE.md (if exists): !`head -30 CLAUDE.md 2>/dev/null || echo "No CLAUDE.md found"`
- Workspace CLAUDE.md: !`head -20 /home/claude/CLAUDE.md 2>/dev/null || echo "N/A"`

## Multi-project tracking system

**CRITICAL**: This workspace tracks 12 projects from a single master file at `/home/claude/TASKS.md`.

- **Always update `/home/claude/TASKS.md`** (the master tracker) — this is the single source of truth
- If working inside a sub-project (e.g., `/home/claude/winflowz/`), update BOTH the local TASKS.md AND the master TASKS.md
- The master file has a Dashboard table, per-project task sections, cross-project concerns, and a backlog
- When checking off tasks in the master file, also update the Dashboard status column if the project phase changed

## Your task

Intelligently manage the TASKS.md file by:
1. Checking off completed tasks
2. Adding remaining tasks to be done
3. Suggesting the next priority action
4. **Keeping the master `/home/claude/TASKS.md` in sync**

### Workspace root detection

If the current directory has no project markers (not inside a specific project) — you are at the **workspace root**. Use **AskUserQuestion**:
- Question: "Which project(s) should I update tasks for?"
- `multiSelect: true`
- Options:
  - **All projects** — "Review and update tasks across the full workspace" (Recommended)
  - One option per project: label = project name, description = number of open tasks in master TASKS.md

### Steps

1. **Analyze current state**:
   - Read TASKS.md if it exists (shown in context above)
   - Check the git status and file changes to identify what's been done
   - Look for project-specific patterns in CLAUDE.md to understand the project structure

2. **Identify completed tasks**:
   - Review unchecked tasks in TASKS.md
   - Cross-reference with actual project state (files, git commits, running processes)
   - Mark tasks as complete by changing `- [ ]` to `- [x]` for done items
   - Add completion timestamps where helpful

3. **Identify remaining tasks**:
   - Based on the project context and any arguments provided by the user (`$ARGUMENTS`)
   - Consider common next steps: tests, documentation, deployment, refactoring
   - Think about the project lifecycle: setup → development → testing → deployment → maintenance
   - Look for TODOs in code, pending PRs, failing tests, or incomplete features

4. **Update TASKS.md**:
   - If TASKS.md doesn't exist, create it with a clear structure:
     ```markdown
     # Tasks

     ## Completed
     - [x] Task name (completed YYYY-MM-DD)

     ## In Progress
     - [ ] Current task

     ## Todo
     - [ ] Next task
     - [ ] Future task

     ## Notes
     - Any important context
     ```
   - If TASKS.md exists, update it:
     - Check off completed items
     - Add new tasks under appropriate sections
     - Move tasks between sections as needed (Todo → In Progress → Completed)
     - Preserve existing notes and context

5. **Suggest next steps**:
   - Analyze the remaining tasks
   - Recommend the highest priority item based on:
     - Blockers (tasks that unblock other work)
     - Dependencies (what needs to happen first)
     - Quick wins (high impact, low effort)
     - User's argument/focus area if provided
   - Explain why this task should be next (1-2 sentences)

### Important

- **Always update the master `/home/claude/TASKS.md`** — even when working in a sub-project directory
- If a local project TASKS.md also exists (e.g., `winflowz/TASKS.md`), update both: local for detail, master for dashboard
- Use the Edit tool to update existing TASKS.md or Write tool to create a new one
- Be intelligent about what's "done" - check actual evidence, don't just guess
- Keep task descriptions clear and actionable
- Use sections to organize tasks logically
- The suggestion should be specific and immediately actionable
- If the user provided arguments, use them to focus on specific task types or areas
- Preserve any manual notes or custom sections the user has added
- Add context/notes when a task is more complex than it appears
- Update the master Dashboard table's "Status" and "Top Priority" columns when significant changes occur
