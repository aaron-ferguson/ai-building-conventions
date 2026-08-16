# Data Conversion Conventions

This file defines how a customer's data crosses a product boundary — **in** from a legacy or competing system, and **out** when they want it back. It is loaded into AI context when a task imports customer data, builds or runs a conversion, maps fields between systems, plans a cutover, or builds an export.

Scope split: `migration-conventions.md` owns your own schema evolving under your own data — expand/contract, backfills, forward-only. This file owns data arriving from or leaving for a system you don't control. The two are routinely confused, and the difference matters: in a migration you know the source, because you wrote it. In a conversion you don't, and everything below follows from that.

This is the discipline most often discovered too late. A product built with no conversion path can be sold, demoed, and loved, and still lose the deal — because the prospect has eleven years of data in the incumbent system and no way to bring it. Conversion is not a professional-services problem that starts after the contract; it is a product requirement that starts at the first schema.

---

## Conversion Is a Product, Not a Script

- **It is built, tested, reviewed, versioned, and owned like any feature.** The single-use script written under deadline by whoever was free is the origin of most conversion disasters, because it is run exactly once, against real data, with no way to check it.
- **It is used more than once.** Every customer, every trial run, every re-run after a failure. Assume tens of executions and build accordingly.
- **All of `coding-conventions.md` and `testing-conventions.md` apply.** Transformation logic is ordinary code with unusually high stakes.
- **It has an owner after go-live.** Conversions come back — a missed record type, a second office, an acquisition.

## Design the Way In Before the First Customer Asks

Cheap now, brutally expensive later (`product-readiness-conventions.md`). Before a product carries real customers it needs:

- **A documented import format** the product itself defines — not one shaped around the first source system you happened to meet. Every subsequent source maps *to your format*, so the number of transformations you own grows by one per customer, not by one per pair of systems.
- **A validation pass separate from the load** — a dry run that reports what would happen and changes nothing. This is the single highest-value component in the whole pipeline and it's usually the one left out.
- **An idempotent, resumable loader** (see below).
- **Provenance fields on every record that can arrive from outside** (see below). Adding these later means a schema migration across every table plus data you can no longer reconstruct.

## Profile the Real Data Before Promising Anything

**Get a real extract early — before the design is fixed, ideally before the deal is signed.**

- **The source vendor's documentation describes the schema, not the data.** Eleven years of use puts things in fields nobody intended, in formats nobody documented, entered by people working around a limitation that was fixed in 2019.
- **The customer's description of their own data is a hypothesis.** They will describe the process as designed, not as practiced. They are not being dishonest; nobody knows their own historical data.
- **Profile it mechanically**, and write the profile down: row counts per entity, null rates per field, distinct-value lists for anything that looks like an enum, min/max dates, duplicate keys, orphaned references, character encodings, embedded delimiters, mixed date formats, numbers stored as text, and text stored past its documented length.
- **Look for the awkward truths specifically**: records referencing deleted parents, dates in the future or before the system existed, duplicate identities that are the same person, free-text fields carrying structured meaning by local convention, and the field that was repurposed halfway through.
- **The profile is what you estimate from.** An estimate given before profiling is a guess, and it is the number everyone will hold you to.

## The Mapping Specification Is the Deliverable

A written, reviewed, field-by-field mapping — the artifact that turns an unbounded problem into a bounded one.

- **Every target field has a source, a constant, a derivation, or an explicit "not populated."** No blanks.
- **Every source field is mapped, defaulted, or explicitly dropped — with a reason.** Unmapped is not decided; it's forgotten, and it's what the customer notices first because it's always the field they care about.
- **Reviewed by someone who knows the source system and someone who knows the target.** Neither one alone can see the mismatch, and the mismatch is where the data loss is.
- **Record the losses and the judgment calls out loud.** Where the source holds something the target has no home for, that is a **product decision, not a technical one** — escalate it, get an answer, write down the answer. Silently dropping it, or force-fitting it into a notes field, is how a customer discovers at go-live that their data is gone.
- **The mapping is versioned in the repo alongside the code that implements it**, and it changes together with that code.

## Transformation Rules Are Tested Code

- **Each rule is a pure function** — one input shape, one output shape, no side effects (`coding-conventions.md`). Testable in isolation, which is the whole point.
- **TDD applies, and the fixtures come from the profile**: the null, the empty string, the whitespace-only value, the duplicate, the maximum-length string, the unicode name, the ambiguous date, the negative amount, the orphan. Write those tests from the real profile, not from imagination — imagination produces tidy data.
- **Fail loudly on the unexpected.** A rule that meets a value it wasn't designed for rejects the record; it never guesses, silently defaults, or writes a null and moves on (`coding-conventions.md` — never swallow failures).
- **Ambiguous dates are the classic silent corruption.** `03/04/2019` is two different days and both are plausible. Determine the source's format from the data, assert it, and reject on violation. The same applies to timezones, currency, and encodings.

## Every Converted Record Carries Its Provenance

Non-negotiable, and impossible to add retroactively:

- **The source system, the source record's key, and the conversion run** that created it, stored on the record.
- This is what makes it possible to answer "where did this come from," to re-run safely, to reconcile, to fix a bad batch selectively, and to explain a discrepancy three years later when nobody involved still works there.
- **It is also the idempotency key.** Without it, a re-run duplicates everything, and the only remedy is a restore.

## Conversions Are Idempotent, Resumable, and Observable

The same properties as a backfill (`migration-conventions.md`), for the same reasons and at higher stakes:

- **Running it twice produces the same result as running it once.** It will be run twice — after a partial failure, after a fix, after a source re-extract.
- **Resumable in bounded batches** with recorded progress, so an interruption at 80% continues rather than restarting or double-loading.
- **Observable** — structured progress events, not a silent process with a spinner (`observability-conventions.md`). On a multi-hour run you must be able to distinguish slow from stuck without attaching a debugger to production.
- **Every run produces a report**: counts in, converted, rejected, defaulted, and transformed-with-a-judgment-call, per entity type.

## Nothing Is Silently Dropped or Silently Fixed

The rule that separates a trustworthy conversion from an untrustworthy one.

- **Records that can't convert go to a rejection report with the reason and enough of the source record to identify it.** They are never dropped, and never quietly coerced into something that fits.
- **The customer decides on exceptions** — fix at source and re-extract, accept a documented default, or accept the loss. The tool never decides on their behalf.
- **Rejects are expected, not a failure of the conversion.** A trial run producing zero rejects on eleven years of real data means the validation isn't looking, not that the data is clean.
- **Reconcile the counts every run**: in = converted + rejected, always, per entity. If that doesn't balance, records vanished inside the pipeline and the run is not trustworthy regardless of how good the output looks.

## Reconciliation Is the Acceptance Test

"It looks right" is not reconciliation, and neither is spot-checking twenty records.

- **Automated control totals, produced by the tooling every run**: record counts by type and status, sums of every monetary and quantity field, date-range boundaries, distinct-entity counts, and referential integrity across the converted set.
- **Compared against the same totals computed from the source**, not against expectation.
- **Reconcile what the business cares about**, which is rarely row counts alone — open matters, active users, outstanding balances, documents attached to the right parent.
- **The customer signs off on the reconciliation report**, on their numbers, before cutover. This protects them and it protects you; a signed report is the difference between a discrepancy that gets investigated and one that becomes a dispute.
- **Sample verification by a domain expert still happens** — records they choose, not records you choose. Automated totals miss systematic errors that preserve counts, like every record attached to the wrong parent.

## Rehearse Repeatedly, at Full Scale, in an Isolated Environment

- **Never convert into production first.** Convert into an isolated environment, verify, then promote (`environment-conventions.md`). A conversion that has only ever been run in the environment that matters has never been tested.
- **Rehearse on the full extract, not a sample.** Scale is where the timing surprises live, and the runtime number is a cutover input: a conversion that takes fourteen hours dictates the cutover plan, and you need to know that weeks ahead, not on the night.
- **More than one trial run.** The first finds the crashes; the second finds the wrong-but-valid data; the third proves the fixes held and the timing is real. One rehearsal is a demo.
- **Each trial produces a reconciliation report the customer reviews.** Their review of trial one is what makes trial two worth running — they see their own data in your product and immediately notice what you couldn't.

## The Customer's Extract Is Production Data

An extract is the most concentrated pile of someone else's sensitive data you will ever hold, and it arrives outside your normal controls — usually as a file, usually over whatever channel was convenient.

- **All of `data-privacy-conventions.md` and `security-conventions.md` apply in full.** It is production data even though it isn't in production, and it is subject to the customer's contract and their regulator, not just yours.
- **It never lands on a laptop, in a personal cloud drive, in a ticket attachment, or in a shared channel.** Agree a secure transfer channel before the first extract, not when the file is already in an inbox.
- **It never goes to an external model or third-party service**, including for "help understanding the schema" — a company profile may forbid this absolutely (see `companies/_template.md`), and where it does, that governs everything here.
- **Encrypted at rest, access limited to the people doing the conversion, with a deletion date agreed up front** and actually executed. Extracts pile up: production copies of customer data, on shared infrastructure, indefinitely, with no owner.
- **Non-production environments still don't hold real customer data as a matter of course** (`environment-conventions.md`). A conversion rehearsal is the deliberate, time-boxed exception — an isolated environment, treated with production controls, torn down after.

## Cutover Is Planned, Rehearsed, and Reversible Until a Named Point

Write the runbook before cutover week, and rehearse it — the sequence, not just the conversion:

- **The freeze window** — when the source system stops accepting changes, who enforces it, and what the customer's staff do meanwhile. Unenforced freezes are the reason delta conversions exist.
- **The delta.** Data created between the final extract and go-live has to be handled: a second incremental conversion, or manual re-entry with a counted list of what must be re-entered. Decide which, in advance, with the customer.
- **Go/no-go criteria, agreed in advance**, with named people who make the call — reconciliation within agreed tolerance, rejects reviewed and accepted, smoke tests passed, support standing by.
- **The point of no return, named explicitly**: the moment the customer starts entering new work in the new system. Before it, rolling back means going back to the source system, which still has everything. After it, there is no rollback — only a forward fix, exactly as in `migration-conventions.md`.
- **A verified restorable backup of the target immediately before load** (`infrastructure-conventions.md`).
- **The legacy system stays readable — not writable — for an agreed period.** Read-only access is the cheapest insurance available and it is what turns a discrepancy from a crisis into a lookup. Agree the retention period and the archive plan while it's still running, and record who owns the eventual shutdown (`deprecation-conventions.md`).

## What Doesn't Convert Faithfully Gets Escalated, Never Invented

Some things genuinely can't come across, and pretending otherwise is worse than saying so:

- **Legacy audit history** usually can't be recreated as native audit records, because it never contained what your model requires. Bring it as immutable read-only history or archive it in the legacy system, but never synthesize audit entries that imply your system observed something it didn't — that is fabricated evidence, and in a regulated domain it is a serious problem.
- **Derived state, permissions, workflow position, and anything computed by the source's business rules** re-derive under *your* rules, or arrive as explicit data. They rarely mean the same thing in both systems even when the field names match.
- **Attachments and documents** are their own conversion — volumes, formats, storage, links to parents, and files the source has lost. Profile them separately; they are usually the largest and the most-forgotten component.
- **Where fidelity is impossible, say so in writing before go-live**, with the workaround. Discovering it afterwards costs the relationship; disclosing it beforehand almost never does.

## The Customer Can Always Leave

Export is a first-class product feature, not a retention lever. A product that makes leaving hard is one nobody's procurement team will approve, and the obligation is increasingly a legal one, not just an ethical one (`data-privacy-conventions.md`).

- **Complete** — all their data, including attachments, audit history, and configuration. Not the subset that was easy.
- **Machine-readable and documented**, in a stable, versioned format with a schema, so someone else can actually load it. A PDF is not an export.
- **Self-service where feasible**, and available on request where not — without a fee, a negotiation, or a support escalation designed to slow it down.
- **Tested by importing it somewhere.** An export nobody has ever round-tripped is a belief, in exactly the sense `infrastructure-conventions.md` means about backups. Round-trip it into a clean instance of your own product as a standing test — that also gives you a conversion source for free when a customer moves between your own instances.
- **Same discipline in both directions**: provenance, reconciliation totals, and a manifest of what's included and what deliberately isn't.

## By Project Scale

The principles don't flex — provenance, idempotency, no silent drops, and reconciliation apply to a fifty-record import too, because a silent drop is silent at any size. What scales:

- **Personal / solo:** a one-off import of your own data still gets a dry-run and a count check. That's the whole ceremony.
- **First real customer:** the full sequence — profile, written mapping, tested rules, at least two rehearsals, a signed reconciliation, a rehearsed cutover.
- **Repeat conversions from the same source:** promote the mapping and rules into a supported connector with its own tests and version. The second customer on the same legacy system is the trigger to stop treating it as bespoke.
- **Contracted or enterprise-scoped work:** conversion is usually the largest, latest, and most under-estimated part of the implementation. Profile before you price it.

## Company & Project Overrides

Approved transfer channels, extract retention periods, whether customer data may be held outside production infrastructure at all, sign-off authority for cutover, and any regulator-mandated retention of the legacy system are company-specific (see `companies/_template.md`) and may only tighten what's here. Everything above is a principle.
