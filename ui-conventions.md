# UI Conventions

This file defines conventions for building user-facing frontend — components, styling, and design systems. It is loaded into AI context when a task builds or changes UI.

Components are code, so the general rules apply first: `coding-conventions.md` (naming, single responsibility, shallow nesting, YAGNI, immutability) governs a component exactly as it governs a function. This file covers only what's specific to the frontend. Accessibility is a hard requirement throughout — see `accessibility-conventions.md`.

---

## Components Are Code

- A component does one thing and is named for what it renders (`InvoiceRow`, not `Item`). A component that needs `// --- section 2 ---` is two components.
- Prefer composition over configuration: many small components combined beats one component with fifteen props and branching render logic.
- Keep rendering and side effects separable — the command-query split (`coding-conventions.md`) applies to data-fetching vs. presentation.
- Don't mutate props or shared state in place; derive and return (`coding-conventions.md` immutability).

## Design System: Adopt, Emerge, then Formalize

Most projects start with **no** design system. Do not build one up front, and do not have AI invent one — that's speculative architecture (`architecture-conventions.md`) and a brand/product judgment call the conventions reserve for a human (`coding-conventions.md` — "What Not to Delegate to AI"). AI *implements* a system; it doesn't *invent* one. Instead, in priority order:

1. **Adopt, don't invent.** Reach for an established, accessible primitive or headless library (e.g. Radix, React Aria, shadcn/ui) plus a small set of design tokens. You inherit consistency and — critically — accessibility that's already been solved and tested, instead of re-solving focus management and ARIA yourself.

2. **If you build your own, let it emerge — one component at a time.** Build each component when a real screen needs it; keep them in one place. Extract the *shared* pieces once 2–3 real usages exist, tokens first (color, spacing, type scale) — the same "extract on the third repetition" trigger as DRY (`coding-conventions.md` Tier 2). The system crystallizes from real usage; you never spec it in advance.

3. **Accessibility applies immediately** — to hand-rolled components too. It does not wait for a design system (`accessibility-conventions.md`).

**When it graduates into a named design system:** when the same components are reused across enough features that *drift* starts causing inconsistency — the maturity trigger (`coding-conventions.md` Tier 3). At that point consolidate tokens + components into a documented system and treat it as the source of truth.

**When a design system already exists,** use it — don't hand-roll a control it already provides. The specific system is named in the company profile (`companies/<name>/`) or the project's own CLAUDE.md.

## Styling

- Styling *approach* (CSS Modules, Tailwind, CSS-in-JS) is a **preference** (`CONVENTIONS_CORE.md` → "How overrides work") — pick one per project and stay consistent; don't mix three in one codebase.
- No magic values in styles. Colors, spacing, and type come from tokens/variables, never hardcoded hex or pixel literals scattered through components — the styling form of "constants at the boundary" (`coding-conventions.md`).

## Keep the Client Honest

- The server is the authority (`security-conventions.md`). The client renders and requests; it never decides permissions, prices, or what data a user may see. Never ship data to the client it isn't allowed to see and rely on the UI to hide it.
- Validate user input in the UI for fast feedback, but treat that as UX only — the server validates again (`security-conventions.md`).

## By Collaboration Mode

The principles above are mode-independent. What flexes is only process rigor:

- **Solo / early:** build accessible, tokenized components as screens need them; let the system emerge.
- **Collaborative / mature:** a shared, documented design system becomes the source of truth, and component/accessibility checks run in CI (`cicd-conventions.md`).
