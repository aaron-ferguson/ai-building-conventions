---
id: "0015"
title: Check a project's .gitignore against git-conventions.md's Essentials list
type: feature
next: develop
status: ready
qa_level: unit
size: s
created: 2026-09-26
source: agent
parent:
blocked_by: []
relates: ["0004"]
expects:
  - scripts/check-gitignore-essentials.sh
  - scripts/check-gitignore-essentials.test.sh
  - git-conventions.md
claimed_by:
claimed_at:
touches:
---

## Problem

`git-conventions.md`'s *.gitignore Essentials* list (`node_modules/`, `dist/`, `build/`, `.env`,
`.env.*`, `coverage/`, `.DS_Store`, `*.log`) is stated as a minimum every project should have, but
nothing checks a project's actual `.gitignore` against it. Noticed while scoping item 0004
(`.claude/backlog/FINDINGS.md`, 2026-09-14) and parked rather than built there — judged lower
value than 0014's destructive-commands gap because a missing `.gitignore` entry is
self-correcting the first time it causes a problem (an unwanted file shows up in `git status` and
gets added on the spot), whereas a destructive command has already done its damage by the time
anyone notices.

## Functional requirements

- FR1 — A script reads a project's `.gitignore` (path argument, default `.` ) and reports any
  entry from the Essentials list that is not covered — matching the literal pattern or a pattern
  that would already ignore it (e.g. `*.log` covers `debug.log`; `node_modules` with no trailing
  slash still covers `node_modules/`), not just an exact string match.
- FR2 — The script exits non-zero when anything is missing, listing each missing entry and citing
  `git-conventions.md`.
- FR3 — The script exits 0 with an all-clear message when every essential is covered.
- FR4 — A project with no `.gitignore` at all is reported as missing every essential, not
  skipped — an absent file is a stronger failure than an incomplete one.
- FR5 — The script has a sibling `.test.sh` per this repo's established pattern.

## Non-functional requirements

| Dimension | Requirement for this item | How it would red | Convention |
|---|---|---|---|
| Documentation | `git-conventions.md`'s Essentials section names this script, per 0004's FR6 precedent | the section names no script after this ticket closes | `documentation-conventions.md` |

## Acceptance criteria

- [ ] AC1 — Given a `.gitignore` missing `.env`, when the script runs, then it exits non-zero and
      names `.env` as missing.
- [ ] AC2 — Given a `.gitignore` covering every essential (via exact or wildcard patterns), when
      the script runs, then it exits 0.
- [ ] AC3 — Given no `.gitignore` file, when the script runs, then it reports every essential as
      missing rather than erroring or skipping silently.
- [ ] AC4 — Given the script's `.test.sh`, when the `unit` command runs, then all cases pass.

## QA plan

- **Level:** unit — matches this repo's `scripts/*.test.sh` pattern.
- **Why this level:** a pure read-and-match function over a text file.
- **Specific checks:** `config.yml`'s `unit` command; run once against this repo's own
  (nonexistent, per `CLAUDE.md`'s Environments block — "no build, no runtime") `.gitignore` case to
  confirm FR4 doesn't false-positive on a repo that genuinely has nothing to ignore yet.

## Out of scope

- Wiring this as a `SessionStart` hook that runs automatically on every session. This ticket
  ships the checkable script; whether and how it runs automatically is a separate decision, since
  a `SessionStart` hook that scans every project on every session start has a cost profile this
  ticket hasn't evaluated.

## Notes & decisions

- 2026-09-26 — Filed by `retro`, draining `.claude/backlog/FINDINGS.md` (2026-09-14). Ranked below
  0014 in `QUEUE.md`, matching the lower-value judgement the original finding already made.
