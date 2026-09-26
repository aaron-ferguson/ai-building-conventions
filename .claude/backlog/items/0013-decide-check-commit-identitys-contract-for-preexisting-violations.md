---
id: "0013"
title: Decide check-commit-identity.sh's contract for pre-existing violations
type: bug
next: design
status: ready
qa_level: unit
size: s
created: 2026-09-26
source: agent
parent:
blocked_by: []
relates: ["0001"]
expects:
  - scripts/check-commit-identity.sh
  - scripts/check-commit-identity.test.sh
  - git-conventions.md
claimed_by:
claimed_at:
touches:
---

## Problem

`scripts/check-commit-identity.sh` prints `134 disallowed commit identity reference(s)` against
this repo's history and still **exits 0** — verified while item 0001 was being verified, and again
while scoping this ticket. The script correctly flags that 134 commits reachable from `main` carry
a corporate committer/author email on what `CLAUDE.md`'s *Environments* block states is a
**public** remote, and the local git config is already correct going forward (every commit made
since is clean).

Nobody has decided whether exiting 0 here is the intended contract. Two readings are both
plausible and nothing in the script or its docs says which is meant:

1. **Deliberate.** History on a public remote is forward-only and cannot be rewritten
   (`migration-conventions.md`'s forward-only principle applies to a git remote as much as a
   database), so failing on unrewindable history would make the guard permanently red for a
   reason nobody can act on.
2. **An oversight.** The guard should fail on *new* violations only (a comparison against the
   previous run, or against a recorded baseline count), so a regression is caught while the
   historical 134 don't block anything.

`cicd-conventions.md`'s newly-landed rule — *a check introduced against an already-dirty codebase
gets a remediation decision in the same change, not silence* — names exactly this gap: the guard
shipped (item 0001) without anyone deciding what happens to the violations it already knew about.

## Open design question  *(only while `next: design`)*

- **Question:** does `check-commit-identity.sh` intentionally exit 0 on pre-existing violations
  (documented as such), or should it fail on *new* violations introduced after a recorded
  baseline?
- **Why it blocks specification:** the two answers produce different scripts — one needs a
  baseline file and a comparison; the other needs only a comment and a NOTES entry explaining why
  exit 0 is correct. The acceptance criteria can't be written until one is chosen.
- **A constraint the decision must respect:** rewriting history on this repo's public remote is
  explicitly out of scope per `CLAUDE.md`'s *Environments* block (admin operations need the owning
  account) — whichever option wins, it cannot assume history gets rewritten.
- **Settle it with:** `/design`.

## Functional requirements

Re-derived once the decision lands.

## Non-functional requirements

| Dimension | Requirement for this item | How it would red | Convention |
|---|---|---|---|
| Documentation | Whichever contract is chosen is stated in the script's own header comment, not only in this ticket | a reader of the script alone cannot tell why it exits 0 | `documentation-conventions.md` |

## Acceptance criteria

Re-derive with the design answer.

- [ ] AC1 — Given the script's header comment, when a reader who has not seen this ticket reads
      it, then they can state whether exit 0 on pre-existing violations is intended and why.

## QA plan

- **Level:** unit — `scripts/check-commit-identity.test.sh` already exercises this script; extend
  it for whichever contract is chosen.
- **Why this level:** the guard's behavior is a pure function over `git log`, matching the repo's
  established sibling-`.test.sh` pattern.
- **Specific checks:** re-derived once the option is chosen.

## Out of scope

- Rewriting or squashing this repo's history to remove the 134 existing violations.

## Notes & decisions

- 2026-09-26 — Filed by `retro`, draining two related `.claude/backlog/FINDINGS.md` entries dated
  2026-09-14 (the exit-0 observation from verifying item 0001, and the "no remediation ticket"
  observation from item 0004's build) rather than leaving the decision unowned. Both entries
  concerned the same underlying question and are merged into this one ticket rather than filed
  twice.
