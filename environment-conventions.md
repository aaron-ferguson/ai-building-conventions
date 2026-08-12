# Environment Conventions

This file defines what environments a project is expected to have, when each becomes required, and how they stay honest. It is loaded into AI context when a task touches environment config, a deploy target, per-environment credentials, or the question "where do I verify this before users see it?"

Scope split: `testing-conventions.md` owns what the *test suite* is. `deployment-conventions.md` owns the *act* of deploying. This file owns the *places* code runs and the path a change takes between them.

The default ladder is **local → staging → production.** A change is written and tested locally, verified in a production-like environment, then promoted. Skipping a rung is a decision with a reason, not a default.

---

## The Three Environments

- **Local** — runs entirely on the developer's machine. Own database, own seed data, own credentials, no network path to production. Every project has this from the first commit; a project you can only run by deploying it has no local environment and needs one.
- **Staging** — a deployed environment that mirrors production closely enough that "it works here" predicts "it works there." Its job is to catch what local cannot: real infrastructure, real build output, real migrations, real integration wiring. It is internal-only.
- **Production** — where the tool is actually available to its users. It exists the moment anyone other than you depends on it.

## Which Environments a Project Needs

Local is always required. Production exists once you deploy. **Staging is the one that's conditional** — because staging's purpose is protecting users, and before there are users there is nothing to protect.

Staging becomes **required** when either is true:

- **The project is released** — real users depend on it, and breaking production costs someone other than you. This is true even for a solo project: a solo developer with public users needs staging exactly as much as a team does, because production breakage doesn't care how many developers there are.
- **More than one person changes the code** — any collaboration at all. Two people's changes interact in ways neither tested locally, and staging is where that interaction surfaces before users find it. This holds even pre-release.

| | Solo, pre-release | Solo, released | Collaborative (any stage) |
|---|---|---|---|
| **Local** | Required | Required | Required |
| **Staging** | Not required — don't build it yet | **Required** | **Required** |
| **Production** | Whenever you first deploy | Required | Required |
| **Verification floor** | Local suite green (rung 1 below) | Local suite + staging smoke of the changed path (rung 3) | CI green + staging smoke (rung 3), on every change |

**Declaring release stage.** Add it to the Profile block in the project's CLAUDE.md so the floor is knowable without opening anything:

```markdown
## Profile
- collaboration: solo | collaborative
- company: none | <name>
- release: pre-release | released      # released = someone other than you depends on it
```

This is a **trigger, not a third dimension of rigor** — it does not lower the bar for code, tests, security, or privacy, all of which are identical at every stage (`collaboration-modes.md`). It only answers whether staging has a job yet. If the line is absent or the answer is arguable, treat the project as `released` and build staging — the cost of an unnecessary staging environment is some setup time; the cost of a missing one is a user-visible outage.

**Promotion is deliberate and cheap**, like the solo → collaborative flip: stand up the environment, add it to the Environments block below, flip the line. Don't pre-build staging on a pre-release solo project "so it's ready" — that's YAGNI applied to infrastructure.

**Projects with nothing deployed** — a library, a CLI distributed as a package, a docs or configuration repo — have no environment ladder, and shouldn't invent one. Their relevant discipline is versioning and release (`deployment-conventions.md`) plus CI. A published package's consumers are its users, so its *release* discipline still tightens once anyone depends on it.

They still keep a short Environments block, reduced to one line: **nothing is deployed, and no branch triggers a deploy.** Don't skip it. That single recorded fact is what tells the push rule in `git-conventions.md` that pushes here are sync rather than release — omit it and every push becomes a question that resolves to "ask," which is the wrong answer for a repo that can't deploy anything. A block that says "none" is doing real work; an absent block is an unanswered question.

## Choosing How Much Verification to Do

The *floor* above is not negotiable. The *depth* above the floor is a deliberate project choice — pick a rung, write it down, and don't drift below it. Each rung costs more and catches more:

1. **Local suite green** — the TDD cycle (`testing-conventions.md`). Always.
2. **CI green on the branch** — same checks, run somewhere that can't be skipped (`cicd-conventions.md`).
3. **Staging smoke of the changed path** — deploy, then exercise the specific thing you changed plus the core action. Minutes, and it catches the whole class of bugs that only exist once the code is built, configured, and deployed.
4. **Full staging pass** — the E2E suite run against staging, migrations rehearsed on a production-shaped dataset (`migration-conventions.md`), and a look at logs and error tracking afterward.
5. **Release verification / UAT** — a human other than the author signs off on staging before promotion. Required where a company profile or contract says so.

Most released projects sit at rung 3 and step up to 4 for risky changes (schema migrations, auth, payment, anything in `deployment-conventions.md`'s "may not roll back" category). Record the chosen rung in the Environments block; if a change warrants more, say so and do more. **Choosing a rung is a decision to make once and revisit, not something to re-litigate per change** — and never a decision to quietly skip because a change "looks small."

### Rung 2+: verifying on production, immediately after deploying

There is a real gap between rungs 2 and 3, and a project with no staging lands in it. Naming it beats leaving those projects with nothing to aim at, because the alternative in practice is not "build staging" — it's verifying nothing.

**Rung 2+ is rung 2 plus an automated check that runs against production the moment a deploy lands.** It is genuinely weaker than rung 3: it catches the same failures *after* users could reach them rather than before. That is the whole of the trade, and it should be written down in those words rather than described as equivalent.

It is a legitimate choice only with all of these, and they are obligations, not suggestions:

- **The check is automated and specific** — asserts the deploy-time configuration and the code paths that only exist in production, not "the site loads." An eyeballed smoke test decays to nothing within a month.
- **Rollback is one action and known to work** — promoting the previous release, not a rebuild. Verifying after exposure is only defensible if exposure is quickly undone.
- **Deploys happen when the blast radius is smallest**, and someone is watching. "Production is the first real environment" is acceptable only when that is true by arrangement rather than by luck.
- **The unavoidable gaps are covered elsewhere** — migrations rehearsed against seeded data locally (`migration-conventions.md`), and real-condition failures caught by production observability (`observability-conventions.md`) rather than a pre-production environment.

**Revisit the moment the blast radius grows**: users you didn't personally invite, money changing hands, data you would mind leaking, or a deploy that has already broken something real. Any of those buys rung 3 its cost.

### What no environment below production can verify

Two categories survive every local and CI check, and they are the reason rung 2+ needs an automated production check rather than confidence:

- **Deploy-time platform configuration.** Headers, redirects, rewrites, caching, CSP — anything the hosting platform applies from a config file (`vercel.json`, `netlify.toml`, an ingress manifest, a CDN rule). If the local dev server doesn't apply them, *nothing local or in CI can*, and a broken CSP is indistinguishable from working code until it's live. A staging environment on the same platform verifies these properly, because it is the same mechanism reading the same file; that is one of the clearest things staging actually buys.
- **Code paths reachable only in production** — the branch selected by the production hostname, a credential only production holds, a feature gated on a production-only flag. These cannot be exercised anywhere else *by construction*, so they need a production check plus a design that fails loudly rather than silently (`coding-conventions.md`).

## Document the Environments Before You Need Them

The project's CLAUDE.md carries an Environments block — this is the topology `deployment-conventions.md` requires, in one place:

```markdown
## Environments

| Env | Where | Owned by | Data | Deploy trigger |
|-----|-------|----------|------|----------------|
| local | localhost:3000 | — | seeded synthetic | `npm run dev` |
| staging | staging.example.com | <account> | synthetic | merge to `main` |
| production | example.com | <account> | real | manual promote |

- Verification level: rung 3 (staging smoke of the changed path)
- Promotion path: local → staging → production. No direct-to-production deploys.
```

If you cannot fill in "owned by" for a row, stop and find out — two similarly named projects on different accounts is a real way to deploy to the wrong place (`deployment-conventions.md`).

**The deploy-trigger column is load-bearing beyond documentation.** It's what decides whether a given `git push` needs human approval: a push that can trigger a deploy is gated, one that can't is treated as sync (`git-conventions.md`). An undocumented trigger therefore doesn't just cost clarity — it forces every push to become a question, and defaults to the gated answer.

**Fill this block in from the platform, not from the existing docs.** Every row is a claim about the world, and a wrong one silently corrupts the push rule that depends on it — in both directions. Check the hosting account, the connected repository, the branch the deploy is wired to. Copying a line from a README that nobody has verified since it was written is how "auto-deploys on push to `main`" ends up describing a project that was never connected, or a project that now deploys from a different branch. If you cannot confirm a trigger, write down that it is unconfirmed rather than transcribing a guess — an unconfirmed trigger resolves to "gated," and a confidently wrong one does not.

## Parity: Make the Differences Intentional

Staging is only useful to the extent it resembles production. Environments always differ; the rule is that **every difference is a decision someone made on purpose and wrote down**, not drift nobody noticed.

- **Same versions** — runtime, database, and critical dependency versions match production. Staging on PostgreSQL 15 against production's 14 makes staging a source of both false passes and false failures.
- **Same backing services, smaller** — if production uses a queue, staging uses that queue, not an in-process stub. Scale down; don't substitute.
- **Same build path** — staging runs the same build command and the same artifact production will run, not a dev build. A change that only breaks in the production build is exactly what staging exists to catch.
- **Changes flow forward, never sideways into production only** — a config or infrastructure fix applied directly to production during an incident is drift the moment the incident ends. Reapply it to staging (and to whatever defines the infrastructure) before closing out. `infrastructure-conventions.md` is how parity becomes enforceable rather than aspirational: all environments come from one definition with different inputs.
- **Record the known differences** — smaller instances, no CDN, a stubbed payment provider. A documented difference is a caveat you can reason about; an undocumented one is a false sense of safety.

**Staging is necessary but not sufficient**, and it's worth being clear about the limit rather than pretending otherwise. Because non-production data is synthetic by rule (below), staging is permanently blind to real-data and real-scale failures — it can tell you a change *works*, never that it works *for your actual users at your actual volume*. That gap is closed by exposing changes progressively in production rather than by making staging more production-like (`progressive-delivery-conventions.md`). The two layers are complementary; neither replaces the other.

## Non-Production Never Touches Production Data or Live Third Parties

This is a hard line, and the most common way a "safe" environment causes real damage.

- **No production data in local or staging.** Use synthetic or anonymized data (`data-privacy-conventions.md`). A production dump on a developer laptop is a breach with a delay on it, and for regulated data it may be a reportable one regardless of intent.
- **No non-production process holds production credentials.** Local and staging get their own database, their own API keys, their own service accounts. A local `.env` that can reach the production database means one typo is a production incident.
- **Third-party integrations point at sandboxes.** Staging must not send real email or SMS, charge real cards, post to real webhooks, or write to a shared external system of record. Use the provider's test mode, and if it has none, stub it — and record that as a known difference above.
- **Seed data is a committed artifact.** A script or fixture set that produces a usefully-shaped dataset, in the repo, versioned with the schema — mechanics in `migration-conventions.md`. "Ask someone for a copy of their local database" is how production data ends up in non-production.
- **Production access is least-privilege, and an agent's session is not exempt** (`security-conventions.md`).

## Config and Secrets Are Per-Environment

- **Config comes from the environment, not from branches or build-time constants.** The same commit runs in all three; what differs is injected. Never `if (env === 'production')` around business logic — that's a code path production has never run in staging.
- **One secret per environment, never shared across them.** Rotating a staging key must not touch production, and a leaked staging key must not grant production access.
- **`.env.example` lists every variable each environment needs**, names only (`security-conventions.md`). A new environment that fails because someone forgot a variable is a documentation bug.
- **Scope deploy credentials to the environment they deploy.** Where the platform supports it, put production secrets behind an environment gate with an approval requirement — GitHub Environments, for example, will withhold environment secrets until a required reviewer approves the job, which makes "approval before production" a mechanism rather than a habit.
- **Namespace the variables the project reads, and reject a partial set.** Generic names — `DATABASE_URL`, `API_KEY`, `SUPABASE_ANON_KEY` — collide with whatever else the developer has exported for other tooling, editors, or another project in the same shell. Prefix them per project (`ACME_DATABASE_URL`) and, where several must agree, require all or none: a half-configured target is worse than an unconfigured one, because it silently points at something nobody chose. Fail with a message naming the variables rather than falling back.

## Promotion: The Same Commit Moves Forward

- **What ran in staging is what goes to production** — the same commit, ideally the same built artifact. Rebuilding for production, or promoting a different branch than the one you verified, discards the evidence staging gave you.
- **Never promote around staging.** A hotfix is the case where you most want to skip it and the case where skipping hurts most. If the fix is urgent, run the rung-3 smoke — it takes minutes.
- **Production deploys stay explicit and approved** (`deployment-conventions.md`, `git-conventions.md`). Staging may deploy automatically on merge; production does not.
- **One change per promotion where practical.** Five commits promoted together means five suspects.

## Make It Obvious Which Environment You're In

Acting on the wrong environment is a recurring, entirely preventable failure:

- Non-production UIs carry a visible, unmissable marker — a banner or color treatment naming the environment. Cheap, and it prevents demoing against production or "testing" a delete on real records.
- Terminal and CLI tooling names the target before doing anything destructive, and any command that touches production prompts for confirmation with the environment name in it.
- Distinguishable hostnames and database names. `app-db` and `app-db-2` is an incident waiting for a tired evening.

## An AI Agent's Default Environment Is Local

Agents run commands faster than you can read them, so the blast radius of a wrong target matters more, not less.

- **Local is the default target for anything an agent runs** — test suites, migrations, seed scripts, data fixes. An agent does not touch staging or production unless the task explicitly says so.
- **A session working on local does not have production credentials available to it.** Not in the environment, not in a file it can read. This is the practical form of "no non-production process holds production credentials" — the agent is one of those processes.
- **Production-affecting commands are proposed, not executed** — the agent names the environment and the command and waits, the same gate as pushing and deploying (`deployment-conventions.md`, `git-conventions.md`).
- **A destructive command with an ambiguous target is a stop, not a guess.** If it isn't obvious which environment a connection string, profile, or context points at, find out before running it.

## Persistent Staging or Ephemeral Per-Change Environments — a Preference

Both satisfy the requirement; pick by project shape and record the choice.

- **Persistent staging** — one long-lived production-mirror. Simple, always reachable, good for release verification and anything a stakeholder needs a stable URL for. Cost: it drifts, and it becomes contended once several people push to it at once.
- **Ephemeral preview environments** — one isolated deployment per branch or PR, destroyed when it merges. No contention, no drift, and the reviewer gets a URL alongside the diff. Cost: setup effort, and per-environment data seeding. If your platform gives these away (preview deploys on most modern hosts), take them.

They are not exclusive: previews answer "does this change work?", persistent staging answers "is the release ready?" A project with formal release verification or external sign-off usually wants both. **Ephemeral environments are torn down** — an orphaned preview is cost and an unmonitored attack surface (`infrastructure-conventions.md`).

Either option is only as easy as your provisioning is: if standing up an environment is a manual afternoon, previews aren't really available to you. That's an argument for `infrastructure-conventions.md`, not against previews.

## Company & Project Overrides

Environment count and naming (`dev`/`test`/`uat`/`pre-prod`), promotion gates, sign-off requirements, and hosting per environment are company-specific — they live in the company profile (`companies/<name>/`), where they may only tighten what's here. Project-specific deviations go in that project's CLAUDE.md and take precedence over the general defaults, never over the principles: local exists and is isolated, non-production never holds production data or credentials, and a released project's changes are verified somewhere production-like before users get them.
