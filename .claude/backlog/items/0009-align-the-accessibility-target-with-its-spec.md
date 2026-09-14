---
id: "0009"
title: Align the accessibility target with the spec version it links
type: bug
next: develop
status: in-progress
qa_level: verify
size: s
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: []
expects:
  - accessibility-conventions.md
  - CONVENTIONS_CORE.md
claimed_by: "2679"
claimed_at: 2026-09-14T18:18:35Z
touches:
---

## Problem

`accessibility-conventions.md:7` reads:

> **Target:** WCAG 2.1 **AA** is the working default. See more details at
> https://www.w3.org/TR/WCAG22/.

The stated target is 2.1; the link is 2.2. Verified 2026-08-26.

> "The accessibility file targets WCAG 2.1 AA and links to the 2.2 spec."
> — email thread *AI Building Conventions*, 2026-08-14

This is one line, and it is wrong in the direction that costs something. WCAG 2.2 AA adds success
criteria 2.1 does not have — among them focus appearance, dragging movements, target size, and
accessible authentication. A project reading "2.1 AA" builds to the older bar; anyone following the
link and reading the newer spec builds to a different one; and both believe they are following the
same convention. Accessibility is a non-negotiable principle in `CONVENTIONS_CORE.md`, so an
ambiguous target undercuts a rule that is supposed to be the firmest kind.

## Functional requirements

- FR1 — The stated target and the linked spec are the same version.
- FR2 — The version chosen is **WCAG 2.2 AA**, the current W3C Recommendation and the one already
  linked. Choosing the lower bar is a deliberate scale-down and would need to be recorded as one
  per `CONVENTIONS_CORE.md`; nothing in the file records it, which is what identifies this as an
  oversight rather than a decision.
- FR3 — The file names what 2.2 adds over 2.1 in a line or two, so a project already built to 2.1
  can see what changed rather than re-reading the spec to find out.
- FR4 — Any other reference to a WCAG version in the suite matches. A one-line fix that leaves a
  second copy saying something else recreates the defect.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Accessibility | This item *is* the accessibility target; it must raise the stated bar to the linked spec, not lower the link to the stated bar | `accessibility-conventions.md` |
| Documentation | FR3's summary of the delta is the "document what you learned in the same change" rule applied to the file being fixed | `documentation-conventions.md` |
| Deprecation | Projects built to 2.1 AA under the old text are not retroactively non-compliant; the file should say whether the new target applies to new work only | `deprecation-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given `accessibility-conventions.md`, when `grep -n 'WCAG 2\.1'` is run, then it
      returns no line that states 2.1 as the target.
- [ ] AC2 — Given the same file, when the Target line is read, then the version it names and the
      version its URL points at are identical.
- [ ] AC3 — Given the same file, when it is read, then it names at least three success criteria
      2.2 AA adds over 2.1 AA.
- [ ] AC4 — Given the whole repo, when `grep -rn 'WCAG' --include='*.md' .` is run, then every hit
      names the same version.
- [ ] AC5 — Given `accessibility-conventions.md`, when the target section is read, then it states
      whether the new target applies to new work only or to existing projects too.

## QA plan

- **Level:** verify — a prose fix with no runner.
- **Why this level:** the assertions are greps over one line and its neighbours.
- **Specific checks:** the literal greps in AC1 and AC4; `scripts/check-convention-links.sh`
  afterwards.

## Out of scope

- Auditing any project against 2.2. This item fixes the convention's statement of its own target;
  what that implies for existing projects is each project's ticket.

## Notes & decisions

- **Why a one-line fix is queued rather than just done.** It is a target change to a non-negotiable
  principle, and FR3 and FR4 are the parts that make it stick — a session that fixed only the
  visible mismatch would leave the delta undocumented and any second reference unchecked.
