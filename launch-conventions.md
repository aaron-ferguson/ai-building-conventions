# Launch Conventions

This file defines what has to be true before people outside the team meet a change, and what happens afterwards. It is loaded into AI context when a task prepares a launch, writes release or customer-facing communication, plans enablement, or runs a post-launch review.

Three distinct things, routinely collapsed into one word:

- **Deploy** — the code is in production. A technical event (`deployment-conventions.md`).
- **Release** — real users are exposed to it, usually progressively (`progressive-delivery-conventions.md`).
- **Launch** — the outside world is told, and everyone who supports, sells, or teaches the product is ready. That's this file.

Collapsing them is what produces the launch where support finds out from a customer. Keeping them separate is what lets you deploy on Tuesday, release to 5% on Wednesday, and launch when you're ready — or never launch at all, because plenty of changes shouldn't be announced.

---

## A Launch Has an Owner and a Decision

- **One named owner** who decides it goes. On a solo project that's you, and naming it still matters, because the failure mode is a launch that happens by accident when a flag gets flipped.
- **A go/no-go against criteria set in advance**, not a vibe on the day. Decided under pressure with the announcement already drafted, every criterion becomes negotiable.
- **"Not yet" stays available right up to the moment.** A launch decision that can only go one way is an announcement schedule, not a decision.

## Readiness Is Checked Before the Announcement, Not After

The check is: **who finds out about this, and is each of them ready?**

- **The product side** — released behind a flag with a verified kill switch, rollout plan agreed, instrumentation confirmed firing (`progressive-delivery-conventions.md`, `measurement-conventions.md`).
- **Support** — knows it exists, knows what it does, and has the **failure modes**, not just the happy path: what users will get wrong, what the error messages mean, what to do about each, and when to escalate to whom. Support briefed only on the happy path is support that can't help.
- **Documentation and in-product help** updated *before* the announcement, not queued behind it (`documentation-conventions.md`).
- **Anyone who sells or demos it** — what it does, what it does *not* do, and who it's for. An oversold feature generates a churn risk and a support load that outlast the launch.
- **Existing users** — what changes for them, whether they must act, and whether anything they rely on stops working (`deprecation-conventions.md`). A change to existing behavior is a bigger event than a new feature and gets treated as one.
- **Data and permissions** — who can see it by default. **A launch that silently widens who can see what is a privacy incident with a press release attached.** Check the default explicitly, every time.
- **Operations** — anyone on call knows it's happening, what's new, and how to turn it off.
- **Commercial and legal**, where relevant — pricing, packaging, entitlement (`product-readiness-conventions.md`), and any commitment the launch language would create. Marketing copy is a contract in some jurisdictions and in most customer relationships.

**Nobody outside the team learns about it from a customer.** That's the rule the whole checklist exists to serve.

## Write the Communication Before Launch Day

- **Drafted and reviewed in advance**, because the version written on the day is the one that overstates.
- **Say what changed, who it's for, what to do, and what didn't change.** Users read release notes to find out whether their workflow broke.
- **Plain language, the user's vocabulary, no internal names** (`ui-conventions.md`). Feature codenames leak constantly and mean nothing to anyone outside.
- **Known limitations are stated up front.** Disclosed, they're a caveat; discovered, they're a defect and a credibility problem.
- **Match the channel to the impact.** A quiet improvement doesn't need an email; a change that alters someone's daily workflow needs notice ahead of time, not an announcement after it lands.

## You Can Un-Ship, But You Can't Un-Tell

The asymmetry that makes launch different from deploy:

- **Every launch has a technical retreat** — the kill switch, verified working before the announcement, not assumed (`progressive-delivery-conventions.md`). "Roll back the deploy" is not a plan if the feature is already in front of users.
- **And a communication retreat** — who says what, to whom, if it comes off. Written in advance, because it will be written under pressure otherwise.
- **Pulling a launch back is a normal, low-drama operation**, and the projects where it's normal are the ones that launch confidently.
- **Anything already sent stays sent.** Emails, notifications, and integrations that fired can't be recalled, which is the argument for a small first cohort.

## Time It Deliberately

- **Not into the weekend, a holiday, or the customer's peak.** Whoever handles the fallout should be at a desk, not at dinner.
- **Not on top of another change.** Two launches in one window means neither can be attributed, and neither can be cleanly reverted (`measurement-conventions.md`).
- **Know the customer's calendar**, not just yours — a court's filing deadline, a quarter close, a term start. Launching into someone's busiest day is a self-inflicted incident.

## Watch It Land

- **Someone watches** for a defined window, with the dashboards open — errors, latency, and the guardrail metrics, not only the success metric (`observability-conventions.md`, `measurement-conventions.md`).
- **Support volume is a launch signal.** A spike in questions about one step is a usability defect reporting itself in real time, and it's the fastest feedback the launch will produce.
- **Predefine what triggers the kill switch**, so the call isn't made from scratch while it's happening.

## The Post-Launch Review Happens on the Date You Set

- **Set the date at launch**, at the end of the measurement window declared in the definition (`measurement-conventions.md`). Unscheduled, it never happens, and the next launch proceeds on the assumption the last one worked.
- **Three questions, written down**: did it hit the success measure, what did we learn about the users, and what did we learn about our process.
- **The result gets recorded, including a negative one** (`documentation-conventions.md`). A feature that missed its outcome is a candidate for removal, not automatic permanent maintenance (`deprecation-conventions.md`).
- **Clean up**: the release flag comes out on the schedule it was given (`progressive-delivery-conventions.md`), and the temporary scaffolding goes with it.

## By Project Scale

- **Personal / solo, no users:** there is no launch. Deploy, release, and move on.
- **Solo with real users:** the checklist collapses to three questions — is the kill switch real, do the docs match, will anyone be surprised by this?
- **Team or customer-facing:** the full sequence, with the owner named and support briefed before the announcement.
- **Contracted or enterprise-scoped work:** launch is often *their* event, not yours — customer training, change management, and a communication window their staff need. Their readiness is a go/no-go criterion, and it is the one most often assumed rather than confirmed.

## Company & Project Overrides

Announcement channels, release-note format and cadence, marketing and legal review requirements, notice periods owed under contract, and who holds go/no-go authority are company-specific (`companies/<name>/`) and may only tighten what's here.
