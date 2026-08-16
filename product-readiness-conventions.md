# Product Readiness Conventions

This file defines the decisions that are cheap to make before a product has customers and near-impossible to unmake after. It is loaded into AI context when a task designs a new product's foundations — data model, identity, permissions, configuration — or when assessing whether an existing product can carry customers it doesn't have yet.

**This is not a tier for large customers.** There is no "enterprise mode" in these conventions, deliberately: the things below are not features you sell to big buyers, they are properties that decide whether a product survives its own success. A three-person customer whose data can't be isolated, whose admin can't be removed cleanly, and whose history was never recorded has the same unfixable problem a large one does — they just find out later, and by then the product has more of them.

Scope split: `deployment-conventions.md` §Production Readiness asks whether *this deploy* is safe to ship. This file asks whether *the product* can carry people who depend on it for years. `architecture-conventions.md` warns against speculative architecture, and that warning stands — nothing here is a speculative feature. Each item is either a **shape** decision that costs nothing today and cannot be retrofitted, or a **record** you must start keeping now because it can't be reconstructed later.

---

## Retrofit Cost Is the Test

Before deferring anything below, ask what it costs to add once real customer data exists. That single question sorts it:

- **Free later** — an admin screen, a rate limit, a self-service export UI, an SSO integration against an identity model that already anticipates one. Defer these happily; build them when someone needs them (YAGNI, `coding-conventions.md`).
- **Expensive but survivable** — an audit trail added later, which works from today forward and leaves an unfillable hole behind it.
- **Effectively impossible** — tenant isolation retrofitted into a live shared schema, a stable identifier for records that were never given one, an authorization model unpicked from hundreds of hardcoded checks, money that was stored as floating point.

**Deferring is fine. Deferring silently is not.** What's deferred goes in the project's CLAUDE.md with the trigger that reopens it.

## Tenancy Is Decided Before the First Table

- **Decide the isolation model before the schema exists** — separate databases, separate schemas, or a shared schema with a tenant column — and write down which and why (`documentation-conventions.md`).
- **Every record that belongs to a customer carries the tenant identity**, from the first table. Adding that column later means backfilling ownership you may no longer be able to determine.
- **Isolation is enforced at the lowest layer you can reach** — row-level security, a scoped connection, a repository layer no query bypasses — never by remembering to add a `WHERE` clause. One forgotten clause is a cross-customer data breach, and it is the single most common serious defect in multi-customer products.
- **The isolation boundary is tested like a security control** — a test that proves tenant A cannot read tenant B, running in CI, not a code review habit (`testing-conventions.md`, `security-conventions.md`).
- **One customer's load cannot degrade another's.** Bound what a single tenant can consume in a request, a job, and a query.

## Identity Is Delegated, Not Owned

Assume an external identity provider will eventually be mandatory, because for any customer with an IT department it is.

- **A person is not their email address.** Give people a stable internal identifier; treat email as a mutable attribute. Email-as-primary-key breaks on the first name change, the first shared mailbox, and every directory integration.
- **Model the account so an external identity can attach to it** — an identity table with a provider and a subject, present from the start even when the only provider is your own password login. That shape is what makes SSO an integration later instead of a rewrite.
- **Never build your own password handling from scratch** (`security-conventions.md`).
- **Deprovisioning is as important as provisioning, and is always the afterthought.** Removing someone's access must be one action with an immediate effect — including their sessions and their tokens. This is what a departing employee's access review actually checks.

## Authorization Is Data, Not Branching Logic

- **Permissions are records you can grant without a deploy.** Scattered `if user.role === 'admin'` checks are unauditable, untestable as a set, and the reason "can we add a read-only auditor role?" turns into a quarter of work.
- **Authorize at one layer**, consulted by every entry point — UI, API, background job, import, export, and support tooling. A permission enforced only in the interface is not a permission (`security-conventions.md`, `ui-conventions.md`).
- **Assume roles you haven't thought of yet**: read-only, delegated, temporary, cross-organization, and support-acting-on-behalf-of. You don't build them now; you make sure the model can express them.
- **Acting on behalf of a customer is a first-class, recorded action**, never a shared login or a quiet impersonation. Support will need it, and unlogged impersonation is the hardest thing to explain after the fact.

## The Audit Trail Starts With the First Write

**You cannot backfill history you never recorded.** This is the item that most often becomes unfixable, and the one most often deferred.

- **Who did what, to which record, when, from where, and what changed** — including the prior value where it matters. Append-only; never updated, never deleted by application code.
- **Covers everything that changes customer-visible state**, which includes background jobs, imports, exports, admin actions, support impersonation, and automated decisions — not just interactive clicks.
- **Separate from application logs.** Logs rotate, get sampled, and are engineering tooling; an audit trail is a customer-facing record with a retention period, sometimes a legal one (`observability-conventions.md`, `data-privacy-conventions.md`).
- **It will be read by someone who wasn't there** — a support agent, an auditor, an opposing party. Record identifiers and values, not prose.

## Per-Customer Difference Is Configuration, Never a Fork

- **A code path named for a customer is a permanent liability.** So is a branch, a per-customer build, and a hardcoded threshold that one customer needed changed.
- **Variation lives in data**: settings with sane defaults, feature entitlements, templates, terminology, workflow options. Adding a customer should never mean adding code.
- **Every setting is a supported permutation.** Each one multiplies what "working" means, so add them deliberately and delete the ones nobody uses (YAGNI applied to configuration).
- **Entitlements are not release flags.** A release flag rolls a change out and is deleted after (`progressive-delivery-conventions.md`); an entitlement is durable product state that says what a customer bought. Conflating them means deleting a flag turns a paying customer's feature off.

## Give Everything a Stable External Identifier

- **Every customer-visible entity has an identifier that never changes and is safe to expose** — not a sequential integer, which leaks volume and invites enumeration.
- It is what integrations key on, what conversion provenance references (`data-conversion-conventions.md`), what support quotes, and what appears in an export. Introducing one later means every external reference to the old identifier breaks.

## Model Time, Money, and Locale Correctly the First Time

Silent, expensive retrofits, every one of them a data-correction project rather than a code change:

- **Timestamps are timezone-aware, stored in UTC, rendered in the user's zone.** A naive local timestamp cannot be repaired once written — the offset it was written in is gone.
- **Money is a decimal or integer minor unit, never a float**, and carries its currency. Rounding errors in stored money are found by an accountant, in public.
- **Dates that are genuinely dates** — a filing date, a birth date — are not instants, and converting them through a timezone shifts them by a day for half the world.
- **Text is unicode end to end**, and length limits are counted in a defined way. Names, addresses, and legal text contain characters your test data doesn't.
- **Locale and format are presentation, not storage.**

## Support Can Answer Questions Without Production Access

- **A support surface exists** — read the record, see its history, see what a customer sees — so that answering a question doesn't require a database console. Otherwise every question escalates to whoever holds production credentials, and standing production access is exactly what `security-conventions.md` forbids.
- **Support actions are permissioned and audited**, especially acting on behalf of a user.
- **Error messages carry a reference** the user can quote and support can find (`observability-conventions.md`).

## The Data Obligations Are Product Features

Not paperwork — each is functionality that has to exist and be tested:

- **Import and export**, both real, both tested by round-trip (`data-conversion-conventions.md`).
- **Retention and deletion that actually delete**, including backups, derived data, caches, and analytics, on a defined timeline (`data-privacy-conventions.md`).
- **Knowing where the data physically lives**, because a customer or a regulator will eventually require it to live somewhere specific.
- **A restore you have performed**, not a backup job that reports success (`infrastructure-conventions.md`).

## The Artifacts a Buyer Will Ask For Are Assembled, Not Authored

Every serious buyer sends a security questionnaire, and the answers are only cheap if they describe things that are already true:

- A statement of where data lives, who can access it, and how access is controlled and reviewed.
- Backup, recovery, and continuity — with the restore date you actually tested.
- Subprocessors and where customer data flows, **including every AI provider** (`ai-product-conventions.md`, `data-privacy-conventions.md`).
- Incident response and notification commitments (`incident-conventions.md`).
- Accessibility conformance (`accessibility-conventions.md`).
- Uptime, support response, and data-return commitments — promise only what the architecture can deliver.

**Written to order, these become commitments nobody verified.** The whole point of the conventions above is that answering honestly takes an afternoon.

## By Project Scale

- **Prototype:** none of this. A prototype is thrown away (`discovery-conventions.md`); if it isn't, that's the problem to fix first.
- **MVP with a first real customer:** the shape decisions and the records — tenancy, identity model, authorization layer, audit trail, stable identifiers, correct time and money. The screens on top of them can all wait.
- **Multiple customers:** entitlements, per-tenant limits, the support surface, self-service export.
- **A customer with an IT department:** SSO, directory-driven provisioning and deprovisioning, exportable audit history, and the questionnaire artifacts. If the model above was right, each is an integration rather than a rewrite — which is the entire payoff of this file.

## Company & Project Overrides

Identity providers, tenancy model, retention periods, residency requirements, certification scope, and required contractual commitments are company-specific (see `companies/_template.md`) and may only tighten what's here.
