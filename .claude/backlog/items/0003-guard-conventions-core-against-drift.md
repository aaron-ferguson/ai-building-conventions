---
id: "0003"
title: Guard CONVENTIONS_CORE.md against drift from the files it restates
type: debt
next: design
status: in-progress
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
claimed_by: "d99b"
claimed_at: 2026-09-14T14:17:01Z
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

## Open design question  *(only while `next: design`)*

- **Question:** does `CONVENTIONS_CORE.md` stop restating rules and become a pure trigger index
  (name + when-to-load + pointer, no rule text), or does it keep the restatements and earn them
  with an automated drift guard?
- **Why it blocks specification:** the two answers produce different tickets with no overlap. The
  index answer is a rewrite of the core with an acceptance criterion about what the file no longer
  contains, and it trades away the thing the core is *for* — a session that has loaded nothing else
  still knows not to `git add .`. The guard answer keeps the core as-is and the deliverable is a
  script, with the open sub-question of what a script can actually assert about two prose
  statements saying the same thing. No acceptance criterion can be written until that is settled.
- **A third option worth pricing before choosing:** keep the restatements but make them *cheap to
  check* — each core bullet carries the source file **and an anchor** (a heading or a stable rule
  id), and the guard asserts only that the anchor still exists and that the source file has not
  been edited more recently than the core's line for it. That is mechanically checkable without
  needing to compare meanings, and it converts an unbounded semantic problem into a staleness
  signal. It is the option the item's estimate assumes.
- **Settle it with:** `/design`. This is a reasoned trade-off between context cost and drift risk,
  not something that needs to be seen, so `/prototype` is the wrong tool.

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

Written against the third option; re-derive with the design answer, and un-tick anything the
re-specification touches.

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
- [ ] AC6 — Given `CONVENTIONS_CORE.md` before and after, when byte counts are compared, then the
      file is no larger than 16,415 bytes.
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
- **AC6 pins an absolute byte count, not a percentage.** The core is a file other tickets in this
  queue also edit, and a target expressed against a moving baseline cannot be closed.
