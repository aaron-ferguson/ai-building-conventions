# Programming Conventions

This file defines coding expectations for this project. Its Tier-1 essentials are summarized in `CONVENTIONS_CORE.md` (always loaded); load this full file when a change warrants the complete rules, the tier system, or the **Review Checklist** at the bottom — run that checklist before finalizing any change.

---

## Tier 1 — Always Apply

These rules have no exceptions. Apply them to every line written.

### Naming
- Name things exactly what they are. `createJiraBugFromDiscrepancy()` not `processItem()`.
- Functions are verbs: `fetchPage`, `buildAdfBlock`, `compareScreenshots`.
- Files are named for what they do: `login.js`, `compare.js`, `report.js`.
- No abbreviations unless universally understood (`url`, `id`, `api`).

### File & Directory Naming
Case carries a signal — don't spend it on everything.

- **Code, source, and documentation files, and all directories:** `lowercase-kebab-case` (`data-privacy-conventions.md`, `user-service/`), or the language's established idiom where one exists (`snake_case.py`, `PascalCase.tsx` components). Named for what they do.
- **Reserve `ALL_CAPS` for canonical entry-point files that must stand out** — `README.md`, `LICENSE`, `CONTRIBUTING.md`, and a repo's always-loaded index (in this repo, `CONVENTIONS_CORE.md`). Caps only signals "start here" if it's rare; if every file shouts, none stands out.
- Don't mix separators within a category. Pick kebab for docs/dirs and stay consistent — a repo with both `data-privacy.md` and `DATA_PRIVACY.md` reads as unmaintained.

### Single Responsibility
- Each file does one thing. If you find yourself writing `// --- Section 2 ---`, that's a second file.
- Each function does one thing. If it needs a comment to explain what it does, it should be a named function instead.

### Fail Loudly and Early
- Validate required inputs at the top of every script and function boundary.
- Throw descriptive errors — never silently return `null` or `undefined` on failure.
- Do not catch errors unless you are explicitly handling them. Let them propagate.

```js
// Good
assert(process.env.APP_USERNAME, 'APP_USERNAME env var is required');

// Bad
const user = process.env.APP_USERNAME || '';
```

### Explicit Over Implicit
- No magic numbers or magic strings — define them as named constants.
- No clever one-liners that require a second read to understand.
- Side effects must be obvious from the function name or clearly documented at the call site.

### Use Types
Prefer typed code in all new work. TypeScript over JavaScript; Python with full type hints.

- Types are the cheapest form of documentation — they make intent explicit without requiring runtime tracing.
- Untyped code hides what values can be and is a common source of silent bugs.
- If adding to an existing untyped codebase, type the module you are touching.

### Constants at the Boundary
- All shared identifiers (API field IDs, project keys, cloud IDs, base URLs) live in a single `constants.js` (or equivalent) imported everywhere.
- Never hardcode these values inline — even once.

### Shallow Nesting
- Max 2 levels of nesting inside a function. Extract early-return guards or named functions instead.
- Prefer flat over nested data structures when the shape is under your control.

### YAGNI — Don't Build for Hypothetical Requirements
- Only build what is needed for the current task.
- Do not add parameters, options, config flags, or code paths "in case we need it later."
- If a future requirement arrives, add it then — with full context. Speculative code is always wrong in ways you can't predict.

### Comments Explain Why, Not What
- Code should be self-documenting — if a comment is needed to explain *what* code does, rename or restructure instead.
- Comments are for *why* a decision was made: non-obvious tradeoffs, external constraints, known limitations.

```js
// Bad — explains what, which the code already says
// Loop through issues and build ticket objects
const tickets = issues.map(buildTicket);

// Good — explains why
// Jira rejects ADF with trailing newlines; strip before sending
const body = content.trimEnd();
```

### Command-Query Separation
- A function either **returns a value** or **causes a side effect** — not both.
- Fetching data: returns a value, causes no side effects.
- Saving/sending/mutating: causes a side effect, returns nothing meaningful (or a success/error signal only).
- Mixing both in one function makes behavior unpredictable and hard to test.

```js
// Bad — fetches AND saves, unclear what the return value means
async function fetchAndSaveIssues() { ... }

// Good — separated
const issues = await fetchIssues();
await saveIssues(issues);
```

### Immutability Preference
- Do not mutate inputs. If a function receives an object or array, return a new one instead of modifying it.
- Mutations that happen inside a function are invisible to the caller and a common source of silent bugs.

```js
// Bad — mutates the input
function addStatus(issue) {
  issue.status = 'open';
  return issue;
}

// Good — returns a new object
function addStatus(issue) {
  return { ...issue, status: 'open' };
}
```

---

## Tier 2 — Apply When Triggered

These are sound principles that create unnecessary complexity when applied too early. Each has a specific trigger condition. Do not apply them before the trigger is met.

### DRY — Extract when you hit the third repetition
**Trigger:** The same logic appears in 3 or more places, and the logic is stable (not still changing).
- Before the third instance: duplication is acceptable.
- At the third instance: extract a named function or module.
- Do not DRY things that are still evolving — premature abstraction is worse than duplication.

### Deep Modules — Wrap when the interface stabilizes
**Trigger:** A module has been in use across 2+ callers and its internal implementation has changed at least once.
- At that point, define a clean public interface and hide the internals.
- A deep module has a simple entry point and complex internals — not a shallow wrapper over complexity.

### Shared Utilities — Extract when copied across files
**Trigger:** A helper function has been copied (not just written once) into a second file.
- At that point, move it to a shared `utils.js` or domain-specific utility module.
- Do not create utility files speculatively.

### Interface Abstraction — Generalize when you have two implementations
**Trigger:** You are writing a second implementation of something that already exists.
- At that point, define a shared interface or base pattern both implementations follow.
- Do not abstract for a hypothetical second implementation that doesn't exist yet.

### Dependency Injection — Pass dependencies in when testing gets painful
**Trigger:** A function has 2+ external dependencies (API clients, file system, browser) and is difficult to test without running the real thing.
- At that point, accept dependencies as parameters instead of instantiating them inside the function.
- This makes the function testable by passing in a mock, and makes its dependencies explicit to the caller.

```js
// Bad — hardcoded dependency, untestable in isolation
async function fetchIssues() {
  const client = new JiraClient(process.env.TOKEN);
  return client.get('/issues');
}

// Good — dependency injected, testable with a mock
async function fetchIssues(client) {
  return client.get('/issues');
}
```

---

## Tier 3 — Revisit When the Codebase Matures

The practices a maturing project needs each have a fuller home elsewhere in these conventions — added since this tier was first written. Tier 3's job is the **trigger**: notice when a project has crossed into needing them, then go apply the real convention. Don't re-define those practices here; this is a signpost, not their home.

Flag for review when any is true:
- The codebase spans 10+ files with shared dependencies.
- A second person starts making regular changes — this is the `collaboration: collaborative` switch (see `collaboration-modes.md`).
- A bug escaped to production that a test would have caught.

When triggered, adopt the practices where they live:
- **CI-enforced tests and required checks** → `testing-conventions.md`, `cicd-conventions.md`.
- **PR + review gates before merge** → `cicd-conventions.md` (collaborative mode); the review criteria are the Review Checklist below.
- **Strict, documented module boundaries** (what each module exposes and hides) → `architecture-conventions.md`, `documentation-conventions.md`.
- **Observability before real users** (error tracking, logs, metrics) → `observability-conventions.md`, `deployment-conventions.md`.

---

## Review Checklist

Run this before finalizing any change — new code, edit, or refactor.

```
NAMING
  [ ] Functions and files are named for exactly what they do
  [ ] No ambiguous names, no single-letter variables outside loops

RESPONSIBILITY
  [ ] Each function does one thing
  [ ] Each file has one clear purpose

SAFETY
  [ ] Required inputs are validated at the top
  [ ] Errors are thrown, not silently swallowed
  [ ] No hardcoded strings or magic numbers (use constants.js)

SECURITY
  [ ] No secrets in the diff — not even "temporarily"
  [ ] External input validated server-side, not just in the UI
  [ ] Change touches auth/credentials/data visibility? → run security-conventions.md security pass

PRIVACY & DATA
  [ ] No PII/secrets in logs, traces, or analytics (identifiers, not contents)
  [ ] New sensitive data, new egress destination, or data sent to a model? → run data-privacy-conventions.md pass

USER-FACING UI
  [ ] Semantic, keyboard-operable, AA contrast, uses the design system → see accessibility-conventions.md

COMPLEXITY
  [ ] Nesting is 2 levels or fewer inside functions
  [ ] No clever code that requires a second read
  [ ] No speculative code — only what the current task requires (YAGNI)

SIDE EFFECTS
  [ ] Functions either return a value or cause a side effect — not both
  [ ] Inputs are not mutated — new values are returned instead

COMMENTS
  [ ] Comments explain why, not what
  [ ] If a comment explains what the code does, rename or restructure instead

TESTING
  [ ] Tests written before implementation — see testing-conventions.md

TIER 2 TRIGGERS — check before adding abstraction
  [ ] DRY extraction: is this the 3rd+ instance of this logic?
  [ ] Utility extraction: was this actually copied from another file?
  [ ] Interface abstraction: does a second implementation actually exist?
  [ ] Dependency injection: does this function have 2+ external deps that make it untestable?

TIER 3 CHECK — is it time to level up?
  [ ] Are we at 10+ files with shared dependencies?
  [ ] Has a bug escaped that a test would have caught?
  [ ] Is more than one person making regular changes?
```

---

## Working with AI

AI coding tools (Claude Code, Copilot, Cursor) are the default development workflow. The conventions above already produce code that AI tools reason about well — explicit, typed, named, and flat. Two additional practices matter.

### Review AI Output Like a Junior Engineer's PR

AI-generated code is confident, fluent, and sometimes subtly wrong. Treat every AI-generated diff as a PR from a smart junior who may have missed a constraint.

- Does this match the intent, or just the letter of the instruction?
- Are there edge cases the AI didn't handle?
- Does this introduce any security vulnerabilities (injection, over-permissioning, exposed secrets)?
- Does this follow the conventions in this repo, or did the AI default to its own style?

Never ship AI-generated code without reading it. Test coverage is the primary defense against accumulated AI errors.

### What Not to Delegate to AI

- **Architectural decisions** — AI generates plausible architecture that fits common patterns, not your specific constraints.
- **Security-sensitive design** — always review auth flows, credential handling, and access control yourself.
- **Judgment calls about what to build** — that is product thinking, not code generation.

Use AI for: implementation within a defined structure, boilerplate, refactoring to a known pattern, test generation for known behavior.

---

## What This File Is Not

- It is not a style guide — use a linter and formatter for that (ESLint + Prettier).
- It is not exhaustive — if a principle isn't here, default to KISS.
- It does not define testing standards — those are in `testing-conventions.md`.
- It is not permanent — update it when a Tier 2 trigger is consistently met across the project, or when a Tier 3 threshold is crossed.
