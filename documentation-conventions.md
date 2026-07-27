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
- When a convention, invariant, or deploy detail changes, updating CLAUDE.md is part of the change, not a follow-up.
- Keep it lean: link to detail (these files, ADRs) rather than inlining it. Inlined copies drift.
- Record dates as absolute (`2026-07-26`), never relative (`last week`) — documents outlive their writing.

## What Not to Document

- Anything the code already says — mirrors the comments rule in `coding-conventions.md`.
- Anything git history already records (who, when, in what order).
- Speculative future plans dressed as documentation. Document what is, and decisions actually made.
