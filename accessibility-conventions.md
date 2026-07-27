# Accessibility Conventions

This file defines accessibility (a11y) expectations for any user-facing interface. It is loaded into AI context when a task builds or changes UI.

Accessibility is not a feature or a late-stage audit — it's a property of correctly-built UI, the same way validated input is a property of correctly-built server code. Building it in costs almost nothing; retrofitting it costs a rewrite. For government and court products it is frequently a legal requirement, not a nicety.

**Target:** WCAG 2.1 **AA** is the working default. See more details at https://www.w3.org/TR/WCAG22/. A company profile may set a higher bar or a specific legal standard (e.g. Section 508) — that profile target wins (`companies/<name>/`).

---

## Semantic Structure First

- Use the right element for the job: a `button` is a button, a link is an `a`, headings (`h1`–`h6`) describe real hierarchy. A `div` with a click handler is not a button and excludes anyone not using a mouse.
- Native elements come with keyboard behavior, focus, and screen-reader semantics for free. Reach for ARIA only to fill genuine gaps — incorrect ARIA is worse than none.
- Every form input has an associated `label`. Every meaningful image has alt text; decorative images are explicitly empty (`alt=""`).

## Keyboard and Focus

- Everything operable by mouse is operable by keyboard, in a logical tab order. If you can't complete the flow without a mouse, it's broken.
- Focus is always visible — never remove focus outlines without replacing them with something at least as clear.
- Manage focus on dynamic changes: when a modal opens, focus moves into it and is trapped; when it closes, focus returns. Route changes move focus to a sensible landmark.

## Perceivable Content

- **Color contrast meets AA:** 4.5:1 for normal text, 3:1 for large text and meaningful UI boundaries. Verify it — don't eyeball it.
- Color is never the *only* carrier of meaning (error state, status, required field). Pair it with text, an icon, or a pattern — color-blind and low-vision users miss color-only signals.
- Content is readable and functional when zoomed to 200%, and reflows rather than requiring horizontal scroll.

## Respect the Design System

- Use the project's design-system components rather than hand-rolling controls. Accessible components are accessibility done once, correctly, and reused — don't rebuild a control the system already provides and get its a11y wrong.
- The design system is the source of truth for accessible color tokens and interaction patterns; align to it rather than inventing local variants.
- The specific design system, and any audit tooling it exposes, is named in the company profile (`companies/<name>/`). A project with no company profile uses whatever design system it declares in its own CLAUDE.md.
- **No design system yet?** Don't invent one up front. See `ui-conventions.md` → "Design System: Adopt, Emerge, then Formalize" — the accessibility rules in this file apply immediately regardless, including to hand-rolled components.

## Verify, Don't Assume

- Run automated checks (axe, Lighthouse, or the design system's audit tooling) as part of building UI — they catch the mechanical failures (missing labels, contrast, roles) cheaply.
- Automated tools catch perhaps half of real issues. For anything non-trivial, do a keyboard-only pass and, where it matters, a screen-reader pass. Automated green is necessary, not sufficient.
- Where UI is under test, include a11y assertions (roles, labels, focus) so regressions are caught like any other (`testing-conventions.md`).

## By Collaboration Mode

Accessibility is a **principle, not a preference** — it doesn't relax for solo projects with real users; excluding users is excluding users regardless of team size. What flexes is only rigor of *process*:

- **Solo / early:** build semantic, keyboard-operable, AA-contrast UI by default and run automated checks.
- **Collaborative / enterprise-ready:** automated a11y checks in CI, the organization's conformance target enforced, and manual verification for critical flows before launch.
