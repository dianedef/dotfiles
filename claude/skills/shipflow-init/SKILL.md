---
name: shipflow-init
description: Bootstrap a new project for ShipFlow tracking — detect stack, generate CLAUDE.md, create TASKS.md, register in PROJECTS.md
disable-model-invocation: true
argument-hint: [project-path] (omit to init current directory)
---

## Context

- Current directory: !`pwd`
- Package.json: !`cat package.json 2>/dev/null | head -60 || echo "no package.json"`
- Requirements.txt: !`cat requirements.txt 2>/dev/null | head -20 || echo "no requirements.txt"`
- Shell scripts: !`ls -1 *.sh 2>/dev/null | head -10 || echo "no .sh files"`
- Existing CLAUDE.md: !`head -30 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Existing TASKS.md: !`head -20 TASKS.md 2>/dev/null || echo "no TASKS.md"`
- Directory listing: !`ls -la 2>/dev/null | head -30`
- Git remote: !`git remote -v 2>/dev/null | head -2 || echo "no git"`
- Project structure: !`find . -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -30`

## Mode detection

- **`$ARGUMENTS` is a path** → Init the project at that path.
- **`$ARGUMENTS` is empty** → Init the current directory.

---

## Flow

### Step 1: Detect project type

Analyze the project to determine:
- **Stack**: framework (Astro, Next.js, React, React Native, Vue, Python, Bash), runtime (Node, Python, Bun)
- **Package manager**: npm, yarn, pnpm, pip, none (detect from lockfiles)
- **UI framework**: React, Vue, Svelte, none
- **CSS solution**: Tailwind, UnoCSS, CSS Modules, styled-components, none
- **Content type**: blog, docs, app, CLI, API, library
- **i18n**: locale dirs, i18n config, bilingual content
- **Auth**: Clerk, Auth.js, Supabase Auth, none
- **Backend**: Convex, Supabase, Firebase, custom API, none
- **Payments**: Stripe, LemonSqueezy, none

### Step 2: Generate CLAUDE.md template

Create a `CLAUDE.md` with:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code when working in this project.

## Project Overview
[Auto-detected: name, description, stack]

## Commands
[Auto-detected from package.json scripts, Makefile, or shell scripts]

## Architecture
[Auto-detected: directory structure, key patterns]

## Key Conventions
[Framework-specific conventions based on detected stack]
```

Use **AskUserQuestion** to let the user review and confirm:
- Question: "I've detected [stack summary]. Here's the generated CLAUDE.md — should I create it?"
- Options:
  - **Create as-is** — "Save the generated CLAUDE.md" (Recommended)
  - **Edit first** — "Let me review and adjust before saving"
  - **Skip** — "Don't create CLAUDE.md"

### Step 3: Create TASKS.md

Create a project-local `TASKS.md` with initial structure:

```markdown
# Tasks — [project name]

## Active
<!-- Current sprint work -->

## Backlog
<!-- Prioritized future work -->

## Audit Findings
<!-- Populated by /shipflow-audit -->
```

Skip if `TASKS.md` already exists.

### Step 4: Register in PROJECTS.md

Read `/home/claude/ShipFlow/PROJECTS.md` and add a row to both tables:

**Project Registry table**:
```
| [name] | [path] | [stack summary] |
```

**Domain Applicability table** — auto-detect defaults:
- Code: ✓ (always)
- Design: ✓ if has UI
- Copy: ✓ if has user-facing content
- SEO: ✓ if web project with public pages
- GTM: ✓ if commercial intent
- Translate: ✓ if i18n detected
- Deps: ✓ if has package manager
- Perf: ✓ (always)

### Step 5: Add to master TASKS.md

Add a section to `/home/claude/TASKS.md`:

```markdown
## [project name]

**Stack**: [summary] | **Phase**: Setup
```

### Step 6: Confirm domain applicability

Use **AskUserQuestion**:
- Question: "Which audit domains apply to [project name]?"
- `multiSelect: true`
- Options: Code, Design, Copy, SEO, GTM, Translate, Deps, Perf
- Pre-select based on auto-detection from Step 4
- Description for each: what was detected (or "not detected — opt in manually")

Update PROJECTS.md with the user's confirmed selection.

### Step 7: Report

```
PROJECT INITIALIZED: [name]
═══════════════════════════════════
Stack:     [detected stack]
Path:      [project path]
CLAUDE.md: [created / skipped / already existed]
TASKS.md:  [created / skipped / already existed]
PROJECTS:  [registered / already registered]
Domains:   [list of applicable domains]
═══════════════════════════════════
Next steps:
  /shipflow-audit        — Run initial audit
  /shipflow-check        — Verify build passes
  /shipflow-tasks        — Start tracking work
```

---

## Important

- Never overwrite an existing CLAUDE.md without asking.
- Never overwrite an existing TASKS.md.
- If the project is already in PROJECTS.md, update the row instead of adding a duplicate.
- Detect the stack from actual files, not just project name.
- The generated CLAUDE.md should match the style of existing project CLAUDE.md files in the workspace.
