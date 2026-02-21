---
name: audit
description: Master audit — launches all 6 domain audits (code, design, copy, seo, gtm, translate) in parallel agents. Works on a single file or the full project.
disable-model-invocation: true
argument-hint: [file-path] (omit for full project)
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -50 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Project structure: !`find src -maxdepth 2 -type d 2>/dev/null | grep -v node_modules | head -20 || echo "no src dir"`
- i18n present: !`find src -path "*/i18n/*" -o -path "*/locales/*" 2>/dev/null | head -3 || echo "no i18n"`
- Package.json scripts: !`cat package.json 2>/dev/null | grep -E '^\s+"(dev|build|lint|typecheck|check)"' || echo "no package.json"`

## Mode detection

- **`$ARGUMENTS` is a file path** → FILE MODE: audit that single file across all domains.
- **`$ARGUMENTS` is empty** → PROJECT MODE: full audit of the entire project.

## Your task

You are the **audit orchestrator**. You do NOT perform the audits yourself. You launch **parallel agents** and then consolidate results.

### Step 1: Determine scope and applicable domains

**Always run these 4:**
- Code (architecture, performance, security, reliability)
- Design (UI/UX, accessibility, responsiveness)
- Copy (clarity, tone, CTAs, grammar)
- SEO (meta tags, headings, structured data, performance)

**Run if applicable:**
- GTM — only if the project has: pricing page, signup flow, analytics, or commercial intent. Skip for pure blogs, documentation sites, or CLI tools.
- Translate — only if the project has multiple locales (i18n files, locale directories, or bilingual content). Skip for single-language projects.

State which domains you're launching and why you're skipping any.

### Step 2: Launch parallel agents

Use the **Task tool** to launch one agent per domain, ALL IN A SINGLE MESSAGE (parallel execution). Each agent should be `subagent_type: "general-purpose"`.

For each agent, provide this prompt structure:

```
You are performing a [DOMAIN] audit of [scope: file path OR full project] in the project at [current directory].

[Paste the FULL audit checklist for that domain from the corresponding skill — PAGE MODE section if file argument given, PROJECT MODE section if no argument]

Project CLAUDE.md context:
[Include the CLAUDE.md content from this skill's context]

IMPORTANT:
- Do NOT fix anything. This is a READ-ONLY analysis pass.
- Score every category A/B/C/D.
- For each issue found, note: file path, line number, what's wrong, severity (critical/high/medium/low), and your proposed fix.
- End with the full report table as specified in the checklist.
```

**Critical rules for agent prompts:**
- Copy the FULL checklist from the corresponding audit skill — don't summarize or skip sections.
- Agents must NOT edit files — analysis only. Fixes happen in Step 4.
- Include the project CLAUDE.md so agents understand project conventions.

### Step 3: Consolidate reports

Once all agents return, compile a **master report**:

```
══════════════════════════════════════════════════════
MASTER AUDIT: [project name or file name]
══════════════════════════════════════════════════════

DOMAIN SCORES
  Code           [A/B/C/D]  —  one-line summary
  Design         [A/B/C/D]  —  one-line summary
  Copy           [A/B/C/D]  —  one-line summary
  SEO            [A/B/C/D]  —  one-line summary
  GTM            [A/B/C/D]  —  one-line summary  (or "skipped — [reason]")
  Translate      [A/B/C/D]  —  one-line summary  (or "skipped — [reason]")

OVERALL          [A/B/C/D]

──────────────────────────────────────────────────────
CRITICAL ISSUES (fix immediately)
  1. [domain] file:line — description
  2. ...

HIGH ISSUES (fix soon)
  1. [domain] file:line — description
  2. ...

MEDIUM ISSUES (improve when possible)
  1. [domain] file:line — description
  2. ...
──────────────────────────────────────────────────────
Total issues: X critical, Y high, Z medium
══════════════════════════════════════════════════════
```

Then print each domain's full detailed report below the master summary.

### Step 4: Log the audit

Update **two** audit logs. Never delete previous rows — this is the history.

**1. Global `/home/claude/AUDIT_LOG.md`** — cross-project dashboard:

```markdown
# Audit Log

> Quick view of all audit runs across all projects. See project-local `AUDIT_LOG.md` for details.

| Date       | Project          | Scope        | Code | Design | Copy | SEO | GTM | Translate | Overall | Issues     |
|------------|------------------|--------------|------|--------|------|-----|-----|-----------|---------|------------|
| 2026-02-21 | plaisirsurprise  | full project | B    | C      | B    | D   | B   | C         | C       | 3/8/12     |
| 2026-02-21 | GoCharbon        | full project | A    | B      | B    | C   | —   | B         | B       | 0/3/7      |
| 2026-03-05 | plaisirsurprise  | index.astro  | A    | B      | B    | B   | B   | B         | B       | 0/2/4      |
```

**2. Project-local `./AUDIT_LOG.md`** — same format but only for this project (no Project column):

```markdown
# Audit Log — [project name]

| Date       | Scope        | Code | Design | Copy | SEO | GTM | Translate | Overall | Issues     |
|------------|--------------|------|--------|------|-----|-----|-----------|---------|------------|
| 2026-02-21 | full project | B    | C      | B    | D   | B   | C         | C       | 3/8/12     |
```

- Issues column format: `critical/high/medium`.
- Use `—` for skipped domains.
- Append a new row per run. This is an append-only log.

### Step 5: Update TASKS.md

Add audit findings as tasks. Two files to update:

**1. Project-local TASKS.md** (e.g., `./TASKS.md` in the current project):
- Create it if it doesn't exist.
- Add an `## Audit Findings` section (or update it if it already exists — replace old findings with fresh ones).
- List all issues (critical, high, and medium) as tasks:

```markdown
## Audit Findings
> Last audit: 2026-02-21 — Overall: [C]

| Pri | Task | Domain | Status |
|-----|------|--------|--------|
| 🔴 | Fix XSS in user comment rendering (src/components/Comments.tsx:42) | Code | 📋 todo |
| 🔴 | Add missing meta descriptions on 8 pages | SEO | 📋 todo |
| 🟠 | Standardize button styles across 12 components | Design | 📋 todo |
| 🟠 | Rewrite homepage headline — benefit-driven | Copy | 📋 todo |
| 🟡 | Add alt text to 5 decorative images | SEO | 📋 todo |
| 🟡 | French typographic spaces before colons | Translate | 📋 todo |
```

- Use 🔴 for critical, 🟠 for high, 🟡 for medium.
- If a previous `## Audit Findings` section exists, replace it entirely with fresh findings (don't accumulate stale issues).

**2. Master `/home/claude/TASKS.md`**:
- Find the section for the current project.
- Add or update an `### Audit` subsection with a summary line and all issues as tasks.
- Update the Dashboard table's "Top Priority" column if audit found critical issues (they take precedence).

### Step 6: Apply fixes

After presenting the consolidated report and updating tracking files, ask the user:

> **Found X critical, Y high, Z medium issues. How do you want to proceed?**
> 1. Fix all (critical + high + medium)
> 2. Fix critical and high only
> 3. Fix critical only
> 4. Don't fix anything — just keep the report

Then apply fixes sequentially (NOT in parallel — fixes may touch the same files). Priority order:
1. Critical security issues
2. Critical bugs
3. High severity across all domains
4. Medium severity across all domains

When fixing, group changes by file to avoid conflicts. If two domains flag the same file, apply all fixes to that file at once.

### Important

- The value of this skill is PARALLELISM. Always launch agents in a single message so they run concurrently. Never run them one by one.
- Keep agent prompts self-contained — each agent should work independently without needing context from other agents.
- If a domain agent fails or times out, report it and continue with the others.
- Don't re-audit what agents already audited. Trust their analysis, consolidate, and fix.
- For FILE MODE: some domain checklists may partially apply (e.g., GTM checks don't make sense for a utility function). Agents should skip irrelevant checks and note "N/A" in their report.
