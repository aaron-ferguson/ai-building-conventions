---
id: "0008"
title: Make the Review Checklist runnable without a human memorising it
type: feature
next: develop
status: in-progress
qa_level: verify
size: m
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0004", "0007"]
expects:
  - coding-conventions.md
  - CONVENTIONS_CORE.md
  - README.md
claimed_by: "efa3"
claimed_at: 2026-09-14T18:16:13Z
touches:
  - coding-conventions.md
  - CONVENTIONS_CORE.md
---

## Problem

`coding-conventions.md:184` opens the **Review Checklist** with *"Run this before finalizing any
change — new code, edit, or refactor."* Verified 2026-08-26: it is **42 checkbox items across 15
sections** — NAMING, RESPONSIBILITY, SAFETY, SECURITY, PRIVACY & DATA, USER-FACING UI, COMPLEXITY,
SIDE EFFECTS, COMMENTS, TESTING, ENVIRONMENT & CONFIG, RELEASE, PERSISTED DATA, and two tier
triggers.

Nobody runs 42 items from memory before every edit, and a checklist that is not run is worse than
no checklist: the document asserts the review happened, and the assertion is what gets relied on.

> "The review checklist runs to about 70 items and while I read it it feels like way past a
> reasonable size where a human runs (especially as a memory burn to become a habit) it before
> every change. It is the strongest subagent candidate in the repo: scoped and automated."
> — email thread *AI Building Conventions*, 2026-08-14

The reviewer's own caveat, from the earlier message in the thread, is the reason this is a `develop`
item rather than a design one — the cheap answer may be sufficient and should be tried first:

> "Starting somewhere around Opus 4.8 Claude is more-than-decent about 'doing this on its own' …
> perhaps if you just add a blurb like 'use subagents to perform this task and scope each subagent
> only to tools it needs to perform the ask on a single item on the checklist' will suffice,
> something to test out locally for sure."

This compounds: the checklist grows every time a session's lesson lands in it, and the repo's git
history is largely sessions sharpening rules. Each addition makes the human-run version less likely
to happen while making the document look more thorough.

## Functional requirements

- FR1 — The Review Checklist states how it is meant to be run, at the point where it is read. Today
  it says *run this* and leaves the mechanism to the reader, which is how a 42-item list becomes a
  list nobody runs.
- FR2 — The stated mechanism is delegation to subagents, each scoped to one section and to only the
  tools that section needs. The checklist's existing 15 sections are the natural unit — they are
  already grouped by concern, and a section is small enough for one agent to hold.
- FR3 — The instruction is written as guidance a capable model can act on, not as a rigid
  per-item procedure. Start with the smallest thing that could work — the blurb — and only specify
  further if measurement (FR5) shows it is not enough.
- FR4 — The sections whose items are **already machine-checkable** are marked as such and point at
  the check that covers them, rather than being reviewed by hand a second time. SAFETY and SECURITY
  overlap with what 0004's hooks enforce, and a human re-reading a rule a hook already blocks is
  the ceremony this repo tells other projects to cut.
- FR5 — The change is measured before it is committed to: the checklist is run both ways over the
  same real diff, and what each caught is recorded. A claim that delegation works better than a
  human read is testable in an afternoon, and this repo's own `measurement-conventions.md` requires
  the verdict be recorded even when it is "it didn't work".
- FR6 — `CONVENTIONS_CORE.md`'s pointer to the checklist reflects the new mechanism, since that
  line is what most sessions actually see.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | The mechanism is documented beside the checklist, and the measurement verdict from FR5 is recorded whichever way it comes out | `documentation-conventions.md`, `measurement-conventions.md` |
| Security | The SECURITY section's items must not become weaker by being delegated; a subagent scoped to too few tools that reports "clean" because it could not look is worse than a human skimming | `security-conventions.md` |
| Performance | Fifteen subagents per change is a real cost. The design must say when the full checklist runs versus a scoped subset, or every small edit pays for a full review | `CONVENTIONS_CORE.md`, "Every rule pays rent in context" |

## Acceptance criteria

- [ ] AC1 — Given `coding-conventions.md`'s Review Checklist, when its opening is read, then it
      states how the checklist is run, not only that it must be.
- [ ] AC2 — Given that statement, when it is read by a session facing a real diff, then it is
      actionable without further instruction from the user.
- [ ] AC3 — Given a section whose items are covered by an automated check, when that section is
      read, then it names the check rather than asking for the same review by hand.
- [ ] AC4 — Given the same real diff reviewed both ways, when the results are compared, then both
      lists are recorded in *Notes & decisions*, including anything the delegated run missed that
      the manual run caught.
- [ ] AC5 — Given `CONVENTIONS_CORE.md`, when its pointer to the Review Checklist is read, then it
      matches the mechanism `coding-conventions.md` now states.
- [ ] AC6 — Given `coding-conventions.md` before and after, when byte counts are compared, then the
      file has not grown by more than 1,500 bytes. The fix is a mechanism, not more checklist.

## QA plan

- **Level:** verify — the deliverable is prose plus a measured comparison; no runner applies.
- **Why this level:** AC4 is the substantive assertion and it is a scored comparison of two review
  runs over one diff, which no suite in this repo can drive.
- **Specific checks:** `wc -c coding-conventions.md` for AC6; the AC4 comparison run against a real
  multi-file diff from this repo's own history, not a toy one; `scripts/check-convention-links.sh`
  for AC5.

## Out of scope

- **Writing the subagent definitions as shipped artifacts.** Where a reusable agent definition would
  live is 0006's question and this item must not pre-empt it. The deliverable here is the
  instruction; if measurement shows the instruction alone is not enough, that finding becomes the
  ticket for the definitions.
- Editing the content of any checklist item. Reorganising how the list is run must not quietly
  change what it checks, or neither change can be reviewed.

## Notes & decisions

- **The reviewer's item count was ~70; the actual count is 42 across 15 sections.** The argument is
  unaffected — 42 is still far past what anyone runs from memory — but the ticket cites the
  verified number so a later reader is not comparing against a figure that was never right.
- **Why FR3 argues for the smallest version first.** The repo's own YAGNI rule and the reviewer's
  note about newer models point the same way: an elaborate per-item procedure is speculative until
  the blurb has been shown to fail. FR5 is what turns that from a preference into a decision.
