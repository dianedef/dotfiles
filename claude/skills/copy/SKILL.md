---
name: copy
description: Professional copywriting review of a single page — clarity, persuasion, tone, microcopy, CTAs
disable-model-invocation: true
argument-hint: <file-path or route>
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Content language clues: !`grep -ri "lang=" src/layouts/*.astro src/app/layout.tsx 2>/dev/null | head -5 || echo "unknown"`

## Your task

Perform a professional copywriting review of the page at `$ARGUMENTS`.

### Step 1: Gather the page

1. Read the target file. If no argument given, ask the user which page to review.
2. Read layout/wrapper components for shared copy (nav, footer, CTAs).
3. Read i18n/translation files if the project uses them.
4. Identify the page's role in the user journey (landing, feature, pricing, blog, docs, etc.).

### Step 2: Audit against this checklist

Score each category **A/B/C/D**. Be strict — professional copywriter standard.

#### 1. Value Proposition & Messaging
- [ ] Primary benefit is clear within 5 seconds of reading
- [ ] Headline answers "what's in it for me?" not "what is this?"
- [ ] Subheadline adds specificity (numbers, outcomes, timeframe)
- [ ] Copy speaks to a specific audience, not everyone
- [ ] Features are framed as benefits (not just feature lists)

#### 2. Clarity & Readability
- [ ] Sentences average under 20 words
- [ ] Paragraphs are 2-3 sentences max
- [ ] No jargon without context (or jargon is intentional for the audience)
- [ ] Active voice dominant (passive < 10%)
- [ ] Flesch-Kincaid grade level appropriate for audience (typically 6-8)
- [ ] No filler words ("very", "really", "just", "actually", "basically")

#### 3. Persuasion & Psychology
- [ ] Social proof present where claims are made (testimonials, numbers, logos)
- [ ] Urgency/scarcity used authentically (not fake countdown timers)
- [ ] Objections addressed before they arise
- [ ] Risk reversal present (guarantee, free trial, no credit card)
- [ ] Emotional trigger matches audience's primary motivation

#### 4. Calls to Action
- [ ] Primary CTA uses action verb + benefit ("Start free trial" not "Submit")
- [ ] One clear primary CTA per section (no competing CTAs)
- [ ] CTA copy matches what actually happens next
- [ ] Button text works standalone (makes sense without surrounding context)
- [ ] Secondary CTAs provide a lower-commitment alternative

#### 5. Microcopy & UX Writing
- [ ] Form labels are clear, not clever
- [ ] Error messages explain what went wrong AND how to fix it
- [ ] Success messages confirm what happened
- [ ] Empty states guide the user to take action
- [ ] Loading states set expectations
- [ ] Navigation labels are predictable (no creative menu names)

#### 6. Tone & Voice Consistency
- [ ] Tone is consistent across the page (no formal → casual switches)
- [ ] Voice matches brand personality throughout
- [ ] Humor (if used) doesn't undermine trust
- [ ] Address style is consistent (tu/vous in French, you/we in English)
- [ ] Technical level is consistent (don't mix beginner and expert language)

#### 7. Grammar & Polish
- [ ] Zero spelling errors
- [ ] Zero grammar errors
- [ ] Consistent capitalization (title case vs sentence case)
- [ ] Consistent punctuation (Oxford comma or not, periods in lists or not)
- [ ] No broken interpolation or placeholder text (`{name}`, `Lorem ipsum`)

### Step 3: Rewrite and fix

For each issue rated B or worse:
1. Quote the problematic copy.
2. Explain why it's weak.
3. Provide a rewritten version directly in the code.
4. For subjective tone choices, propose 2 options and ask the user.

### Step 4: Report

```
COPY REVIEW: [page name]
─────────────────────────────────────
Value Proposition  [A/B/C/D] — one-line summary
Clarity            [A/B/C/D] — one-line summary
Persuasion         [A/B/C/D] — one-line summary
Calls to Action    [A/B/C/D] — one-line summary
Microcopy          [A/B/C/D] — one-line summary
Tone & Voice       [A/B/C/D] — one-line summary
Grammar & Polish   [A/B/C/D] — one-line summary
─────────────────────────────────────
OVERALL            [A/B/C/D]

Rewrites applied: X | Needs decision: Y
```

### Important

- Detect the content language automatically. If French, review in French and apply French copywriting conventions (tutoiement/vouvoiement per project CLAUDE.md).
- Preserve the author's voice — elevate, don't replace. The goal is sharper copy, not a different personality.
- Never use clichés ("leverage", "empower", "seamless", "révolutionner", "unique").
- All rewrites must fit the UI constraints (button width, card height, etc.).
