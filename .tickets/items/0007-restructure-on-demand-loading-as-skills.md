---
id: "0007"
title: Restructure on-demand rule loading as Claude Skills
type: feature
next: design
status: blocked
qa_level: verify
size: l
created: 2026-08-26
source: external:email-2026-08-14-bozidar
parent:
blocked_by: ["0006"]
relates: ["0003", "0008"]
expects:
  - CONVENTIONS_CORE.md
  - README.md
  - CLAUDE.md
claimed_by:
claimed_at:
touches:
---

## Problem

The suite loads rules by asking the model to read an index and choose well. `CONVENTIONS_CORE.md`
ends with a *Load for More Detail* section listing 34 files and when each applies; every session,
in every project, the model is expected to notice that the task in front of it triggers
`migration-conventions.md` and go read it.

That is a **compliance problem solved with content**, and Claude Code has a mechanism built for
exactly this shape — Skills, matched on description metadata, loaded by the harness rather than by
the model's diligence.

> "Your structure for this appears entirely 'homegrown' so to speak while Claude already has
> machinery/conventions to handle this in a 'Claude-way' … On demand loading is the core approach,
> and as-written relies on Claude reading an index and choosing well among tens of files. Claude
> Skills will turn that into a matching problem with metadata instead of a compliance problem with
> content. Another cool thing that I *particularly love* about Skills is that I can see feedback
> while Claude is running that it found a skill and loaded it."
> — email thread *AI Building Conventions*, 2026-08-14

Two things follow. The failure is **silent**: when the model does not load
`migration-conventions.md`, the session proceeds without it and nothing in the transcript says so,
so neither the model nor Aaron can tell a session that applied the migration rules from one that
never saw them. And the index grows: 34 files today, and every new convention file makes the
matching harder while adding a line to the always-loaded core.

## Open design question  *(only while `next: design`)*

- **Question:** which convention files become Skills, and which stay as text the core points at?
  Not every file is a Skill-shaped thing. `incident-conventions.md` — *load only during or right
  after one* — is a near-perfect trigger match. `coding-conventions.md` applies to almost every
  session and might be better always-on. The all-or-nothing framings are both probably wrong, and
  the decision is where the line falls.
- **Sub-questions the answer has to cover:**
  - Do the rules stay in one file per topic, or does a Skill's progressive disclosure change how
    each file is structured?
  - What happens to `CONVENTIONS_CORE.md` if the index it carries is replaced by Skill matching —
    which interacts directly with 0003's question about whether the core restates or indexes.
  - How does a project override a preference when the rule arrives via a Skill rather than an
    import? The precedence chain — project `CLAUDE.md` > company profile > general default — has
    to keep working.
- **Why it blocks specification:** no acceptance criterion can be written before the set of Skills
  is chosen, because the criteria are per-Skill.
- **Blocked on 0006** because a Skill has to be installed from somewhere, and the checkout-relative
  and plugin answers put Skills in different places with different update paths.
- **Settle it with:** `/design`, then verify the matching behaviour by running real tasks against
  the candidate descriptions — the reviewer's own question was whether Aaron had *"ran into an
  issue where you expected Claude to 'match' something but it just did not do it"*, and the honest
  answer is that nobody has measured it either way.

## Functional requirements

Re-derived once the decision lands. These hold under any answer:

- FR1 — For each convention that becomes a Skill, its trigger is expressed as description metadata
  the harness matches on, not as a line in an index the model is asked to consult.
- FR2 — A session that loads a convention shows that it did. The visible-load feedback is a
  substantial part of the value here, because it is what makes a missed match observable.
- FR3 — The preference-override precedence stated in `CONVENTIONS_CORE.md` still holds for a rule
  delivered as a Skill, and `README.md` says how.
- FR4 — Anything that stops being reachable through the core's index is reachable some other stated
  way. A file that no session can now load is worse than one it might forget to.
- FR5 — Before the restructure is committed to, the matching is measured: a set of representative
  tasks is run against the candidate Skill descriptions and the match rate recorded. A refactor
  justified by "matching beats compliance" that never measured either is an assertion.

## Non-functional requirements

| Dimension | Requirement for this item | Convention |
|---|---|---|
| Documentation | The new loading model is described in `README.md` in the same change, and the old wiring is not left described alongside it | `documentation-conventions.md` |
| Deprecation | Projects wired by `@` import keep working, or get a replacement path and notice proportional to the switching cost — several projects reference these files today | `deprecation-conventions.md` |
| Performance | Skills that match too broadly cost context in every session; the descriptions are the control and FR5 is how their cost is seen | `CONVENTIONS_CORE.md`, "Every rule pays rent in context" |
| Dependencies | A Skill-based suite must degrade to readable Markdown for anyone not using Claude Code, or the decision to drop that audience is stated | `dependency-conventions.md` |

## Acceptance criteria

Re-derive with the design answer; un-tick anything the re-specification touches.

- [ ] AC1 — Given a task that triggers a convention now delivered as a Skill, when a session runs
      it, then the Skill loads and the session shows that it loaded.
- [ ] AC2 — Given the representative task set from FR5, when it is run before and after, then the
      match rate for each is recorded in *Notes & decisions* — including the cases that got worse.
- [ ] AC3 — Given a project that overrides a preference in its own `CLAUDE.md`, when the governing
      Skill loads, then the project's value wins.
- [ ] AC4 — Given every convention file, when the new structure is read, then each is reachable by
      a stated mechanism, and `scripts/check-convention-links.sh` exits zero.
- [ ] AC5 — Given a project still wired by `@` import, when a session runs, then it either still
      works or `README.md` states its migration path.

## QA plan

- **Level:** verify — the deliverable is structure and metadata; no test runner applies.
- **Why this level:** the one real measurement, AC2, is a set of scripted session runs whose
  scoring is a human read of whether the right file loaded. Naming it as the assertion is honest;
  pretending a suite covers it is not.
- **Specific checks:** the FR5 task set, run and scored; `scripts/check-convention-links.sh`;
  `scripts/check-core-drift.sh` if 0003 has landed by then, since this item rewrites what the core
  points at.

## Out of scope

- Deciding the distribution channel — that is 0006, and this item is blocked on it.
- Rewriting the *content* of any convention. This is a change to how rules are loaded, not to what
  they say. A restructure that quietly edits rules cannot be reviewed as either.

## Notes & decisions

- **Why FR5 exists.** The reviewer's case for Skills is strong but untested here, and the same
  email notes that with newer models the trend runs the other way — *"it might be better to give
  them general guidance and let them figure things out."* Both cannot be right for this repo.
  Measuring before restructuring 34 files is cheap; discovering afterwards is not.
- **Why this sits below 0005 despite being the reviewer's headline point.** 0005 is small, certain,
  and changes the meaning of every rule in the suite including the ones this item would package.
  Relabelling first means the Skills carry the corrected semantics rather than being redone.
