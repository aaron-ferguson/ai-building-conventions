---
id: "0005"
title: Fix the default that makes every unlabeled rule non-negotiable
type: bug
next: design
status: ready
qa_level: verify
size: m
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0003", "0012"]
expects:
  - CONVENTIONS_CORE.md
  - README.md
  - coding-conventions.md
  - collaboration-modes.md
  - companies/_template.md
claimed_by:
claimed_at:
touches:
---

## Problem

`CONVENTIONS_CORE.md` splits every rule into two kinds — **principles**, which no project may
override, and **preferences**, which a project or company profile may. The reviewer named this
split as the best thing in the repo. Then it states the default (verified 2026-08-26,
`CONVENTIONS_CORE.md`, *Profiles & How Overrides Work*):

> "When a rule is an overridable preference, its file says so explicitly; assume everything else is
> a principle."

Labelling is opt-in for preferences only, so the unlabeled majority is silently non-negotiable.
That sweeps in rules nobody would defend as inviolable — *max 2 levels of nesting*, *functions are
verbs*, *no clever one-liners*, *files are named for what they do* — and gives them the same
standing as *validate all external input server-side* and *secrets never appear in source*.

> "The default for unlabeled rules is backwards. In core we have preference will be marked as such
> and all else falls under principle but then there is a myriad of things that are unlabeled (e.g.
> two-levels nesting max, no abbreviations…) so under the stated default all of them are technically
> non-negotiable and cannot be overridden which is unlikely a good choice."
> — email thread *AI Building Conventions*, 2026-08-14 (attributed there to Claude)

Two costs, and the second is the one that matters. An agent reading the default refuses a
reasonable project-level override of a style rule. And a document where everything is
non-negotiable trains the reader that nothing is — which spends the credibility that makes the
genuine principles hold.

## Open design question  *(only while `next: design`)*

- **Question:** which way does the default point, and what carries the label?
  Three candidates, and the choice determines the ticket:
  1. **Invert it** — unlabeled means preference; principles are explicitly marked. Smallest set to
     label, and the set is stable (correctness and safety rules change rarely). Risk: a genuine
     principle that nobody remembered to mark becomes overridable, which is the failure direction
     that costs the most.
  2. **Require a label on every rule** — no default at all, and a script fails on an unlabeled
     rule. Removes the failure mode in both directions and is the only option that stays true as
     rules are added, but it is the largest edit and adds a marker to every bullet in the suite.
  3. **Keep the default and narrow its scope** — principle-by-default applies only within the files
     that carry correctness and safety rules; the craft and style files default to preference.
     Cheapest, but it moves the ambiguity to "which kind of file is this?" rather than removing it.
- **Why it blocks specification:** the acceptance criteria differ completely — option 1 is an edit
  to one paragraph plus marking perhaps a dozen rules, option 2 is a suite-wide edit plus a
  checker with its own tests, option 3 is a paragraph and a per-file front-matter line. No FR list
  survives the choice.
- **A constraint the decision must respect:** `CONVENTIONS_CORE.md` states its own calibration —
  *"the default written down is the thorough, more-protective one"* and *"scaling down never
  touches a principle."* Whichever option wins has to be reconcilable with that, or that paragraph
  changes too and the change is stated rather than left to contradict itself.
- **Settle it with:** `/design`.

## Functional requirements

Re-derived once the decision lands. These hold under every option:

- FR1 — `CONVENTIONS_CORE.md`'s *Profiles & How Overrides Work* section states the chosen default
  unambiguously, in a form that tells a reader what an **unlabeled** rule is without consulting
  another file.
- FR2 — Every rule whose standing changes under the new default is labelled, so the change is
  applied rather than only announced.
- FR3 — `README.md`'s guidance on adding a rule to these files states how a new rule gets its
  label, since the default is only stable if the next rule written follows it.
- FR4 — The reasoning is recorded where a future reader will hit the question, not only in this
  ticket.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | The decision and its reasoning land in the same change as the edit, per the repo's own "document what you learned in the same change" rule | `documentation-conventions.md` |
| Performance | Labels are added to an always-loaded file; whatever marker is chosen must be short, because `CONVENTIONS_CORE.md` is loaded into every session in every project | `CONVENTIONS_CORE.md`, "Every rule pays rent in context" |

## Acceptance criteria

Re-derive with the design answer; un-tick anything the re-specification touches.

- [ ] AC1 — Given `CONVENTIONS_CORE.md`, when the overrides section is read, then it states what an
      unlabeled rule is, in one sentence, with no forward reference.
- [ ] AC2 — Given the chosen option, when the rules whose standing it changes are inspected, then
      each carries the label the new default requires.
- [ ] AC3 — Given `README.md`, when its guidance on adding a rule is read, then it says how the new
      rule is labelled.
- [ ] AC4 — Given `CONVENTIONS_CORE.md`'s calibration paragraph, when it is read alongside the new
      default, then the two do not contradict each other.
- [ ] AC5 — Given the security, testing, privacy and accessibility rules in
      `CONVENTIONS_CORE.md`, when each is read under the new default, then each is still
      non-overridable. The change must not weaken a genuine principle as a side effect.

## QA plan

- **Level:** verify — prose only, no runner applies.
- **Why this level:** there is nothing to execute; the assertions are greps and a read.
- **Specific checks:** grep `CONVENTIONS_CORE.md` for the chosen label marker and count the
  labelled rules against the list the design step produced; read AC4 and AC5 by hand, since "do
  these two paragraphs contradict each other" is not greppable and the ticket should not pretend
  otherwise. Run `scripts/check-convention-links.sh` afterwards — FR2 touches many files.

## Out of scope

- **Re-deciding which specific rules are principles.** This item fixes the *default* and labels
  what the default changes. An argument about one rule's standing is its own ticket — TDD's is
  0012, and it is deliberately separate so this one does not become a referendum.
- Anything about company-profile precedence, which is orthogonal and already stated.

## Notes & decisions

- **Why the failure directions are asymmetric**, and why the design step should weigh them rather
  than counting rules: an over-strict default costs an argument, and a too-loose default costs a
  principle nobody notices was dropped. That asymmetry is the reason option 2 exists despite being
  the most work.
