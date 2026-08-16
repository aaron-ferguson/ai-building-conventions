# Deprecation Conventions

This file defines how something shipped is taken away — a field, an endpoint, a feature, an integration, or a whole product. It is loaded into AI context when a task removes or replaces user-facing behavior, plans a sunset, or decides what to do with a feature nobody uses.

**Everything you ship is a promise.** Deprecation is how a promise is withdrawn without breaking the trust that made it worth anything. Done well it's routine; done badly it's the thing customers remember about you longer than any feature.

The other half of this file is that **removal is normal and healthy**. Unused features are not free: they carry test surface, support burden, migration cost on every schema change, and a share of every future decision. A product that never removes anything is not being careful — it's accumulating a tax that eventually decides what it can build.

---

## Know Who Uses It Before You Decide

- **Instrument first, decide second** (`measurement-conventions.md`). Every deprecation begins as a question — who actually uses this, how often, and to do what — and the answer is regularly the opposite of what everyone assumed.
- **Low usage is not no usage, and it isn't the same as low importance.** The 2% may be using it once a quarter for the thing that matters most, or they may be your largest customer.
- **Ask why they use it.** The people who'd be hurt by the removal usually know something about the product that isn't in the design.
- **No usage data means you can't decide yet.** Add the instrumentation, wait a full cycle — a quarter, a term, a fiscal close — and then decide.

## Nothing Is Removed Without a Path or an Explicit Decision

- **State the replacement path** — what to do instead, and how to get there. If that path is materially worse for some users, say so plainly rather than describing a downgrade as an improvement.
- **Where there is no replacement, that's a decision that gets made deliberately and communicated honestly**, not disguised as an upgrade. Users forgive removals; they don't forgive being told a loss was a gain.
- **Migrate on their behalf where you can.** A deprecation that requires no action from most users is the one that goes smoothly. Where data must move, it's a conversion with the same rules — provenance, reconciliation, nothing silently dropped (`data-conversion-conventions.md`).
- **The decision is recorded**, with the usage evidence and the reasoning (`documentation-conventions.md`), so it isn't relitigated from scratch when someone complains.

## Notice Is Proportional to Switching Cost

What sets the period is not how long the feature existed but **how much work the user has to do and how much time they need to schedule it**:

- **Cosmetic or additive change**: announce at launch.
- **A workflow someone does daily**: notice before it changes, not after.
- **Anything requiring the user to build, integrate, or migrate** — an API, an export format, an integration: a period long enough to fit their planning cycle, and for anyone with an IT department that means quarters, not weeks.
- **A contractual commitment sets the floor**, and it is a floor, not a target.
- **Notice runs from when they can actually act** — the replacement must exist and be documented before the clock starts. A deprecation announced before the alternative ships is not notice.

## Announce, Warn, Disable, Remove

The same shape as expand/contract (`migration-conventions.md`), for the same reason: the gaps are where you find out you were wrong while it's still free.

1. **Announce** — in the release notes and directly to the people the usage data says are affected. A general announcement is not notice to a specific integrator.
2. **Warn in place** — in the product, in the API response, in the logs. The warning names the replacement and the date. In-product warning is what reaches people who never read the email.
3. **Disable behind a flag** — off by default, reversible in seconds (`progressive-delivery-conventions.md`). Turn it off for a cohort first. If nothing breaks, the removal is safe; if something does, you've learned it without an incident.
4. **Remove** — code, flags, tests, documentation, and the dead configuration. A deprecation that never reaches this step is the worst of both worlds: the feature is unsupported *and* still maintained.

**Every deprecation has a named owner and a date, recorded the moment it's announced** — the same discipline as a release flag, and it fails the same way without it. An announced deprecation with no follow-through teaches users to ignore the next one.

## Deprecating an API Is a Contract Change

- **Version it; never change behavior silently under callers** (`api-conventions.md`). Silent behavior change is the worst possible deprecation, because it fails at the caller with no signal pointing back at you.
- **Signal the sunset in the response itself** — a deprecation header with the date — so it reaches machines and the developers reading the logs.
- **A field's meaning changing is a breaking change**, even when its name and type don't. Callers parse meaning, not shape.
- **Where you know the callers, contact them individually.** For anything integrated, that's the notice that works.

## Sunsetting a Whole Product Is a Data Obligation

The hardest version, and the one where reputation is actually made:

- **Tell people early** — early enough to choose and implement an alternative, and before they find out from a rumor or an acquisition rumour. The instinct to delay is exactly wrong; the delay is what people remember.
- **Their data comes back first.** A complete, documented, machine-readable export, available well before shutdown, tested by round-trip (`data-conversion-conventions.md`). Holding data hostage as a retention tactic at end of life is indefensible and increasingly illegal.
- **Help them leave.** Where a successor system exists, provide the conversion or the mapping. This is the same discipline that brought their data in, run in reverse, and the effort spent here is what determines whether they'd ever buy from you again.
- **Read-only access outlives write access.** A period where the product still answers questions but accepts no new work is cheap and enormously valuable to anyone mid-transition.
- **Shutdown is not deletion.** Retention obligations — theirs and yours — may require keeping data long after the service stops, and deleting on the shutdown date can destroy records someone is legally required to hold. Decide the retention and deletion schedule explicitly, in writing, in advance (`data-privacy-conventions.md`).
- **Decommission the infrastructure deliberately** once the retention period ends, including backups, and record that it happened (`infrastructure-conventions.md`).

## Internal Removal Is Continuous and Unceremonious

Not everything removed is user-facing, and this half needs no process at all:

- **Dead code, unused flags, orphaned tables, and superseded internal endpoints get deleted as soon as they're dead** (`coding-conventions.md`, `progressive-delivery-conventions.md`). Version control is the archive; commented-out code is not a backup.
- **Contract phase is a real step, not an aspiration.** A schema left permanently in its expanded state is a deprecation that was announced and never finished (`migration-conventions.md`).
- **A feature that missed its outcome is a removal candidate by default**, reviewed at the post-launch review (`measurement-conventions.md`, `launch-conventions.md`). Keeping it because removing it feels like an admission is how products get heavy.

## By Project Scale

- **Personal / solo, no users:** delete it. The whole file collapses to "check nothing depends on it."
- **Solo with real users:** announce, warn, then remove — even to twelve users, and even when you're fairly sure none of them use it.
- **Team or customer-facing:** the full sequence, with an owner, a date, and direct notice to affected users.
- **Contracted or enterprise-scoped work:** notice periods, data-return obligations, and sometimes the right to remove at all are set by the agreement. Read it before announcing anything.

## Company & Project Overrides

Minimum notice periods, support windows for prior versions, customer-communication approval, and data-return commitments at end of life are company-specific (see `companies/_template.md`) and may only tighten what's here.
