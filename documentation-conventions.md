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

## Tactical Records Live Outside the Conventions

A durable principle and a record of one event are different kinds of document, and mixing them makes both harder to use. Postmortems, incident timelines, and status notes are **tactical artifacts** — they never go in the conventions directory. Where they *do* go is declared per project: the company profile names the system for company work, and a solo project defaults to `docs/incidents/` in its own repo with one dated file per event. See `incident-conventions.md` for the rule and its one exception (records holding personal or exploitable detail don't go in a shareable repo).

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
- **Durable facts only — never current state.** CLAUDE.md is a project-wide instruction set read at the start of every session, so everything in it is taken as permanently true. A broken test suite, an in-flight migration, a temporarily pinned version, "don't touch X until Y ships" — these are *status*. They go stale silently and mislead every later session. The test: if it stops being true without anyone editing CLAUDE.md, it doesn't belong in CLAUDE.md. Put it where it stays in context — session memory, an issue, or the working doc for that piece of work.
- When a convention, invariant, or deploy detail changes, updating CLAUDE.md is part of the change, not a follow-up.
- Keep it lean: link to detail (these files, ADRs) rather than inlining it. Inlined copies drift.
- Record dates as absolute (`2026-07-26`), never relative (`last week`) — documents outlive their writing.

## What Not to Document

- Anything the code already says — mirrors the comments rule in `coding-conventions.md`.
- Anything git history already records (who, when, in what order).
- Speculative future plans dressed as documentation. Document what is, and decisions actually made.
- **Current state in the README or CLAUDE.md** — what's broken, in progress, or temporarily true. Those two documents are the project's durable layer, so a status line in either is wrong the moment it changes and nobody remembers to delete it. The README says how to run the tests, never how they last did.

  This is a constraint on those two files, not on documentation generally. State belongs in writing — a troubleshooting log, an investigation write-up, a migration checklist, a known-gaps register — it just belongs in a document whose *purpose* is that work, sitting next to the thing it describes. Give it an absolute date, and delete it when the work closes. A doc that exists to track state is doing its job; a durable doc that quietly accumulates state is not.
