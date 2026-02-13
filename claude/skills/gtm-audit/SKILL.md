---
name: gtm-audit
description: Professional full-site go-to-market audit — conversion funnels, positioning coherence, trust architecture, analytics, market readiness
disable-model-invocation: true
context: fork
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Analytics: !`grep -ri "analytics\|gtag\|plausible\|umami\|posthog\|vercel/analytics" src/ 2>/dev/null | head -10 || echo "none"`
- Auth/payment: !`grep -ri "clerk\|stripe\|lemonsqueezy\|paddle\|auth" package.json 2>/dev/null | head -5 || echo "none"`
- Environment hints: !`grep -ri "STRIPE\|CLERK\|PAYMENT\|PRICE" .env.example .env.local 2>/dev/null | head -10 || echo "none"`

## Your task

Perform a full go-to-market audit of the entire project. Think like a CMO reviewing before launch.

### Phase 1: Positioning Map

Read the homepage, about, pricing, and key landing pages. Document:

1. **Core value proposition**: What is it? Is it stated explicitly or just implied?
2. **Target audience**: Who is this for? Is it specific enough?
3. **Competitive angle**: What makes this different? Is it communicated?
4. **Pricing model**: What is it? Is it aligned with the value proposition?
5. **Brand promise**: What's the implicit promise? Is it kept throughout?

Deliver a **one-sentence positioning statement**: "[Product] helps [audience] [achieve outcome] by [unique mechanism], unlike [alternatives]."

### Phase 2: Conversion Funnel Map

Trace every conversion path through the site:

```
Traffic Source → Landing Page → Consideration → Conversion → Post-Conversion
```

For each path:
- [ ] Entry point matches traffic intent
- [ ] Each step has a clear next action
- [ ] No dead ends or distractions
- [ ] Friction points are minimized (form fields, required accounts, etc.)
- [ ] Fallback capture exists (newsletter, free resource) for non-converters

### Phase 3: Page-by-Page GTM Audit

For each page, classify its funnel role and audit accordingly:

**Awareness pages** (blog, content, landing):
- [ ] Captures attention with a strong hook
- [ ] Links to consideration/conversion pages
- [ ] Email/lead capture present
- [ ] Shareable (OG tags, good social preview)

**Consideration pages** (features, how-it-works, case studies):
- [ ] Addresses specific objections
- [ ] Social proof relevant to the feature discussed
- [ ] Comparison with alternatives (if appropriate)
- [ ] Clear path to pricing/signup

**Conversion pages** (pricing, signup, checkout):
- [ ] Price anchoring used effectively
- [ ] Risk reversal present (guarantee, free trial)
- [ ] Urgency is authentic (not fake)
- [ ] Checkout/signup friction minimized
- [ ] Trust signals near the payment/action area

**Retention pages** (dashboard, settings, onboarding):
- [ ] Onboarding guides to first value moment
- [ ] Upgrade prompts are contextual (not random)
- [ ] Help/support is accessible

### Phase 4: Trust Architecture

Audit trust signals across the entire site:

- [ ] Testimonials: present, specific, credible (name + role + company)
- [ ] Social proof: user counts, client logos, media mentions
- [ ] Security signals: SSL, privacy policy, data handling info
- [ ] Authority signals: team page, credentials, certifications
- [ ] Consistency: promises made on marketing pages match actual product
- [ ] Legal compliance: mentions légales (FR), privacy policy, CGV, cookie consent

### Phase 5: Analytics & Measurement

- [ ] Analytics is installed and loading on all pages
- [ ] Key conversion events are tracked:
  - CTA clicks
  - Form submissions
  - Signup completions
  - Pricing page views
  - Feature page engagement
- [ ] UTM parameters are preserved through navigation
- [ ] Goal/conversion tracking is configured
- [ ] Key pages have heatmap or session recording capability (or easy to add)

### Phase 6: Launch Readiness Checklist

- [ ] All pages load without errors
- [ ] Mobile experience is complete (not just "works")
- [ ] Forms actually submit (test them)
- [ ] Payment flow works end-to-end (if applicable)
- [ ] Email templates/notifications exist and are branded
- [ ] 404 page is helpful and branded
- [ ] Social media preview looks good (test OG image rendering)
- [ ] Legal pages are complete (privacy, terms, cookie policy, mentions légales)
- [ ] Contact channel is functional and monitored
- [ ] Backup/error recovery plan exists

### Phase 7: Fix

Fix all issues directly in code. Priority:
1. **Broken conversion paths** (CTAs that lead nowhere, dead forms)
2. **Missing trust signals** (add testimonial sections, trust badges)
3. **Missing analytics tracking** (add event tracking to key actions)
4. **Legal compliance** (add missing legal pages, cookie consent)
5. **Funnel leaks** (pages without CTAs, dead-end content)

For strategic recommendations (positioning changes, pricing restructuring, new pages), document them clearly in the report.

### Phase 8: Report

```
GTM AUDIT: [project name]
═══════════════════════════════════════

POSITIONING
  Value proposition:     [clear / vague / missing]
  Target audience:       [specific / generic]
  Differentiation:       [strong / weak / absent]
  One-liner: "[positioning statement]"

CONVERSION FUNNEL
  Primary path:          [description] — [A/B/C/D]
  Secondary paths:       [count] identified
  Dead ends found:       [count]
  Avg. friction score:   [low / medium / high]

PAGE SCORES (by funnel role)
  Awareness
    /blog              [A/B/C/D]
    ...
  Consideration
    /features          [A/B/C/D]
    ...
  Conversion
    /pricing           [A/B/C/D]
    /signup            [A/B/C/D]
    ...

TRUST ARCHITECTURE     [A/B/C/D]
ANALYTICS & TRACKING   [A/B/C/D]
LAUNCH READINESS       [A/B/C/D]
═══════════════════════════════════════
OVERALL                [A/B/C/D]

Fixed: X issues across Y files
Strategic recommendations: Z (detailed below)
```

### Important

- This is a business review, not just a code review. Every recommendation must tie to acquisition, conversion, or retention.
- For French market: RGPD is mandatory, mentions légales are legally required, and CGV are needed for any commercial transaction.
- Don't recommend building things that don't exist. Optimize what's there. List "should build" items separately.
- If the project is pre-launch, focus the report on launch readiness. If post-launch, focus on conversion optimization.
- Be specific with business impact estimates (use industry conversion benchmarks).
