---
name: design
description: Professional UI/UX design review of a single page — accessibility, visual hierarchy, responsiveness, consistency
disable-model-invocation: true
argument-hint: <file-path or route>
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- Tailwind/CSS config: !`cat tailwind.config.* 2>/dev/null | head -60 || echo "no tailwind config"`
- Global styles: !`cat src/styles/global.css 2>/dev/null || cat src/assets/styles/*.css 2>/dev/null | head -80 || echo "no global styles found"`

## Your task

Perform a professional UI/UX design review of the page at `$ARGUMENTS`.

### Step 1: Gather the page

1. Read the target file (`$ARGUMENTS`). If no argument given, ask the user which page to review.
2. Read its layout/wrapper component if it imports one.
3. Read any component files it imports (follow the imports).
4. Read the relevant CSS/Tailwind classes used.

### Step 2: Audit against this checklist

Score each category **A/B/C/D** (A = excellent, D = critical issues). Be strict — professional standard.

#### 1. Visual Hierarchy & Layout
- [ ] Clear primary action / CTA above the fold
- [ ] Logical reading flow (F-pattern or Z-pattern)
- [ ] Proper whitespace rhythm — consistent spacing scale (not arbitrary px values)
- [ ] Content sections have clear visual separation
- [ ] No orphaned headings, dangling text, or layout widows

#### 2. Typography
- [ ] Heading hierarchy is semantic (h1 > h2 > h3, no skipped levels)
- [ ] Body text is 16px+ with line-height >= 1.5
- [ ] Max line width ~65-75 characters (measure/prose constraint)
- [ ] Font pairing is intentional (max 2-3 families)
- [ ] No font-size under 14px except legal/fine print

#### 3. Color & Contrast
- [ ] WCAG AA contrast ratios (4.5:1 text, 3:1 large text/UI)
- [ ] Color is not the only way to convey information
- [ ] Consistent color token usage (no hardcoded hex outside design system)
- [ ] Interactive elements have visible focus/hover/active states
- [ ] Dark mode support if the project uses it

#### 4. Responsiveness
- [ ] Mobile-first or gracefully responsive (no horizontal scroll)
- [ ] Touch targets >= 44x44px on mobile
- [ ] Images/media have proper aspect ratio handling
- [ ] Navigation works on small screens
- [ ] No content hidden or broken between 320px-1440px

#### 5. Component Consistency
- [ ] Buttons follow a single pattern (size, radius, padding)
- [ ] Cards/containers have consistent elevation/border treatment
- [ ] Icons are same set and consistent size
- [ ] Spacing uses design system tokens, not arbitrary values
- [ ] States are covered: empty, loading, error, populated

#### 6. Accessibility
- [ ] All images have meaningful alt text (or alt="" for decorative)
- [ ] Form inputs have visible labels (not just placeholders)
- [ ] Keyboard navigation works (tab order, focus visible)
- [ ] ARIA roles where needed (modals, menus, tabs)
- [ ] Skip navigation link present if applicable
- [ ] Animations respect `prefers-reduced-motion`

### Step 3: Fix what you can

For each issue rated B or worse:
1. Explain the problem with the specific line/component.
2. Fix it directly in the code.
3. If a fix requires a design decision (e.g., color choice), propose 2 options and ask the user.

### Step 4: Report

Output a summary table:

```
DESIGN REVIEW: [page name]
─────────────────────────────────────
Visual Hierarchy   [A/B/C/D] — one-line summary
Typography         [A/B/C/D] — one-line summary
Color & Contrast   [A/B/C/D] — one-line summary
Responsiveness     [A/B/C/D] — one-line summary
Consistency        [A/B/C/D] — one-line summary
Accessibility      [A/B/C/D] — one-line summary
─────────────────────────────────────
OVERALL            [A/B/C/D]

Fixed: X issues | Remaining: Y issues
```

### Important

- Be ruthlessly honest. A-level means genuinely production-ready, not "it works".
- When the project has a design system or Tailwind config, enforce its tokens — don't introduce new arbitrary values.
- Respect the project's existing aesthetic. Improve, don't redesign.
- If the project content is in French, review the design in that language context (e.g., French text is ~15% longer than English).
