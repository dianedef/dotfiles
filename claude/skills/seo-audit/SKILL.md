---
name: seo-audit
description: Professional full-site SEO audit — technical SEO, on-page optimization, internal linking, structured data, crawlability
disable-model-invocation: true
context: fork
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Sitemap: !`cat public/sitemap*.xml 2>/dev/null | head -50 || echo "no sitemap"`
- Robots.txt: !`cat public/robots.txt 2>/dev/null || echo "no robots.txt"`
- SEO config: !`find src -name "*seo*" -o -name "*meta*" -o -name "*head*" 2>/dev/null | grep -v node_modules | head -10 || echo "none"`
- Astro config: !`cat astro.config.* 2>/dev/null | head -50 || echo "no astro config"`
- Content files count: !`find src/content -type f 2>/dev/null | wc -l || echo "0"`

## Your task

Perform a full technical + on-page SEO audit of the entire project.

### Phase 1: Technical SEO Infrastructure

Read the site config, layouts, and head components. Audit:

#### Crawlability & Indexation
- [ ] `robots.txt` exists and is correct (no accidental `Disallow: /`)
- [ ] `sitemap.xml` exists and lists all public pages
- [ ] Sitemap is referenced in `robots.txt`
- [ ] Canonical URLs are set on all pages (absolute URLs)
- [ ] No orphan pages (pages not linked from anywhere)
- [ ] No `noindex` on pages that should be indexed
- [ ] 404 page exists and returns proper status code
- [ ] Redirects are 301 (permanent), not 302

#### Site Architecture
- [ ] URL structure is clean, hierarchical, and consistent
- [ ] Max 3 clicks from homepage to any page
- [ ] Breadcrumbs present on nested pages
- [ ] Pagination uses `rel="next"` / `rel="prev"` if applicable

#### Performance (SEO-critical)
- [ ] SSG/SSR is used (not client-side rendering for content pages)
- [ ] HTML is served with proper content (not empty shell + JS)
- [ ] Images optimized (WebP/AVIF, proper sizing, lazy loading)
- [ ] LCP image is eagerly loaded with `fetchpriority="high"`
- [ ] No render-blocking resources
- [ ] Fonts use `font-display: swap`

### Phase 2: On-Page SEO — Systematic Scan

For EVERY page, check and record:

| Page | Title (len) | H1 | Meta Desc (len) | OG Image | Schema | Internal Links |
|------|------------|-----|-----------------|----------|--------|---------------|

Flags:
- [ ] Title present and 50-60 chars
- [ ] Exactly one H1
- [ ] Meta description 150-160 chars
- [ ] OG tags complete (title, description, image, url)
- [ ] Twitter card tags present
- [ ] Images have alt text
- [ ] Heading hierarchy is sequential (no h1→h3 skips)
- [ ] At least 2 internal links on the page

### Phase 3: Content SEO

- [ ] No duplicate titles across pages
- [ ] No duplicate meta descriptions across pages
- [ ] No thin pages (< 300 words of meaningful content)
- [ ] Blog/article pages have: author, date, category, reading time
- [ ] Content collections have proper frontmatter (title, description, date, image)

### Phase 4: Structured Data

- [ ] JSON-LD present on relevant pages:
  - Homepage: `Organization` or `WebSite` with `SearchAction`
  - Blog posts: `Article` with author, date, image
  - Product/pricing: `Product` or `Offer`
  - FAQ sections: `FAQPage`
  - Breadcrumbs: `BreadcrumbList`
- [ ] JSON-LD is valid (proper schema.org types and required fields)

### Phase 5: Internal Linking

Map the internal link graph:
1. Which pages have the most inbound internal links?
2. Which important pages are under-linked?
3. Are anchor texts descriptive (not "click here" or "read more")?
4. Does the navigation reinforce page hierarchy?

### Phase 6: Fix

Fix all issues directly in code. Priority order:
1. **Missing/broken meta tags** (title, description, canonical) — highest SEO impact
2. **Missing structured data** — add JSON-LD to key pages
3. **Heading hierarchy fixes** — semantic corrections
4. **Image alt text** — add descriptive alts everywhere
5. **Internal linking gaps** — add contextual links
6. **Sitemap/robots.txt** — ensure completeness
7. **Performance issues** — lazy loading, font loading, image optimization

### Phase 7: Report

```
SEO AUDIT: [project name]
═══════════════════════════════════════

TECHNICAL SEO
  Crawlability:      [A/B/C/D] — robots.txt, sitemap, canonicals
  Site Architecture:  [A/B/C/D] — URL structure, depth, breadcrumbs
  Performance:        [A/B/C/D] — rendering, images, fonts

ON-PAGE SEO (X pages scanned)
  Titles:            X/Y correct (Z missing, W too long)
  Meta Descriptions: X/Y correct (Z missing, W duplicated)
  H1 Tags:           X/Y correct (Z missing, W duplicated)
  OG Tags:           X/Y complete
  Alt Text:          X/Y images covered

STRUCTURED DATA
  Pages with schema: X/Y
  Types used:        [list]

INTERNAL LINKING
  Avg links/page:    X
  Orphan pages:      [list]
  Under-linked:      [list]

PAGE-BY-PAGE
  /                  [A/B/C/D]
  /about             [A/B/C/D]
  ...
═══════════════════════════════════════
OVERALL              [A/B/C/D]

Fixed: X issues across Y files
Critical remaining: Z items
```

### Important

- For French sites: meta descriptions and titles should be in French. URL slugs can use accented characters if the project already does.
- For Astro sites: leverage `@astrojs/sitemap` integration if not already present. Use Astro's built-in `<Image>` component for optimization.
- Prioritize pages by traffic potential: homepage > landing pages > product pages > blog > utility pages.
- When adding structured data, validate it against schema.org specs. Don't generate invalid JSON-LD.
- For sites with 100+ content pages, focus the detailed audit on templates/layouts since all pages of a type share the same SEO structure.
