---
name: seo
description: Professional technical & on-page SEO audit of a single page — meta tags, headings, schema, Core Web Vitals, internal linking
disable-model-invocation: true
argument-hint: <file-path or route>
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Sitemap: !`cat public/sitemap*.xml 2>/dev/null | head -30 || echo "no sitemap found"`
- Robots.txt: !`cat public/robots.txt 2>/dev/null || echo "no robots.txt"`
- SEO/head component: !`find src -name "*seo*" -o -name "*head*" -o -name "*meta*" 2>/dev/null | grep -v node_modules | head -10 || echo "none found"`

## Your task

Perform a professional SEO audit of the page at `$ARGUMENTS`.

### Step 1: Gather the page

1. Read the target file. If no argument given, ask the user which page to review.
2. Read the layout/head component that injects meta tags.
3. Read the SEO config/defaults (BaseHead.astro, metadata.ts, or equivalent).
4. Read the sitemap config if it exists.

### Step 2: Audit against this checklist

Score each category **A/B/C/D**. Be strict — production SEO standard.

#### 1. Meta Tags & Head
- [ ] `<title>` present, 50-60 characters, includes primary keyword
- [ ] `<meta description>` present, 150-160 characters, includes CTA
- [ ] `<meta robots>` allows indexing (or intentionally noindex for private pages)
- [ ] `<link rel="canonical">` present and correct (absolute URL)
- [ ] `<html lang="xx">` matches content language
- [ ] No duplicate meta tags

#### 2. Open Graph & Social
- [ ] `og:title`, `og:description`, `og:image` present
- [ ] `og:image` is 1200x630px (or close) with absolute URL
- [ ] `og:type` is set (article, website, product, etc.)
- [ ] `og:url` matches canonical
- [ ] Twitter card meta (`twitter:card`, `twitter:title`, `twitter:image`)
- [ ] Social preview would look good when shared (no truncation)

#### 3. Heading Structure
- [ ] Exactly one `<h1>` per page
- [ ] H1 contains primary keyword naturally
- [ ] Heading hierarchy is sequential (h1 > h2 > h3, no skips)
- [ ] Headings are descriptive, not generic ("Our Services" → "Web Design Services in Paris")
- [ ] No headings used purely for styling (use CSS instead)

#### 4. Content & Keywords
- [ ] Primary keyword appears in: title, H1, first paragraph, URL
- [ ] Keyword density is natural (1-2%, not stuffed)
- [ ] Related/LSI keywords are present
- [ ] Content length is competitive for the keyword intent (check: informational > 1000 words, transactional can be shorter)
- [ ] No thin content pages (< 300 words unless intentional)
- [ ] No duplicate content with other pages on the site

#### 5. Images & Media
- [ ] All `<img>` have descriptive `alt` text with keywords where natural
- [ ] Images use modern formats (WebP/AVIF with fallbacks)
- [ ] Images have explicit `width` and `height` (prevents CLS)
- [ ] Images are lazy-loaded below the fold (`loading="lazy"`)
- [ ] Hero/LCP image is NOT lazy-loaded (eager or `fetchpriority="high"`)

#### 6. Technical SEO
- [ ] URLs are clean (lowercase, hyphens, no trailing slashes inconsistency)
- [ ] Page is in sitemap.xml
- [ ] Internal links use descriptive anchor text (not "click here")
- [ ] At least 2-3 internal links to/from this page
- [ ] No broken links (href="#" or empty hrefs)
- [ ] Structured data / JSON-LD present (Article, Product, FAQ, BreadcrumbList, etc.)
- [ ] Breadcrumbs present for nested pages

#### 7. Performance (SEO-impacting)
- [ ] No render-blocking resources in `<head>` (defer/async scripts)
- [ ] Critical CSS inlined or loaded early
- [ ] Fonts use `font-display: swap`
- [ ] No massive JS bundles loaded for static content
- [ ] Third-party scripts are deferred (analytics, chat widgets)

### Step 3: Fix what you can

For each issue rated B or worse:
1. Identify the exact file and line.
2. Fix it directly in the code.
3. For content decisions (keyword choice, meta description wording), propose 2 options and ask the user.

### Step 4: Report

```
SEO REVIEW: [page name] — target keyword: "[inferred keyword]"
─────────────────────────────────────
Meta Tags & Head   [A/B/C/D] — one-line summary
Social / OG        [A/B/C/D] — one-line summary
Heading Structure  [A/B/C/D] — one-line summary
Content & Keywords [A/B/C/D] — one-line summary
Images & Media     [A/B/C/D] — one-line summary
Technical SEO      [A/B/C/D] — one-line summary
Performance        [A/B/C/D] — one-line summary
─────────────────────────────────────
OVERALL            [A/B/C/D]

Fixed: X issues | Needs decision: Y issues
```

### Important

- Infer the target keyword from the page content and URL. If unclear, ask.
- For French content, apply French SEO conventions (accented characters in URLs are OK if consistent, meta descriptions in French, etc.).
- Never stuff keywords. Natural language always wins.
- Structured data must be valid JSON-LD — use schema.org types.
- Be aware of Astro's static generation: many performance issues are already handled by the framework. Focus on what the developer controls.
