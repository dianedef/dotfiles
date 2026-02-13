---
name: copy-audit
description: Professional copywriting audit across an entire project — voice consistency, messaging hierarchy, conversion copy, microcopy
disable-model-invocation: true
context: fork
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- i18n/translations: !`find src -path "*/i18n/*" -o -path "*/locales/*" -o -path "*/messages/*" 2>/dev/null | head -10 || echo "none"`
- Content collections: !`find src/content -type f 2>/dev/null | head -20 || echo "no content dir"`
- Content language: !`grep -ri "lang=" src/layouts/*.astro src/app/layout.tsx 2>/dev/null | head -3 || echo "unknown"`

## Your task

Perform a full-project copywriting audit. Focus on systemic patterns, not just per-page issues.

### Phase 1: Voice & Tone Inventory

Read the homepage, about page, and 3-5 key pages. Document:

1. **Brand voice profile**: Is the voice consistent? Describe it (e.g., "professional but warm, technical but approachable").
2. **Address style**: tu/vous (FR) or formal/informal (EN) — is it consistent everywhere?
3. **Terminology**: List key terms used for the product/service. Flag synonyms used inconsistently (e.g., "dashboard" vs "panel" vs "interface" for the same thing).
4. **Tone range**: Where does tone shift? Is it intentional (e.g., playful marketing → serious legal) or accidental?

### Phase 2: Messaging Hierarchy

Map the entire site's messaging:

1. **Homepage**: What's the primary message? Is it the strongest possible version?
2. **Feature/product pages**: Do they reinforce the homepage message or contradict it?
3. **Blog/content**: Does content support the core positioning?
4. **Pricing**: Is the value framing consistent with feature pages?
5. **About/team**: Does it build credibility for the claims made elsewhere?

Flag any messaging contradictions or gaps.

### Phase 3: Page-by-Page Copy Scan

For each page, check:

- [ ] Headline is benefit-driven (not feature-driven or vague)
- [ ] Body copy is scannable (short paragraphs, bullet points, subheadings)
- [ ] CTAs use action verbs + benefit
- [ ] No filler words or corporate jargon
- [ ] No spelling/grammar errors
- [ ] No placeholder text or broken interpolation
- [ ] Microcopy is helpful (form labels, error messages, empty states)

### Phase 4: Conversion Copy Check

- [ ] Landing pages have a clear single message
- [ ] Pricing page frames value before cost
- [ ] Signup/onboarding copy reduces anxiety
- [ ] Error messages are human and actionable
- [ ] Success messages reinforce value ("You're in!" vs "Form submitted")
- [ ] 404 page is helpful (not just a dead end)

### Phase 5: Fix

Rewrite and fix all issues directly in the code. Prioritize:
1. **Homepage and pricing** (highest traffic/impact pages)
2. **CTAs across the site** (direct conversion impact)
3. **Inconsistent terminology** (fix at source: i18n files or shared constants)
4. **Grammar/spelling errors** (zero tolerance)
5. **Microcopy** (error messages, empty states, confirmations)

For tone/voice decisions, propose options and ask the user.

### Phase 6: Report

```
COPY AUDIT: [project name]
═══════════════════════════════════════

VOICE & TONE
  Brand voice:  [description]
  Consistency:  [A/B/C/D]
  Terminology:  X inconsistencies found

MESSAGING HIERARCHY
  Core message clarity:    [A/B/C/D]
  Cross-page coherence:    [A/B/C/D]

PAGE SCORES
  /                  [A/B/C/D] — "[current headline]"
  /pricing           [A/B/C/D] — "[current headline]"
  /about             [A/B/C/D] — "[current headline]"
  ...

CONVERSION COPY        [A/B/C/D]
MICROCOPY              [A/B/C/D]
GRAMMAR & POLISH       [A/B/C/D]
═══════════════════════════════════════
OVERALL                [A/B/C/D]

Rewrites applied: X across Y files
Terminology standardized: Z terms
Needs decision: W items
```

### Important

- Detect content language automatically. Review in that language.
- For French sites: check tutoiement/vouvoiement consistency, French typographic rules (espaces insécables before : ; ! ?), and avoid anglicisms when French alternatives exist.
- Build a mini style guide from what you find. Standardize terminology, then apply it everywhere.
- Never change copy that's clearly a direct quote or testimonial.
- All rewrites must fit UI constraints (don't write a 10-word button label).
