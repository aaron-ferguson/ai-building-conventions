# Referencing These Conventions From a Project

This file shows how a project's own `CLAUDE.md` should wire in these conventions so the lean-loading design actually holds. Copy the template below into a new project's `CLAUDE.md` and fill in the project-specific parts.

---

## The one rule: import the core, link the rest

Claude Code treats the two kinds of reference differently:

- **`@path`** — the file's full contents are **inlined into every session**. Use this for exactly one conventions file: `CONVENTIONS_CORE.md`, the always-loaded summary.
- **A plain path in prose** (no `@`) — the file is **not** loaded; it's an instruction to read that file *when the task calls for it*. Use this for every other conventions file.

That distinction is the whole design. `@`-importing `CODING_CONVENTIONS.md`, `AI_PRODUCT_CONVENTIONS.md`, and the rest would pull hundreds of lines into every session — the context bloat the core-doc split exists to avoid. Import the core; link the detail.

If you find yourself wanting to `@`-import a second conventions file "so it's always there," that's the same speculative-loading mistake — the core already carries the essentials, and the full file's own header tells the agent when to load it.

---

## Template

Paste into a new project's `CLAUDE.md`, then edit the bracketed parts:

```markdown
# CLAUDE.md — [Project Name]

## Conventions
Always-loaded essentials (imported):
@[path-to]/ai-coding-conventions/CONVENTIONS_CORE.md

The core file lists every other conventions file and when to load it.
Read those on demand — do **not** import them here. Company constraints
(if any) live in the company profile referenced under Profile below.

## Profile
- collaboration: solo | collaborative     # see COLLABORATION_MODES.md
- company: none | [name]                   # if set, read the profile at:
  #   [path-to]/ai-coding-conventions/companies/[name]/[NAME]_PROFILE.md
  #   (gitignored — read on demand; do not import or copy its contents here)

## Critical invariants
[The 1–3 hard, always-relevant rules for THIS project — the ones an agent
must not violate even mid-task. For a company project, restate the safety-
critical constraints here in one line each (e.g. "No court/case/PII data
leaves the trust boundary; no external model calls on sensitive data") and
point to the company profile for the full detail. Carry the invariant; link
the detail.]

## Stack
[Language, framework, key libraries, how to run / test / deploy — or a
pointer to the README, per DOCUMENTATION_CONVENTIONS.md.]

## Overrides
[Any preference-level override of a general default — branching strategy,
commit format, etc. Principles cannot be overridden. See CONVENTIONS_CORE.md
→ "How overrides work". Most projects have none; delete this section if so.]
```

---

## Why each part is shaped this way

- **Only the core is imported.** Everything else is on-demand by design; the core's "Load for More Detail" list plus each file's own header trigger tells the agent when to pull one in.
- **The company profile is referenced by path, never imported or copied.** It's gitignored, so copying its contents into a tracked `CLAUDE.md` would leak company constraints into a file that might be shared — defeating the isolation. Read it on demand instead.
- **Critical invariants are restated inline, not left to a linked file.** A safety rule an agent could violate mid-task (before it thinks to read a linked file) belongs *in* `CLAUDE.md`. This is the `DOCUMENTATION_CONVENTIONS.md` rule — carry the invariant, link the detail — and it's the one deliberate exception to "link, don't inline."
- **Profile lines are declared, not inferred.** `collaboration` and `company` drive which rules and constraints apply; an agent shouldn't have to guess them.

---

## Verifying it's actually lean

After wiring a project, sanity-check that only the core is imported:

- Search the project `CLAUDE.md` for `@` references — there should be exactly one, ending in `CONVENTIONS_CORE.md`.
- No conventions file other than the core, and no company profile, should appear as an `@`-import or have its contents pasted in.
