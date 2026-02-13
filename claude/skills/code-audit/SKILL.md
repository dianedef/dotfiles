---
name: code-audit
description: Professional full-project code audit — architecture, performance, reliability, security, and modern best practices
disable-model-invocation: true
context: fork
argument-hint: [focus: arch|perf|security|all]
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -120 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Package.json: !`cat package.json 2>/dev/null | head -80 || echo "no package.json"`
- Dependencies: !`cat package.json 2>/dev/null | grep -E '"(dependencies|devDependencies)"' -A 100 | head -80 || pip list 2>/dev/null | head -40 || echo "unknown"`
- Lockfile: !`ls -1 package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock 2>/dev/null | head -3 || echo "none"`
- Project structure: !`find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.astro" -o -name "*.vue" -o -name "*.py" -o -name "*.sh" \) 2>/dev/null | grep -v node_modules | grep -v .git | grep -v dist | sort | head -60`
- Config files: !`ls -1 tsconfig*.json astro.config.* next.config.* vite.config.* vitest.config.* .eslintrc* eslint.config.* prettier.config.* .env.example 2>/dev/null || echo "none"`
- CI/CD: !`ls -1 .github/workflows/*.yml Dockerfile docker-compose.yml 2>/dev/null || echo "none"`

## Your task

Perform a comprehensive code audit. If `$ARGUMENTS` specifies a focus (arch, perf, security), prioritize that area but still scan all others. Default is `all`.

---

## PHASE 1: ARCHITECTURE

Read the project structure, entry points, configs, and 10-15 key files. Audit:

### 1.1 Project Structure & Organization
- [ ] Clear separation of concerns (pages/routes, components, utils, services, types)
- [ ] No circular dependencies between modules
- [ ] No god files (single files doing too many things, > 300 lines)
- [ ] Barrel exports (`index.ts`) are not re-exporting the entire tree (causes bundle bloat)
- [ ] Config is centralized, not scattered across files
- [ ] Environment variables are typed and validated at startup (not raw `process.env` everywhere)

### 1.2 Data Flow & State Management
- [ ] Data flows in one direction (no prop drilling > 3 levels deep)
- [ ] Server state and client state are separated (React Query/Convex for server, local state for UI)
- [ ] No redundant state (derived values computed, not stored)
- [ ] API/database calls are in a service layer, not inside components
- [ ] Real-time subscriptions are properly cleaned up on unmount
- [ ] No stale closures in effects/callbacks

### 1.3 Error Boundaries & Resilience
- [ ] Error boundaries exist at route level (React) or error pages (Astro/Next)
- [ ] API calls have proper error handling (not just `.catch(console.error)`)
- [ ] Network failures show user-friendly messages, not raw errors
- [ ] Retry logic exists for transient failures (with exponential backoff)
- [ ] Partial failures are handled gracefully (one failed component doesn't crash the page)

### 1.4 Type Safety
- [ ] `strict: true` in tsconfig (or equivalent strictness)
- [ ] No `any` types (grep for them — each one is a potential runtime crash)
- [ ] API responses are validated at the boundary (Zod, Valibot, or runtime checks)
- [ ] Shared types between frontend/backend (no duplicated type definitions)
- [ ] Enums or const maps instead of magic strings

### 1.5 Dependency Health
- [ ] No deprecated packages (check for known deprecated libs)
- [ ] No packages with known CVEs (check for obvious vulnerable versions)
- [ ] No duplicate functionality (two libs doing the same thing)
- [ ] No unnecessary dependencies (check if something could be native)
- [ ] Lock file is committed and up to date
- [ ] Node/Python version is pinned (`.node-version`, `.python-version`, `engines` field)

---

## PHASE 2: PERFORMANCE

### 2.1 Bundle & Loading
- [ ] Code splitting at route level (dynamic imports for pages)
- [ ] No massive dependencies imported for one function (e.g., full lodash for `_.debounce`)
- [ ] Tree-shaking works (ESM imports, no `require()` in frontend code)
- [ ] Images use modern formats (WebP/AVIF) with proper sizing
- [ ] Fonts are subset and use `font-display: swap`
- [ ] No unnecessary polyfills for modern browsers
- [ ] Third-party scripts are deferred or loaded async

### 2.2 Rendering
- [ ] Static pages are pre-rendered at build time (SSG) where possible
- [ ] Dynamic pages use SSR with proper caching headers
- [ ] Client-side hydration is minimal (Astro islands, React Server Components)
- [ ] No full-page re-renders from minor state changes
- [ ] Lists use proper keys (not index) and are virtualized if > 100 items
- [ ] Expensive computations are memoized (`useMemo`, `computed`)
- [ ] Images below the fold are lazy-loaded; LCP image is eagerly loaded

### 2.3 Data Fetching
- [ ] No waterfall requests (parallel fetching where possible)
- [ ] Data is fetched at the right level (layout vs page vs component)
- [ ] Caching strategy exists (HTTP cache headers, stale-while-revalidate, Convex reactive queries)
- [ ] Pagination or infinite scroll for large lists (not loading 1000 items)
- [ ] No N+1 query patterns (fetching related data in loops)
- [ ] GraphQL/API queries fetch only needed fields (no over-fetching)

### 2.4 Database & Backend (if applicable)
- [ ] Database queries are indexed for common access patterns
- [ ] No unbounded queries (always paginate or limit)
- [ ] Connection pooling is configured
- [ ] Expensive operations are async/background (not blocking request)
- [ ] File uploads use streaming, not buffering entire file in memory

---

## PHASE 3: SECURITY

### 3.1 Authentication & Authorization
- [ ] Auth tokens are stored securely (httpOnly cookies, not localStorage for session tokens)
- [ ] Every API route/mutation checks authentication
- [ ] Authorization is checked per resource (not just "is logged in")
- [ ] Session expiration and refresh token rotation exist
- [ ] Password reset flow is secure (time-limited tokens, no user enumeration)
- [ ] OAuth state parameter is validated (CSRF protection)

### 3.2 Input Validation & Injection
- [ ] All user input is validated server-side (client validation is UX, not security)
- [ ] SQL/NoSQL queries use parameterized queries (no string concatenation)
- [ ] HTML output is escaped (XSS prevention — React/Astro do this by default, but check `dangerouslySetInnerHTML`, `set:html`)
- [ ] File uploads validate type, size, and content (not just extension)
- [ ] URLs and redirects are validated (no open redirect vulnerabilities)
- [ ] No `eval()`, `new Function()`, or dynamic `import()` with user input

### 3.3 Secrets & Configuration
- [ ] No secrets in source code (grep for API keys, tokens, passwords)
- [ ] `.env` files are in `.gitignore`
- [ ] Secrets use environment variables or a secret manager (Doppler, etc.)
- [ ] Different secrets for dev/staging/production
- [ ] No secrets logged or exposed in error messages
- [ ] `.env.example` exists with dummy values for documentation

### 3.4 HTTP Security
- [ ] HTTPS enforced (redirect HTTP → HTTPS)
- [ ] Security headers set: `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy`
- [ ] CORS is configured restrictively (not `*` in production)
- [ ] Cookies use `Secure`, `HttpOnly`, `SameSite` attributes
- [ ] Rate limiting on auth endpoints and API routes
- [ ] No sensitive data in URL query parameters (use POST body)

### 3.5 Data Protection
- [ ] PII is handled carefully (not logged, not cached publicly)
- [ ] User data deletion is possible (RGPD/GDPR right to erasure)
- [ ] Backups exist for critical data
- [ ] File uploads are stored outside the web root
- [ ] Exported data is sanitized (no formula injection in CSV exports)

---

## PHASE 4: RELIABILITY

### 4.1 Error Handling
- [ ] Errors are caught and handled at every async boundary
- [ ] Error types are specific (not catch-all `Error`)
- [ ] Errors are logged with context (not swallowed silently)
- [ ] User-facing errors are helpful and actionable
- [ ] External service failures have fallback behavior
- [ ] Unhandled rejections are caught at the process level

### 4.2 Testing
- [ ] Test coverage exists for critical paths (auth, payments, data mutations)
- [ ] Tests are not brittle (no snapshot tests of entire pages, no hardcoded dates)
- [ ] E2E tests cover the main user journey
- [ ] Tests run in CI before merge
- [ ] Test data is isolated (no shared state between tests)
- [ ] Edge cases are tested: empty state, max length, special characters, concurrent access

### 4.3 Observability
- [ ] Structured logging exists (not just `console.log`)
- [ ] Error tracking service is configured (Sentry, LogRocket, etc.) or easy to add
- [ ] Health check endpoint exists (for uptime monitoring)
- [ ] Key metrics are trackable (response time, error rate, queue depth)

### 4.4 Deployment & Recovery
- [ ] Build is reproducible (lockfile committed, no floating versions)
- [ ] Zero-downtime deployment is possible
- [ ] Rollback is straightforward (revert commit and redeploy)
- [ ] Database migrations are backward-compatible
- [ ] Feature flags or gradual rollout mechanism exists (or easy to add)

---

## PHASE 5: MODERN BEST PRACTICES

### 5.1 Framework-Specific (detect and apply)

**Astro 5**:
- [ ] Using Content Collections v2 (type-safe, schema-validated)
- [ ] Using `<Image>` component (not raw `<img>`)
- [ ] Using View Transitions where appropriate
- [ ] Minimal client JS (islands architecture respected)
- [ ] Using `astro:env` for env validation if available

**Next.js 15+**:
- [ ] Using App Router (not Pages Router for new code)
- [ ] Server Components by default, `"use client"` only when needed
- [ ] Using `next/image` and `next/font`
- [ ] Proper `loading.tsx` and `error.tsx` at route segments
- [ ] Metadata API for SEO (not manual `<Head>`)

**React**:
- [ ] No class components (hooks only)
- [ ] No legacy context API
- [ ] Using Suspense for async data
- [ ] No `useEffect` for data fetching (use React Query, SWR, or RSC)
- [ ] Event handlers are stable (useCallback where needed for performance)

**Convex**:
- [ ] Queries are reactive (not using `fetchQuery` where `useQuery` works)
- [ ] Mutations are transactional and idempotent
- [ ] Actions are used only for external API calls (not for DB reads/writes)
- [ ] Indexes are defined for common query patterns
- [ ] File storage uses Convex storage API (not external URLs)

**Python**:
- [ ] Type hints on all function signatures
- [ ] Using Pydantic for data validation
- [ ] Async where I/O-bound (FastAPI, httpx)
- [ ] No mutable default arguments
- [ ] Virtual environment or dependency isolation

### 5.2 Code Quality
- [ ] Consistent code style (formatter configured: Prettier, Black, etc.)
- [ ] Linter configured and passing (ESLint, Ruff, etc.)
- [ ] No commented-out code blocks (use version control)
- [ ] No TODO/FIXME/HACK comments older than 3 months
- [ ] Functions are < 50 lines, doing one thing
- [ ] Naming is clear and consistent (no abbreviations, no Hungarian notation)

---

## PHASE 6: FIX

Fix all issues directly in code. Priority order:

1. **CRITICAL SECURITY** — secrets in code, SQL injection, XSS, auth bypass
2. **HIGH SECURITY** — missing validation, permissive CORS, missing headers
3. **ARCHITECTURE** — circular deps, god files, untyped boundaries
4. **RELIABILITY** — silent error swallowing, missing error boundaries
5. **PERFORMANCE** — bundle size, waterfall fetches, missing lazy loading
6. **BEST PRACTICES** — deprecated patterns, legacy APIs, code quality

For changes that require architectural decisions (e.g., choosing a caching strategy, restructuring modules), document the options in the report.

---

## PHASE 7: REPORT

```
CODE AUDIT: [project name] — [stack detected]
═══════════════════════════════════════════════════

ARCHITECTURE                           [A/B/C/D]
  Structure & Organization             [A/B/C/D]
  Data Flow & State                    [A/B/C/D]
  Error Resilience                     [A/B/C/D]
  Type Safety                          [A/B/C/D]
  Dependency Health                    [A/B/C/D]

PERFORMANCE                            [A/B/C/D]
  Bundle & Loading                     [A/B/C/D]
  Rendering                            [A/B/C/D]
  Data Fetching                        [A/B/C/D]

SECURITY                               [A/B/C/D]
  Auth & Authorization                 [A/B/C/D]
  Input Validation                     [A/B/C/D]
  Secrets Management                   [A/B/C/D]
  HTTP Security                        [A/B/C/D]

RELIABILITY                            [A/B/C/D]
  Error Handling                       [A/B/C/D]
  Testing                              [A/B/C/D]
  Observability                        [A/B/C/D]

MODERN PRACTICES                       [A/B/C/D]
  Framework Best Practices             [A/B/C/D]
  Code Quality                         [A/B/C/D]
═══════════════════════════════════════════════════
OVERALL                                [A/B/C/D]

CRITICAL fixes applied:     X
HIGH fixes applied:         X
MEDIUM fixes applied:       X
Architectural decisions needed: X (detailed below)

TOP 5 IMPROVEMENTS (by impact):
1. [description + files affected]
2. ...
```

---

## Important

- Be ruthlessly honest. A-level means "I would deploy this to production with confidence today."
- Detect the stack automatically. Only audit sections relevant to the project (don't audit Convex patterns in a pure Astro blog).
- When a fix touches shared infrastructure (config, utils, types), apply it once at the source — don't patch per-file.
- Security findings are never optional. Flag them even if the user asked to focus on performance.
- For shell/Bash projects (BuildFlowz): focus on input validation, error handling, quoting, `set -euo pipefail`, and ShellCheck findings.
- Don't refactor working code for aesthetics. Only change code that has a concrete issue (bug, vulnerability, performance regression, or deprecated pattern with a migration path).
