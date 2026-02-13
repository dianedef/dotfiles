---
name: design-audit
description: Professional UI/UX design audit across an entire project — systematic review of all pages, components, and design system coherence
disable-model-invocation: true
context: fork
---

## Context

- Current directory: !`pwd`
- Project CLAUDE.md: !`head -100 CLAUDE.md 2>/dev/null || echo "no CLAUDE.md"`
- All pages: !`find src/pages src/app -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Component files: !`find src/components -name "*.astro" -o -name "*.tsx" -o -name "*.vue" 2>/dev/null | grep -v node_modules | sort`
- Tailwind config: !`cat tailwind.config.* 2>/dev/null | head -80 || echo "no tailwind"`
- Global CSS: !`cat src/styles/global.css 2>/dev/null || cat src/assets/styles/*.css 2>/dev/null | head -100 || echo "none"`

## Your task

Perform a full-project design audit. This is a systematic review, not a page-by-page review.

### Phase 1: Design System Inventory

Read the Tailwind config, global styles, and 5-10 representative components. Document:

1. **Color palette**: List all colors actually used (Tailwind classes + custom). Flag inconsistencies (e.g., `text-gray-600` AND `text-gray-500` for similar purposes).
2. **Typography scale**: List all font sizes, weights, and line heights in use. Flag violations of the scale.
3. **Spacing system**: Check if spacing is consistent (Tailwind scale) or has arbitrary values.
4. **Component patterns**: Identify repeated patterns (cards, buttons, sections). Flag inconsistencies between instances.
5. **Breakpoint usage**: Check if responsive breakpoints are consistent.

### Phase 2: Page-by-Page Scan

For each page (read them all), check:

- [ ] Visual hierarchy — does the eye know where to go?
- [ ] Consistent use of the design system (no rogue colors/sizes)
- [ ] Responsive: no horizontal scroll, proper stacking on mobile
- [ ] Accessibility: contrast ratios, alt text, focus states, ARIA
- [ ] States covered: loading, empty, error (for dynamic pages)
- [ ] No layout shifts (explicit width/height on images, proper font loading)

### Phase 3: Cross-Page Consistency

- [ ] Header/footer identical across pages
- [ ] Navigation active states work correctly
- [ ] Page transitions feel cohesive (no jarring style changes)
- [ ] Consistent card/list treatment across different content types
- [ ] Consistent spacing between sections across all pages
- [ ] Favicon, apple-touch-icon, and theme-color present

### Phase 4: Fix

Fix all issues you find directly in the code. Prioritize:
1. **Accessibility violations** (legal risk + user impact)
2. **Design system inconsistencies** (fix in components, not per-page)
3. **Responsive breakages** (mobile-first)
4. **Missing states** (loading/error/empty)

For subjective design decisions, list them in the report for the user to decide.

### Phase 5: Report

```
DESIGN AUDIT: [project name]
═══════════════════════════════════════

DESIGN SYSTEM HEALTH
  Colors:     X tokens used, Y inconsistencies
  Typography: X sizes used, Y violations
  Spacing:    [consistent / mixed / chaotic]
  Components: X patterns, Y inconsistencies

PAGE SCORES
  /                  [A/B/C/D]
  /about             [A/B/C/D]
  /pricing           [A/B/C/D]
  ...

CROSS-PAGE CONSISTENCY    [A/B/C/D]
ACCESSIBILITY             [A/B/C/D]
RESPONSIVENESS            [A/B/C/D]
═══════════════════════════════════════
OVERALL                   [A/B/C/D]

Fixed: X issues across Y files
Needs decision: Z items (listed below)
```

### Important

- This is an architecture-level review. Don't just list issues per page — identify **systemic** problems and fix them at the source (component/config level).
- If a color or spacing inconsistency appears 20 times, fix the component or create a utility class — don't patch each instance.
- Respect the existing visual identity. Unify, don't redesign.
