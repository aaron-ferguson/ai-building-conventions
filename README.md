# AI Building Conventions

A single, versioned home for the principles and best practices held across every project — so current and future projects inherit the same standard instead of re-deriving it each time. The goal is good habits everywhere.

**Scope is the whole lifecycle**, not just the code: discovery and validation, definition, design, build, delivery and launch, operation, carrying customers over years, and eventual retirement. The phase map in `CONVENTIONS_CORE.md` is the index of that — it exists so a skipped phase is *visible*, since the expensive surprises (no evidence behind the build, no way to get a customer's data in or out, no audit trail to backfill) are all phases quietly skipped earlier.

Projects don't copy these rules. They **link** to them, so a change here propagates everywhere without touching a single project.

---

## How it's organized

- **`CONVENTIONS_CORE.md`** is the always-loaded summary — the essential rules plus an index of every other file and when to load it. Everything else loads **on demand**, only when a task actually touches that area. This keeps session context lean; see each file's header for its trigger.
- **Two independent axes**, both declared per project:
  - **Collaboration mode** (`collaboration-modes.md`) — `solo` ↔ `collaborative`. Flexes only the merge/review/CI ceremony.
  - **Company** (`companies/<name>/`, gitignored) — adds a company's constraints and house preferences. Isolated so the general conventions stay shareable and private information stays private.
- **One trigger**, also declared per project: **release stage** (`environment-conventions.md`) — `pre-release` ↔ `released`. Not an axis of rigor; it answers only whether a staging environment has a job yet.
- **Principles vs. preferences** — principles (correctness/safety) are non-negotiable; preferences (git strategy, commit format, API style) have a default here but can be overridden. Precedence: project CLAUDE.md > company profile > general default. Full detail in `CONVENTIONS_CORE.md` → "How overrides work".

---

## Wiring a project into these conventions

Works the same whether the project already has a `CLAUDE.md` or none — you're **adding two sections** (plus, for company projects, a third), not scaffolding from scratch.

### 1. Add the Conventions import

If the project has no `CLAUDE.md`, create one. Add this near the top — it is the **only** convention file you import; everything else loads on demand via the core's index:

```markdown
## Conventions
@[path-to]/ai-building-conventions/CONVENTIONS_CORE.md

The core file indexes every other conventions file and when to load it.
Read those on demand — do not import them here.
```

`@path` inlines a file into **every** session — use it for the core summary only. A plain path (no `@`) is an instruction to read a file *when the task calls for it*; that's how every other convention file, and any company profile, should be referenced.

### 2. Add the Profile block

```markdown
## Profile
- collaboration: solo | collaborative     # see collaboration-modes.md
- company: none | [name]                   # if set, read on demand:
  #   [path-to]/ai-building-conventions/companies/[name]/[name]-profile.md
- release: pre-release | released           # see environment-conventions.md
```

Default `collaboration: solo` and `company: none` unless the project is otherwise. Default `release: pre-release` **only** while you are the sole person who depends on the project — if anyone else uses it, it's `released`, and if that's arguable, it's `released`. The company profile is **referenced by path, never imported or pasted** — it's gitignored, and copying it into a tracked `CLAUDE.md` would leak company constraints into a file that might be shared.

### 3. (Company projects) Restate critical invariants inline

The one deliberate exception to "link, don't inline": a safety rule an agent could violate *before* it thinks to open a linked file belongs directly in `CLAUDE.md`. Restate the hard, always-relevant constraints in one line each and point to the profile for detail:

```markdown
## Critical invariants
- No PII or other private data leaves the trust boundary; no external model calls
  on sensitive data. Full detail: companies/[name]/[name]-profile.md.
```

Carry the invariant; link the detail (`documentation-conventions.md`).

### 4. Verify it stayed lean

Check the project's `CLAUDE.md` imports (`@` lines) that point into this conventions directory: there should be **exactly one**, ending in `CONVENTIONS_CORE.md`. No other convention file, and no company profile, should be imported or pasted in. Imports unrelated to these conventions (a monorepo package's own `CLAUDE.md`, other project docs) are fine — leave them alone; this check is only about convention imports.

---

## Keeping projects up to date

This is the payoff of linking instead of inlining: **most convention changes need no project update at all.** Edit a rule here and every linked project picks it up on its next session — there's nothing to sync.

You only touch a project's `CLAUDE.md` when something *about that project* changes:

- Its collaboration mode, company, or release stage changes → update the Profile block. (First public release is the common one: flip `release` and stand up staging.)
- Its environments change → update the Environments block (`environment-conventions.md`).
- A new project-specific override or critical invariant appears → update those sections.
- The path to this conventions directory moves → update the one `@import`.

If you ever find a convention's substance copied into a project's `CLAUDE.md`, that's drift — replace the copy with a link so it can't fall out of date.

---

## Working on the conventions themselves

- `companies/` is **gitignored** — company profiles never enter this repo's history, so it can be shared (consulting, handoff, a future employer) without leaking anyone's constraints. Onboard a company by copying `companies/_template.md`.
- Keep general files **company-agnostic** — no company name, product, or tooling in a tracked file. Company specifics live only in that company's profile.
- When adding a rule, decide if it's a **principle** (non-negotiable) or a **preference** (has a default, overridable) and, if a preference, say so in the file. Assume principle unless tagged otherwise.
- **Keep every file slim.** These load into sessions across all projects, so a rule earns its length (`CONVENTIONS_CORE.md` → "Every rule pays rent"). Write the rule and the failure it prevents, in the surrounding file's style — usually one bullet. Cut the justification, the worked example that restates the rule, and the paragraph re-explaining why it matters.
- **Prefer editing an existing rule to adding one.** A new lesson is usually a sharper version of a rule already there. A new bullet beside it says the same thing twice, and the two drift apart later.
- **Check the diff size before committing.** Lessons from one session growing a file by more than a few lines means the reasoning went in with the rule. Compress, then commit.
- **Put it in the narrowest file that covers it.** The core is loaded always; everything else loads on demand. A rule that only applies while editing this repo belongs here or in `CLAUDE.md`, not in the core.
