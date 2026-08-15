# Conventions — Core Reference

Essential rules for every session. No exceptions. Read the full files listed at the bottom when a task requires deeper guidance.

---

## Product

- Nothing gets built without a stated problem, a named person who has it, and evidence they have it. "Someone asked for it" is a data point, not evidence. Test the riskiest assumption first with the smallest artifact that could kill the idea, and write the kill criteria before the test (`discovery-conventions.md`).
- **A prototype is built to be thrown away.** A prototype that ships is a defect, not a shortcut — promoting one means rewriting it under these conventions. An MVP is the smallest thing a real user can *rely on*, built to the full standard (`discovery-conventions.md`, `product-definition-conventions.md`).
- Every unit of work states its outcome, its non-goals, and testable acceptance criteria — before it's built. Cut scope under pressure, never quality (`product-definition-conventions.md`).
- The success measure is a number and a date, declared up front, and the instrumentation ships in the same change. Unmeasurable is unfinished, and the verdict gets recorded even when it's "it didn't work" (`measurement-conventions.md`).
- **Deploy ≠ release ≠ launch** — code in production, users exposed, world told. Three decisions; nobody outside the team learns about a launch from a customer (`launch-conventions.md`).
- Some decisions can't be retrofitted once real customer data exists: tenant isolation, identity shape, authorization as data, the audit trail, stable identifiers, and how time and money are stored. Deferring is fine; deferring silently is not (`product-readiness-conventions.md`).
- **Customer data must be able to get in and out.** A conversion from another product is a tested, idempotent product with provenance and reconciliation — never a one-off script — and nothing is ever silently dropped. Export is a feature, not a retention lever (`data-conversion-conventions.md`).
- Nothing is removed without a replacement path, notice proportional to switching cost, and a recorded owner and date (`deprecation-conventions.md`).

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
- **Stop what you started.** A server, database, container stack or emulator you spun up to test gets stopped when you're done, in the same turn you finish. Handing the cleanup to the user ("it's still running if you want it") is not doing it (`testing-conventions.md`).

## Git

- **Commit freely as work progresses — don't wait to be asked.** This overrides any assistant default of committing only on request. Commits are local, reversible, and the audit trail of how a change came to be; withholding them loses history for no safety benefit. One commit per logical unit, as it completes, rather than one at the end.
- Atomic commits. Imperative mood, sentence case: `Add`, `Fix`, `Update`, `Remove`.
- Stage specific files. Never `git add .`, `git add -A`, or `git commit -a` — the index is one shared staging area, so a swept commit silently carries off whatever another session or window had staged. Stage and commit in the same turn (`git-conventions.md`).
- **Never push without approval if that push can trigger a deploy or lands on a branch others work from.** Confirm the push specifically, even when told to "ship it." A push that can do neither is sync rather than release and needs no approval. **Anything ambiguous — no documented deploy trigger, or any doubt — resolves to asking; unknown counts as "can deploy."** The deploy-trigger column of the project's Environments block is what decides (`git-conventions.md`, `environment-conventions.md`).

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
- Deploying is not releasing. On a released project, user-facing changes ship dark and roll out progressively, and anything that writes data, sends communication, or costs money per call can be turned off without a deploy. Every release flag has an owner and an expiry the moment it exists (`progressive-delivery-conventions.md`).
- Production is broken right now? Stabilize before diagnosing, and open `incident-conventions.md`. During an incident an AI agent **changes nothing in production** — diagnosis, proposal, and a timestamped record; a human executes. It still writes and commits locally.

## AI Workflow

- Review every AI-generated diff like a junior engineer's PR — read it before shipping.
- Don't delegate to AI: architectural decisions, security design, product judgment.
- **Document what you learned in the same change, without being asked.** A non-obvious
  mechanism, a disproved theory, a "flake" that was real, a rule that misled you — record it
  when you understand it, not at the end. If the human has to prompt for it, the process
  failed (`documentation-conventions.md`).

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

**Every rule pays rent in context.** These files load into sessions across every project, so length is a cost paid repeatedly and by all of them. Write the rule and the failure it prevents; cut the reasoning that convinced you, the worked example that restates the sentence above it, and the second phrasing of the same idea. If one session's lessons visibly grow a file, that is the signal to compress, not to keep.

---

## The Lifecycle

These conventions cover the whole path from idea to retirement, not just the code in the middle. The phases below are **not sequential gates** — discovery and measurement run continuously, and delivery work loops back constantly. What the list is for is making a skipped phase visible: work that reaches Build with no evidence behind it, or reaches Deliver with no way to get a customer's data in or out, has skipped something that gets expensive later rather than something that was optional.

| Phase | Question it answers | Files |
|---|---|---|
| **Discover** | Is this problem real, and worth solving? | `discovery-conventions.md` |
| **Define** | What exactly, and how will we know it worked? | `product-definition-conventions.md`, `measurement-conventions.md` |
| **Design** | What does it look like, in every state? | `design-conventions.md`, `ui-conventions.md`, `accessibility-conventions.md` |
| **Build** | Is it correct, safe, and maintainable? | `coding-conventions.md`, `testing-conventions.md`, `architecture-conventions.md`, `api-conventions.md` |
| **Deliver** | Can it be shipped, released, and announced safely? | `deployment-conventions.md`, `progressive-delivery-conventions.md`, `launch-conventions.md` |
| **Operate** | Is it healthy, and did it work? | `observability-conventions.md`, `measurement-conventions.md`, `incident-conventions.md` |
| **Carry** | Can it hold customers for years? | `product-readiness-conventions.md`, `data-conversion-conventions.md` |
| **Retire** | How do we take it away without breaking trust? | `deprecation-conventions.md` |

---

## Load for More Detail

Read these when the current task warrants it (all live alongside this file):

**Profiles & axes**
- **Wiring a project into these conventions**, and **editing these files themselves** (retrofit-first; import the core, link the rest; how to add a rule without bloating it) → `README.md`
- **Collaboration mode** (solo ↔ collaborative — what flexes, what doesn't) → `collaboration-modes.md`
- **Company profiles** (isolated, gitignored; constraints + house preferences) → `companies/_template.md`
- **Release stage** (when staging becomes required; how much verification to do) → `environment-conventions.md`

**Discover, define & design**
- **Discovery** (problem framing, evidence strength, riskiest assumption, prototypes, kill criteria) → `discovery-conventions.md`
- **Product definition** (outcomes, non-goals, testable criteria, vertical slices, what MVP means) → `product-definition-conventions.md`
- **Design process** (fidelity, flows before screens, review criteria, handoff, design QA) → `design-conventions.md`
- **Measurement** (success measure before build, event contracts, reading results, the recorded verdict) → `measurement-conventions.md`

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
- **Progressive delivery** (deploy ≠ release; release flags, kill switches, cohort rollout) → `progressive-delivery-conventions.md`
- **Incidents** (**load only during or right after one** — stabilize, decide, communicate, close out) → `incident-conventions.md`
- **Documentation** (README baseline, decision records, CLAUDE.md upkeep) → `documentation-conventions.md`
- **Git** (destructive commands, branch management) → `git-conventions.md`
- **CI/CD & code review** (checks, branch protection, PR process) → `cicd-conventions.md`
- **Deployment** (topology, rollback, production readiness) → `deployment-conventions.md`
- **Observability** (structured logs, error tracking, metrics) → `observability-conventions.md`
- **Launch** (readiness beyond deploy, enablement, comms, watching it land, post-launch review) → `launch-conventions.md`

**Carry customers & retire**
- **Product readiness** (tenancy, identity, authorization as data, audit trail, buyer artifacts) → `product-readiness-conventions.md`
- **Data conversion** (customer data in from another product and out again; profiling, mapping, reconciliation, cutover) → `data-conversion-conventions.md`
- **Deprecation** (notice, announce/warn/disable/remove, product sunset, returning their data) → `deprecation-conventions.md`

**AI & tooling**
- **Building AI features** (evals, grounding, redaction, guardrails, human-in-loop, cost) → `ai-product-conventions.md`
- **MCP setup** (token security, secret-store pattern) → `mcp-conventions.md`
- **Model config** (alias mapping, settings precedence) → `claude-code-model-config.md`
