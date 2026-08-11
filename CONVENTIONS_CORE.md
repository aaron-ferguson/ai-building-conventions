# Conventions — Core Reference

Essential rules for every session. No exceptions. Read the full files listed at the bottom when a task requires deeper guidance.

---

## Code

- Name things exactly what they are. Functions are verbs. Files are named for what they do.
- Each file does one thing. Each function does one thing.
- Validate inputs at the top. Throw descriptive errors. Never swallow failures silently.
- No magic numbers or strings — use a constants file. No clever one-liners.
- Use types: TypeScript over JavaScript; Python with full type hints.
- Max 2 levels of nesting. Extract early-return guards or named functions instead.
- YAGNI: only build what the current task requires. No speculative code.
- Comments explain why, not what. If you need to explain what, rename instead.
- Functions either return a value or cause a side effect — not both.
- Don't mutate inputs. Return new values.

## Testing

- TDD always: write the test first → confirm red → implement → confirm green → commit. No exceptions.
- Every bug fix starts with a failing test that reproduces it — red → fix → green. The test stays as a permanent guard.
- Run tests as part of the normal TDD cycle — after implementing, run the scoped suite automatically.
- Configure test output to be lean by default (summary + failures only). Add verbosity temporarily when troubleshooting, then revert.

## Git

- Atomic commits. Imperative mood, sentence case: `Add`, `Fix`, `Update`, `Remove`.
- Stage specific files. Never `git add .` or `git add -A`.
- Never push without explicit user approval.

## Security

- Secrets never appear in source, config, commits, or AI context. OS secret store + env vars only.
- All external input is validated server-side. The client is never the authority.
- LLM output is untrusted input — validate it like anything user-supplied.
- Nothing holds standing production access it doesn't currently need — including an AI session. MFA on every account that can reach production.

## Environments & Data

- Every project runs locally, isolated from production. Once anyone but you depends on it — or anyone but you changes it — changes are verified in a production-like staging environment before promotion (`environment-conventions.md`).
- Non-production environments never hold production data or production credentials. An AI session's default target is local.
- You can recreate the environment from the repo, and infrastructure changes go in the repo — not into a console (`infrastructure-conventions.md`).
- Data anyone would miss is backed up somewhere a single failure can't reach, and you have restored from it at least once. An untested backup is a belief.
- Schema changes are additive first: never change a schema and the code depending on it in one deploy. Production migrations are forward-only — plan the forward fix, not a rollback (`migration-conventions.md`).
- Production is broken right now? Stabilize before diagnosing, and open `incident-conventions.md`. During an incident an AI agent is **read-only** — diagnosis, proposal, and a timestamped record; a human executes.

## AI Workflow

- Review every AI-generated diff like a junior engineer's PR — read it before shipping.
- Don't delegate to AI: architectural decisions, security design, product judgment.

---

## Profiles & How Overrides Work

Every project declares two things in its CLAUDE.md:

```markdown
## Profile
- collaboration: solo | collaborative   # merge/review ceremony — see collaboration-modes.md
- company: none | <name>                # loads companies/<name>/ (gitignored) — see companies/_template.md
- release: pre-release | released       # whether anyone but you depends on it — see environment-conventions.md
```

`collaboration` and `company` are two independent axes. **Neither lowers the bar.** The standard for code quality, testing, security, privacy, and AI practice is the same on a solo weekend project as on a customer-facing one — building good habits is the whole point. `collaboration` flexes only the human process around merging and shipping. `company` *adds* constraints; it never subtracts.

`release` is not a third axis of rigor — it's a **trigger**, like the maturity triggers in `coding-conventions.md` Tier 3. It answers one question: does a staging environment have a job yet? Nothing else flexes on it. Absent or arguable → treat the project as `released` (`environment-conventions.md`).

Everything in these conventions is one of two kinds:

- **Principles** — justified by correctness or safety (TDD, fail-loudly, validate at the boundary, no secrets in the repo, use types, YAGNI, accessibility). **Non-negotiable.** No project or company overrides them; a company profile may only make them stricter.
- **Preferences** — justified by consistency, where reasonable choices differ and none is strictly better (git branching strategy, commit format, formatter config, package manager, API style). The general repo picks a **default** so you don't re-litigate it; it can be overridden.

Precedence for a preference (most-specific wins): **project CLAUDE.md > company profile > general default.** Principles sit above all of it. When a rule is an overridable preference, its file says so explicitly; assume everything else is a principle.

**How these conventions are calibrated.** The default written down is the thorough, more-protective one, and each file then says what a smaller project may deliberately drop. This direction is intentional: it's easier to scale a known-good practice down than to discover the missing half of one later, and a small project built to the full standard is how the habit gets built in the first place. Two rules follow from it:

- **Scaling down is a decision that gets written into the project's CLAUDE.md** — never a default, and never something that happens by drift or under time pressure.
- **Scaling down never touches a principle.** What flexes is ceremony and scope (how many environments, how formal the process, how much verification above the floor), not correctness or safety.

Where a file offers a ladder of options, the top rung is the target and the lower rungs are named scale-downs — not equal choices.

---

## Load for More Detail

Read these when the current task warrants it (all live alongside this file in `AI_CODING_CONVENTIONS/`):

**Profiles & axes**
- **Wiring a project into these conventions** (retrofit-first; import the core, link the rest) → `README.md`
- **Collaboration mode** (solo ↔ collaborative — what flexes, what doesn't) → `collaboration-modes.md`
- **Company profiles** (isolated, gitignored; constraints + house preferences) → `companies/_template.md`
- **Release stage** (when staging becomes required; how much verification to do) → `environment-conventions.md`

**Craft**
- **Coding rules + Review Checklist** → `coding-conventions.md`
- **Testing** (TDD cycle, isolation, what to test) → `testing-conventions.md`
- **Architecture** (modular monolith, vertical slices) → `architecture-conventions.md`
- **API design** (contracts, versioning, compatibility) → `api-conventions.md`
- **UI / frontend & UX** (components, design systems, usability heuristics, UI states, forms, perceived performance) → `ui-conventions.md`
- **Accessibility** (WCAG AA default, semantic UI, design-system reuse) → `accessibility-conventions.md`

**Safety & data**
- **Security** (secrets, trust boundaries, injection, AI-specific risks) → `security-conventions.md`
- **Data privacy** (classification, PII in logs, redaction before egress) → `data-privacy-conventions.md`
- **Dependencies** (when a package earns its place, lockfiles, supply chain) → `dependency-conventions.md`

**Ship & operate**
- **Environments** (local/staging/production, parity, per-env config, promotion path) → `environment-conventions.md`
- **Infrastructure** (defined in code, drift, state, provisioning, backups & restore drills) → `infrastructure-conventions.md`
- **Migrations** (expand/contract, forward-only, backfills, seed data) → `migration-conventions.md`
- **Incidents** (**load only during or right after one** — stabilize, decide, communicate, close out) → `incident-conventions.md`
- **Documentation** (README baseline, decision records, CLAUDE.md upkeep) → `documentation-conventions.md`
- **Git** (destructive commands, branch management) → `git-conventions.md`
- **CI/CD & code review** (checks, branch protection, PR process) → `cicd-conventions.md`
- **Deployment** (topology, rollback, production readiness) → `deployment-conventions.md`
- **Observability** (structured logs, error tracking, metrics) → `observability-conventions.md`

**AI & tooling**
- **Building AI features** (evals, grounding, redaction, guardrails, human-in-loop, cost) → `ai-product-conventions.md`
- **MCP setup** (token security, secret-store pattern) → `mcp-conventions.md`
- **Model config** (alias mapping, settings precedence) → `claude-code-model-config.md`
