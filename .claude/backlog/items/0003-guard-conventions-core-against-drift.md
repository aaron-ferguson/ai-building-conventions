---
id: "0003"
title: Guard CONVENTIONS_CORE.md against drift from the files it restates
type: debt
next: develop
status: ready
qa_level: unit
size: m
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0005"]
expects:
  - CONVENTIONS_CORE.md
  - README.md
  - documentation-conventions.md
  - scripts/check-core-drift.sh
  - scripts/check-core-drift.test.sh
claimed_by:
claimed_at:
touches:
---

## Problem

`CONVENTIONS_CORE.md` is 16KB and always loaded, into every session across every project wired to
this repo. It restates roughly forty rules that also live in their own source files —
`discovery-conventions.md`, `git-conventions.md`, `testing-conventions.md` and the rest — each
bullet ending in a parenthesised pointer to the file it came from.

That is the exact pattern this repo tells everyone else not to use. `documentation-conventions.md`
and `README.md` both warn that a second copy of a rule *"says the same thing twice, and the two
drift apart later."* Nothing checks the core against its sources.
`scripts/check-convention-links.sh` verifies that the **filenames** resolve; it says nothing about
whether the **rule** still matches what that file says.

> "The core file is a duplication in disguise and there is nothing guarding against it. It restates
> 40-ish rules that live in their own source files … It is tolerable for an always-loaded
> context/index, but it is the highest drift risk in the repo and nothing checks it."
> — email thread *AI Building Conventions*, 2026-08-14 (attributed there to Codex)

The failure is silent and expensive in a way the other tickets are not. A core bullet that has
drifted from its source is read by **every session in every project**, and both the session and
the human believe the rule being followed is the current one. Nobody is counting that damage. The
repo's git history shows the sources being sharpened repeatedly — five of the last six commits edit
convention files — with no corresponding mechanism to notice when a sharpening leaves the core
behind.

## Design decision — 2026-09-14

**Decided: keep the restatements; earn them with the anchor + staleness guard (the third
option). Rejected: the pure-index rewrite.**

- `README.md:13` defines `CONVENTIONS_CORE.md` as *"the always-loaded summary — the essential
  rules plus an index"* — the pure-index rewrite contradicts the file's stated job everywhere
  else in this repo, not only in this ticket's framing. The repo already commits to the opposite
  pattern on purpose: `README.md`'s "Critical invariants" guidance restates a hard rule inline
  precisely because an agent can violate it *before* it thinks to open the linked file. `git add
  -A` is that shape — nothing prompts a session to go read `git-conventions.md` first.
- Feasibility confirmed, not assumed: `git-conventions.md`, `discovery-conventions.md`, and
  `testing-conventions.md` all carry stable `##`/`###` headings for the rules the core restates,
  so "anchor = heading text, checked by grep" is real. Per-bullet staleness is a `git blame` on
  the core's line vs. `git log -1` on the source file — no semantic diffing required.
- **Sizing gap FR2 doesn't call out:** roughly 15 bullets (Code lines 20–29, Security lines
  50–53, Testing lines 35–38) restate rules from `coding-conventions.md` /
  `security-conventions.md` / `testing-conventions.md` with **no pointer at all** today — not an
  anchor to add, a pointer to create from scratch. FR2 as written already covers this; `develop`
  should size the retrofit against all restating bullets, not just the ones already in
  parentheses.
- **AC6's number is stale, independent of this ticket.** 16,415 bytes was the file's exact size
  at the commit before this ticket was created (`d1b2d9f`, 2026-08-26). Two unrelated commits
  since (`ae730bc` 2026-08-29, `260ac0d` 2026-09-08) grew it to 17,290 bytes — 875 over that cap
  before this ticket changes anything, and FR2's retrofit of ~15 missing pointers will add bytes
  on top. Re-baseline AC6 against the size measured at the start of `develop`, not the figure
  below.

## Functional requirements

Written against the third option above and **re-derived once the design decision lands** — if the
answer is the pure-index rewrite, FR2–FR4 are replaced wholesale.

- FR1 — The chosen answer and its reasoning are recorded in `README.md`'s guidance on editing these
  files, so the core's role is stated where an editor reads it rather than inferred from its shape.
- FR2 — Every rule bullet in `CONVENTIONS_CORE.md` that restates a rule carries a resolvable
  pointer to the source file **and** an anchor within it.
- FR3 — `scripts/check-core-drift.sh` reports every core bullet whose anchor no longer resolves in
  its source file, and every core bullet whose source file has been modified more recently than the
  core itself, exiting non-zero when either holds.
- FR4 — That script has `scripts/check-core-drift.test.sh` beside it per this repo's sibling-test
  pattern, with a case proving each of the two failure modes fires independently.
- FR5 — `CLAUDE.md`'s verification bullet names the new check, so it runs with the link checker
  rather than instead of being remembered.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | This item enforces the repo's own no-second-copy rule against its own most-read file; cite that rule, never restate it inside the core or the script | `documentation-conventions.md` |
| Performance | `CONVENTIONS_CORE.md` is loaded into every session in every project, so its size is a cost paid repeatedly. Whichever answer wins must not grow the file — the anchors in FR2 replace text rather than adding to it | `CONVENTIONS_CORE.md`, "Every rule pays rent in context" |

## Acceptance criteria

Confirmed against the design decision above — AC1–AC5 and AC7 stand as written. AC6's byte
figure is corrected below; it was accurate at ticket creation and went stale from unrelated
edits before this ticket started (see Notes & decisions).

- [ ] AC1 — Given `README.md`, when its guidance on editing these files is read, then it states
      whether the core restates rules or indexes them, and why.
- [ ] AC2 — Given `scripts/check-core-drift.sh` run against a fixture where a core bullet's anchor
      is absent from its source file, when it completes, then it exits non-zero naming that bullet.
- [ ] AC3 — Given the same script run against a fixture where a source file's last modification is
      newer than the core's, when it completes, then it exits non-zero naming that file.
- [ ] AC4 — Given the same script run against a fixture where anchors resolve and the core is not
      stale, when it completes, then it exits zero.
- [ ] AC5 — Given the real repo after the change, when `scripts/check-core-drift.sh` is run, then
      it exits zero.
- [ ] AC6 — Given `CONVENTIONS_CORE.md`'s byte count measured at the start of `develop` (**not**
      16,415 — that figure is stale, see Notes & decisions), when the same file is measured after
      this change, then it is no larger than that starting count.
- [ ] AC7 — Given `scripts/check-core-drift.test.sh`, when it is run, then it passes and contains a
      distinct case for AC2 and AC3.

## QA plan

- **Level:** unit — the deliverable is a script with the repo's sibling-`.test.sh` pattern.
- **Why this level:** no runtime and no seam to cross; the doc assertions are greps and a byte
  count run alongside.
- **Specific checks:** `config.yml`'s `unit` command; `wc -c CONVENTIONS_CORE.md` for AC6;
  `scripts/check-convention-links.sh` afterwards, since FR2 edits every pointer in the core and a
  mistyped one is exactly what that script exists to catch.

## Out of scope

- **Asserting that two prose statements mean the same thing.** No script does this, and a ticket
  that promised it would either never close or close on a check that cannot fail. Staleness and a
  missing anchor are the signals available; the design step should say so out loud rather than
  leave the gap implied.
- Restructuring the core into Skills — that is 0007, and it is downstream of a distribution
  decision this item does not need.

## Notes & decisions

- **Why this ranks above the enforcement work in 0004** despite being smaller and less visible: a
  drifted core rule is silently wrong output governing every session in every project, and nobody
  is counting the damage. 0004 prevents specific bad acts that are at least noticeable afterwards.
- **Design decision (2026-09-14):** kept the restatements, rejected the pure-index rewrite — full
  reasoning in "Design decision" above. FR1–FR5 stand unchanged; AC1–AC5 and AC7 confirmed
  unchanged; AC6 corrected in place (byte figure re-baselined, same intent) rather than added to,
  since it's the same criterion with a stale number rather than a new one.
- **AC6's number was never wrong, only aged.** 16,415 bytes matched `CONVENTIONS_CORE.md` exactly
  at commit `d1b2d9f` (2026-08-16), the last edit before this ticket was created (2026-08-26).
  Two later commits unrelated to this ticket — `ae730bc` (2026-08-29, rule/reasoning layering) and
  `260ac0d` (2026-09-08, knowledge-vs-shape duplication) — added core bullets and grew the file to
  17,290 bytes, 875 over the pinned cap, before this ticket's own work starts. A ticket that pins
  an absolute count against a file other tickets also edit needs that count re-measured at
  build time, not trusted from the ticket text — the same staleness this ticket exists to guard
  against, just not yet automated.
- **Sizing note for `develop`:** FR2 requires a pointer on *every* restating bullet, not just the
  ones that already have one. About 15 bullets in Code (lines 20–29), Security (lines 50–53), and
  Testing (lines 35–38) restate rules from `coding-conventions.md`, `security-conventions.md`, and
  `testing-conventions.md` respectively with no pointer today. Budget for creating those, not only
  adding anchors to existing ones — this is very likely to push the file up against AC6's cap
  rather than hold it flat, which is exactly why AC6 needed re-baselining above.
- **AC6 pins an absolute byte count, not a percentage.** The core is a file other tickets in this
  queue also edit, and a target expressed against a moving baseline cannot be closed.
