# UI Conventions

This file defines conventions for building any software with a front-facing interface — the engineering of the frontend *and* the UI/UX principles that make it usable. It is loaded into AI context when a task builds or changes UI.

Two things frame everything below:

- **Components are code.** `coding-conventions.md` (naming, single responsibility, shallow nesting, YAGNI, immutability) governs a component exactly as it governs a function. This file covers only what's specific to the interface.
- **Accessibility is a hard requirement, not a principle to weigh.** Keyboard operability, semantic markup, sufficient contrast, and screen-reader support are mandatory throughout and defined in `accessibility-conventions.md`. Where a principle below touches contrast, touch targets, or motion, that file is the authority.

Most of what follows are **principles** (usability is not a matter of taste). The **preferences** — which font, the exact palette, the animation style, the styling library — belong to the design system or the company profile (`companies/<name>/`), not here.

---

## Part 1 — Building the UI

### Components Are Code
- A component does one thing and is named for what it renders (`InvoiceRow`, not `Item`). A component that needs `// --- section 2 ---` is two components.
- Prefer composition over configuration: many small components combined beats one component with fifteen props and branching render logic.
- Keep rendering and side effects separable — the command-query split (`coding-conventions.md`) applies to data-fetching vs. presentation.
- Don't mutate props or shared state in place; derive and return (`coding-conventions.md` immutability).

### Design System: Adopt, Emerge, then Formalize
Most projects start with **no** design system. Do not build one up front, and do not have AI invent one — that's speculative architecture (`architecture-conventions.md`) and a brand/product judgment call the conventions reserve for a human (`coding-conventions.md` — "What Not to Delegate to AI"). AI *implements* a system; it doesn't *invent* one. Instead, in priority order:

1. **Adopt, don't invent.** Reach for an established, accessible primitive or headless library (e.g. Radix, React Aria, shadcn/ui) plus a small set of design tokens. You inherit consistency and — critically — accessibility that's already been solved and tested.
2. **If you build your own, let it emerge — one component at a time.** Build each component when a real screen needs it; keep them in one place. Extract the *shared* pieces once 2–3 real usages exist, tokens first (color, spacing, type scale) — the same "extract on the third repetition" trigger as DRY (`coding-conventions.md` Tier 2).
3. **Accessibility applies immediately** — to hand-rolled components too. It does not wait for a design system.

**When it graduates into a named design system:** when the same components are reused across enough features that *drift* starts causing inconsistency — the maturity trigger (`coding-conventions.md` Tier 3). Consolidate tokens + components into a documented source of truth. **When a design system already exists,** use it — don't hand-roll a control it provides. The specific system is named in the company profile or the project's CLAUDE.md.

### Styling
- Styling *approach* (CSS Modules, Tailwind, CSS-in-JS) is a **preference** — pick one per project and stay consistent; don't mix three in one codebase.
- No magic values in styles. Colors, spacing, and type come from tokens/variables, never hardcoded hex or pixel literals scattered through components — the styling form of "constants at the boundary" (`coding-conventions.md`).

### Keep the Client Honest
- The server is the authority (`security-conventions.md`). The client renders and requests; it never decides permissions, prices, or what data a user may see. Never ship data to the client it isn't allowed to see and rely on the UI to hide it.
- Validate user input in the UI for fast feedback, but treat that as UX only — the server validates again (`security-conventions.md`).

---

## Part 2 — UX Principles

These apply whenever a tool has a front-facing interface, regardless of stack.

### Usability Heuristics (Nielsen)
The canonical checklist for evaluating any interface:

1. **Visibility of system status** — always show what's happening (loading, progress, saved/unsaved) with timely feedback.
2. **Match the real world** — speak the user's language and follow real-world conventions; no internal jargon.
3. **User control and freedom** — clearly marked exits, cancel, and undo/redo so users escape mistakes.
4. **Consistency and standards** — the same word/action/component means the same thing everywhere.
5. **Error prevention** — design out mistakes with constraints and good defaults, don't just message them after.
6. **Recognition over recall** — make options visible; don't force users to remember across screens.
7. **Flexibility and efficiency** — novices succeed by default; experts get accelerators (shortcuts, saved actions).
8. **Aesthetic and minimalist design** — show only what's relevant; every extra element dilutes the important ones.
9. **Help users recover from errors** — plain-language messages that state the problem and a concrete fix.
10. **Help and documentation** — prefer self-explanatory UI; when help is needed, make it searchable and task-focused.

### Design for the User's Mind
The evidence-based "laws" worth internalizing:

- **Jakob's Law** — users expect your app to work like the others they already use; honor established patterns before inventing new ones.
- **Hick's Law** — more choices means slower decisions; reduce and group options.
- **Fitts's Law** — make frequent/important targets large and close; keep destructive actions small, far, and separated from benign ones.
- **Miller's Law** — working memory holds ~7±2 items; chunk information instead of relying on recall.
- **Doherty Threshold** — responses under ~400ms keep users engaged; when you can't be that fast, show immediate feedback.
- **Aesthetic-Usability Effect** — polished interfaces are perceived as more usable and are forgiven minor flaws; visual quality is not optional decoration.
- **Peak-End Rule** — users judge an experience by its most intense moment and its ending; invest in success states and graceful endings.
- **Tesler's Law** — complexity is conserved; absorb irreducible complexity in the system rather than pushing it onto the user.
- **Postel's Law** — be liberal in what you accept (tolerate spaces, casing, formats), conservative in what you output.

Applied defaults: **reduce cognitive load** (remove elements, decisions, and steps that don't serve the task), **recognition over recall** (menus, autocomplete, recently-used, sensible defaults), and **progressive disclosure** (show essentials first; reveal advanced options on demand).

### Visual Hierarchy & Layout
- **Hierarchy** — rank every element by importance and express that rank through size, weight, color, contrast, and position, so the eye lands on the most important thing first.
- **Typography** — a small, consistent type scale; limit font families (usually one or two); body text large enough to read comfortably; generous line height and a readable line length (~50–75 characters).
- **Spacing on a scale** — use a consistent spacing scale (an 8px grid is the common default: ~16px padding inside components, ~24px between sections). Whitespace is a tool, not wasted space — it groups, separates, and reduces clutter.
- **Proximity and grouping (Gestalt)** — related elements sit close together; use spacing and shared regions to convey grouping rather than boxes and lines everywhere.
- **Color with restraint** — a limited, purposeful palette; semantic colors for status (success/warning/error) used consistently; roughly a 60/30/10 split of dominant/secondary/accent. Contrast requirements are set by `accessibility-conventions.md`.
- **Scannability** — people scan, they don't read; front-load key information, support F/Z-pattern scanning, and keep interfaces uncluttered (KISS applied to UI).

### Every Screen Has Multiple States
Design and build all of them — the states AI-generated UIs most often skip are exactly the ones users hit:

- **Loading** — never leave an action silent. Use **skeleton screens** (they set expectations and prevent layout shift) over generic spinners for content; but if a load would take under ~300ms, show nothing — a flashed spinner reads as a glitch.
- **Empty** — explain *why* it's empty and give the next action; treat the first-run empty state as onboarding, not a dead end.
- **Error** — never "An error occurred." State what went wrong in plain language and give a way forward (a Retry action, a fix). Design for partial failure, not just total success.
- **Success / populated** — confirm consequential actions; don't leave the user guessing whether it worked.
- **Partial / ideal** — design both the sparse real-world state and the full "ideal" state so the layout holds either way.

### Feedback & Perceived Performance
- **Immediate feedback** — every action gets a perceptible response within ~50–100ms (hover, press, loading indicator); silence reads as "broken."
- **Optimistic UI** — for frequent, low-risk actions (like, toggle, mark done), update the UI immediately and reconcile with the server after, rolling back only on failure.
- **Perceived performance** — under the Doherty Threshold, skeletons, optimistic updates, and progress indicators keep the app feeling fast even when the work is slow.
- **Purposeful motion** — animation should clarify (where did this come from, what changed), not decorate; keep durations short (~150–300ms) and always respect `prefers-reduced-motion` (`accessibility-conventions.md`).

### Error Prevention & Forgiveness
- **Prevent first** — constraints, input masks, disabled invalid actions, and good defaults so mistakes can't easily happen.
- **Guard destructive actions** — require confirmation, or better, offer an **Undo** window; never a lone unguarded delete. Prefer Undo-based flows over modal confirmations where feasible.
- **Separate dangerous from benign** — distance and visually differentiate destructive controls (Fitts's Law plus redundant cues: color, icon, label).
- **Don't lose the user's work** — preserve input on error, autosave where appropriate, prefer soft-delete and drafts. Non-destructive by default.

### Forms & Input
- **Single column** — measurably faster to complete than multi-column; aligns with vertical scanning and adapts to mobile.
- **Persistent, top-aligned labels** — never placeholder-as-label (it vanishes on input and breaks accessibility). Mark required vs. optional explicitly.
- **Inline validation, well-timed** — validate after a field is completed (on blur), not aggressively on every keystroke; put the error next to the field, in plain language that says how to fix it.
- **Minimize fields** — every field is friction; ask only for what you need now (YAGNI applied to forms). Group related fields; sensible defaults; one clear primary action.
- **Mobile input** — use the right input type so the correct keyboard appears; size touch targets per `accessibility-conventions.md`.
- **Forgiving input** — accept varied formats and normalize (Postel's Law) rather than rejecting.

### Content & UX Writing
- **Plain language** — the user's vocabulary, not system or internal jargon; concise and scannable, key info first.
- **Actionable labels** — buttons name the outcome (`Save changes`, `Delete invoice`), not generic `OK` / `Submit`.
- **Helpful microcopy** — error and empty-state copy tells the user what to do next; keep tone consistent across the product.

### Responsive & Performance
- **Mobile-first, fluid** — design for the small viewport first, then enhance; drive breakpoints by where the content breaks, not by specific device sizes; test across a real viewport range.
- **Performance is UX.** Meet Core Web Vitals "good" thresholds at the 75th percentile: **LCP ≤ 2.5s** (main content appears), **INP ≤ 200ms** (interaction responsiveness — the metric that replaced FID), **CLS ≤ 0.1** (no unexpected layout shift). Reserve space for async content so it doesn't jump.
- **Degrade gracefully** — assume slow networks and constrained devices; handle offline and partial-data states rather than breaking.

---

## By Collaboration Mode

The principles above are mode-independent — a solo project's UI is used by real people too. What flexes is only process rigor:

- **Solo / early:** build accessible, tokenized components with all their states as screens need them; let the design system emerge.
- **Collaborative / mature:** a shared, documented design system is the source of truth, and component, accessibility, and Core Web Vitals checks run in CI (`cicd-conventions.md`).
