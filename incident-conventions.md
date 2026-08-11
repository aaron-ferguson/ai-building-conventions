# Incident Conventions

**Load this file when production is currently broken, or when you are closing out an incident that was.** It is deliberately separate from every other convention so there is one place to go under pressure, and so it isn't carried in context the rest of the time.

Unlike the other files, this one is written to be *used*, not studied — checklists first, reasoning second. If you are in an incident right now, start at "Is This an Incident?" and work down. If you are reading this calmly, start at "Before You Need This" and go make those things true.

Every other convention file owns a mechanic — rollback, forward fix, restore, break-glass, alerting, the regression test. This file owns the **sequence**: which one you reach for, in what order, and when the incident is actually over.

There are two paths, and they are not interchangeable:

- **Path A — operational.** Something is broken or degraded. The goal is to restore service.
- **Path B — security or privacy.** A credential, a boundary, or personal data may have been exposed. The goal is to contain and **preserve**, and a legal clock may already be running. If there is any chance you are in Path B, go there first — several Path A instincts are actively harmful there.

---

## Before You Need This

None of what follows works if these aren't already true. Each has a home elsewhere; this is the checklist.

```
[ ] Errors reach a human automatically, without a user reporting them  → observability-conventions.md
[ ] You know the rollback move for the current deploy                  → deployment-conventions.md
[ ] You have restored from a backup at least once, successfully        → infrastructure-conventions.md
[ ] Break-glass access is defined before the emergency                → security-conventions.md
[ ] Environments, hosts, and account owners are documented            → environment-conventions.md
[ ] You know who to escalate a security or privacy incident to        → companies/<name>/ (or below, if solo)
```

Discovering one of these is missing *during* an incident is itself a finding for the postmortem.

## Is This an Incident?

A bug is a defect in the backlog. An **incident** is production behavior that is harming users or data **right now**, or a security or privacy boundary that may have been crossed. Two questions:

- Is it happening now, in production?
- Does someone outside the team feel it — or could data be affected?

If yes to both, it's an incident and it preempts other work. If it's user-visible but tolerable and nothing is at risk, it's a prioritized bug; use the normal process.

**Severity** — declare one out loud, early:

| | Meaning | Response |
|---|---|---|
| **SEV1** | Core function unavailable, data being lost or corrupted, or sensitive data possibly exposed | Drop everything. Page. Communicate externally. Postmortem required. |
| **SEV2** | Significant degradation, or a subset of users blocked, with a workaround | Respond now. Internal comms. Escalate if it grows. Postmortem required. |
| **SEV3** | User-visible but tolerable, no data at risk, no spread | Track as a prioritized bug. Note it if anything about it was surprising. |

**When in doubt, declare higher.** Downgrading costs nothing; upgrading late costs the whole difference. And **declaring an incident is never a failure** — the cost of declaring must stay low enough that people do it early, because the alternative is someone quietly hoping it resolves.

Anything touching credentials, unauthorized access, or personal data is **SEV1 until proven otherwise**, and goes to Path B.

---

# Path A — Operational Incident

## 1. Stabilize Before You Diagnose

The instinct is to find the root cause first. Resist it: **restore service, then understand.** Root cause is a follow-up unless you already know it *and* the fix is genuinely faster than the mitigation.

```
[ ] Capture evidence first — it's 60 seconds and it's gone once you act:
      the deployed commit/version, the error-tracker state, the log window,
      a snapshot if data is involved, the dashboard as it looks right now
[ ] Declare severity and say who is leading
[ ] Ask "what changed?" — almost always a deploy, a migration, a config
      change, a flag flip, or a dependency
[ ] Mitigate (see the tree below)
[ ] Verify the mitigation worked — actively, not by watching errors stop
```

- **Time-box diagnosis.** If you don't understand it within a set window — 15 minutes is a reasonable default for SEV1 — mitigate anyway and diagnose from the evidence afterward. Unbounded investigation while users are down is a choice, and usually the wrong one.
- **One person changes things at a time.** Two people fixing concurrently makes the system unreadable and you lose the ability to attribute any improvement to any action.
- **Write down every action as you take it, with a timestamp.** Memory is unreliable under stress, and this record is the spine of the postmortem. This is the single most delegatable job in an incident — see the AI section.
- **Don't ship a rushed forward fix when a mitigation exists.** Untested code written under pressure is how a SEV2 becomes a SEV1.

## 2. The Stabilization Decision Tree

| It started right after… | Move | Detail |
|---|---|---|
| — **the feature has a kill switch** | **Flip it off. Fastest move available, always permitted, no approval needed.** Then diagnose | `progressive-delivery-conventions.md` |
| **a flag being turned on** | Turn it back off, then treat as a release problem rather than a code problem | `progressive-delivery-conventions.md` |
| **a code deploy** | Roll back to the previous artifact | `deployment-conventions.md` |
| **a migration** | **Forward fix.** Never run a down migration under pressure — untested destructive code at the worst moment | `migration-conventions.md` |
| **an infra or config change** | Revert the definition and re-apply; reconcile any console change at close-out | `infrastructure-conventions.md` |
| **nothing you changed** | A dependency or provider. Degrade gracefully and communicate; don't rewrite the integration now | `observability-conventions.md` |
| — **data is missing or corrupted** | Stop the writes first, *then* restore. You have drilled this | `infrastructure-conventions.md` |
| — **you lack the access to act** | Break-glass: loud, time-boxed, rotated after use | `security-conventions.md` |
| — **no clear trigger at all** | Narrow by correlation ID and time window; check what changed anywhere, including things you don't own | `observability-conventions.md` |

Stopping writes before restoring is the one people get wrong: restoring underneath a system that is still writing corrupt data just produces a newer corrupt state.

## 3. Communicate

Communication is part of the response, not a distraction from it.

- **Internally, immediately** — before you understand anything. What's broken, who's leading, when the next update comes. The *cadence* matters more than the content.
- **"We don't know yet" is a valid update.** Silence gets read as nothing happening, which is when people start improvising in parallel.
- **Externally, when users are affected**: acknowledge, state the impact, say what they can do meanwhile, give a next-update time. Never speculate publicly about cause, and never commit to a fix time you don't have.
- **One named person speaks externally** — not whoever happens to be closest to a keyboard.
- Anything in Path B: **no external communication without counsel.** Move to that path.

## 4. Close Out

The incident is not over when it stops hurting. It's over when all of these are true:

```
[ ] Service verified restored by an actual smoke check, not by absence of errors
[ ] A failing regression test reproduces the defect → red → fix → green, and it stays
      permanently                                              → testing-conventions.md
[ ] Emergency console/infra changes reconciled into the definition AND applied to
      staging                                → infrastructure-conventions.md, environment-conventions.md
[ ] Break-glass credentials rotated, temporary access revoked  → security-conventions.md
[ ] Temporary mitigations have a ticket and an owner — a disabled feature or a
      scaled-up instance is debt, not a resolution. A kill switch left off is an
      outage nobody is measuring   → progressive-delivery-conventions.md
[ ] Flag flips made during the response are in the timeline, with times
[ ] The monitoring gap is closed: if a human told you before your tooling did, that is
      a defect in observability and fixing it is part of this incident
[ ] The record is written                                       → "Postmortems" below
```

The regression test is the non-negotiable one. It's the same rule as any bug fix (`testing-conventions.md`) and it's what makes the incident permanently unrepeatable rather than merely over.

---

# Path B — Security or Privacy Incident

**Enter here if:** a credential or key may have been exposed, unauthorized access is suspected, personal or sensitive data may have gone somewhere it shouldn't (including into a model provider, a log, an artifact, an email, or an AI conversation), or you found sensitive data in a place the design says it can't be.

This path is deliberately short on prescription and heavy on escalation, because the binding obligations are legal, jurisdiction-specific, and not something a general convention or an engineer should determine (`data-privacy-conventions.md`).

```
[ ] ESCALATE FIRST, before investigating. Not a solo call.
      → the contact named in companies/<name>/
[ ] CONTAIN without destroying: revoke the credential, block the path, take the
      surface offline. Rotate at the source (security-conventions.md).
[ ] PRESERVE. Do not clean up, delete, or "tidy" the exposure.
[ ] Assume a clock is already running, starting from discovery.
[ ] Record what you know: what was exposed, when, for how long, to whom, and how
      you found out.
```

Why the Path A instincts hurt here:

- **Deleting the exposure destroys the evidence of its scope** — and scope is what determines the legal obligation. A restart that clears the logs can turn an answerable question into an unanswerable one.
- **Breach notification clocks run from discovery, not from the end of your investigation** (`data-privacy-conventions.md`). Taking a week to be sure does not buy you a week.
- **Do not determine your own notification obligations.** Counsel does that. Your job is accurate facts, fast.
- **Don't widen the exposure while responding** — no pasting the exposed data into a chat channel, a ticket, or an AI conversation to analyze it (`security-conventions.md`).

**If there is no company profile and no counsel:** the obligation does not disappear. Write down what happened, when you discovered it, what was exposed, and whose data it was. If other people's personal data is involved, get legal advice — this is one of the few areas where a personal side project can carry genuine statutory duty.

---

## Roles

Named out loud at the start, even if one person holds several:

- **Incident lead** — owns the response and makes the calls. Deliberately *not* the person typing; someone tracking the whole picture instead of a terminal.
- **Operator** — makes the changes. One at a time, announced before doing them.
- **Scribe** — maintains the timeline. See below; this is the best use of an AI agent in an incident.
- **Comms** — internal updates, and external if needed.

**Solo, you hold all four.** That's precisely why the written timeline matters more, not less — you have no scribe, and you are the person least able to reconstruct it later.

## Working With AI Agents During an Incident

An incident is the highest-risk configuration in this entire convention set: time pressure, production access within reach, destructive commands available, and a strong bias toward action. Gates get waived exactly when they matter most. So:

- **An agent operates read-only for the duration of an incident.** Diagnosis, proposal, and documentation only. It does not deploy, roll back, run migrations, restart services, restore backups, modify infrastructure, or touch production data. A human operator executes; the agent proposes and explains.
- **An agent never declares the incident over**, and never decides a severity.
- **Never paste exposed secrets or personal data into the agent's context** to have it analyzed (`security-conventions.md`, and Path B above).

Within read-only, lean on agents hard — they are good at precisely what humans do worst under stress:

- Reading log volume and correlating events by request or correlation ID.
- Diffing recent deploys, migrations, and config changes against the moment symptoms started.
- Checking whether this error has appeared before, and what happened then.
- Holding the whole picture while the operator is heads-down in one terminal.

**The agent is the scribe, and this is its primary job.** The standard for that record:

- **Exact timestamps on everything**, in one consistent timezone, stated.
- **Every observation, when it was observed** — including the ones that turned out to be irrelevant.
- **Every action a human took**: what, when, who, and what changed afterward.
- **Behavior described in the words it was noticed in**, before anyone had a theory. Early raw observations are the most valuable and the first to be unconsciously rewritten.
- **Written as it happens, never reconstructed at the end.** Reconstruction is where the detail that explains the incident quietly disappears.
- **Formatted to be skimmed by a human later** — chronological, one line per event, no narrative prose. Someone should be able to read the whole timeline in under a minute and know the shape of what happened.

## Postmortems

**Blameless, always.** The question is what made the mistake possible — what the system allowed, what feedback was missing, what was easy to get wrong. A postmortem that names a person as the cause has failed at its only job, and it guarantees the next person hides the next incident. Same instinct as "failing tests are victories" (`testing-conventions.md`): the finding is the value.

- **Required for SEV1 and SEV2.** SEV3 gets a short note if anything about it was surprising.
- **Written within a few days**, while memory is fresh and before the timeline gets tidied by hindsight.
- **Contents:** the timeline (from the scribe's record), impact (who, how long, what data), the trigger, why it wasn't caught earlier, the regression test that now guards it, and follow-up actions.
- **Every action item has a named owner and a due date, or it is not an action item.** Ownerless follow-ups are the standard way postmortems produce nothing.
- **Collaborative mode:** reviewed by someone who wasn't part of the response. They see the assumptions the responders can't.

### Where Incident Records Live

**Never in the conventions directory.** A postmortem is a tactical artifact about one event; these files are durable principles. Mixing them makes both harder to use.

Where they *do* live is declared per project, in the project's CLAUDE.md alongside the Environments block:

- **Company projects** — the company profile names the system (issue tracker, wiki, or an incident tool). It is authoritative.
- **Solo / personal projects** — default to `docs/incidents/` in the project repo, one dated file per incident (`2026-08-10-checkout-outage.md`). In-repo is right for solo work: it's versioned, it sits next to the code it describes, and it lands in the same history as the regression test that closed it.
- **The exception that overrides both:** a record containing personal data, customer identities, or exploitable security detail does **not** go in a repo that might be shared or handed off. That goes wherever the company profile directs, or a private store — and the repo holds a pointer, not the content.

```markdown
## Incidents
- Records: docs/incidents/, one dated file per incident
- Severity scheme: default (see incident-conventions.md)
- Security/privacy escalation: <who to contact>
```

That last line is the one to fill in *now*, not during. For a solo project with no company, it's the name of a lawyer, or an honest note that you don't have one yet.

## AI Feature Failures Are Sometimes Incidents

A model provider outage, a prompt-injection event, a guardrail bypass, or a bad model output reaching a user **may or may not** be an incident — judge it by the same test as anything else: is it harming users or data right now?

When it is, it runs through the paths above (a bad output that exposed one user's data to another is Path B, not Path A). The AI-specific mechanics — evals, guardrails, grounding, human-in-the-loop, model-version flags — live in `ai-product-conventions.md` and are a different subject. Keep them separate; cross-reference when they meet.

## By Project Scale

**The process above is the default, and it's deliberately thorough.** Scale it down explicitly, in writing, in the project's CLAUDE.md — never by drift, and never in the middle of an incident.

What a **solo pre-release** project can drop: severity declaration, comms, and named roles. There is no one to tell and no one to coordinate with.

What it should keep anyway, because these are habits worth having before they're needed:

- Stabilize before diagnosing, and capture evidence first.
- The decision tree — knowing rollback from forward fix from restore.
- A written, timestamped timeline.
- The regression test.
- Closing the monitoring gap.

**Solo released:** add severity, external communication to users, and postmortems for SEV1/SEV2. **Collaborative:** the full process, with roles named out loud and postmortems reviewed by a non-responder. **Company profile:** whatever it adds on top, which for regulated products is usually the entire Path B contact chain and comms approval process.

## Company & Project Overrides

Severity definitions and names, paging and on-call arrangements, response-time commitments, status-page and customer-notification procedures, the security escalation chain, and where records live are all company-specific — they live in the company profile (`companies/<name>/`) and may only tighten what's here. On-call rotation and alert routing are staffing matters this file deliberately doesn't cover; `observability-conventions.md` routes alerts to "whoever is on the hook," and the profile says who that is.

The severity *scheme* is a **preference** — three levels is a reasonable default, not a truth. Everything else above is a principle: stabilize before diagnosing, preserve before cleaning up, escalate security incidents rather than handling them alone, agents stay read-only, the regression test closes the loop, and postmortems are blameless.
