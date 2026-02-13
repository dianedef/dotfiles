---
name: check
description: Run typecheck, lint, and build for the current project, then fix any errors found
disable-model-invocation: true
argument-hint: [fix|nofix]
---

## Context

- Current directory: !`pwd`
- Package manager lockfiles: !`ls -1 package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock 2>/dev/null || echo "none found"`
- Package.json scripts (if any): !`cat package.json 2>/dev/null | grep -E '^\s+"(dev|build|lint|typecheck|check|test|format)"' || echo "no package.json"`
- Project CLAUDE.md (if any): !`head -80 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`

## Your task

Run all available checks for the current project and fix errors if found.

### Step 1: Detect project type and run checks

Based on the context above, identify the project stack and run the appropriate commands **sequentially** (each depends on the previous passing):

**TypeScript/JavaScript projects** (has package.json):
- Typecheck: `npm run typecheck` or `yarn typecheck` or `pnpm typecheck` (match the lockfile)
- Lint: `npm run lint` or equivalent (if script exists)
- Build: `npm run build` or `pnpm build` or `yarn build`

**Astro projects** (has astro in dependencies):
- `pnpm check` or `npm run check` (Astro type checking)
- `pnpm build` or `npm run build`

**Python projects** (has requirements.txt or Pipfile):
- `python -m py_compile` on changed files, or `pytest --co -q` (collect-only) to validate
- `pytest -x` (stop on first failure)

**Bash projects** (shell scripts, no package.json):
- `bash -n` syntax check on `.sh` files
- Run test scripts if they exist (`./test_*.sh`)

### Step 2: Fix errors

If `$ARGUMENTS` is "nofix", stop here and just report the errors.

Otherwise (default behavior, including when `$ARGUMENTS` is "fix" or empty):

1. Read each error message carefully.
2. Open the failing file(s) and fix the root cause.
3. Re-run the failed check to confirm the fix works.
4. Repeat until all checks pass or you've attempted 3 fix cycles.

### Step 3: Report

Summarize what was checked, what failed, and what was fixed. If anything still fails after 3 attempts, explain the remaining errors clearly so the user can decide what to do.

### Important

- Use the correct package manager for the project (check lockfiles).
- Do not install dependencies — if something is missing, tell the user.
- Do not modify test expectations to make tests pass. Fix the actual code.
- If the project CLAUDE.md specifies custom check commands, use those instead.
