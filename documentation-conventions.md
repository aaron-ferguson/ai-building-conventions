# Documentation Conventions

This file defines documentation expectations for all projects. Durability is mostly about future readers — including future AI sessions with no memory of why anything is the way it is.

---

## README Baseline

Every project's README answers, in this order:

1. **What this is** — one paragraph, plain language.
2. **How to run it** — the exact commands, including env vars needed (names only, see `security-conventions.md`).
3. **How to test it** — the command and any setup.
4. **How to deploy it** — or a pointer to where that's documented.

If a new machine can't go from clone to running app using only the README, the README is broken. Fix it in the same change that revealed the gap.

**Verify a setup doc's commands; don't just read them.** Nobody re-reads instructions for a project they can already run, so drift surfaces only for a newcomer. Script the check — do the task-runner targets and paths a doc names still exist? — and treat a broken instruction as a bug in the same commit. Changing an environment (a new local dependency, a moved config file) invalidates setup docs nothing else references.

## Tactical Records Live Outside the Conventions

A durable principle and a record of one event are different kinds of document, and mixing them makes both harder to use. Postmortems, incident timelines, and status notes are **tactical artifacts** — they never go in the conventions directory. Where they *do* go is declared per project: the company profile names the system for company work, and a solo project defaults to `docs/incidents/` in its own repo with one dated file per event. See `incident-conventions.md` for the rule and its one exception (records holding personal or exploitable detail don't go in a shareable repo).

## Separate the Rule From the Reasoning

A rule and the derivation behind it are different documents with different readers. The rule is read every time; the derivation is read once — when the rule is challenged, or a decision it governs goes wrong. Inlining the second into the first lengthens the always-loaded document for a payoff that lands rarely.

**The operative document carries the rule and a pointer; the log carries why.** Three layers, read from most often to least:

- **Always loaded** — CLAUDE.md, the entry-point README. Invariants and pointers, nothing else.
- **Loaded for the task** — the file that owns a figure, an interface, a decision. The rule, the constraint, and any caveat that changes how the thing is read.
- **Loaded on demand** — decision log, ADRs, findings register. What was tried, what was disproved, what moved when.

**This trade deliberately loses some of the time.** Reasoning kept out of the loaded layers means a mistake occasionally gets made that a longer document would have prevented. That is the cheaper failure: the log is one hop away, so a caught mistake is diagnosed and corrected in minutes, while a bloated document dilutes every rule in it, in every session, forever. Optimise for recovering fast over pre-empting everything.

**Two things never move to the log.** A caveat that changes how a live figure or interface is read (this is an estimate; this is a request, not an agreed term), and a rule an agent could violate before it thinks to open another file. Those are operative, not historical — a correction lives with the thing it corrects.

## Write It Down When You Learn It, Not When You Finish

Every other trigger in this file fires on a **change** — you edited the deploy path, so you
update CLAUDE.md. Discovery needs its own trigger, because the most valuable thing a session
produces is often something nobody set out to change: why a bug was possible, what the
failing thing actually was, which plausible explanation was wrong.

That knowledge decays fast. It is complete in the moment you understand it, half gone by the
end of the session, and unrecoverable to the next reader, who sees only a diff that looks
obvious in hindsight. **Waiting until the work is finished is already too late, and waiting
to be asked means it is the human remembering, not the process working.**

Write it down in the same change as the code, when any of these happens:

- **A bug turns out to have a non-obvious mechanism.** Record the mechanism, not the symptom.
  The next reader gets the fix from the diff; what they cannot get is why it was possible.
- **You were wrong on the way to being right.** A theory you tested and disproved is worth as
  much as the answer — it stops the next session re-running the same dead end.
- **Something looked like noise and wasn't** (flake, "just a timeout", "probably unrelated").
  Say what distinguished the real cause, so the next occurrence isn't dismissed the same way.
- **A stated rule turned out to be wrong or misleading.** Fix the rule in that change. A
  document that misled you once will mislead the next reader identically.
- **You hit a trap that cost real time** — a corrupted cache, a config in two places, a
  silently ignored setting. Cheap to write, expensive to rediscover.

Where it goes follows the rules already in this file: a debated or expensive-to-reverse
decision becomes an ADR; a durable invariant goes in CLAUDE.md; a mechanism belongs in the
working doc for that class of problem, next to the related findings. If no such doc exists,
start one — a findings register that grows is worth more than five orphaned notes.

## Decision Records (Lightweight ADRs)

Write a decision record when a decision is **expensive to reverse** or **was genuinely debated** — architecture choices, technology selections, invariants, rejected alternatives.

- Location: `docs/decisions/NNN-short-title.md`, numbered sequentially.
- Format — three sections, a page or less:
  - **Context** — the situation and constraints at the time.
  - **Decision** — what was chosen, stated plainly.
  - **Consequences** — what this makes easier, what it makes harder, what would trigger revisiting.
- Records are append-only. A reversed decision gets a new record that supersedes the old one; the old one stays as history.
- Don't write ADRs for routine choices. If nobody would ever ask "why did we do it this way?", skip it.

Why this matters for AI-driven development: an AI session can read the code but not the reasoning. Without decision records, every session risks helpfully "fixing" a deliberate choice.

## CLAUDE.md Is Living Documentation

- Each project's CLAUDE.md carries: the stack, the key invariants, and project-specific overrides of these conventions. It is the first thing an AI session reads — keep it current.
- **A change that contradicts a documented rule must update that rule in the same commit.** Adding what you learned is the easy half and the one everyone remembers; the dangerous half is the sentence elsewhere that your change just made false. A stale rule is worse than a missing one — it is read as current, it is followed, and it gets the previous behaviour restored by someone who thinks they are fixing a regression. When a change reverses a decision, grep for the rule you are overturning and correct it where it lives, including the note that says *not* to do the thing you just did. Say plainly that it was reversed and by whom, so the next reader can tell a decision from an erosion.
- **A rationale is a cached claim about the thing it justifies, and it ages with no contradicting change at all.** The previous rule fires on a reversal; this one has no reversal to fire on — the justification stays literally true of the version it was written against while the thing it describes moves out from under it. A size-gate exemption keyed to a commit, naming the two sections that made the file large, went stale as the file grew past it by a tenth: the block now furthest over the goal is not mentioned in it, and nothing reddened, because the guard checks that a justification exists and never that it still describes the file. The same shape produced two comments characterising a flag by its old contract beside code that reasons from it, each sentence correct in isolation. Where a check accepts a written reason, it has to assert the reason against the current artifact — the count, the sections, the contract — or the exemption outlives the argument for it.
- **Durable facts only — never current state.** CLAUDE.md is a project-wide instruction set read at the start of every session, so everything in it is taken as permanently true. A broken test suite, an in-flight migration, a temporarily pinned version, "don't touch X until Y ships" — these are *status*. They go stale silently and mislead every later session. The test: if it stops being true without anyone editing CLAUDE.md, it doesn't belong in CLAUDE.md. Put it where it stays in context — session memory, an issue, or the working doc for that piece of work.
- When a convention, invariant, or deploy detail changes, updating CLAUDE.md is part of the change, not a follow-up.
- Keep it lean: link to detail (these files, ADRs) rather than inlining it. Inlined copies drift.
- Record dates as absolute (`2026-07-26`), never relative (`last week`) — documents outlive their writing.

## What Not to Document

- Anything the code already says — mirrors the comments rule in `coding-conventions.md`.
- Anything git history already records (who, when, in what order).
- Speculative future plans dressed as documentation. Document what is, and decisions actually made.
- **Current state in the README or CLAUDE.md** — what's broken, in progress, or temporarily true. Those two documents are the project's durable layer, so a status line in either is wrong the moment it changes and nobody remembers to delete it. The README says how to run the tests, never how they last did.

  **A passing-test count is the canonical violation** — "412 unit tests green" reads like a durable fact and is state, wrong the next time anyone adds a test, and it rots silently because no failure ever points at it. Name the capability instead ("every suite runs against the local stack") and let the command be the source of truth. The same applies to counts of files, endpoints, or supported cases.

  This is a constraint on those two files, not on documentation generally. State belongs in writing — a troubleshooting log, an investigation write-up, a migration checklist, a known-gaps register — it just belongs in a document whose *purpose* is that work, sitting next to the thing it describes. Give it an absolute date, and delete it when the work closes. A doc that exists to track state is doing its job; a durable doc that quietly accumulates state is not.
