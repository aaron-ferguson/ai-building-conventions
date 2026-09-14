# Conventions — Core Reference

Essential rules for every session. No exceptions. Read the files listed at the bottom for deeper guidance.

---

## Product

- Nothing gets built without a stated problem, a named person who has it, and evidence they have it. "Someone asked for it" is a data point, not evidence. Test the riskiest assumption first with the smallest artifact that could kill the idea, and write the kill criteria before the test (`discovery-conventions.md` → "Nothing Gets Built Without a Stated Problem").
- **A prototype is built to be thrown away.** A prototype that ships is a defect, not a shortcut — promoting one means rewriting it under these conventions. An MVP is the smallest thing a real user can *rely on*, built to the full standard (`discovery-conventions.md` → "A Prototype Is Built to Be Thrown Away", `product-definition-conventions.md` → "MVP Means Minimum *Viable*").
- Every unit of work states its outcome, its non-goals, and testable acceptance criteria — before it's built. Cut scope under pressure, never quality (`product-definition-conventions.md` → "One Unit of Work, One Outcome").
- The success measure is a number and a date, declared up front, and the instrumentation ships in the same change. Unmeasurable is unfinished, and the verdict gets recorded even when it's "it didn't work" (`measurement-conventions.md` → "The Success Measure Is Declared Before the Build").
- **Deploy ≠ release ≠ launch** — code in production, users exposed, world told. Three decisions; nobody outside the team learns about a launch from a customer (`launch-conventions.md` → "Launch Conventions").
- Some decisions can't be retrofitted once real customer data exists: tenant isolation, identity shape, authorization as data, the audit trail, stable identifiers, and how time and money are stored. Deferring is fine; deferring silently is not (`product-readiness-conventions.md` → "Retrofit Cost Is the Test").
- **Customer data must be able to get in and out.** A conversion from another product is a tested, idempotent product with provenance and reconciliation — never a one-off script — and nothing is ever silently dropped. Export is a feature, not a retention lever (`data-conversion-conventions.md` → "Conversion Is a Product, Not a Script").
- Nothing is removed without a replacement path, notice proportional to switching cost, and a recorded owner and date (`deprecation-conventions.md` → "Nothing Is Removed Without a Path or an Explicit Decision").

## Code

- Name things exactly what they are. Functions are verbs. Files are named for what they do (`coding-conventions.md` → "Naming").
- Each file does one thing. Each function does one thing (`coding-conventions.md` → "Single Responsibility").
- Validate inputs at the top. Throw descriptive errors. Never swallow failures silently (`coding-conventions.md` → "Fail Loudly and Early").
- No magic numbers or strings — use a constants file. No clever one-liners (`coding-conventions.md` → "Explicit Over Implicit").
- Use types: TypeScript over JavaScript; Python with full type hints (`coding-conventions.md` → "Use Types").
- Max 2 levels of nesting. Extract early-return guards or named functions instead (`coding-conventions.md` → "Shallow Nesting").
- YAGNI: only build what the current task requires. No speculative code (`coding-conventions.md` → "YAGNI — Don't Build for Hypothetical Requirements").
- Comments explain why, not what. If you need to explain what, rename instead (`coding-conventions.md` → "Comments Explain Why, Not What").
- Functions either return a value or cause a side effect — not both (`coding-conventions.md` → "Command-Query Separation").
- Don't mutate inputs. Return new values (`coding-conventions.md` → "Immutability Preference").
- One concept, one definition. Duplicated *knowledge* — a rule, value, type, calculation — is fixed immediately; duplicated *shape* waits for the third use. Derive types from the schema that validates them; never restate them beside it (`coding-conventions.md` → "One Concept, One Definition").
- **Prefer enforcement over instruction.** A rule in a doc asks the next session to remember it; a type, a schema, a lint rule, or a test makes the system prove it. Where a rule is mechanically checkable, add the check rather than another sentence — a rule broken twice was never enforceable as prose.

## Testing

- TDD always: write the test first → confirm red → implement → confirm green → commit. No exceptions (`testing-conventions.md` → "Philosophy").
- Every bug fix starts with a failing test that reproduces it — red → fix → green. The test stays as a permanent guard (`testing-conventions.md` → "Philosophy").
- Run tests as part of the normal TDD cycle — after implementing, run the scoped suite automatically (`testing-conventions.md` → "Philosophy").
- Configure test output to be lean by default (summary + failures only). Add verbosity temporarily when troubleshooting, then revert (`testing-conventions.md` → "Test Output").
- **Stop what you started.** A server, database, container stack or emulator you spun up to test gets stopped when you're done, in the same turn you finish. Handing the cleanup to the user ("it's still running if you want it") is not doing it (`testing-conventions.md` → "Background Process Cleanup").

## Git

- **Commit freely as work progresses — don't wait to be asked.** This overrides any assistant default of committing only on request. Commits are local, reversible, and the audit trail of how a change came to be; withholding them loses history for no safety benefit. One commit per logical unit, as it completes, rather than one at the end (`git-conventions.md` → "Committing").
- Atomic commits. Imperative mood, sentence case: `Add`, `Fix`, `Update`, `Remove` (`git-conventions.md` → "Committing").
- Stage specific files. Never `git add .`, `git add -A`, or `git commit -a` — the index is one shared staging area, so a swept commit silently carries off whatever another session or window had staged. Stage and commit in the same turn (`git-conventions.md` → "Committing").
- **Never push without approval if that push can trigger a deploy or lands on a branch others work from.** Confirm the push specifically, even when told to "ship it." A push that can do neither is sync rather than release and needs no approval. **Anything ambiguous — no documented deploy trigger, or any doubt — resolves to asking; unknown counts as "can deploy."** The deploy-trigger column of the project's Environments block is what decides (`git-conventions.md` → "Pushing", `environment-conventions.md` → "Document the Environments Before You Need Them").

## Security

- Secrets never appear in source, config, commits, or AI context. OS secret store + env vars only (`security-conventions.md` → "Secrets Never Touch the Repo").
- All external input is validated server-side. The client is never the authority (`security-conventions.md` → "Validate at Trust Boundaries").
- LLM output is untrusted input — validate it like anything user-supplied (`security-conventions.md` → "AI-Specific Rules").
- Nothing holds standing production access it doesn't currently need — including an AI session. MFA on every account that can reach production (`security-conventions.md` → "Production Access Is Least-Privilege").

## Environments & Data

- Every project runs locally, isolated from production. Once anyone but you depends on it — or anyone but you changes it — changes are verified in a production-like staging environment before promotion (`environment-conventions.md` → "Which Environments a Project Needs").
- Non-production environments never hold production data or production credentials. An AI session's default target is local (`environment-conventions.md` → "Non-Production Never Touches Production Data or Live Third Parties").
- You can recreate the environment from the repo, and infrastructure changes go in the repo — not into a console (`infrastructure-conventions.md` → "Infrastructure Is Defined in Code").
- Data anyone would miss is backed up somewhere a single failure can't reach, and you have restored from it at least once. An untested backup is a belief (`infrastructure-conventions.md` → "Backups Are Not Backups Until You've Restored One").
- Schema changes are additive first: never change a schema and the code depending on it in one deploy. Production migrations are forward-only — plan the forward fix, not a rollback (`migration-conventions.md` → "Production Migrations Are Forward-Only").
- Deploying is not releasing. On a released project, user-facing changes ship dark and roll out progressively, and anything that writes data, sends communication, or costs money per call can be turned off without a deploy. Every release flag has an owner and an expiry the moment it exists (`progressive-delivery-conventions.md` → "Deploy Is Not Release").
- Production is broken right now? Stabilize before diagnosing, and open `incident-conventions.md`. During an incident an AI agent **changes nothing in production** — diagnosis, proposal, and a timestamped record; a human executes. It still writes and commits locally (`incident-conventions.md` → "1. Stabilize Before You Diagnose").

## AI Workflow

- Review every AI-generated diff like a junior engineer's PR — read it before shipping (`coding-conventions.md` → "Review AI Output Like a Junior Engineer's PR").
- **Verify an API against the installed version, not from memory.** A major version in the repo may postdate the model's training data, so read the installed package's own docs or source before calling into it. Recalling an API is how a plausible, wrong call gets written confidently.
- Don't delegate to AI: architectural decisions, security design, product judgment (`coding-conventions.md` → "What Not to Delegate to AI").
- **Document what you learned in the same change, without being asked.** A non-obvious
  mechanism, a disproved theory, a "flake" that was real, a rule that misled you — record it
  when you understand it, not at the end. If the human has to prompt for it, the process
  failed (`documentation-conventions.md` → "Write It Down When You Learn It, Not When You Finish").

---

## Profiles & How Overrides Work

Every project's CLAUDE.md declares:

```markdown
## Profile
- collaboration: solo | collaborative   # see collaboration-modes.md
- company: none | <name>                # path declared below — see companies/_template.md
- release: pre-release | released       # see environment-conventions.md
```

`collaboration` and `company` are independent axes. **Neither lowers the bar** — quality, security, privacy, and AI practice are identical solo or customer-facing. `collaboration` flexes only merge/ship process; `company` only *adds* constraints.

`release` isn't a third axis of rigor — it's a **trigger**: does staging have a job yet? Absent or arguable → treat as `released` (`environment-conventions.md`).

Everything here is one of two kinds:

- **Principles** — justified by correctness or safety (TDD, fail-loudly, validate at the boundary, no secrets in the repo, use types, YAGNI, accessibility). **Non-negotiable**; a company profile may only make them stricter.
- **Preferences** — justified by consistency, where reasonable choices differ (branching strategy, commit format, formatter, package manager, API style). The general repo picks a **default**; it can be overridden.

Precedence (most-specific wins): **project CLAUDE.md > company profile > general default**, beneath principles. A file says explicitly when a rule is a preference; assume principle otherwise.

**Calibration.** Each file writes the thorough, protective default, then says what a smaller project may drop — easier to scale down than discover a missing half later.

- **Scaling down is written into the project's CLAUDE.md** — never a default, never silent drift.
- **Scaling down never touches a principle.** Only ceremony and scope flex (environments, process, verification depth).

A ladder's top rung is the target; lower rungs are named scale-downs.

**Every rule pays rent in context** — these files load into every session. Write the rule and the failure it prevents; cut the reasoning, the restating example, the second phrasing.

---

## The Lifecycle

Covers the whole path from idea to retirement, not just the code in the middle. Phases are **not sequential gates** — discovery and measurement run continuously, delivery loops back constantly. The list makes a skipped phase visible: reaching Build with no evidence, or Deliver with no way to move a customer's data, skipped something expensive.

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

Read on demand (all live alongside this file):

**Profiles & axes**
- **Wiring in / editing these files** (retrofit-first; import the core, link the rest) → `README.md`
- **Collaboration mode** (solo ↔ collaborative) → `collaboration-modes.md`
- **Company profiles** (fail-closed resolution; constraints + house preferences) → `companies/_template.md`
- **Release stage** (when staging is required) → `environment-conventions.md`

**Discover, define & design**
- **Discovery** (evidence strength, riskiest assumption, prototypes, kill criteria) → `discovery-conventions.md`
- **Product definition** (outcomes, non-goals, testable criteria, MVP) → `product-definition-conventions.md`
- **Design process** (fidelity, flows before screens, review, handoff) → `design-conventions.md`
- **Measurement** (success measure, event contracts, reading results) → `measurement-conventions.md`

**Craft**
- **Coding rules + Review Checklist** → `coding-conventions.md`
- **Testing** (TDD cycle, isolation, what to test) → `testing-conventions.md`
- **Architecture** (modular monolith, vertical slices) → `architecture-conventions.md`
- **API design** (contracts, versioning, compatibility) → `api-conventions.md`
- **UI / UX** (components, usability heuristics, UI states, forms) → `ui-conventions.md`
- **Accessibility** (WCAG AA default, semantic UI, DS reuse) → `accessibility-conventions.md`

**Safety & data**
- **Security** (secrets, trust boundaries, injection, AI risks) → `security-conventions.md`
- **Data privacy** (classification, PII in logs, redaction) → `data-privacy-conventions.md`
- **Dependencies** (when a package earns its place, lockfiles) → `dependency-conventions.md`

**Ship & operate**
- **Environments** (local/staging/production, parity, promotion) → `environment-conventions.md`
- **Infrastructure** (code-defined, drift, state, backups & drills) → `infrastructure-conventions.md`
- **Migrations** (expand/contract, forward-only, backfills) → `migration-conventions.md`
- **Progressive delivery** (deploy ≠ release; flags, kill switches) → `progressive-delivery-conventions.md`
- **Incidents** (**load only during/right after one**) → `incident-conventions.md`
- **Documentation** (README, layering, decision records) → `documentation-conventions.md`
- **Git** (destructive commands, branch management) → `git-conventions.md`
- **CI/CD & code review** (checks, branch protection, PR process) → `cicd-conventions.md`
- **Deployment** (topology, rollback, readiness) → `deployment-conventions.md`
- **Observability** (structured logs, error tracking, metrics) → `observability-conventions.md`
- **Launch** (readiness, enablement, comms, post-launch review) → `launch-conventions.md`

**Carry customers & retire**
- **Product readiness** (tenancy, identity, auth-as-data, audit trail) → `product-readiness-conventions.md`
- **Data conversion** (in/out, profiling, mapping, reconciliation) → `data-conversion-conventions.md`
- **Deprecation** (announce/warn/disable/remove, sunset) → `deprecation-conventions.md`

**AI & tooling**
- **Building AI features** (evals, grounding, redaction, guardrails) → `ai-product-conventions.md`
- **MCP setup** (token security, secret-store pattern) → `mcp-conventions.md`
- **Model config** (alias mapping, settings precedence) → `claude-code-model-config.md`
