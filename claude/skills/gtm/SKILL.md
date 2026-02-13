---
name: gtm
description: Professional go-to-market review of a single page — conversion, positioning, trust signals, funnel alignment
disable-model-invocation: true
argument-hint: <file-path or route>
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Analytics setup: !`grep -ri "analytics\|gtag\|plausible\|umami\|posthog\|vercel/analytics" src/ 2>/dev/null | head -10 || echo "no analytics found"`
- Navigation/routes: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | head -20 || echo "no pages found"`

## Your task

Perform a professional go-to-market review of the page at `$ARGUMENTS`.

### Step 1: Gather the page

1. Read the target file. If no argument given, ask the user which page to review.
2. Read the site navigation to understand where this page sits in the funnel.
3. Read the homepage/landing page to understand overall positioning.
4. Read pricing page if it exists (for conversion context).

### Step 2: Audit against this checklist

Score each category **A/B/C/D**. Be strict — growth/marketing professional standard.

#### 1. Positioning & Differentiation
- [ ] It's immediately clear what this product/service does (5-second test)
- [ ] The unique value proposition is explicit, not implied
- [ ] Competitive differentiation is visible (why this vs alternatives)
- [ ] Target audience is obvious from language, imagery, and examples
- [ ] Positioning is specific ("AI scheduling for freelancers") not vague ("the best tool")

#### 2. Conversion Architecture
- [ ] Page has a clear single goal (one primary conversion action)
- [ ] The conversion path has minimal friction (fewest clicks/fields possible)
- [ ] CTA is visible without scrolling
- [ ] CTA is repeated at logical intervals (after each value section)
- [ ] Exit intent or secondary capture exists (newsletter, free resource)
- [ ] Pricing is transparent (no "contact us for pricing" unless enterprise)

#### 3. Trust & Credibility
- [ ] Social proof is present and specific (numbers > vague claims)
- [ ] Testimonials include name, role, photo, or company (not anonymous)
- [ ] Trust badges where appropriate (security, certifications, media logos)
- [ ] Case studies or results with real data
- [ ] Professional design (no template look, no stock photo overuse)
- [ ] Contact information or support access is visible

#### 4. Objection Handling
- [ ] FAQ section addresses top 3-5 objections
- [ ] Pricing objections handled (free tier, guarantee, comparison)
- [ ] "Who is this for / not for" clarity
- [ ] Setup/onboarding complexity addressed (show how easy it is)
- [ ] Data/privacy concerns addressed if relevant

#### 5. Funnel Alignment
- [ ] Page matches the intent of its traffic source (ad → landing page consistency)
- [ ] Internal links guide users deeper into the funnel (not sideways)
- [ ] Blog/content links back to product pages naturally
- [ ] Navigation doesn't distract from the conversion goal
- [ ] Post-conversion flow exists (confirmation, onboarding, next step)

#### 6. Analytics & Tracking
- [ ] Analytics tool is installed and loading
- [ ] Key conversion events are tracked (CTA clicks, form submissions, signups)
- [ ] UTM parameters are preserved through the funnel
- [ ] A/B testing infrastructure exists or is easy to add
- [ ] Core Web Vitals are monitored (they affect paid ad quality score)

#### 7. Market Readiness
- [ ] Legal pages exist (privacy policy, terms of service, legal mentions for FR)
- [ ] Cookie consent is implemented if EU-targeted
- [ ] Accessibility meets minimum legal requirements (especially for FR)
- [ ] Contact/support channel is functional
- [ ] Mobile experience is equal to desktop (majority of traffic is mobile)

### Step 3: Fix what you can

For each issue rated B or worse:
1. Explain the business impact (e.g., "Missing social proof reduces conversion ~15%").
2. Fix code-level issues directly (missing tracking, broken links, missing legal pages).
3. For strategic decisions (positioning, pricing, testimonial selection), provide specific recommendations with reasoning.

### Step 4: Report

```
GTM REVIEW: [page name] — funnel stage: [awareness/consideration/conversion/retention]
─────────────────────────────────────
Positioning        [A/B/C/D] — one-line summary
Conversion         [A/B/C/D] — one-line summary
Trust & Proof      [A/B/C/D] — one-line summary
Objection Handling [A/B/C/D] — one-line summary
Funnel Alignment   [A/B/C/D] — one-line summary
Analytics          [A/B/C/D] — one-line summary
Market Readiness   [A/B/C/D] — one-line summary
─────────────────────────────────────
OVERALL            [A/B/C/D]

Fixed: X issues | Strategic recommendations: Y
```

### Important

- Think like a growth lead, not just a developer. Every recommendation should tie to revenue or user acquisition.
- For French projects, apply French market specifics: RGPD compliance, mentions légales, CGV if e-commerce.
- Be specific with numbers when citing conversion impact (use industry benchmarks).
- Don't recommend adding features that don't exist yet — review what's there and optimize it.
- If this is a content/blog page, evaluate it as top-of-funnel: does it capture leads and link to conversion pages?
