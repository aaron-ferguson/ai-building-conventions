---
id: "0010"
title: Add conventions for working with Claude itself
type: feature
next: design
status: ready
qa_level: verify
size: l
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: []
relates: ["0007", "0008"]
expects:
  - CONVENTIONS_CORE.md
  - README.md
  - claude-code-model-config.md
claimed_by:
claimed_at:
touches:
---

## Problem

The suite covers the whole lifecycle from discovery to deprecation, and says a great deal about
what AI-assisted work must produce — review every diff, never delegate architecture or security
design, document what you learned. It says almost nothing about **how to actually run the sessions
that produce it**. Verified 2026-08-26: the only file about the tool itself is
`claude-code-model-config.md`, 2.5KB on alias mapping and settings precedence.

Missing entirely: managing context through a long-running task, when a subagent is the right tool
and how to scope one, planning before executing, how a session hands off to the next one.

> "The biggest thing I think is missing is guidance on how to effectively work with Claude itself.
> If this is top-level Claude-foo it feels like there should be strong guidance on what good
> project-level Claude-foo is, guidance on how to manage context through long-running tasks
> (probably the biggest issue that Users will hit), how to effectively use subagents, how to plan,
> execute …"
> — email thread *AI Building Conventions*, 2026-08-14

References the reviewer offered, and uses himself alongside his own setup:

- https://github.com/garrytan/gstack
- https://github.com/obra/superpowers
- https://dive.vladyslavpodoliako.com/

The gap has a visible cost inside this repo already. Two of the three most substantial rules added
to `testing-conventions.md` recently are about a session mis-verifying its own work — confirming a
mutation landed, keeping fixtures independent of the tree. Those are context-and-execution
failures that landed in a *testing* file because there was nowhere else to put them.

## Open design question  *(only while `next: design`)*

- **Question:** what belongs in a convention here, versus what is a *skill* or a *workflow* that
  should not be written down as a rule at all?
  The distinction matters more here than anywhere else in the suite. "Compact before context runs
  out" is a technique that changes with every release; "a session hands off through a durable
  artifact, never through the conversation" is a principle that will outlive several. A file full
  of the first kind is stale in a quarter and is exactly the context-bloat this repo warns about.
- **Sub-questions:**
  - One file, or several? Context management, subagents, and plan/execute are three different
    subjects with three different trigger conditions.
  - How does this relate to the `ai-building-tools` skills Aaron already runs — `/queue`,
    `/develop`, `/verify`, `/retro` — which encode a plan-execute-verify loop in working code? A
    convention that describes a workflow those skills already implement is a second copy, and this
    repo's own rule says the second copy drifts.
  - Which of the reviewer's three references say something durable, and which are one team's
    current tooling? Reading them is part of the design step, not a substitute for it.
- **Why it blocks specification:** the answer decides whether the deliverable is one 6KB principles
  file or a set of Skills, and no acceptance criterion survives that choice.
- **Settle it with:** `/design`, after reading the three references.

## Functional requirements

Re-derived once the decision lands. These hold under any answer:

- FR1 — Context management through a long-running task is covered: how a session knows it is losing
  the thread, and what it does about it. The reviewer called this the biggest issue users hit.
- FR2 — Subagent use is covered: when delegation is right, how to scope one, and what a subagent's
  result is worth — the suite already says LLM output is untrusted input, and a subagent's report
  is LLM output.
- FR3 — Handoff between sessions is covered: what a session must leave behind so the next one can
  continue without the conversation. This repo already learned that lesson twice — `FINDINGS.md`
  exists because of it, and the `ai-building-tools` backlog carries handoff in a ticket field.
- FR4 — Every rule written here is durable at the level `CONVENTIONS_CORE.md` demands: it states
  the failure it prevents, and it does not depend on a UI affordance or a flag that will be renamed.
  Anything that fails that test is a note in a project's `CLAUDE.md`, not a convention.
- FR5 — Nothing here restates what the `ai-building-tools` skills already implement; where a
  workflow exists in code, the convention cites it.
- FR6 — `CONVENTIONS_CORE.md`'s index gains the new file or files with a trigger, and its **AI
  Workflow** section stays the summary rather than growing a second copy of the detail.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | This is a new convention file; it takes the same standards as any other — cite rather than restate, and state the failure each rule prevents | `documentation-conventions.md` |
| Privacy & data | Any guidance about what goes into a session's context has to hold the line already set: no court, case, or PII data reaches an external provider, and secrets never enter AI context | `data-privacy-conventions.md`, `security-conventions.md` |
| Performance | The suite is already 34 files and the core already 16KB. A new always-relevant file is the most expensive kind of addition; the trigger has to be sharp or this pays rent in every session | `CONVENTIONS_CORE.md`, "Every rule pays rent in context" |
| Dependencies | Guidance tied to one vendor's current UI is a dependency with no lockfile. Prefer rules that hold for any capable agent | `dependency-conventions.md` |

## Acceptance criteria

Re-derive with the design answer; un-tick anything the re-specification touches.

- [ ] AC1 — Given the new file or files, when read, then each of context management, subagent use,
      and session handoff is covered by at least one rule that states the failure it prevents.
- [ ] AC2 — Given each rule, when tested against FR4, then none depends on a named UI affordance,
      keyboard shortcut, or flag.
- [ ] AC3 — Given the `ai-building-tools` skills, when the new content is compared against them,
      then no workflow they implement is restated here, and each is cited where relevant.
- [ ] AC4 — Given `CONVENTIONS_CORE.md`, when its index is read, then the new file appears with a
      trigger, and the AI Workflow section has not grown into a duplicate of it.
- [ ] AC5 — Given the two testing rules about mis-verified work, when the new file is read, then it
      is clear whether they now belong here; if they stay in `testing-conventions.md`, the reason
      is recorded.
- [ ] AC6 — Given the three reviewer references, when *Notes & decisions* is read, then it records
      what each contributed and what was deliberately left out.

## QA plan

- **Level:** verify — new prose, no runner.
- **Why this level:** nothing executes; the assertions are structured reads plus
  `scripts/check-convention-links.sh` for the index wiring.
- **Specific checks:** `scripts/check-convention-links.sh`; AC2 walked rule by rule; `wc -c` on the
  new file against the size the design step budgeted.

## Out of scope

- **Model selection and settings precedence** — `claude-code-model-config.md` already covers it and
  a second copy would drift.
- **Anything about this repo's own distribution as Skills** — that is 0006 and 0007. What this item
  produces has to survive either answer.

## Notes & decisions

- **Why this ranks in Tier 4 despite the reviewer calling it the biggest gap.** It is an absence of
  value, not a defect that gets worse: nothing degrades while it waits, and every ticket above it
  either bleeds now or compounds. It is the top of its tier, and it is the most valuable thing in
  the queue once the compounding work is clear.
