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
- Run tests as part of the normal TDD cycle — after implementing, run the scoped suite automatically.
- Configure test output to be lean by default (summary + failures only). Add verbosity temporarily when troubleshooting, then revert.

## Git

- Atomic commits. Imperative mood, sentence case: `Add`, `Fix`, `Update`, `Remove`.
- Stage specific files. Never `git add .` or `git add -A`.
- Never push without explicit user approval.

## Security

- Secrets never appear in source, config, commits, or AI context. Keychain + env vars only.
- All external input is validated server-side. The client is never the authority.
- LLM output is untrusted input — validate it like anything user-supplied.

## AI Workflow

- Review every AI-generated diff like a junior engineer's PR — read it before shipping.
- Don't delegate to AI: architectural decisions, security design, product judgment.

---

## Profiles & How Overrides Work

Every project declares two things in its CLAUDE.md:

```markdown
## Profile
- collaboration: solo | collaborative   # merge/review ceremony — see COLLABORATION_MODES.md
- company: none | <name>                # loads companies/<name>/ (gitignored) — see companies/_TEMPLATE.md
```

These are two independent axes. **Neither lowers the bar.** The standard for code quality, testing, security, privacy, and AI practice is the same on a solo weekend project as on a court-facing one — building good habits is the whole point. `collaboration` flexes only the human process around merging and shipping. `company` *adds* constraints; it never subtracts.

Everything in these conventions is one of two kinds:

- **Principles** — justified by correctness or safety (TDD, fail-loudly, validate at the boundary, no secrets in the repo, use types, YAGNI, accessibility). **Non-negotiable.** No project or company overrides them; a company profile may only make them stricter.
- **Preferences** — justified by consistency, where reasonable choices differ and none is strictly better (git branching strategy, commit format, formatter config, package manager, API style). The general repo picks a **default** so you don't re-litigate it; it can be overridden.

Precedence for a preference (most-specific wins): **project CLAUDE.md > company profile > general default.** Principles sit above all of it. When a rule is an overridable preference, its file says so explicitly; assume everything else is a principle.

---

## Load for More Detail

Read these when the current task warrants it (all live alongside this file in `AI_CODING_CONVENTIONS/`):

**Profiles & axes**
- **Wiring a project's CLAUDE.md** (import the core, link the rest) → `PROJECT_CLAUDE_TEMPLATE.md`
- **Collaboration mode** (solo ↔ collaborative — what flexes, what doesn't) → `COLLABORATION_MODES.md`
- **Company profiles** (isolated, gitignored; constraints + house preferences) → `companies/_TEMPLATE.md`

**Craft**
- **Coding rules + Review Checklist** → `CODING_CONVENTIONS.md`
- **Testing** (TDD cycle, isolation, what to test) → `TESTING_CONVENTIONS.md`
- **Architecture** (modular monolith, vertical slices) → `ARCHITECTURE_CONVENTIONS.md`
- **API design** (contracts, versioning, compatibility) → `API_CONVENTIONS.md`
- **Accessibility** (WCAG AA default, semantic UI, design-system reuse) → `ACCESSIBILITY_CONVENTIONS.md`

**Safety & data**
- **Security** (secrets, trust boundaries, injection, AI-specific risks) → `SECURITY_CONVENTIONS.md`
- **Data privacy** (classification, PII in logs, redaction before egress) → `DATA_PRIVACY_CONVENTIONS.md`
- **Dependencies** (when a package earns its place, lockfiles, supply chain) → `DEPENDENCY_CONVENTIONS.md`

**Ship & operate**
- **Documentation** (README baseline, decision records, CLAUDE.md upkeep) → `DOCUMENTATION_CONVENTIONS.md`
- **Git** (destructive commands, branch management) → `GIT_CONVENTIONS.md`
- **CI/CD & code review** (checks, branch protection, PR process) → `CICD_CONVENTIONS.md`
- **Deployment** (topology, rollback, production readiness) → `DEPLOYMENT_CONVENTIONS.md`
- **Observability** (structured logs, error tracking, metrics) → `OBSERVABILITY_CONVENTIONS.md`

**AI & tooling**
- **Building AI features** (evals, grounding, redaction, guardrails, human-in-loop, cost) → `AI_PRODUCT_CONVENTIONS.md`
- **MCP setup** (token security, Keychain pattern) → `MCP_CONVENTIONS.md`
- **Model config** (alias mapping, settings precedence) → `CLAUDE_CODE_MODEL_CONFIG.md`
