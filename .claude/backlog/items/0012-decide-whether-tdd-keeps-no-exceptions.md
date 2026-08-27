---
id: "0012"
title: Decide whether TDD keeps its "no exceptions" framing
type: chore
next: design
status: ready
qa_level: verify
size: s
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0005"]
expects:
  - CONVENTIONS_CORE.md
  - testing-conventions.md
claimed_by:
claimed_at:
touches:
---

## Problem

`CONVENTIONS_CORE.md` states *"TDD always: write the test first → confirm red → implement → confirm
green → commit. No exceptions."* `testing-conventions.md:9` is marginally softer — *"No exceptions
for functional changes"* — and the two do not say quite the same thing.

The reviewer, who opened by naming the principle/preference split as the best thing in the repo,
flagged this as the place it is not applied:

> "Then I saw 'TDD always, no exceptions.' It is stated there without the wiggle room and is a
> thing that both developers as well as Agents will skip the most. Perhaps consider making TDD a
> strong default with room for exceptions."
> — email thread *AI Building Conventions*, 2026-08-14

The argument is not that TDD is wrong. It is that an absolute rule which is in practice
routinely skipped costs more than a strong default with stated exceptions, because the gap between
what the document says and what happens teaches the reader that the document is aspirational — and
that lesson generalises to the rules where it would be expensive.

**This is a deliberate stance in the repo, not an oversight**, which is why it is queued as a
decision and not a fix. `CONVENTIONS_CORE.md` names TDD explicitly as a principle, and its
calibration section states the design: *"the default written down is the thorough, more-protective
one"*, and *"scaling down is a decision that gets written into the project's CLAUDE.md — never a
default, and never something that happens by drift or under time pressure."* Read that way, the
existing rule already has the escape hatch the reviewer is asking for; it just requires the
skipping to be *declared* rather than silent. Whether that is sufficient is the question.

## Open design question  *(only while `next: design`)*

- **Question:** does TDD stay an unqualified principle, or become a strong default with stated
  exceptions?
  1. **Keep it absolute**, and make the existing escape hatch visible at the point of the rule —
     the core's TDD bullet says "no exceptions" and never mentions that a project may record a
     scale-down in its `CLAUDE.md`, so a reader meets the absolute and not the mechanism.
  2. **Strong default with a named exception list** — spike code destined to be thrown away,
     a one-line config change, a change with no functional surface. Honest about practice, and the
     risk is that the list becomes the path of least resistance.
  3. **Keep it absolute and reconcile the two files' wording**, treating the difference between
     "no exceptions" and "no exceptions for functional changes" as the real defect.
- **Why it blocks specification:** each answer edits a different file in a different direction, and
  option 2 requires an exception list nobody has drafted.
- **The evidence that should decide it, and which nobody has:** how often TDD is actually skipped
  in Aaron's own sessions, and what happened when it was. `measurement-conventions.md` requires a
  verdict be recorded even when it is unflattering; a look at this repo's and one project's recent
  history would turn this from an argument into an observation.
- **Interacts with 0005.** If that item inverts the labelling default, TDD's standing has to be
  explicitly marked either way, and the two decisions should be made in a consistent direction.
- **Settle it with:** `/design`.

## Functional requirements

Re-derived once the decision lands. These hold under any answer:

- FR1 — `CONVENTIONS_CORE.md` and `testing-conventions.md` state the same rule in the same terms.
  Whichever answer wins, the two files' present disagreement is a defect on its own.
- FR2 — Wherever the rule is stated, the mechanism for departing from it — whatever that is under
  the chosen answer — is visible at that point rather than in a section the reader may not reach.
- FR3 — The decision and its reasoning are recorded, so the next reviewer to raise this meets an
  answer instead of an argument.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | The reasoning lands with the change, and the two files stop disagreeing | `documentation-conventions.md` |
| Performance | Whatever is added is added to the always-loaded core; an exception list is exactly the kind of growth `CONVENTIONS_CORE.md` warns about paying rent for | `CONVENTIONS_CORE.md`, "Every rule pays rent in context" |

## Acceptance criteria

Re-derive with the design answer; un-tick anything the re-specification touches.

- [ ] AC1 — Given `CONVENTIONS_CORE.md` and `testing-conventions.md`, when the TDD rule is read in
      each, then both state the same rule with no difference in scope.
- [ ] AC2 — Given the rule as stated in the core, when read by someone who reads nothing else, then
      they can tell whether a departure is permitted and what it requires.
- [ ] AC3 — Given the decision, when *Notes & decisions* is read, then it records which option was
      chosen and what was weighed.
- [ ] AC4 — Given the core before and after, when byte counts are compared, then the file has not
      grown by more than 400 bytes.

## QA plan

- **Level:** verify — prose, no runner.
- **Why this level:** nothing executes.
- **Specific checks:** `grep -n 'TDD' CONVENTIONS_CORE.md testing-conventions.md` and a read of
  both hits side by side for AC1; `wc -c CONVENTIONS_CORE.md` for AC4.

## Out of scope

- **Changing the TDD cycle itself** — red, implement, green, commit is not in question.
- The wider labelling default, which is 0005. This item settles one rule's standing; that one
  settles how standing is expressed across the suite.

## Notes & decisions

- **Queued as a decision, not a fix, on purpose.** The reviewer is arguing against a considered
  position, and the repo's calibration section is a real answer to him — it may simply not be
  visible from where the rule is stated. An agent should not resolve this by quietly softening a
  rule the author deliberately made absolute.
