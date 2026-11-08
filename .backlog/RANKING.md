# Why the order is what it is — AI Building Conventions

Standing reasoning behind `QUEUE.md`. Read on a re-rank, not on every claim — which is the whole
reason it is a separate file. `QUEUE.md` is rewritten on every claim and every close, by every
window, so prose parked there is re-read on each of those edits while changing perhaps once a week.

## The shape of this backlog

Every row came from one external review of this repo — the email thread *AI Building Conventions*
with Bozidar Dangubic, 2026-08-14, swept 2026-08-26. That gives the order an unusual property worth
stating, because it tells the next reader what kind of argument to make: **the reviewer's emphasis
and this ranking disagree, deliberately.** He led with Claude Skills and called the missing
"how to work with Claude" guidance the biggest gap; those sit at 0007 and 0010. What is at the top
instead is exposure that is live on a public remote right now, and drift that is silently wrong in
every session.

So this is ranked mostly by **tier**, not by dependency — the one dependency edge that matters is
0006 → 0007. Two rows were dropped from his list before ranking because they are already fixed:
the `handoff-move-ai-dir-out-of-icloud.md` file is gone from the repo, and
`scripts/check-convention-links.sh` now handles illustrative paths like `NNN-short-title.md`
explicitly, which was his complaint about the verification rule being unpassable as written.

## Item by item

- **0001 — corporate identity in commit metadata.** Tier 1. The repo is public, `company: none` is
  its headline constraint, and every commit publishes an employer domain. Damage accrues while it
  sits, because it accrues per commit. Above 0002 on blast radius: it is every commit ever made
  and every future one, against one file.
- **0002 — the tracked-file sweep.** Tier 1, same root cause as 0001 — a public repo publishing
  what it says it does not. Below 0001 only on blast radius.
- **0003 — guard the core against drift.** Tier 2, and the non-obvious placement in this queue: it
  is smaller and far less visible than the enforcement work below it, and it ranks above anyway.
  The test that decided it is Tier 1's *"output that is silently wrong, which is the worst case
  because nobody is counting the damage."* A drifted bullet in `CONVENTIONS_CORE.md` governs every
  session in every project, and both the session and the human believe the current rule is the one
  being followed. It stops short of Tier 1 only because nothing is known to have drifted yet.
- **0004 — hooks.** Tier 2, the reviewer's strongest argument: *"rules are either enforced or they
  are not going to be happening."* Compounding because every project wired to these conventions
  inherits the unenforced version. Below 0003 on the silently-wrong test above; above everything
  below it on blast radius.
- **0005 — the unlabeled-rule default.** Tier 2. Beat 0006 and 0007 on tie-breaker 4, smaller and
  more certain: it is one paragraph plus a labelling pass, and it changes the standing of every
  rule in the suite — including the rules 0007 would package, which is why it goes first.
- **0006 — distribution and portability.** Tier 2, and placed above 0007 by *a prerequisite
  outranks its dependent* rather than by importance. Compounding in a quiet way: every project
  wired up adds another absolute path a future move has to find.
- **0007 — Skills.** Tier 2, `blocked_by: 0006`. The reviewer's headline point, ranked seventh — a
  Skill has to be installed from somewhere, and it should carry the semantics 0005 fixes rather
  than being redone after.
- **0008 — the Review Checklist.** Tier 2, low. Compounding because the checklist grows every time
  a session's lesson lands in it, and each addition makes the human-run version less likely.
- **0009 — the WCAG version mismatch.** Tier 2, bottom. A one-line fix against a non-negotiable
  principle, which is why it is Tier 2 and not Tier 5, but it loses tie-breaker 1 to every row
  above: one statement in one file. Deliberately **not** floated to the top for being small — that
  is the clear-the-deck reflex, and tie-breaker 4 only applies once blast radius has failed to
  separate.
- **0010 — conventions for working with Claude.** Tier 4, top of tier, and the other non-obvious
  placement. The reviewer called it the biggest thing missing and he may be right about value; it
  is still an absence rather than a defect, and nothing degrades while it waits. It becomes the
  most valuable row in the queue once Tiers 1 and 2 are clear.
- **0011 — legal and acceptable use.** Tier 4. Lower than 0010 because the practice already in
  place — the mandatory co-authorship trailer — is the conservative, defensible side of the
  industry split. What is missing is the reason, not the behaviour.
- **0012 — TDD's "no exceptions".** Tier 4, bottom. It is an argument against a considered position
  rather than a defect, and the repo's calibration section is already a partial answer to it.

## What would change the order

- **If 0003's design step finds the core has already drifted**, that row becomes Tier 1 and the
  drift itself becomes its own bleeding ticket above 0001.
- **If the audience answer changes** from "personal now, portable by design" to a company-wide
  rollout, 0006 promotes hard — it stops being hygiene and becomes the thing everything else ships
  through — and 0011 promotes with it, because a company rollout makes acceptable use a real policy
  question rather than a documented posture.
- **If 0004's hooks land and get disabled in practice**, that is evidence for the reviewer's
  general-guidance-over-rules position and it weakens the case for 0007 as well. Watch for it.
- **If 0008's measurement (FR5) shows delegation catches less than a human read**, 0008 shrinks to a
  documentation fix and drops to Tier 5.
