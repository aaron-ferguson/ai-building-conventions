# AI Coding Conventions

A single, versioned home for the engineering principles I hold across every project — so current and future projects inherit the same standard instead of re-deriving it each time. The goal is good habits everywhere: the bar is the same on a solo weekend project as on a court-facing one.

Projects don't copy these rules. They **link** to them, so a change here propagates everywhere without touching a single project.

---

## How it's organized

- **`CONVENTIONS_CORE.md`** is the always-loaded summary — the essential rules plus an index of every other file and when to load it. Everything else loads **on demand**, only when a task actually touches that area. This keeps session context lean; see each file's header for its trigger.
- **Two independent axes**, both declared per project (neither lowers the bar):
  - **Collaboration mode** (`COLLABORATION_MODES.md`) — `solo` ↔ `collaborative`. Flexes only the merge/review/CI ceremony.
  - **Company** (`companies/<name>/`, gitignored) — adds a company's constraints and house preferences. Isolated so the general conventions stay shareable and no company can see another's profile.
- **Principles vs. preferences** — principles (correctness/safety) are non-negotiable; preferences (git strategy, commit format, API style) have a default here but can be overridden. Precedence: project CLAUDE.md > company profile > general default. Full detail in `CONVENTIONS_CORE.md` → "How overrides work".

---

## Wiring a project into these conventions

Works the same whether the project already has a `CLAUDE.md` or none — you're **adding two sections** (plus, for company projects, a third), not scaffolding from scratch.

### 1. Add the Conventions import

If the project has no `CLAUDE.md`, create one. Add this near the top — it is the **only** convention file you import; everything else loads on demand via the core's index:

```markdown
## Conventions
@[path-to]/ai-coding-conventions/CONVENTIONS_CORE.md

The core file indexes every other conventions file and when to load it.
Read those on demand — do not import them here.
```

`@path` inlines a file into **every** session — use it for the core summary only. A plain path (no `@`) is an instruction to read a file *when the task calls for it*; that's how every other convention file, and any company profile, should be referenced.

### 2. Add the Profile block

```markdown
## Profile
- collaboration: solo | collaborative     # see COLLABORATION_MODES.md
- company: none | [name]                   # if set, read on demand:
  #   [path-to]/ai-coding-conventions/companies/[name]/[NAME]_PROFILE.md
```

Default `collaboration: solo` and `company: none` unless the project is otherwise. The company profile is **referenced by path, never imported or pasted** — it's gitignored, and copying it into a tracked `CLAUDE.md` would leak company constraints into a file that might be shared.

### 3. (Company projects) Restate critical invariants inline

The one deliberate exception to "link, don't inline": a safety rule an agent could violate *before* it thinks to open a linked file belongs directly in `CLAUDE.md`. Restate the hard, always-relevant constraints in one line each and point to the profile for detail:

```markdown
## Critical invariants
- No court/case/PII data leaves the trust boundary; no external model calls
  on sensitive data. Full detail: companies/[name]/[NAME]_PROFILE.md.
```

Carry the invariant; link the detail (`DOCUMENTATION_CONVENTIONS.md`).

### 4. Verify it stayed lean

Search the project's `CLAUDE.md` for `@` — there should be **exactly one** import, ending in `CONVENTIONS_CORE.md`. No other convention file, and no company profile, should be imported or pasted in.

---

## Keeping projects up to date

This is the payoff of linking instead of inlining: **most convention changes need no project update at all.** Edit a rule here and every linked project picks it up on its next session — there's nothing to sync.

You only touch a project's `CLAUDE.md` when something *about that project* changes:

- Its collaboration mode or company changes → update the Profile block.
- A new project-specific override or critical invariant appears → update those sections.
- The path to this conventions directory moves → update the one `@import`.

If you ever find a convention's substance copied into a project's `CLAUDE.md`, that's drift — replace the copy with a link so it can't fall out of date.

---

## Working on the conventions themselves

- `companies/` is **gitignored** — company profiles never enter this repo's history, so it can be shared (consulting, handoff, a future employer) without leaking anyone's constraints. Onboard a company by copying `companies/_TEMPLATE.md`.
- Keep general files **company-agnostic** — no company name, product, or tooling in a tracked file. Company specifics live only in that company's profile.
- When adding a rule, decide if it's a **principle** (non-negotiable) or a **preference** (has a default, overridable) and, if a preference, say so in the file. Assume principle unless tagged otherwise.
