# Progressive Delivery Conventions

This file defines how a change reaches users once it reaches production. It is loaded into AI context when a task adds a user-facing behavior change to a released project, introduces or removes a flag, or plans a rollout.

The principle is **bound the blast radius of a release**. Flags, cohort rollouts, and kill switches are mechanisms for it — not the goal, and not interchangeable with each other.

## How this relates to staging

There's an argument that staging is pointless — it drifts, its data is synthetic, it never sees real traffic — so you should ship behind a flag and validate against production instead. That argument is half right, and the half that's wrong matters:

- **Staging answers:** does this work at all, somewhere production-like, before anyone is exposed?
- **Progressive delivery answers:** does this work at production scale, with real data and real users — and can I bound who gets hurt if not?

Staging *structurally cannot* answer the second, and never will: `environment-conventions.md` requires synthetic data in non-production, so staging is permanently blind to real-data and real-scale failures. Progressive delivery cannot replace the first, because the first exposure still lands on a real person.

So the honest conclusion is **staging is necessary but not sufficient.** This file adds a layer; it removes nothing. And note the limit of what a flag buys you: a flagged-off feature still ships its code into the same process, so a memory leak or a resource hog degrades everyone regardless of the flag's state. **A flag bounds behavioral exposure, not operational exposure.**

---

## Deploy Is Not Release

The distinction the whole file rests on:

- **Deploying** puts code in production. Covered by `deployment-conventions.md` and `environment-conventions.md`.
- **Releasing** exposes that code's behavior to users. That's this file.

Separating them is what makes a rollout gradual, a rollback instant, and a mitigation possible without waiting on a build. Collapsing them means every release decision is also a deploy decision, and the only rollback you have is the slowest one available.

## What Is and Isn't in Scope

Only two kinds of toggle are conventions here, because they have opposite lifecycles:

- **Release flags** — short-lived, deleted after rollout. Below.
- **Kill switches** — long-lived on purpose. Below.

Three things that get called flags and are governed elsewhere:

- **Entitlements and permissions** — which customer, plan, or role may use something. **This is authorization, not delivery.** It's enforced server-side, default deny, and it never lives in a flag system (`security-conventions.md`).
- **Per-environment configuration** — injected per environment, never branched on in code (`environment-conventions.md`).
- **A/B experiments** — measurement rather than delivery, and out of scope. If a project needs them later, they get their own conventions; don't smuggle them in as release flags, because their lifecycle is "runs until statistically conclusive," not "deleted after rollout."

---

## Release Flags

**Default for every `released` project:** a user-facing behavior change ships dark and is exposed progressively.

**What gets a release flag:** any change to what users see or experience, where a bad version of it would be worse than the current state.

**What doesn't**, and forcing one on is a mistake:

- **Bug fixes.** A flag delays relief to the people currently affected. Fix it and ship it; the regression test is the safety net (`testing-conventions.md`).
- **Changes with no user-facing cohort** — background jobs, build configuration, internal refactors, dependency bumps.
- **Anything on a `pre-release` project.** There is no subset of users to roll out to, so a flag is branch-count with no benefit. Flags arrive with the `release: released` switch, like staging (`environment-conventions.md`).

### Name flags for the feature, and never invert them

- **Name a flag after what it enables, positively** — `new-meeting-ui`, never `disable-old-meeting-ui`. A negated name produces `disable-x: false`, and a double negative gets misread under exactly the conditions where the mistake costs most.
- **Off is always the current, known-good path; on is the new behavior.** One rule makes the safe default, the value served when the flag store is unreachable, and an absent flag key all mean the same thing.
- Kill switches take the same polarity: the flag names the feature, and off stops it.

### A release flag has an owner and an expiry date the moment it's created

This is the non-negotiable part, because the failure mode is guaranteed otherwise: the flag nobody dares remove because nobody remembers what it gates.

- **Owner and expiry recorded at creation**, not "we'll clean it up later." No exceptions for urgent work — urgent work is where this discipline is most needed.
- **The change is not done when the flag is on. It's done when the flag is gone.** Full exposure is the second-to-last step; deleting the flag, the old code path, and the flag's tests is the last one, and it's part of the same piece of work — not a follow-up ticket that will be deprioritized forever.
- **An expired flag is a defect, and a test enforces it.** Past its date and still present means the rollout stalled or the cleanup was skipped. Make the expiry a gate rather than a note: a test that fails once a flag is past its date turns cleanup from something you remember into something you cannot skip. Extending a date then becomes a deliberate, visible act.
- **Removing a flag means removing the old path too.** A flag deleted while both branches remain has moved the mess, not cleaned it.

### They compose with expand/contract

A release flag is the natural companion to a schema change: `migration-conventions.md` requires the code to handle both shapes while both exist, and the flag is what decides which shape a given request uses. Sequence them together — expand the schema, deploy dark, roll the flag forward, then contract the schema *and* remove the flag. Don't put the migration itself behind a flag; migrations have their own sequence.

---

## Kill Switches

A kill switch turns a feature off in production **without a deploy**. It is long-lived on purpose, and it exists because a deploy takes minutes and some failures do damage every second.

### Assess the blast radius before shipping, not after

For any change a released project is about to expose, answer three questions. This belongs in the pre-production process, alongside the review checklist:

1. **What's the worst thing this can do if it's wrong?**
2. **How fast does that damage accumulate?**
3. **Can I stop it without a deploy?**

If the answer to 2 is "continuously" and to 3 is "no," the change needs a kill switch before it ships. Record the assessment's outcome, not just the conclusion — the next person needs to know what you decided was fine.

### What warrants one

- **Anything that writes data.** A bad write path corrupts continuously for the entire duration of a deploy, and the damage may outlast the fix (`infrastructure-conventions.md` — restore is the recovery, and it's expensive).
- **Anything sending outbound communication** — email, SMS, push, webhooks to a customer's system. You cannot un-send. This is the strongest case on the list.
- **Anything calling a metered or paid external service**, including a model provider. Runaway cost is a real incident.
- **Anything with identified performance or resource risk** — a new query pattern, an unbounded fan-out, a synchronous call in a hot path.
- **Anything on a critical path where degradation beats failure** — if the feature can be off and the product still works, that's a switch worth having.

### How it has to work

- **Reachable without a deploy, and reachable during an incident.** A kill switch behind a pipeline run is not a kill switch. It's the fastest entry in the `incident-conventions.md` decision tree, which only holds if flipping it takes seconds.
- **The off state is the tested, known-good path.** Turning the switch off must land users somewhere that already worked, not in an untested fallback written for the purpose.
- **It survives the flag system being down.** If the flag store is unreachable, evaluation returns the safe default rather than throwing into the user path. Log that lookup failure loudly — `coding-conventions.md` says never swallow a failure, and this is the narrow case where you serve the safe default *and* make the failure visible, rather than failing the request.
- **Kill switches are exempt from expiry.** Unlike release flags, they're meant to stay. But they're reviewed periodically, and a switch guarding code that no longer exists gets removed like any other dead code.

---

## Rolling Out

Expose in widening rings, and don't advance on a timer:

1. **Internal only** — you and the team.
2. **A small real cohort** — a percentage, or opted-in users, or a single friendly customer.
3. **Progressive widening**, pausing at each step long enough for problems to actually surface.
4. **Everyone**, then remove the flag.

Two requirements make this real rather than theatre:

- **You can observe the cohort separately.** Errors, latency, and the feature's own success metric, sliced by flag state. Without that, a canary is just a slower deploy with extra steps — you'd notice the same failures at the same time either way. See `observability-conventions.md`.
- **Cohort assignment is sticky.** A user must get the same variant on every request. Flapping between old and new behavior is worse for that user than either version, and it makes any signal you collect meaningless.

Advance when the current ring looks healthy on the signals you named *before* starting, not when a day has passed. Define the roll-back-immediately condition up front too — the point of a small ring is a cheap decision to abandon.

### Pick the cohort unit to match how users actually work

A percentage of individual users is the default only for products where users are independent. Where people **collaborate on the same records** — a team, an office, an organization, a shared case or account — the cohort unit is that whole group, not a slice through it. Colleagues seeing different behavior on the same shared item is worse than no rollout at all: it produces confusion neither version would have caused, and it makes the signal you're collecting uninterpretable.

### When contracts govern who may receive a change early

For products sold under contract, a customer's agreement may require notification — or a notice period — before their users see a behavior change. Terms differ per customer, so there is no single policy to apply. Two rules follow:

- **Default to notification being required.** Ship on the assumption that a customer must be told, and treat an unchecked contract as one that requires it. Same posture as any unconfirmed obligation (`data-privacy-conventions.md` — contract terms are frequently the tightest constraint of all).
- **Early-ring eligibility is an explicit allowlist of customers confirmed exempt** — never an exclusion list, and never inferred from a customer being small, new, or friendly. Absence from the list means not eligible. The determination comes from the contract via whoever owns contracts, carries the date it was verified, and expires at renewal, since an amendment can add a clause. Record the list in the company profile (`companies/<name>/`).

If that allowlist is empty, the honest consequence is that there is no external early ring: the first real-user exposure is a notified customer, and the internal ring carries more weight. That's a planning constraint to surface early, not a rule to route around under deadline pressure.

## Flipping a Flag Is a Production Change

A flag flip changes production behavior with no code review, no CI, and no promotion path. That's a hole in everything `deployment-conventions.md` and `environment-conventions.md` require, and it's closed with an asymmetry:

- **Turning something OFF is always permitted, immediately, by anyone who can reach the switch.** No approval, no gate. This is the mitigation path and nothing may slow it down. It is always logged.
- **Turning something ON for users IS a release**, and takes the release gate: a deliberate decision by someone authorized, recorded the same way a deploy is (`git-conventions.md`, `deployment-conventions.md` — a release is never an accidental side effect).

Both directions:

- **Every flip is recorded** — what changed, who, when, and to which cohort. During an incident, flips go in the timeline like any other action (`incident-conventions.md`).
- **Flag state is part of "what's deployed."** When diagnosing, "what changed?" includes flag flips, not just commits. A system whose behavior you can't reconstruct from its recorded state is one you can't debug.
- **Production flag state is visible somewhere** — you should be able to answer "what is on right now, for whom?" without reading code.

## Flags Are Not Security Boundaries

- **Dark code still ships.** Its endpoints exist, its strings are in the bundle, its routes may respond. Anyone can flip a client-side flag in their own browser.
- **Evaluate server-side** for anything that matters. The client is a rendering surface, not a decision-maker (`security-conventions.md`).
- **Never gate access to data or privileged actions with a flag.** That's authorization: server-enforced, default deny, checked on every request. A flag controls *whether a behavior is live*; authorization controls *who may invoke it*. Conflating them produces an access control anyone can bypass.

## Keep the Branch Count Down

Every live flag is a branch in production. *n* flags means 2ⁿ reachable states and you have tested a handful. This is the cost that makes flags worth rationing, and it's the same instinct as YAGNI and the nesting limit in `coding-conventions.md`.

- **One flag, one decision point.** Check it once, at a boundary, and pass the result down. A flag consulted in six places is six things to remove and six chances to miss one.
- **Never nest flags.** Two flags whose combination has meaning is a design problem; collapse them into one decision.
- **Flags don't wrap business logic.** They select an implementation, or gate an entry point. A conditional threaded through a function's internals is the thing that never gets cleaned up.
- **Test both states.** The flag's on-path and its off-path each get coverage, and the off-path stays covered until the flag is deleted (`testing-conventions.md`). You are not obliged to test every *combination* of flags — but if a combination matters, that's the signal you have too many.

## By Project Scale

**Pre-release, solo:** none of this applies. There are no users to roll out to, so a flag is pure cost. What you keep is the habit of separating "deployed" from "released" mentally, so it isn't a new idea when it matters.

**Released, solo:** the floor, which is genuinely cheap — **you can turn a risky feature off without a deploy.** That may be one environment variable and one conditional; it does not require a flag platform. Plus the blast-radius assessment before shipping anything that writes data or sends communication, and release flags on user-facing changes with the owner-and-expiry discipline. A solo developer needs the kill switch *more* than a team does: there's nobody else to hold the pager while you build a fix.

**Collaborative:** add recorded flips with attribution, and flag ownership that survives the owner going on holiday — an unowned flag in a shared codebase is the canonical stale flag.

**Trigger for the full apparatus** (percentage cohorts, sticky assignment, per-cohort dashboards, automatic rollback, a flag management platform): real user scale, a change you genuinely cannot verify pre-production, or a user-visible change that's awkward to reverse. Adopt it when one of those is true — not before. This is the one area where more machinery can *reduce* safety, because flag debt is a real harm and an unused rollout platform is just more surface.

## Company & Project Overrides

Flag platform or library, naming conventions, who may flip a flag on in production, cohort definitions, and rollout policy for regulated features are company-specific (`companies/<name>/`) and may only tighten what's here.

**Preferences:** the tooling, the ring sizes, the naming scheme. **Principles:** off is always permitted and on is a release, flags are never security boundaries, the off path is the tested path, evaluation fails to the safe default, and every release flag has an owner and an expiry from the moment it exists.
